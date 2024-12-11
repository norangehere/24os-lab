#include "proc.h"

#include "defs.h"
#include "elf.h"
#include "mm.h"
#include "printk.h"
#include "stdlib.h"
#include "string.h"
#include "vm.h"

extern void __dummy();
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

struct task_struct *idle;            // idle process
struct task_struct *current;         // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS];  // 线程数组，所有的线程都保存在此

extern char _sramdisk[];
extern char _eramdisk[];
extern uint64_t swapper_pg_dir[];

uint64_t nr_tasks = 2;

void *memcpy(void *dst, const void *src, size_t n) {
  char *str1 = (char *)dst;
  char *str2 = (char *)src;
  for (uint64_t i = 0; i < n; ++i) *(str1++) = *(str2++);
  return dst;
}

void load_program(struct task_struct *task) {
  Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
  Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
  for (int i = 0; i < ehdr->e_phnum; ++i) {
    Elf64_Phdr *phdr = phdrs + i;
    if (phdr->p_type == PT_LOAD) {
      uint64_t start_pg = phdr->p_vaddr;
      uint64_t pg_offset = phdr->p_vaddr & 0xfff;
      uint64_t size = phdr->p_memsz + pg_offset;
      uint64_t perm = ((phdr->p_flags & PF_X) << 3) |
                      ((phdr->p_flags & PF_W) << 1) |
                      ((phdr->p_flags & PF_R) >> 1);
      do_mmap(&task->mm, start_pg, phdr->p_memsz, phdr->p_offset,
              phdr->p_filesz, perm);
      // delete in lab5 for using demand paging
      //   void *page = alloc_pages((size + PGSIZE - 1) / PGSIZE);
      //   if (!page) {
      //     printk("alloc_pages failed\n");
      //     return;
      //   }
      //   memcpy((void *)(page + pg_offset), (void *)(_sramdisk +
      //   phdr->p_offset),
      //          phdr->p_filesz);
      //   memset(page + pg_offset + phdr->p_filesz, 0,
      //          phdr->p_memsz - phdr->p_filesz);
      //   create_mapping(task->pgd, start_pg, (uint64_t)page - PA2VA_OFFSET,
      //   size,perm);
      // end delete
    }
  }
  task->thread.sepc = (uint64_t)ehdr->e_entry;
}

void task_init() {
  srand(2024);
  void *idle_page = kalloc();
  if (!idle_page) {
    printk("kalloc failed\n");
    return;
  }
  idle = (struct task_struct *)idle_page;
  idle->state = TASK_RUNNING;
  idle->counter = 0;
  idle->priority = 0;
  idle->pid = 0;
  current = idle;
  task[0] = idle;

  for (int i = 1; i < nr_tasks; ++i) {
    void *task_page = kalloc();
    if (!task_page) {
      printk("kalloc failed\n");
      return;
    }
    task[i] = (struct task_struct *)task_page;
    task[i]->pid = i;
    task[i]->state = TASK_RUNNING;
    task[i]->counter = 0;
    task[i]->priority =
        PRIORITY_MIN + rand() % (PRIORITY_MAX - PRIORITY_MIN + 1);
    task[i]->thread.ra = (uint64_t)__dummy;
    task[i]->thread.sp = (uint64_t)((unsigned long)task_page + PGSIZE);
    uint64_t sstatus = 0;
    sstatus &= ~(1 << 8);
    task[i]->thread.sstatus = sstatus | (1 << 5) | (1 << 18);
    task[i]->thread.sscratch = USER_END;
    task[i]->pgd = (uint64_t *)kalloc();
    if (!task[i]->pgd) {
      printk("kalloc failed\n");
      return;
    }
    memcpy((void *)task[i]->pgd, (void *)swapper_pg_dir, PGSIZE);
    // 将uapp所在的页面映射到每个进程的页表中
    load_program(task[i]);
    do_mmap(&task[i]->mm, USER_END - PGSIZE, PGSIZE, 0, PGSIZE,
            VM_READ | VM_WRITE | VM_ANON);

    // delete in lab4 for changing to load elf program
    //   task[i]->thread.sepc = (uint64_t)USER_START;
    //   void *uapp = alloc_pages(
    //       ((uint64_t)_eramdisk - (uint64_t)_sramdisk + PGSIZE - 1) / PGSIZE);
    //   memcpy(uapp, _sramdisk, (uint64_t)_eramdisk - (uint64_t)_sramdisk);
    //   create_mapping(task[i]->pgd, USER_START, (uint64_t)uapp - PA2VA_OFFSET,
    //                  (uint64_t)(_eramdisk - _sramdisk), 0x1f);
    // end delete

    // delete in lab5 for demand paging
    // 用户态栈
    // void *user_stack_page = kalloc();
    // if (!user_stack_page) {
    //   printk("kalloc failed\n");
    //   return;
    // }
    // create_mapping(task[i]->pgd, USER_END - PGSIZE,
    //                (uint64_t)user_stack_page - PA2VA_OFFSET, PGSIZE, 0x17);
    // end delete
  }

  printk("...task_init done!\n");
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
  struct vm_area_struct *vma = mm->mmap;
  while (vma != NULL) {
    if (addr >= vma->vm_start && addr < vma->vm_end) {
      return vma;
    }
    vma = vma->vm_next;
  }
  return NULL;
}

uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len,
                 uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
  struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
  new_vma->vm_start = addr;
  new_vma->vm_end = addr + len;
  new_vma->vm_flags = flags;
  new_vma->vm_pgoff = vm_pgoff;
  new_vma->vm_filesz = vm_filesz;
  new_vma->vm_next = NULL;
  new_vma->vm_prev = NULL;
  new_vma->vm_mm = mm;
  struct vm_area_struct *vma;
  for (vma = mm->mmap; vma && vma->vm_next; vma = vma->vm_next);
  if (vma) {
    vma->vm_next = new_vma;
    new_vma->vm_prev = vma;
  } else {
    mm->mmap = new_vma;
  }

  return addr;
}

void dummy() {
  uint64_t MOD = 1000000007;
  uint64_t auto_inc_local_var = 0;
  int last_counter = -1;
  while (1) {
    if ((last_counter == -1 || current->counter != last_counter) &&
        current->counter > 0) {
      if (current->counter == 1) {
        --(current->counter);  // forced the counter to be zero if this thread
                               // is going to be scheduled
      }  // in case that the new counter is also 1, leading the information
         // not printed.
      last_counter = current->counter;
      auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
      printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid,
             auto_inc_local_var);
#if TEST_SCHED
      tasks_output[tasks_output_index++] = current->pid + '0';
      if (tasks_output_index == MAX_OUTPUT) {
        for (int i = 0; i < MAX_OUTPUT; ++i) {
          if (tasks_output[i] != expected_output[i]) {
            printk("\033[31mTest failed!\033[0m\n");
            printk("\033[31m    Expected: %s\033[0m\n", expected_output);
            printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
            sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN,
                             SBI_SRST_RESET_REASON_NONE);
          }
        }
        printk("\033[32mTest passed!\033[0m\n");
        printk("\033[32m    Output: %s\033[0m\n", expected_output);
        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN,
                         SBI_SRST_RESET_REASON_NONE);
      }
#endif
    }
  }
}

void schedule() {
  struct task_struct *next = NULL;
  uint64_t max_counter = 0;

  for (int i = 0; i < nr_tasks; i++) {
    if (task[i]->counter > max_counter) {
      max_counter = task[i]->counter;
      next = task[i];
    }
  }

  if (!max_counter) {
    for (int i = 1; i < nr_tasks; i++) {
      if (task[i]) task[i]->counter = task[i]->priority;
      printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid,
             task[i]->priority, task[i]->counter);
    }
    for (int i = 1; i < nr_tasks; i++)
      if (task[i]->counter > max_counter) {
        max_counter = task[i]->counter;
        next = task[i];
      }
  }

  if (next) {
    // next->counter--;
    switch_to(next);
  }
}

void do_timer() {
  // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
  // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0
  // 则直接返回，否则进行调度

  if (current == idle || current->counter == 0)
    schedule();
  else if (current->counter > 0) {
    current->counter--;
    return;
  }
}

void switch_to(struct task_struct *next) {
  if (current == next) return;
  printk("\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n", next->pid,
         next->priority, next->counter);
  struct task_struct *prev = current;
  current = next;
  __switch_to(prev, next);
}
