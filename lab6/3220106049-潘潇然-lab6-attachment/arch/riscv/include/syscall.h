#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#include "printk.h"
#include "proc.h"
#include "stdint.h"

#define SYS_OPENAT 56
#define SYS_CLOSE 57
#define SYS_LSEEK 62
#define SYS_READ 63
#define SYS_WRITE 64
#define SYS_GETPID 172
#define SYS_CLONE 220
#define FILE_READABLE 0x1
#define FILE_WRITABLE 0x2

void sys_call(struct pt_regs *regs);

uint64_t sys_write(struct pt_regs *regs);

void sys_getpid(struct pt_regs *regs);

uint64_t sys_read(struct pt_regs *regs);

uint64_t do_fork(struct pt_regs *regs);

uint64_t do_cow_fork(struct pt_regs *regs);

#endif