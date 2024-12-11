#include "clock.h"
#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
  // 通过 `scause` 判断 trap 类型
  // 如果是 interrupt 判断是否是 timer interrupt
  // 如果是 timer interrupt 则打印输出相关信息，并通过
  // `clock_set_next_event()`设置下一次时钟中断
  //  `clock_set_next_event()` 见 4.3.4 节
  // 其他 interrupt /exception 可以直接忽略，推荐打印出来供以后调试
  uint64_t flag = 0x8000000000000000;  // 第一位是1
  uint64_t exception_code = 0x5;       // exception code for timer interrupt
  //   printk("[S] Supervisor Mode Trap: scause: %lx, sepc: %lx\n", scause,
  //   sepc);
  if (scause & 0x8000000000000000)       // if interrupt
    if (scause == 0x8000000000000005) {  // if timer interrupt
      printk("[S] Supervisor Mode Timer Interrupt\n");
      clock_set_next_event();
      do_timer();
    } else
      printk("[S] Supervisor Mode Other Interrupt (scause: %lx, sepc: %lx).\n",
             scause, sepc);
  else {
    printk("[S] Supervisor Mode Exception (scause: %lx, sepc: %lx).\n", scause,
           sepc);
  }
}