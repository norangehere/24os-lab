    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -256        
    sd x1, 248(sp)  
    sd x3, 240(sp)
    sd x4, 232(sp)
    sd x5, 224(sp)
    sd x6, 216(sp)
    sd x7, 208(sp)
    sd x8, 200(sp)
    sd x9, 192(sp)
    sd x10, 184(sp)
    sd x11, 176(sp)
    sd x12, 168(sp)
    sd x13, 160(sp)
    sd x14, 152(sp)
    sd x15, 144(sp)
    sd x16, 136(sp)
    sd x17, 128(sp)
    sd x18, 120(sp)
    sd x19, 112(sp)
    sd x20, 104(sp)
    sd x21, 96(sp)
    sd x22, 88(sp)
    sd x23, 80(sp)
    sd x24, 72(sp)
    sd x25, 64(sp)
    sd x26, 56(sp)
    sd x27, 48(sp)
    sd x28, 40(sp)
    sd x29, 32(sp)
    sd x30, 24(sp)
    sd x31, 16(sp)
    csrr a0, scause  
    csrr a1, sepc
    sd a1, 8(sp)
    sd x2, 0(sp)

    # 2. call trap_handler            
    call trap_handler      

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack  
    ld a1, 8(sp)  
    csrw sepc, a1
    ld x1, 248(sp)
    ld x3, 240(sp)
    ld x4, 232(sp)
    ld x5, 224(sp)
    ld x6, 216(sp)
    ld x7, 208(sp)
    ld x8, 200(sp)
    ld x9, 192(sp)
    ld x10, 184(sp)
    ld x11, 176(sp)
    ld x12, 168(sp)
    ld x13, 160(sp)
    ld x14, 152(sp)
    ld x15, 144(sp)
    ld x16, 136(sp)
    ld x17, 128(sp)
    ld x18, 120(sp)
    ld x19, 112(sp)
    ld x20, 104(sp)
    ld x21, 96(sp)
    ld x22, 88(sp)
    ld x23, 80(sp)
    ld x24, 72(sp)
    ld x25, 64(sp)
    ld x26, 56(sp)
    ld x27, 48(sp)
    ld x28, 40(sp)
    ld x29, 32(sp)
    ld x30, 24(sp)
    ld x31, 16(sp)
    ld x2, 0(sp)
    addi sp, sp, 256

    # 4. return from trap
    sret                 

    .extern dummy
    .globl __dummy
__dummy:
    la a0,dummy
    csrw sepc,a0
    sret

    .globl __switch_to
__switch_to:    
    # save state to prev process
    addi t0,a0,32
    sd ra, 0(t0)          
    sd sp, 8(t0)          
    sd s0, 16(t0)         
    sd s1, 24(t0)         
    sd s2, 32(t0)         
    sd s3, 40(t0)       
    sd s4, 48(t0)         
    sd s5, 56(t0)         
    sd s6, 64(t0)        
    sd s7, 72(t0)        
    sd s8, 80(t0)         
    sd s9, 88(t0)         
    sd s10, 96(t0)       
    sd s11, 104(t0)     

    # restore state from next process  
    addi t0,a1,32
    ld ra, 0(t0)          
    ld sp, 8(t0)          
    ld s0, 16(t0)         
    ld s1, 24(t0)         
    ld s2, 32(t0)        
    ld s3, 40(t0)        
    ld s4, 48(t0)         
    ld s5, 56(t0)         
    ld s6, 64(t0)       
    ld s7, 72(t0)        
    ld s8, 80(t0)        
    ld s9, 88(t0)         
    ld s10, 96(t0)        
    ld s11, 104(t0)     
    
    ret 

    .globl _new_traps
_new_traps:
    addi sp,sp,-8
    sd t0, 0(sp)

    csrr t0,sepc
    li t1,0xffffffdf80000000
    add t0,t0,t1
    csrw sepc,t0

    ld t0,0(sp)
    addi sp,sp,8
    sret
