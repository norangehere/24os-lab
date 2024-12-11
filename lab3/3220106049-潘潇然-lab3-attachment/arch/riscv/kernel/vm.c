#include "defs.h"
#include "mm.h"
#include "stdint.h"
#include "string.h"

void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz,
                    uint64_t perm);

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
  /*
   * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表
   * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
   *     high bit 可以忽略
   *     中间 9 bit 作为 early_pgtbl 的 index
   *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 +
   *12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
   * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
   **/
  memset(early_pgtbl, 0x0, PGSIZE);
  uint64_t index;
  // 设置 PA == VA 的 1 GiB 等值映射
  // [53:28] = [55:30]
  index = ((uint64_t)(PHY_START) >> 30) & 0x1ff;  // 取[38:30]
  early_pgtbl[index] = (((PHY_START >> 30) & 0x3ffffff) << 28) | 0xf;

  // 设置 PA + PA2VA_OFFSET == VA 的 1 GiB 映射
  index = ((uint64_t)(VM_START) >> 30) & 0x1ff;
  early_pgtbl[index] = (((PHY_START >> 30) & 0x3ffffff) << 28) | 0xf;
  printk("..setup_vm done!\n");
}

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[];
extern char _srodata[];
extern char _sdata[];

void setup_vm_final() {
  memset(swapper_pg_dir, 0x0, PGSIZE);

  // No OpenSBI mapping required
  // mapping kernel text X|-|R|V
  uint64_t va = _stext;
  uint64_t pa = (uint64_t)_stext - PA2VA_OFFSET;
  create_mapping((uint64_t *)swapper_pg_dir, va, pa,
                 (uint64_t)(_srodata - _stext), 11);

  // mapping kernel rodata -|-|R|V
  va += _srodata - _stext;
  pa += _srodata - _stext;
  create_mapping((uint64_t *)swapper_pg_dir, va, pa,
                 (uint64_t)(_sdata - _srodata), 3);

  // mapping other memory -|W|R|V
  va += _sdata - _srodata;
  pa += _sdata - _srodata;
  create_mapping((uint64_t *)swapper_pg_dir, va, pa,
                 PHY_SIZE - (uint64_t)(_sdata - _stext), 7);

  // set satp with swapper_pg_dir
  uint64_t now_satp =
      (((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | ((uint64_t)0x8 << 60);
  csr_write(satp, now_satp);
  // flush TLB
  asm volatile("sfence.vma zero, zero");
  printk("..setup_vm_final done\n");
  return;
}

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz,
                    uint64_t perm) {
  /*
   * pgtbl 为根页表的基地址
   * va, pa 为需要映射的虚拟地址、物理地址
   * sz 为映射的大小，单位为字节
   * perm 为映射的权限（即页表项的低 8 位）
   *
   * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
   * 可以使用 V bit 来判断页表项是否存在
   **/
  uint64_t va_end = va + sz;
  uint64_t vpn2, vpn1, vpn0;
  while (va < va_end) {
    vpn2 = (va >> 30) & 0x1FF;
    vpn1 = (va >> 21) & 0x1FF;
    vpn0 = (va >> 12) & 0x1FF;

    // 处理第一级页表
    uint64_t *pte2 = &pgtbl[vpn2];
    uint64_t *pgtbl_lvl1;
    if (!(*pte2 & PTE_V)) {
      pgtbl_lvl1 = (uint64_t *)(kalloc() - PA2VA_OFFSET);
      *pte2 = ((uint64_t)pgtbl_lvl1 >> 12 << 10) | PTE_V;
    }
    pgtbl_lvl1 = (uint64_t *)(((*pte2 >> 10) << 12) + PA2VA_OFFSET);

    // 处理第二级页表
    uint64_t *pte1 = &pgtbl_lvl1[vpn1];
    uint64_t *pgtbl_lvl0;
    if (!(*pte1 & PTE_V)) {
      pgtbl_lvl0 = (uint64_t *)(kalloc() - PA2VA_OFFSET);
      *pte1 = ((uint64_t)pgtbl_lvl0 >> 12 << 10) | PTE_V;
    }
    pgtbl_lvl0 = (uint64_t *)(((*pte1 >> 10) << 12) + PA2VA_OFFSET);

    // 处理第三级页表
    uint64_t *pte0 = &pgtbl_lvl0[vpn0];
    *pte0 = (((uint64_t)pa & 0x003ffffffffffc00) >> 2) | perm;

    // 下一个页面
    va += PGSIZE;
    pa += PGSIZE;
  }
}