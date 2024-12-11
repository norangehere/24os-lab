#include "clock.h"
#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
#include "syscall.h"

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
  //   printk("[S] Supervisor Mode Trap: scause: %lx, sepc: %lx\n", scause,
  //   sepc);
  if (scause & 0x8000000000000000)       // if interrupt
    if (scause == 0x8000000000000005) {  // if timer interrupt
      //   printk("[S] Supervisor Mode Timer Interrupt\n");
      clock_set_next_event();
      do_timer();
    } else {
      printk("[S] Supervisor Mode Other Interrupt (scause: %lx, sepc: %lx).\n",
             scause, sepc);
      while (1);
    }
  else {
    if (scause == 0x8) {
      //   printk("[S] Supervisor Mode Environment Call from U-mode.\n");
      sys_call(regs);
      regs->sepc += 4;
    } else {
      printk("[S] Supervisor Mode Exception (scause: %lx, sepc: %lx).\n",
             scause, sepc);
      while (1);
    }
  }
  return;
}