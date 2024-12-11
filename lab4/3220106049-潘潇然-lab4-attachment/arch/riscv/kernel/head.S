    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    la sp, boot_stack_top  
    jal setup_vm
    jal relocate

    # set stvec = _traps
    la a0, _traps         
    csrw stvec, a0     
      
    jal mm_init   
    jal setup_vm_final
    jal task_init
    
    # set sie[STIE] = 1
    csrr a0, sie          
    ori a0, a0, 0x20      
    csrw sie, a0          

    # set first time interrupt
    rdtime a0
    la t0, 10000000
    add a0, a0, t0
    la a6, 0x0
    la a7, 0x54494d45
    ecall

    # set sstatus[SIE] = 1
    #csrr a0, sstatus      
    #ori a0, a0, 0x2      
    #csrw sstatus, a0      

    
    jal start_kernel             

    .extern _new_traps
relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    li t0, 0xffffffdf80000000
    add ra, ra, t0
    add sp, sp, t0

    # handle stvec
    # la a0, _new_traps
    # add a0, a0, t0
    # csrw stvec, a0   

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl
    li t2, 8
    slli t2, t2, 60
    la t1, early_pgtbl
    srli t1, t1, 12
    or t1, t1, t2
    csrw satp, t1

    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: