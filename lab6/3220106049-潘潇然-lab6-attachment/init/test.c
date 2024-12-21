#include "printk.h"

// #define csr_read(csr)                                 \
//   ({                                                  \
//     unsigned long __tmp;                              \
//     __asm__ volatile("csrr %0, " #csr : "=r"(__tmp)); \
//     __tmp;                                            \
//   })

// #define csr_write(csr, value) \
//   __asm__ volatile("csrw " #csr ", %0" : : "r"(value))

void test() {
  int i = 0;
  //   unsigned long write_value = 0x20106049;
  //   csr_write(sscratch, write_value);
  //   unsigned long read_value = csr_read(sscratch);
  //   printk("write value: %lx\n", write_value);
  //   printk("sscratch value: %lx\n", read_value);
  while (1) {
    if ((++i) % 100000000 == 0) {
      //   printk("kernel is running!\n");
      i = 0;
    }
  }
}