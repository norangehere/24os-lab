#ifndef _VM_H_
#define _VM_H_

#include "stdint.h"

void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz,
                    uint64_t perm);

void setup_vm_final();

void setup_vm();

#endif