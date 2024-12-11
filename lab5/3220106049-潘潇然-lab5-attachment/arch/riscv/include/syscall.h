#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#include "printk.h"
#include "proc.h"
#include "stdint.h"

#define SYS_WRITE 64
#define SYS_GETPID 172
#define SYS_CLONE 220

void sys_call(struct pt_regs *regs);

void sys_write(struct pt_regs *regs);

void sys_getpid(struct pt_regs *regs);

uint64_t do_fork(struct pt_regs *regs);

uint64_t do_cow_fork(struct pt_regs *regs);

#endif