#include "syscall.h"

#include "printk.h"

extern struct task_struct *current;

void sys_call(struct pt_regs *regs) {
  //   printk("syscall %d\n", regs->s[17]);
  if (regs->s[17] == SYS_WRITE)
    sys_write(regs);
  else if (regs->s[17] == SYS_GETPID)
    sys_getpid(regs);
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