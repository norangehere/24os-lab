#include "sbi.h"

#include "stdint.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid, uint64_t arg0,
                        uint64_t arg1, uint64_t arg2, uint64_t arg3,
                        uint64_t arg4, uint64_t arg5) {
  struct sbiret ret;

  __asm__ volatile(
      "mv a7, %2\n"
      "mv a6, %3\n"
      "mv a0, %4\n"
      "mv a1, %5\n"
      "mv a2, %6\n"
      "mv a3, %7\n"
      "mv a4, %8\n"
      "mv a5, %9\n"
      "ecall\n"
      "mv %0, a0\n"
      "mv %1, a1\n"
      : "=r"(ret.error), "=r"(ret.value)
      : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3),
        "r"(arg4), "r"(arg5)
      : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7");

  return ret;
}

struct sbiret sbi_set_timer(uint64_t stime_value) {
  struct sbiret ret;

  sbi_ecall(0x54494d45, 0, stime_value, 0, 0, 0, 0, 0);

  return ret;
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
  struct sbiret ret;

  sbi_ecall(0x4442434e, 2, byte, 0, 0, 0, 0, 0);

  return ret;
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
  struct sbiret ret;

  sbi_ecall(0x53525354, 0, reset_type, reset_reason, 0, 0, 0, 0);

  return ret;
}