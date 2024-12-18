#include "clock.h"
#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
#include "string.h"
#include "syscall.h"
#include "vm.h"

extern char _sramdisk[];
void do_page_fault(struct pt_regs *regs, uint64_t scause);

extern struct task_struct *current;

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
  //   printk("[S] Supervisor Mode Trap: scause: %lx, sepc: %lx\n", scause,
  //   sepc);
  if (scause & 0x8000000000000000)       // if interrupt
    if (scause == 0x8000000000000005) {  // if timer interrupt
      //   printk("[S] Supervisor Mode Timer Interrupt\n");
      clock_set_next_event();
      do_timer();
    } else {
      Log("[S] Unhandled Supervisor Mode Interrupt (scause: %lx, sepc: %lx).\n",
          scause, sepc);
      while (1);
    }
  else {
    if (scause == 0x8) {
      //   printk("[S] Supervisor Mode Environment Call from U-mode.\n");
      sys_call(regs);
      regs->sepc += 4;
    } else if (scause == 0xc || scause == 0xd || scause == 0xf) {
      Log("[PID = %d PC = %lx] Valid page fault at [0x%lx] with cause %d",
          current->pid, regs->sepc, regs->stval, scause);
      do_page_fault(regs, scause);
    } else {
      Log("[S] Unhandled Supervisor Mode Exception (scause: %lx, sepc: %lx).",
          scause, sepc);
      while (1);
    }
  }
  return;
}

void do_page_fault(struct pt_regs *regs, uint64_t scause) {
  uint64_t bad_address = regs->stval;
  struct vm_area_struct *vma = find_vma(&current->mm, bad_address);
  Log(GREEN "find vma area: [%lx, %lx), flags: %lx" CLEAR, vma->vm_start,
      vma->vm_end, vma->vm_flags);
  if (!vma)
    Err("Fail to find vma when doing page fault at [0x%lx]\n", bad_address);
  if ((vma->vm_flags & VM_EXEC == 0) && scause == 0xc ||
      (vma->vm_flags & VM_READ == 0) && scause == 0xd ||
      (vma->vm_flags & VM_WRITE == 0) && scause == 0xf)
    Err("Catch wrong page fault at [0x%lx] with no permission, cause %lx\n",
        bad_address, scause);

  // COW
  if ((vma->vm_flags & VM_WRITE == 0x4) && scause == 0xf) {
    Log(GREEN "may be cow" CLEAR);
    // get pte
    uint64_t vpn2 = (bad_address >> 30) & 0x1ff;
    uint64_t vpn1 = (bad_address >> 21) & 0x1ff;
    uint64_t vpn0 = (bad_address >> 12) & 0x1ff;
    uint64_t *pte2 = &current->pgd[vpn2];
    if (*pte2 & PTE_V) {
      uint64_t *pgtbl_lvl1;
      pgtbl_lvl1 = (uint64_t *)(((*pte2 >> 10) << 12) + PA2VA_OFFSET);
      uint64_t *pte1 = &pgtbl_lvl1[vpn1];
      if (*pte1 & PTE_V) {
        uint64_t *pgtbl_lvl0;
        pgtbl_lvl0 = (uint64_t *)(((*pte1 >> 10) << 12) + PA2VA_OFFSET);
        uint64_t *pte = &pgtbl_lvl0[vpn0];
        if ((*pte & PTE_V) && (*pte & ~PTE_W)) {  // 确认是COW
          Log(GREEN "Copy on write at [0x%lx]\n" CLEAR, bad_address);
          uint64_t pa = ((*pte >> 10) << 12);
          uint64_t refcnt = get_page_refcnt((void *)(pa + PA2VA_OFFSET));
          Log(GREEN "Copy on write at [0x%lx] with refcnt: %d\n" CLEAR,
              bad_address, refcnt);
          if (refcnt > 1) {
            put_page((void *)(pa + PA2VA_OFFSET));
            void *new_page = kalloc();
            memcpy(new_page, (void *)PGROUNDDOWN(bad_address), PGSIZE);
            uint64_t new_pa = ((uint64_t)new_page - PA2VA_OFFSET);
            create_mapping(current->pgd, bad_address, new_pa, PGSIZE,
                           ((*pte) & 0xff) | PTE_W);
          } else {
            // 引用计数为 1，直接设置可写权限
            *pte |= PTE_W;
          }
          asm volatile("sfence.vma zero, zero");
          return;
        }
      }
    }
  }
  uint64_t page = (uint64_t)alloc_page();
  memset((void *)page, 0, PAGE_SIZE);
  if (!(vma->vm_flags & VM_ANON)) {
    uint64_t begin_offset = vma->vm_start & 0xfff;
    uint64_t end_remain = PGSIZE - (vma->vm_start + vma->vm_filesz) & 0xfff;
    uint64_t first_flag = 0, last_flag = 0;
    if (PGROUNDDOWN(bad_address) == PGROUNDDOWN(vma->vm_start)) first_flag = 1;
    if (PGROUNDDOWN(bad_address) ==
        PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1))
      last_flag = 1;
    if (first_flag && last_flag)
      memcpy((void *)(page + begin_offset),
             (void *)((uint64_t)_sramdisk + vma->vm_pgoff),
             PGSIZE - begin_offset - end_remain);
    else if (first_flag)
      memcpy((void *)page + begin_offset,
             (void *)((uint64_t)_sramdisk + vma->vm_pgoff),
             PGSIZE - begin_offset);
    else if (last_flag)
      memcpy((void *)page,
             (void *)((uint64_t)_sramdisk + vma->vm_pgoff +
                      PGROUNDDOWN(bad_address) - vma->vm_start),
             PGSIZE - end_remain);
    else
      memcpy((void *)page,
             (void *)((uint64_t)_sramdisk + vma->vm_pgoff +
                      PGROUNDDOWN(bad_address) - vma->vm_start),
             PGSIZE);
  }
  uint64_t perm = 0x11 | (vma->vm_flags & VM_EXEC) |
                  (vma->vm_flags & VM_WRITE) | (vma->vm_flags & VM_READ);
  create_mapping(current->pgd, PGROUNDDOWN(bad_address), page - PA2VA_OFFSET,
                 PGSIZE, perm);
}