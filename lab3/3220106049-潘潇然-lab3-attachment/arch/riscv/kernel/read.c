#include <printk.h>

#define csr_read(csr)                             \
  ({                                              \
    unsigned long __tmp;                          \
    asm volatile("csrr %0, " #csr : "=r"(__tmp)); \
    __tmp;                                        \
  })

int main() {
  unsigned long sstatus_value = csr_read(sstatus);
  printk("sstatus value: %lx\n", sstatus_value);
  return 0;
}
