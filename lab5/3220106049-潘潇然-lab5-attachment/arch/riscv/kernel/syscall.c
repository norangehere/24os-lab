#include "syscall.h"

#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "vm.h"

extern struct task_struct *current;
extern struct task_struct *task[];
extern uint64_t nr_tasks;
extern void __ret_from_fork();
extern uint64_t swapper_pg_dir[];

void sys_call(struct pt_regs *regs) {
  //   printk("syscall %d\n", regs->s[17]);
  if (regs->s[17] == SYS_WRITE)
    sys_write(regs);
  else if (regs->s[17] == SYS_GETPID)
    sys_getpid(regs);
  else if (regs->s[17] == SYS_CLONE) {
    // do_fork(regs);
    do_cow_fork(regs);
  }
}

void sys_write(struct pt_regs *regs) {
  if (regs->s[10] == (uint64_t)1) {
    char *buf = (char *)regs->s[11];
    uint64_t count = regs->s[12];
    for (uint64_t i = 0; i < count; i++) printk("%c", buf[i]);
    regs->s[10] = count;
  } else
    printk("fd value error,fd = %d\n", regs->s[10]);
}

void sys_getpid(struct pt_regs *regs) {
  //   printk("pid = %d\n", current->pid);
  regs->s[10] = current->pid;
}

uint64_t do_cow_fork(struct pt_regs *regs) {
  // 创建新进程，拷贝内核栈
  struct task_struct *new_task = (struct task_struct *)kalloc();
  if (!new_task) {
    Err("kalloc new task failed");
  }
  memcpy((void *)new_task, (void *)current, PGSIZE);
  new_task->pid = nr_tasks;
  task[nr_tasks++] = new_task;
  new_task->state = TASK_RUNNING;
  new_task->thread.ra = (uint64_t)&__ret_from_fork;
  new_task->mm.mmap = NULL;
  new_task->thread.sscratch = csr_read(sscratch);
  struct pt_regs *child_regs =
      (struct pt_regs *)((uint64_t)new_task + (uint64_t)regs -
                         PGROUNDDOWN((uint64_t)regs));
  new_task->thread.sp = (uint64_t)child_regs;
  child_regs->s[10] = 0;
  child_regs->sepc += 4;
  child_regs->s[2] = new_task->thread.sp;

  // 创建子进程页表
  new_task->pgd = (uint64_t *)kalloc();
  if (!new_task->pgd) {
    Err("kalloc child pgd failed");
  }
  memcpy((void *)new_task->pgd, (void *)swapper_pg_dir, PGSIZE);
  struct vm_area_struct *vma = current->mm.mmap;
  while (vma) {
    struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
    if (!new_vma) {
      Err("kalloc new vma failed");
    }
    memcpy((void *)new_vma, (void *)vma, sizeof(struct vm_area_struct));
    new_vma->vm_prev = NULL;
    new_vma->vm_next = NULL;
    // 插入到子进程的 VMA 链表中
    if (new_task->mm.mmap == NULL) {
      new_task->mm.mmap = new_vma;
    } else {
      struct vm_area_struct *now = new_task->mm.mmap;
      while (now->vm_next) {
        now = now->vm_next;
      }
      now->vm_next = new_vma;
      new_vma->vm_prev = now;
    }
    // walk VMA 对应的每一页
    uint64_t addr = PGROUNDDOWN(vma->vm_start);
    while (addr < vma->vm_end) {
      uint64_t vpn2 = (addr >> 30) & 0x1ff;
      uint64_t vpn1 = (addr >> 21) & 0x1ff;
      uint64_t vpn0 = (addr >> 12) & 0x1ff;
      uint64_t *pte2 = &current->pgd[vpn2];
      if (!(*pte2 & PTE_V)) {
        addr += PGSIZE;
        continue;
      }
      uint64_t *pgtbl_lvl1;
      pgtbl_lvl1 = (uint64_t *)(((*pte2 >> 10) << 12) + PA2VA_OFFSET);
      uint64_t *pte1 = &pgtbl_lvl1[vpn1];
      if (!(*pte1 & PTE_V)) {
        addr += PGSIZE;
        continue;
      }
      uint64_t *pgtbl_lvl0;
      pgtbl_lvl0 = (uint64_t *)(((*pte1 >> 10) << 12) + PA2VA_OFFSET);
      uint64_t *pte = &pgtbl_lvl0[vpn0];
      if (*pte & PTE_V) {
        uint64_t pa = (*pte >> 10) << 12;
        get_page((void *)(pa + PA2VA_OFFSET));
        *pte &= ~PTE_W;
        uint64_t perm = ((*pte) & 0xff) & (~PTE_W);
        create_mapping(new_task->pgd, addr, pa, PGSIZE, perm);
        Log(GREEN "Copy on write at [0x%lx]" CLEAR, addr);
      }
      addr += PGSIZE;
    }
    vma = vma->vm_next;
  }
  asm volatile("sfence.vma zero, zero");
  Log(YELLOW "[PID = %d] forked from [PID = %d]\n" CLEAR, new_task->pid,
      current->pid);
  return new_task->pid;
}

uint64_t do_fork(struct pt_regs *regs) {
  // 创建新进程，拷贝内核栈
  struct task_struct *new_task = (struct task_struct *)kalloc();
  if (!new_task) {
    Err("kalloc new task failed");
  }
  memcpy((void *)new_task, (void *)current, PGSIZE);
  new_task->pid = nr_tasks;
  task[nr_tasks++] = new_task;
  new_task->state = TASK_RUNNING;
  new_task->thread.ra = (uint64_t)&__ret_from_fork;
  new_task->mm.mmap = NULL;
  new_task->thread.sscratch = csr_read(sscratch);
  struct pt_regs *child_regs =
      (struct pt_regs *)((uint64_t)new_task + (uint64_t)regs -
                         PGROUNDDOWN((uint64_t)regs));
  new_task->thread.sp = (uint64_t)child_regs;
  child_regs->s[10] = 0;
  child_regs->sepc += 4;
  child_regs->s[2] = new_task->thread.sp;

  // 创建子进程页表
  new_task->pgd = (uint64_t *)kalloc();
  if (!new_task->pgd) {
    Err("kalloc child pgd failed");
  }
  memcpy((void *)new_task->pgd, (void *)swapper_pg_dir, PGSIZE);
  struct vm_area_struct *vma = current->mm.mmap;
  while (vma) {
    struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
    if (!new_vma) {
      Err("kalloc new vma failed");
    }
    memcpy((void *)new_vma, (void *)vma, sizeof(struct vm_area_struct));
    new_vma->vm_prev = NULL;
    new_vma->vm_next = NULL;
    // 插入到子进程的 VMA 链表中
    if (new_task->mm.mmap == NULL) {
      new_task->mm.mmap = new_vma;
    } else {
      struct vm_area_struct *now = new_task->mm.mmap;
      while (now->vm_next) {
        now = now->vm_next;
      }
      now->vm_next = new_vma;
      new_vma->vm_prev = now;
    }
    // walk VMA 对应的每一页
    uint64_t addr = PGROUNDDOWN(vma->vm_start);
    while (addr < vma->vm_end) {
      uint64_t vpn2 = (addr >> 30) & 0x1ff;
      uint64_t vpn1 = (addr >> 21) & 0x1ff;
      uint64_t vpn0 = (addr >> 12) & 0x1ff;
      uint64_t *pte2 = &current->pgd[vpn2];
      if (!(*pte2 & PTE_V)) {
        addr += PGSIZE;
        continue;
      }
      uint64_t *pgtbl_lvl1;
      pgtbl_lvl1 = (uint64_t *)(((*pte2 >> 10) << 12) + PA2VA_OFFSET);
      uint64_t *pte1 = &pgtbl_lvl1[vpn1];
      if (!(*pte1 & PTE_V)) {
        addr += PGSIZE;
        continue;
      }
      uint64_t *pgtbl_lvl0;
      pgtbl_lvl0 = (uint64_t *)(((*pte1 >> 10) << 12) + PA2VA_OFFSET);
      uint64_t *pte = &pgtbl_lvl0[vpn0];
      if (*pte & PTE_V) {
        void *page = kalloc();
        if (!page) {
          Err("kalloc page failed");
        }
        memcpy(page, (void *)addr, PGSIZE);
        uint64_t perm = 0x11 | ((*pte) & 0xff);
        create_mapping(new_task->pgd, addr, (uint64_t)page - PA2VA_OFFSET,
                       PGSIZE, perm);
      }
      addr += PGSIZE;
    }
    vma = vma->vm_next;
  }
  asm volatile("sfence.vma zero, zero");
  Log(YELLOW "[PID = %d] forked from [PID = %d]\n" CLEAR, new_task->pid,
      current->pid);
  return new_task->pid;
}
