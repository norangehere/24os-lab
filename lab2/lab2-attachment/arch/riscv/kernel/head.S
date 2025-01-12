    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    la a0, boot_stack_top  
    mv sp, a0             

    # set stvec = _traps
    la a0, _traps         
    csrw stvec, a0        

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
    csrr a0, sstatus      
    ori a0, a0, 0x2      
    csrw sstatus, a0      

    jal mm_init   
    jal task_init

    jal start_kernel             

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: