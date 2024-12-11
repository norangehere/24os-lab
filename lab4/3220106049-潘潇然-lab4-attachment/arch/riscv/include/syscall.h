#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#include "printk.h"
#include "proc.h"
#include "stdint.h"

#define SYS_WRITE 64
#define SYS_GETPID 172

void sys_call(struct pt_regs *regs);

void sys_write(struct pt_regs *regs);

void sys_getpid(struct pt_regs *regs);

#endif