#include "printk.h"
#include "stdint.h"

extern void test();

extern char _stext[];
extern char _srodata[];

int start_kernel() {
  printk("2024");
  printk(" ZJU Operating System\n");
  //   printk("The value of _stext is: %lx\n", (uint64_t)(*_stext));
  //   printk("The value of _srodata is: %lx\n", (uint64_t)(*_srodata));
  //   *_stext = 0x0;
  //   *_srodata = 0x1;
  //   asm volatile("call _srodata");

  test();
  return 0;
}
