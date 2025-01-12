
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    la a0, boot_stack_top  
    80200000:	00003517          	auipc	a0,0x3
    80200004:	01053503          	ld	a0,16(a0) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    mv sp, a0             
    80200008:	00050113          	mv	sp,a0

    # set stvec = _traps
    la a0, _traps         
    8020000c:	00003517          	auipc	a0,0x3
    80200010:	00c53503          	ld	a0,12(a0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec, a0        
    80200014:	10551073          	csrw	stvec,a0

    # set sie[STIE] = 1
    csrr a0, sie          
    80200018:	10402573          	csrr	a0,sie
    ori a0, a0, 0x20      
    8020001c:	02056513          	ori	a0,a0,32
    csrw sie, a0          
    80200020:	10451073          	csrw	sie,a0

    # set first time interrupt
    rdtime a0
    80200024:	c0102573          	rdtime	a0
    la t0, 10000000
    80200028:	009892b7          	lui	t0,0x989
    8020002c:	6802829b          	addiw	t0,t0,1664 # 989680 <_skernel-0x7f876980>
    add a0, a0, t0
    80200030:	00550533          	add	a0,a0,t0
    la a6, 0x0
    80200034:	0000081b          	sext.w	a6,zero
    la a7, 0x54494d45
    80200038:	544958b7          	lui	a7,0x54495
    8020003c:	d458889b          	addiw	a7,a7,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    ecall
    80200040:	00000073          	ecall

    # set sstatus[SIE] = 1
    csrr a0, sstatus      
    80200044:	10002573          	csrr	a0,sstatus
    ori a0, a0, 0x2      
    80200048:	00256513          	ori	a0,a0,2
    csrw sstatus, a0      
    8020004c:	10051073          	csrw	sstatus,a0

    jal start_kernel             
    80200050:	51c000ef          	jal	ra,8020056c <start_kernel>

0000000080200054 <_traps>:
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -256        
    80200054:	f0010113          	addi	sp,sp,-256
    sd x1, 248(sp)  
    80200058:	0e113c23          	sd	ra,248(sp)
    sd x3, 240(sp)
    8020005c:	0e313823          	sd	gp,240(sp)
    sd x4, 232(sp)
    80200060:	0e413423          	sd	tp,232(sp)
    sd x5, 224(sp)
    80200064:	0e513023          	sd	t0,224(sp)
    sd x6, 216(sp)
    80200068:	0c613c23          	sd	t1,216(sp)
    sd x7, 208(sp)
    8020006c:	0c713823          	sd	t2,208(sp)
    sd x8, 200(sp)
    80200070:	0c813423          	sd	s0,200(sp)
    sd x9, 192(sp)
    80200074:	0c913023          	sd	s1,192(sp)
    sd x10, 184(sp)
    80200078:	0aa13c23          	sd	a0,184(sp)
    sd x11, 176(sp)
    8020007c:	0ab13823          	sd	a1,176(sp)
    sd x12, 168(sp)
    80200080:	0ac13423          	sd	a2,168(sp)
    sd x13, 160(sp)
    80200084:	0ad13023          	sd	a3,160(sp)
    sd x14, 152(sp)
    80200088:	08e13c23          	sd	a4,152(sp)
    sd x15, 144(sp)
    8020008c:	08f13823          	sd	a5,144(sp)
    sd x16, 136(sp)
    80200090:	09013423          	sd	a6,136(sp)
    sd x17, 128(sp)
    80200094:	09113023          	sd	a7,128(sp)
    sd x18, 120(sp)
    80200098:	07213c23          	sd	s2,120(sp)
    sd x19, 112(sp)
    8020009c:	07313823          	sd	s3,112(sp)
    sd x20, 104(sp)
    802000a0:	07413423          	sd	s4,104(sp)
    sd x21, 96(sp)
    802000a4:	07513023          	sd	s5,96(sp)
    sd x22, 88(sp)
    802000a8:	05613c23          	sd	s6,88(sp)
    sd x23, 80(sp)
    802000ac:	05713823          	sd	s7,80(sp)
    sd x24, 72(sp)
    802000b0:	05813423          	sd	s8,72(sp)
    sd x25, 64(sp)
    802000b4:	05913023          	sd	s9,64(sp)
    sd x26, 56(sp)
    802000b8:	03a13c23          	sd	s10,56(sp)
    sd x27, 48(sp)
    802000bc:	03b13823          	sd	s11,48(sp)
    sd x28, 40(sp)
    802000c0:	03c13423          	sd	t3,40(sp)
    sd x29, 32(sp)
    802000c4:	03d13023          	sd	t4,32(sp)
    sd x30, 24(sp)
    802000c8:	01e13c23          	sd	t5,24(sp)
    sd x31, 16(sp)
    802000cc:	01f13823          	sd	t6,16(sp)
    csrr a0, scause  
    802000d0:	14202573          	csrr	a0,scause
    csrr a1, sepc
    802000d4:	141025f3          	csrr	a1,sepc
    sd a1, 8(sp)
    802000d8:	00b13423          	sd	a1,8(sp)
    sd x2, 0(sp)
    802000dc:	00213023          	sd	sp,0(sp)

    # 2. call trap_handler            
    call trap_handler      
    802000e0:	3e4000ef          	jal	ra,802004c4 <trap_handler>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack  
    ld a1, 8(sp)  
    802000e4:	00813583          	ld	a1,8(sp)
    csrw sepc, a1
    802000e8:	14159073          	csrw	sepc,a1
    ld x1, 248(sp)
    802000ec:	0f813083          	ld	ra,248(sp)
    ld x3, 240(sp)
    802000f0:	0f013183          	ld	gp,240(sp)
    ld x4, 232(sp)
    802000f4:	0e813203          	ld	tp,232(sp)
    ld x5, 224(sp)
    802000f8:	0e013283          	ld	t0,224(sp)
    ld x6, 216(sp)
    802000fc:	0d813303          	ld	t1,216(sp)
    ld x7, 208(sp)
    80200100:	0d013383          	ld	t2,208(sp)
    ld x8, 200(sp)
    80200104:	0c813403          	ld	s0,200(sp)
    ld x9, 192(sp)
    80200108:	0c013483          	ld	s1,192(sp)
    ld x10, 184(sp)
    8020010c:	0b813503          	ld	a0,184(sp)
    ld x11, 176(sp)
    80200110:	0b013583          	ld	a1,176(sp)
    ld x12, 168(sp)
    80200114:	0a813603          	ld	a2,168(sp)
    ld x13, 160(sp)
    80200118:	0a013683          	ld	a3,160(sp)
    ld x14, 152(sp)
    8020011c:	09813703          	ld	a4,152(sp)
    ld x15, 144(sp)
    80200120:	09013783          	ld	a5,144(sp)
    ld x16, 136(sp)
    80200124:	08813803          	ld	a6,136(sp)
    ld x17, 128(sp)
    80200128:	08013883          	ld	a7,128(sp)
    ld x18, 120(sp)
    8020012c:	07813903          	ld	s2,120(sp)
    ld x19, 112(sp)
    80200130:	07013983          	ld	s3,112(sp)
    ld x20, 104(sp)
    80200134:	06813a03          	ld	s4,104(sp)
    ld x21, 96(sp)
    80200138:	06013a83          	ld	s5,96(sp)
    ld x22, 88(sp)
    8020013c:	05813b03          	ld	s6,88(sp)
    ld x23, 80(sp)
    80200140:	05013b83          	ld	s7,80(sp)
    ld x24, 72(sp)
    80200144:	04813c03          	ld	s8,72(sp)
    ld x25, 64(sp)
    80200148:	04013c83          	ld	s9,64(sp)
    ld x26, 56(sp)
    8020014c:	03813d03          	ld	s10,56(sp)
    ld x27, 48(sp)
    80200150:	03013d83          	ld	s11,48(sp)
    ld x28, 40(sp)
    80200154:	02813e03          	ld	t3,40(sp)
    ld x29, 32(sp)
    80200158:	02013e83          	ld	t4,32(sp)
    ld x30, 24(sp)
    8020015c:	01813f03          	ld	t5,24(sp)
    ld x31, 16(sp)
    80200160:	01013f83          	ld	t6,16(sp)
    ld x2, 0(sp)
    80200164:	00013103          	ld	sp,0(sp)
    addi sp, sp, 256
    80200168:	10010113          	addi	sp,sp,256

    # 4. return from trap
    sret                 
    8020016c:	10200073          	sret

0000000080200170 <get_cycles>:
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    80200170:	fe010113          	addi	sp,sp,-32
    80200174:	00813c23          	sd	s0,24(sp)
    80200178:	02010413          	addi	s0,sp,32
  // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime
  // 寄存器）的值并返回
  uint64_t cycles;
  // 使用 rdtime 获取 time 寄存器中的值
  __asm__ volatile("rdtime %0" : "=r"(cycles));
    8020017c:	c01027f3          	rdtime	a5
    80200180:	fef43423          	sd	a5,-24(s0)
  return cycles;
    80200184:	fe843783          	ld	a5,-24(s0)
}
    80200188:	00078513          	mv	a0,a5
    8020018c:	01813403          	ld	s0,24(sp)
    80200190:	02010113          	addi	sp,sp,32
    80200194:	00008067          	ret

0000000080200198 <clock_set_next_event>:

void clock_set_next_event() {
    80200198:	fe010113          	addi	sp,sp,-32
    8020019c:	00113c23          	sd	ra,24(sp)
    802001a0:	00813823          	sd	s0,16(sp)
    802001a4:	02010413          	addi	s0,sp,32
  // 下一次时钟中断的时间点
  uint64_t next = get_cycles() + TIMECLOCK;
    802001a8:	fc9ff0ef          	jal	ra,80200170 <get_cycles>
    802001ac:	00050713          	mv	a4,a0
    802001b0:	00003797          	auipc	a5,0x3
    802001b4:	e5078793          	addi	a5,a5,-432 # 80203000 <TIMECLOCK>
    802001b8:	0007b783          	ld	a5,0(a5)
    802001bc:	00f707b3          	add	a5,a4,a5
    802001c0:	fef43423          	sd	a5,-24(s0)

  // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
  __asm__ volatile(
    802001c4:	fe843783          	ld	a5,-24(s0)
    802001c8:	0000081b          	sext.w	a6,zero
    802001cc:	544958b7          	lui	a7,0x54495
    802001d0:	d458889b          	addiw	a7,a7,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    802001d4:	00078513          	mv	a0,a5
    802001d8:	00000073          	ecall
      "mv a0, %0\n"
      "ecall\n"
      :
      : "r"(next)
      : "a0", "a7");
    802001dc:	00000013          	nop
    802001e0:	01813083          	ld	ra,24(sp)
    802001e4:	01013403          	ld	s0,16(sp)
    802001e8:	02010113          	addi	sp,sp,32
    802001ec:	00008067          	ret

00000000802001f0 <main>:
    unsigned long __tmp;                          \
    asm volatile("csrr %0, " #csr : "=r"(__tmp)); \
    __tmp;                                        \
  })

int main() {
    802001f0:	fe010113          	addi	sp,sp,-32
    802001f4:	00113c23          	sd	ra,24(sp)
    802001f8:	00813823          	sd	s0,16(sp)
    802001fc:	02010413          	addi	s0,sp,32
  unsigned long sstatus_value = csr_read(sstatus);
    80200200:	100027f3          	csrr	a5,sstatus
    80200204:	fef43423          	sd	a5,-24(s0)
    80200208:	fe843783          	ld	a5,-24(s0)
    8020020c:	fef43023          	sd	a5,-32(s0)
  printk("sstatus value: %lx\n", sstatus_value);
    80200210:	fe043583          	ld	a1,-32(s0)
    80200214:	00002517          	auipc	a0,0x2
    80200218:	dec50513          	addi	a0,a0,-532 # 80202000 <_srodata>
    8020021c:	278010ef          	jal	ra,80201494 <printk>
  return 0;
    80200220:	00000793          	li	a5,0
}
    80200224:	00078513          	mv	a0,a5
    80200228:	01813083          	ld	ra,24(sp)
    8020022c:	01013403          	ld	s0,16(sp)
    80200230:	02010113          	addi	sp,sp,32
    80200234:	00008067          	ret

0000000080200238 <sbi_ecall>:

#include "stdint.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid, uint64_t arg0,
                        uint64_t arg1, uint64_t arg2, uint64_t arg3,
                        uint64_t arg4, uint64_t arg5) {
    80200238:	f8010113          	addi	sp,sp,-128
    8020023c:	06813c23          	sd	s0,120(sp)
    80200240:	06913823          	sd	s1,112(sp)
    80200244:	07213423          	sd	s2,104(sp)
    80200248:	07313023          	sd	s3,96(sp)
    8020024c:	08010413          	addi	s0,sp,128
    80200250:	faa43c23          	sd	a0,-72(s0)
    80200254:	fab43823          	sd	a1,-80(s0)
    80200258:	fac43423          	sd	a2,-88(s0)
    8020025c:	fad43023          	sd	a3,-96(s0)
    80200260:	f8e43c23          	sd	a4,-104(s0)
    80200264:	f8f43823          	sd	a5,-112(s0)
    80200268:	f9043423          	sd	a6,-120(s0)
    8020026c:	f9143023          	sd	a7,-128(s0)
  struct sbiret ret;

  __asm__ volatile(
    80200270:	fb843e03          	ld	t3,-72(s0)
    80200274:	fb043e83          	ld	t4,-80(s0)
    80200278:	fa843f03          	ld	t5,-88(s0)
    8020027c:	fa043f83          	ld	t6,-96(s0)
    80200280:	f9843283          	ld	t0,-104(s0)
    80200284:	f9043483          	ld	s1,-112(s0)
    80200288:	f8843903          	ld	s2,-120(s0)
    8020028c:	f8043983          	ld	s3,-128(s0)
    80200290:	000e0893          	mv	a7,t3
    80200294:	000e8813          	mv	a6,t4
    80200298:	000f0513          	mv	a0,t5
    8020029c:	000f8593          	mv	a1,t6
    802002a0:	00028613          	mv	a2,t0
    802002a4:	00048693          	mv	a3,s1
    802002a8:	00090713          	mv	a4,s2
    802002ac:	00098793          	mv	a5,s3
    802002b0:	00000073          	ecall
    802002b4:	00050e93          	mv	t4,a0
    802002b8:	00058e13          	mv	t3,a1
    802002bc:	fdd43023          	sd	t4,-64(s0)
    802002c0:	fdc43423          	sd	t3,-56(s0)
      : "=r"(ret.error), "=r"(ret.value)
      : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3),
        "r"(arg4), "r"(arg5)
      : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7");

  return ret;
    802002c4:	fc043783          	ld	a5,-64(s0)
    802002c8:	fcf43823          	sd	a5,-48(s0)
    802002cc:	fc843783          	ld	a5,-56(s0)
    802002d0:	fcf43c23          	sd	a5,-40(s0)
    802002d4:	fd043703          	ld	a4,-48(s0)
    802002d8:	fd843783          	ld	a5,-40(s0)
    802002dc:	00070313          	mv	t1,a4
    802002e0:	00078393          	mv	t2,a5
    802002e4:	00030713          	mv	a4,t1
    802002e8:	00038793          	mv	a5,t2
}
    802002ec:	00070513          	mv	a0,a4
    802002f0:	00078593          	mv	a1,a5
    802002f4:	07813403          	ld	s0,120(sp)
    802002f8:	07013483          	ld	s1,112(sp)
    802002fc:	06813903          	ld	s2,104(sp)
    80200300:	06013983          	ld	s3,96(sp)
    80200304:	08010113          	addi	sp,sp,128
    80200308:	00008067          	ret

000000008020030c <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
    8020030c:	fb010113          	addi	sp,sp,-80
    80200310:	04113423          	sd	ra,72(sp)
    80200314:	04813023          	sd	s0,64(sp)
    80200318:	03213c23          	sd	s2,56(sp)
    8020031c:	03313823          	sd	s3,48(sp)
    80200320:	05010413          	addi	s0,sp,80
    80200324:	faa43c23          	sd	a0,-72(s0)
  struct sbiret ret;

  sbi_ecall(0x54494d45, 0, stime_value, 0, 0, 0, 0, 0);
    80200328:	00000893          	li	a7,0
    8020032c:	00000813          	li	a6,0
    80200330:	00000793          	li	a5,0
    80200334:	00000713          	li	a4,0
    80200338:	00000693          	li	a3,0
    8020033c:	fb843603          	ld	a2,-72(s0)
    80200340:	00000593          	li	a1,0
    80200344:	54495537          	lui	a0,0x54495
    80200348:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    8020034c:	eedff0ef          	jal	ra,80200238 <sbi_ecall>

  return ret;
    80200350:	fc043783          	ld	a5,-64(s0)
    80200354:	fcf43823          	sd	a5,-48(s0)
    80200358:	fc843783          	ld	a5,-56(s0)
    8020035c:	fcf43c23          	sd	a5,-40(s0)
    80200360:	fd043703          	ld	a4,-48(s0)
    80200364:	fd843783          	ld	a5,-40(s0)
    80200368:	00070913          	mv	s2,a4
    8020036c:	00078993          	mv	s3,a5
    80200370:	00090713          	mv	a4,s2
    80200374:	00098793          	mv	a5,s3
}
    80200378:	00070513          	mv	a0,a4
    8020037c:	00078593          	mv	a1,a5
    80200380:	04813083          	ld	ra,72(sp)
    80200384:	04013403          	ld	s0,64(sp)
    80200388:	03813903          	ld	s2,56(sp)
    8020038c:	03013983          	ld	s3,48(sp)
    80200390:	05010113          	addi	sp,sp,80
    80200394:	00008067          	ret

0000000080200398 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200398:	fb010113          	addi	sp,sp,-80
    8020039c:	04113423          	sd	ra,72(sp)
    802003a0:	04813023          	sd	s0,64(sp)
    802003a4:	03213c23          	sd	s2,56(sp)
    802003a8:	03313823          	sd	s3,48(sp)
    802003ac:	05010413          	addi	s0,sp,80
    802003b0:	00050793          	mv	a5,a0
    802003b4:	faf40fa3          	sb	a5,-65(s0)
  struct sbiret ret;

  sbi_ecall(0x4442434e, 2, byte, 0, 0, 0, 0, 0);
    802003b8:	fbf44603          	lbu	a2,-65(s0)
    802003bc:	00000893          	li	a7,0
    802003c0:	00000813          	li	a6,0
    802003c4:	00000793          	li	a5,0
    802003c8:	00000713          	li	a4,0
    802003cc:	00000693          	li	a3,0
    802003d0:	00200593          	li	a1,2
    802003d4:	44424537          	lui	a0,0x44424
    802003d8:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    802003dc:	e5dff0ef          	jal	ra,80200238 <sbi_ecall>

  return ret;
    802003e0:	fc043783          	ld	a5,-64(s0)
    802003e4:	fcf43823          	sd	a5,-48(s0)
    802003e8:	fc843783          	ld	a5,-56(s0)
    802003ec:	fcf43c23          	sd	a5,-40(s0)
    802003f0:	fd043703          	ld	a4,-48(s0)
    802003f4:	fd843783          	ld	a5,-40(s0)
    802003f8:	00070913          	mv	s2,a4
    802003fc:	00078993          	mv	s3,a5
    80200400:	00090713          	mv	a4,s2
    80200404:	00098793          	mv	a5,s3
}
    80200408:	00070513          	mv	a0,a4
    8020040c:	00078593          	mv	a1,a5
    80200410:	04813083          	ld	ra,72(sp)
    80200414:	04013403          	ld	s0,64(sp)
    80200418:	03813903          	ld	s2,56(sp)
    8020041c:	03013983          	ld	s3,48(sp)
    80200420:	05010113          	addi	sp,sp,80
    80200424:	00008067          	ret

0000000080200428 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200428:	fb010113          	addi	sp,sp,-80
    8020042c:	04113423          	sd	ra,72(sp)
    80200430:	04813023          	sd	s0,64(sp)
    80200434:	03213c23          	sd	s2,56(sp)
    80200438:	03313823          	sd	s3,48(sp)
    8020043c:	05010413          	addi	s0,sp,80
    80200440:	00050793          	mv	a5,a0
    80200444:	00058713          	mv	a4,a1
    80200448:	faf42e23          	sw	a5,-68(s0)
    8020044c:	00070793          	mv	a5,a4
    80200450:	faf42c23          	sw	a5,-72(s0)
  struct sbiret ret;

  sbi_ecall(0x53525354, 0, reset_type, reset_reason, 0, 0, 0, 0);
    80200454:	fbc46603          	lwu	a2,-68(s0)
    80200458:	fb846683          	lwu	a3,-72(s0)
    8020045c:	00000893          	li	a7,0
    80200460:	00000813          	li	a6,0
    80200464:	00000793          	li	a5,0
    80200468:	00000713          	li	a4,0
    8020046c:	00000593          	li	a1,0
    80200470:	53525537          	lui	a0,0x53525
    80200474:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200478:	dc1ff0ef          	jal	ra,80200238 <sbi_ecall>

  return ret;
    8020047c:	fc043783          	ld	a5,-64(s0)
    80200480:	fcf43823          	sd	a5,-48(s0)
    80200484:	fc843783          	ld	a5,-56(s0)
    80200488:	fcf43c23          	sd	a5,-40(s0)
    8020048c:	fd043703          	ld	a4,-48(s0)
    80200490:	fd843783          	ld	a5,-40(s0)
    80200494:	00070913          	mv	s2,a4
    80200498:	00078993          	mv	s3,a5
    8020049c:	00090713          	mv	a4,s2
    802004a0:	00098793          	mv	a5,s3
    802004a4:	00070513          	mv	a0,a4
    802004a8:	00078593          	mv	a1,a5
    802004ac:	04813083          	ld	ra,72(sp)
    802004b0:	04013403          	ld	s0,64(sp)
    802004b4:	03813903          	ld	s2,56(sp)
    802004b8:	03013983          	ld	s3,48(sp)
    802004bc:	05010113          	addi	sp,sp,80
    802004c0:	00008067          	ret

00000000802004c4 <trap_handler>:
#include "printk.h"
#include "stdint.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    802004c4:	fd010113          	addi	sp,sp,-48
    802004c8:	02113423          	sd	ra,40(sp)
    802004cc:	02813023          	sd	s0,32(sp)
    802004d0:	03010413          	addi	s0,sp,48
    802004d4:	fca43c23          	sd	a0,-40(s0)
    802004d8:	fcb43823          	sd	a1,-48(s0)
  // 如果是 interrupt 判断是否是 timer interrupt
  // 如果是 timer interrupt 则打印输出相关信息，并通过
  // `clock_set_next_event()`设置下一次时钟中断
  //  `clock_set_next_event()` 见 4.3.4 节
  // 其他 interrupt /exception 可以直接忽略，推荐打印出来供以后调试
  uint64_t flag = 0x8000000000000000;  // 第一位是1
    802004dc:	fff00793          	li	a5,-1
    802004e0:	03f79793          	slli	a5,a5,0x3f
    802004e4:	fef43423          	sd	a5,-24(s0)
  uint64_t exception_code = 0x5;       // exception code for timer interrupt
    802004e8:	00500793          	li	a5,5
    802004ec:	fef43023          	sd	a5,-32(s0)
  if (scause & flag)                   // if interrupt
    802004f0:	fd843703          	ld	a4,-40(s0)
    802004f4:	fe843783          	ld	a5,-24(s0)
    802004f8:	00f777b3          	and	a5,a4,a5
    802004fc:	04078463          	beqz	a5,80200544 <trap_handler+0x80>
    if ((scause & ~flag) == exception_code) {  // if timer interrupt
    80200500:	fe843783          	ld	a5,-24(s0)
    80200504:	fff7c713          	not	a4,a5
    80200508:	fd843783          	ld	a5,-40(s0)
    8020050c:	00f777b3          	and	a5,a4,a5
    80200510:	fe043703          	ld	a4,-32(s0)
    80200514:	00f71c63          	bne	a4,a5,8020052c <trap_handler+0x68>
      printk("[S] Supervisor Mode Timer Interrupt\n");
    80200518:	00002517          	auipc	a0,0x2
    8020051c:	b0050513          	addi	a0,a0,-1280 # 80202018 <_srodata+0x18>
    80200520:	775000ef          	jal	ra,80201494 <printk>
      clock_set_next_event();
    80200524:	c75ff0ef          	jal	ra,80200198 <clock_set_next_event>
      printk("[S] Supervisor Mode Other Interrupt (scause: %lx, sepc: %lx).\n",
             scause, sepc);
  else
    printk("[S] Supervisor Mode Exception (scause: %lx, sepc: %lx).\n", scause,
           sepc);
    80200528:	0300006f          	j	80200558 <trap_handler+0x94>
      printk("[S] Supervisor Mode Other Interrupt (scause: %lx, sepc: %lx).\n",
    8020052c:	fd043603          	ld	a2,-48(s0)
    80200530:	fd843583          	ld	a1,-40(s0)
    80200534:	00002517          	auipc	a0,0x2
    80200538:	b0c50513          	addi	a0,a0,-1268 # 80202040 <_srodata+0x40>
    8020053c:	759000ef          	jal	ra,80201494 <printk>
    80200540:	0180006f          	j	80200558 <trap_handler+0x94>
    printk("[S] Supervisor Mode Exception (scause: %lx, sepc: %lx).\n", scause,
    80200544:	fd043603          	ld	a2,-48(s0)
    80200548:	fd843583          	ld	a1,-40(s0)
    8020054c:	00002517          	auipc	a0,0x2
    80200550:	b3450513          	addi	a0,a0,-1228 # 80202080 <_srodata+0x80>
    80200554:	741000ef          	jal	ra,80201494 <printk>
    80200558:	00000013          	nop
    8020055c:	02813083          	ld	ra,40(sp)
    80200560:	02013403          	ld	s0,32(sp)
    80200564:	03010113          	addi	sp,sp,48
    80200568:	00008067          	ret

000000008020056c <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel() {
    8020056c:	ff010113          	addi	sp,sp,-16
    80200570:	00113423          	sd	ra,8(sp)
    80200574:	00813023          	sd	s0,0(sp)
    80200578:	01010413          	addi	s0,sp,16
    printk("2024");
    8020057c:	00002517          	auipc	a0,0x2
    80200580:	b4450513          	addi	a0,a0,-1212 # 802020c0 <_srodata+0xc0>
    80200584:	711000ef          	jal	ra,80201494 <printk>
    printk(" ZJU Operating System\n");
    80200588:	00002517          	auipc	a0,0x2
    8020058c:	b4050513          	addi	a0,a0,-1216 # 802020c8 <_srodata+0xc8>
    80200590:	705000ef          	jal	ra,80201494 <printk>

    test();
    80200594:	01c000ef          	jal	ra,802005b0 <test>
    return 0;
    80200598:	00000793          	li	a5,0
}
    8020059c:	00078513          	mv	a0,a5
    802005a0:	00813083          	ld	ra,8(sp)
    802005a4:	00013403          	ld	s0,0(sp)
    802005a8:	01010113          	addi	sp,sp,16
    802005ac:	00008067          	ret

00000000802005b0 <test>:
//   })

// #define csr_write(csr, value) \
//   __asm__ volatile("csrw " #csr ", %0" : : "r"(value))

void test() {
    802005b0:	fe010113          	addi	sp,sp,-32
    802005b4:	00113c23          	sd	ra,24(sp)
    802005b8:	00813823          	sd	s0,16(sp)
    802005bc:	02010413          	addi	s0,sp,32
  int i = 0;
    802005c0:	fe042623          	sw	zero,-20(s0)
  //   csr_write(sscratch, write_value);
  //   unsigned long read_value = csr_read(sscratch);
  //   printk("write value: %lx\n", write_value);
  //   printk("sscratch value: %lx\n", read_value);
  while (1) {
    if ((++i) % 100000000 == 0) {
    802005c4:	fec42783          	lw	a5,-20(s0)
    802005c8:	0017879b          	addiw	a5,a5,1
    802005cc:	fef42623          	sw	a5,-20(s0)
    802005d0:	fec42783          	lw	a5,-20(s0)
    802005d4:	00078713          	mv	a4,a5
    802005d8:	05f5e7b7          	lui	a5,0x5f5e
    802005dc:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    802005e0:	02f767bb          	remw	a5,a4,a5
    802005e4:	0007879b          	sext.w	a5,a5
    802005e8:	fc079ee3          	bnez	a5,802005c4 <test+0x14>
      printk("kernel is running!\n");
    802005ec:	00002517          	auipc	a0,0x2
    802005f0:	af450513          	addi	a0,a0,-1292 # 802020e0 <_srodata+0xe0>
    802005f4:	6a1000ef          	jal	ra,80201494 <printk>
      i = 0;
    802005f8:	fe042623          	sw	zero,-20(s0)
    if ((++i) % 100000000 == 0) {
    802005fc:	fc9ff06f          	j	802005c4 <test+0x14>

0000000080200600 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200600:	fe010113          	addi	sp,sp,-32
    80200604:	00113c23          	sd	ra,24(sp)
    80200608:	00813823          	sd	s0,16(sp)
    8020060c:	02010413          	addi	s0,sp,32
    80200610:	00050793          	mv	a5,a0
    80200614:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200618:	fec42783          	lw	a5,-20(s0)
    8020061c:	0ff7f793          	zext.b	a5,a5
    80200620:	00078513          	mv	a0,a5
    80200624:	d75ff0ef          	jal	ra,80200398 <sbi_debug_console_write_byte>
    return (char)c;
    80200628:	fec42783          	lw	a5,-20(s0)
    8020062c:	0ff7f793          	zext.b	a5,a5
    80200630:	0007879b          	sext.w	a5,a5
}
    80200634:	00078513          	mv	a0,a5
    80200638:	01813083          	ld	ra,24(sp)
    8020063c:	01013403          	ld	s0,16(sp)
    80200640:	02010113          	addi	sp,sp,32
    80200644:	00008067          	ret

0000000080200648 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200648:	fe010113          	addi	sp,sp,-32
    8020064c:	00813c23          	sd	s0,24(sp)
    80200650:	02010413          	addi	s0,sp,32
    80200654:	00050793          	mv	a5,a0
    80200658:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    8020065c:	fec42783          	lw	a5,-20(s0)
    80200660:	0007871b          	sext.w	a4,a5
    80200664:	02000793          	li	a5,32
    80200668:	02f70263          	beq	a4,a5,8020068c <isspace+0x44>
    8020066c:	fec42783          	lw	a5,-20(s0)
    80200670:	0007871b          	sext.w	a4,a5
    80200674:	00800793          	li	a5,8
    80200678:	00e7de63          	bge	a5,a4,80200694 <isspace+0x4c>
    8020067c:	fec42783          	lw	a5,-20(s0)
    80200680:	0007871b          	sext.w	a4,a5
    80200684:	00d00793          	li	a5,13
    80200688:	00e7c663          	blt	a5,a4,80200694 <isspace+0x4c>
    8020068c:	00100793          	li	a5,1
    80200690:	0080006f          	j	80200698 <isspace+0x50>
    80200694:	00000793          	li	a5,0
}
    80200698:	00078513          	mv	a0,a5
    8020069c:	01813403          	ld	s0,24(sp)
    802006a0:	02010113          	addi	sp,sp,32
    802006a4:	00008067          	ret

00000000802006a8 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    802006a8:	fb010113          	addi	sp,sp,-80
    802006ac:	04113423          	sd	ra,72(sp)
    802006b0:	04813023          	sd	s0,64(sp)
    802006b4:	05010413          	addi	s0,sp,80
    802006b8:	fca43423          	sd	a0,-56(s0)
    802006bc:	fcb43023          	sd	a1,-64(s0)
    802006c0:	00060793          	mv	a5,a2
    802006c4:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    802006c8:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    802006cc:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    802006d0:	fc843783          	ld	a5,-56(s0)
    802006d4:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    802006d8:	0100006f          	j	802006e8 <strtol+0x40>
        p++;
    802006dc:	fd843783          	ld	a5,-40(s0)
    802006e0:	00178793          	addi	a5,a5,1
    802006e4:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    802006e8:	fd843783          	ld	a5,-40(s0)
    802006ec:	0007c783          	lbu	a5,0(a5)
    802006f0:	0007879b          	sext.w	a5,a5
    802006f4:	00078513          	mv	a0,a5
    802006f8:	f51ff0ef          	jal	ra,80200648 <isspace>
    802006fc:	00050793          	mv	a5,a0
    80200700:	fc079ee3          	bnez	a5,802006dc <strtol+0x34>
    }

    if (*p == '-') {
    80200704:	fd843783          	ld	a5,-40(s0)
    80200708:	0007c783          	lbu	a5,0(a5)
    8020070c:	00078713          	mv	a4,a5
    80200710:	02d00793          	li	a5,45
    80200714:	00f71e63          	bne	a4,a5,80200730 <strtol+0x88>
        neg = true;
    80200718:	00100793          	li	a5,1
    8020071c:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200720:	fd843783          	ld	a5,-40(s0)
    80200724:	00178793          	addi	a5,a5,1
    80200728:	fcf43c23          	sd	a5,-40(s0)
    8020072c:	0240006f          	j	80200750 <strtol+0xa8>
    } else if (*p == '+') {
    80200730:	fd843783          	ld	a5,-40(s0)
    80200734:	0007c783          	lbu	a5,0(a5)
    80200738:	00078713          	mv	a4,a5
    8020073c:	02b00793          	li	a5,43
    80200740:	00f71863          	bne	a4,a5,80200750 <strtol+0xa8>
        p++;
    80200744:	fd843783          	ld	a5,-40(s0)
    80200748:	00178793          	addi	a5,a5,1
    8020074c:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200750:	fbc42783          	lw	a5,-68(s0)
    80200754:	0007879b          	sext.w	a5,a5
    80200758:	06079c63          	bnez	a5,802007d0 <strtol+0x128>
        if (*p == '0') {
    8020075c:	fd843783          	ld	a5,-40(s0)
    80200760:	0007c783          	lbu	a5,0(a5)
    80200764:	00078713          	mv	a4,a5
    80200768:	03000793          	li	a5,48
    8020076c:	04f71e63          	bne	a4,a5,802007c8 <strtol+0x120>
            p++;
    80200770:	fd843783          	ld	a5,-40(s0)
    80200774:	00178793          	addi	a5,a5,1
    80200778:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    8020077c:	fd843783          	ld	a5,-40(s0)
    80200780:	0007c783          	lbu	a5,0(a5)
    80200784:	00078713          	mv	a4,a5
    80200788:	07800793          	li	a5,120
    8020078c:	00f70c63          	beq	a4,a5,802007a4 <strtol+0xfc>
    80200790:	fd843783          	ld	a5,-40(s0)
    80200794:	0007c783          	lbu	a5,0(a5)
    80200798:	00078713          	mv	a4,a5
    8020079c:	05800793          	li	a5,88
    802007a0:	00f71e63          	bne	a4,a5,802007bc <strtol+0x114>
                base = 16;
    802007a4:	01000793          	li	a5,16
    802007a8:	faf42e23          	sw	a5,-68(s0)
                p++;
    802007ac:	fd843783          	ld	a5,-40(s0)
    802007b0:	00178793          	addi	a5,a5,1
    802007b4:	fcf43c23          	sd	a5,-40(s0)
    802007b8:	0180006f          	j	802007d0 <strtol+0x128>
            } else {
                base = 8;
    802007bc:	00800793          	li	a5,8
    802007c0:	faf42e23          	sw	a5,-68(s0)
    802007c4:	00c0006f          	j	802007d0 <strtol+0x128>
            }
        } else {
            base = 10;
    802007c8:	00a00793          	li	a5,10
    802007cc:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802007d0:	fd843783          	ld	a5,-40(s0)
    802007d4:	0007c783          	lbu	a5,0(a5)
    802007d8:	00078713          	mv	a4,a5
    802007dc:	02f00793          	li	a5,47
    802007e0:	02e7f863          	bgeu	a5,a4,80200810 <strtol+0x168>
    802007e4:	fd843783          	ld	a5,-40(s0)
    802007e8:	0007c783          	lbu	a5,0(a5)
    802007ec:	00078713          	mv	a4,a5
    802007f0:	03900793          	li	a5,57
    802007f4:	00e7ee63          	bltu	a5,a4,80200810 <strtol+0x168>
            digit = *p - '0';
    802007f8:	fd843783          	ld	a5,-40(s0)
    802007fc:	0007c783          	lbu	a5,0(a5)
    80200800:	0007879b          	sext.w	a5,a5
    80200804:	fd07879b          	addiw	a5,a5,-48
    80200808:	fcf42a23          	sw	a5,-44(s0)
    8020080c:	0800006f          	j	8020088c <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200810:	fd843783          	ld	a5,-40(s0)
    80200814:	0007c783          	lbu	a5,0(a5)
    80200818:	00078713          	mv	a4,a5
    8020081c:	06000793          	li	a5,96
    80200820:	02e7f863          	bgeu	a5,a4,80200850 <strtol+0x1a8>
    80200824:	fd843783          	ld	a5,-40(s0)
    80200828:	0007c783          	lbu	a5,0(a5)
    8020082c:	00078713          	mv	a4,a5
    80200830:	07a00793          	li	a5,122
    80200834:	00e7ee63          	bltu	a5,a4,80200850 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80200838:	fd843783          	ld	a5,-40(s0)
    8020083c:	0007c783          	lbu	a5,0(a5)
    80200840:	0007879b          	sext.w	a5,a5
    80200844:	fa97879b          	addiw	a5,a5,-87
    80200848:	fcf42a23          	sw	a5,-44(s0)
    8020084c:	0400006f          	j	8020088c <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200850:	fd843783          	ld	a5,-40(s0)
    80200854:	0007c783          	lbu	a5,0(a5)
    80200858:	00078713          	mv	a4,a5
    8020085c:	04000793          	li	a5,64
    80200860:	06e7f863          	bgeu	a5,a4,802008d0 <strtol+0x228>
    80200864:	fd843783          	ld	a5,-40(s0)
    80200868:	0007c783          	lbu	a5,0(a5)
    8020086c:	00078713          	mv	a4,a5
    80200870:	05a00793          	li	a5,90
    80200874:	04e7ee63          	bltu	a5,a4,802008d0 <strtol+0x228>
            digit = *p - ('A' - 10);
    80200878:	fd843783          	ld	a5,-40(s0)
    8020087c:	0007c783          	lbu	a5,0(a5)
    80200880:	0007879b          	sext.w	a5,a5
    80200884:	fc97879b          	addiw	a5,a5,-55
    80200888:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    8020088c:	fd442783          	lw	a5,-44(s0)
    80200890:	00078713          	mv	a4,a5
    80200894:	fbc42783          	lw	a5,-68(s0)
    80200898:	0007071b          	sext.w	a4,a4
    8020089c:	0007879b          	sext.w	a5,a5
    802008a0:	02f75663          	bge	a4,a5,802008cc <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    802008a4:	fbc42703          	lw	a4,-68(s0)
    802008a8:	fe843783          	ld	a5,-24(s0)
    802008ac:	02f70733          	mul	a4,a4,a5
    802008b0:	fd442783          	lw	a5,-44(s0)
    802008b4:	00f707b3          	add	a5,a4,a5
    802008b8:	fef43423          	sd	a5,-24(s0)
        p++;
    802008bc:	fd843783          	ld	a5,-40(s0)
    802008c0:	00178793          	addi	a5,a5,1
    802008c4:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802008c8:	f09ff06f          	j	802007d0 <strtol+0x128>
            break;
    802008cc:	00000013          	nop
    }

    if (endptr) {
    802008d0:	fc043783          	ld	a5,-64(s0)
    802008d4:	00078863          	beqz	a5,802008e4 <strtol+0x23c>
        *endptr = (char *)p;
    802008d8:	fc043783          	ld	a5,-64(s0)
    802008dc:	fd843703          	ld	a4,-40(s0)
    802008e0:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    802008e4:	fe744783          	lbu	a5,-25(s0)
    802008e8:	0ff7f793          	zext.b	a5,a5
    802008ec:	00078863          	beqz	a5,802008fc <strtol+0x254>
    802008f0:	fe843783          	ld	a5,-24(s0)
    802008f4:	40f007b3          	neg	a5,a5
    802008f8:	0080006f          	j	80200900 <strtol+0x258>
    802008fc:	fe843783          	ld	a5,-24(s0)
}
    80200900:	00078513          	mv	a0,a5
    80200904:	04813083          	ld	ra,72(sp)
    80200908:	04013403          	ld	s0,64(sp)
    8020090c:	05010113          	addi	sp,sp,80
    80200910:	00008067          	ret

0000000080200914 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200914:	fd010113          	addi	sp,sp,-48
    80200918:	02113423          	sd	ra,40(sp)
    8020091c:	02813023          	sd	s0,32(sp)
    80200920:	03010413          	addi	s0,sp,48
    80200924:	fca43c23          	sd	a0,-40(s0)
    80200928:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    8020092c:	fd043783          	ld	a5,-48(s0)
    80200930:	00079863          	bnez	a5,80200940 <puts_wo_nl+0x2c>
        s = "(null)";
    80200934:	00001797          	auipc	a5,0x1
    80200938:	7c478793          	addi	a5,a5,1988 # 802020f8 <_srodata+0xf8>
    8020093c:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80200940:	fd043783          	ld	a5,-48(s0)
    80200944:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80200948:	0240006f          	j	8020096c <puts_wo_nl+0x58>
        putch(*p++);
    8020094c:	fe843783          	ld	a5,-24(s0)
    80200950:	00178713          	addi	a4,a5,1
    80200954:	fee43423          	sd	a4,-24(s0)
    80200958:	0007c783          	lbu	a5,0(a5)
    8020095c:	0007871b          	sext.w	a4,a5
    80200960:	fd843783          	ld	a5,-40(s0)
    80200964:	00070513          	mv	a0,a4
    80200968:	000780e7          	jalr	a5
    while (*p) {
    8020096c:	fe843783          	ld	a5,-24(s0)
    80200970:	0007c783          	lbu	a5,0(a5)
    80200974:	fc079ce3          	bnez	a5,8020094c <puts_wo_nl+0x38>
    }
    return p - s;
    80200978:	fe843703          	ld	a4,-24(s0)
    8020097c:	fd043783          	ld	a5,-48(s0)
    80200980:	40f707b3          	sub	a5,a4,a5
    80200984:	0007879b          	sext.w	a5,a5
}
    80200988:	00078513          	mv	a0,a5
    8020098c:	02813083          	ld	ra,40(sp)
    80200990:	02013403          	ld	s0,32(sp)
    80200994:	03010113          	addi	sp,sp,48
    80200998:	00008067          	ret

000000008020099c <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    8020099c:	f9010113          	addi	sp,sp,-112
    802009a0:	06113423          	sd	ra,104(sp)
    802009a4:	06813023          	sd	s0,96(sp)
    802009a8:	07010413          	addi	s0,sp,112
    802009ac:	faa43423          	sd	a0,-88(s0)
    802009b0:	fab43023          	sd	a1,-96(s0)
    802009b4:	00060793          	mv	a5,a2
    802009b8:	f8d43823          	sd	a3,-112(s0)
    802009bc:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    802009c0:	f9f44783          	lbu	a5,-97(s0)
    802009c4:	0ff7f793          	zext.b	a5,a5
    802009c8:	02078663          	beqz	a5,802009f4 <print_dec_int+0x58>
    802009cc:	fa043703          	ld	a4,-96(s0)
    802009d0:	fff00793          	li	a5,-1
    802009d4:	03f79793          	slli	a5,a5,0x3f
    802009d8:	00f71e63          	bne	a4,a5,802009f4 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    802009dc:	00001597          	auipc	a1,0x1
    802009e0:	72458593          	addi	a1,a1,1828 # 80202100 <_srodata+0x100>
    802009e4:	fa843503          	ld	a0,-88(s0)
    802009e8:	f2dff0ef          	jal	ra,80200914 <puts_wo_nl>
    802009ec:	00050793          	mv	a5,a0
    802009f0:	2a00006f          	j	80200c90 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    802009f4:	f9043783          	ld	a5,-112(s0)
    802009f8:	00c7a783          	lw	a5,12(a5)
    802009fc:	00079a63          	bnez	a5,80200a10 <print_dec_int+0x74>
    80200a00:	fa043783          	ld	a5,-96(s0)
    80200a04:	00079663          	bnez	a5,80200a10 <print_dec_int+0x74>
        return 0;
    80200a08:	00000793          	li	a5,0
    80200a0c:	2840006f          	j	80200c90 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200a10:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200a14:	f9f44783          	lbu	a5,-97(s0)
    80200a18:	0ff7f793          	zext.b	a5,a5
    80200a1c:	02078063          	beqz	a5,80200a3c <print_dec_int+0xa0>
    80200a20:	fa043783          	ld	a5,-96(s0)
    80200a24:	0007dc63          	bgez	a5,80200a3c <print_dec_int+0xa0>
        neg = true;
    80200a28:	00100793          	li	a5,1
    80200a2c:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200a30:	fa043783          	ld	a5,-96(s0)
    80200a34:	40f007b3          	neg	a5,a5
    80200a38:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200a3c:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200a40:	f9f44783          	lbu	a5,-97(s0)
    80200a44:	0ff7f793          	zext.b	a5,a5
    80200a48:	02078863          	beqz	a5,80200a78 <print_dec_int+0xdc>
    80200a4c:	fef44783          	lbu	a5,-17(s0)
    80200a50:	0ff7f793          	zext.b	a5,a5
    80200a54:	00079e63          	bnez	a5,80200a70 <print_dec_int+0xd4>
    80200a58:	f9043783          	ld	a5,-112(s0)
    80200a5c:	0057c783          	lbu	a5,5(a5)
    80200a60:	00079863          	bnez	a5,80200a70 <print_dec_int+0xd4>
    80200a64:	f9043783          	ld	a5,-112(s0)
    80200a68:	0047c783          	lbu	a5,4(a5)
    80200a6c:	00078663          	beqz	a5,80200a78 <print_dec_int+0xdc>
    80200a70:	00100793          	li	a5,1
    80200a74:	0080006f          	j	80200a7c <print_dec_int+0xe0>
    80200a78:	00000793          	li	a5,0
    80200a7c:	fcf40ba3          	sb	a5,-41(s0)
    80200a80:	fd744783          	lbu	a5,-41(s0)
    80200a84:	0017f793          	andi	a5,a5,1
    80200a88:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200a8c:	fa043703          	ld	a4,-96(s0)
    80200a90:	00a00793          	li	a5,10
    80200a94:	02f777b3          	remu	a5,a4,a5
    80200a98:	0ff7f713          	zext.b	a4,a5
    80200a9c:	fe842783          	lw	a5,-24(s0)
    80200aa0:	0017869b          	addiw	a3,a5,1
    80200aa4:	fed42423          	sw	a3,-24(s0)
    80200aa8:	0307071b          	addiw	a4,a4,48
    80200aac:	0ff77713          	zext.b	a4,a4
    80200ab0:	ff078793          	addi	a5,a5,-16
    80200ab4:	008787b3          	add	a5,a5,s0
    80200ab8:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200abc:	fa043703          	ld	a4,-96(s0)
    80200ac0:	00a00793          	li	a5,10
    80200ac4:	02f757b3          	divu	a5,a4,a5
    80200ac8:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200acc:	fa043783          	ld	a5,-96(s0)
    80200ad0:	fa079ee3          	bnez	a5,80200a8c <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200ad4:	f9043783          	ld	a5,-112(s0)
    80200ad8:	00c7a783          	lw	a5,12(a5)
    80200adc:	00078713          	mv	a4,a5
    80200ae0:	fff00793          	li	a5,-1
    80200ae4:	02f71063          	bne	a4,a5,80200b04 <print_dec_int+0x168>
    80200ae8:	f9043783          	ld	a5,-112(s0)
    80200aec:	0037c783          	lbu	a5,3(a5)
    80200af0:	00078a63          	beqz	a5,80200b04 <print_dec_int+0x168>
        flags->prec = flags->width;
    80200af4:	f9043783          	ld	a5,-112(s0)
    80200af8:	0087a703          	lw	a4,8(a5)
    80200afc:	f9043783          	ld	a5,-112(s0)
    80200b00:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200b04:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b08:	f9043783          	ld	a5,-112(s0)
    80200b0c:	0087a703          	lw	a4,8(a5)
    80200b10:	fe842783          	lw	a5,-24(s0)
    80200b14:	fcf42823          	sw	a5,-48(s0)
    80200b18:	f9043783          	ld	a5,-112(s0)
    80200b1c:	00c7a783          	lw	a5,12(a5)
    80200b20:	fcf42623          	sw	a5,-52(s0)
    80200b24:	fd042783          	lw	a5,-48(s0)
    80200b28:	00078593          	mv	a1,a5
    80200b2c:	fcc42783          	lw	a5,-52(s0)
    80200b30:	00078613          	mv	a2,a5
    80200b34:	0006069b          	sext.w	a3,a2
    80200b38:	0005879b          	sext.w	a5,a1
    80200b3c:	00f6d463          	bge	a3,a5,80200b44 <print_dec_int+0x1a8>
    80200b40:	00058613          	mv	a2,a1
    80200b44:	0006079b          	sext.w	a5,a2
    80200b48:	40f707bb          	subw	a5,a4,a5
    80200b4c:	0007871b          	sext.w	a4,a5
    80200b50:	fd744783          	lbu	a5,-41(s0)
    80200b54:	0007879b          	sext.w	a5,a5
    80200b58:	40f707bb          	subw	a5,a4,a5
    80200b5c:	fef42023          	sw	a5,-32(s0)
    80200b60:	0280006f          	j	80200b88 <print_dec_int+0x1ec>
        putch(' ');
    80200b64:	fa843783          	ld	a5,-88(s0)
    80200b68:	02000513          	li	a0,32
    80200b6c:	000780e7          	jalr	a5
        ++written;
    80200b70:	fe442783          	lw	a5,-28(s0)
    80200b74:	0017879b          	addiw	a5,a5,1
    80200b78:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b7c:	fe042783          	lw	a5,-32(s0)
    80200b80:	fff7879b          	addiw	a5,a5,-1
    80200b84:	fef42023          	sw	a5,-32(s0)
    80200b88:	fe042783          	lw	a5,-32(s0)
    80200b8c:	0007879b          	sext.w	a5,a5
    80200b90:	fcf04ae3          	bgtz	a5,80200b64 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200b94:	fd744783          	lbu	a5,-41(s0)
    80200b98:	0ff7f793          	zext.b	a5,a5
    80200b9c:	04078463          	beqz	a5,80200be4 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200ba0:	fef44783          	lbu	a5,-17(s0)
    80200ba4:	0ff7f793          	zext.b	a5,a5
    80200ba8:	00078663          	beqz	a5,80200bb4 <print_dec_int+0x218>
    80200bac:	02d00793          	li	a5,45
    80200bb0:	01c0006f          	j	80200bcc <print_dec_int+0x230>
    80200bb4:	f9043783          	ld	a5,-112(s0)
    80200bb8:	0057c783          	lbu	a5,5(a5)
    80200bbc:	00078663          	beqz	a5,80200bc8 <print_dec_int+0x22c>
    80200bc0:	02b00793          	li	a5,43
    80200bc4:	0080006f          	j	80200bcc <print_dec_int+0x230>
    80200bc8:	02000793          	li	a5,32
    80200bcc:	fa843703          	ld	a4,-88(s0)
    80200bd0:	00078513          	mv	a0,a5
    80200bd4:	000700e7          	jalr	a4
        ++written;
    80200bd8:	fe442783          	lw	a5,-28(s0)
    80200bdc:	0017879b          	addiw	a5,a5,1
    80200be0:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200be4:	fe842783          	lw	a5,-24(s0)
    80200be8:	fcf42e23          	sw	a5,-36(s0)
    80200bec:	0280006f          	j	80200c14 <print_dec_int+0x278>
        putch('0');
    80200bf0:	fa843783          	ld	a5,-88(s0)
    80200bf4:	03000513          	li	a0,48
    80200bf8:	000780e7          	jalr	a5
        ++written;
    80200bfc:	fe442783          	lw	a5,-28(s0)
    80200c00:	0017879b          	addiw	a5,a5,1
    80200c04:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200c08:	fdc42783          	lw	a5,-36(s0)
    80200c0c:	0017879b          	addiw	a5,a5,1
    80200c10:	fcf42e23          	sw	a5,-36(s0)
    80200c14:	f9043783          	ld	a5,-112(s0)
    80200c18:	00c7a703          	lw	a4,12(a5)
    80200c1c:	fd744783          	lbu	a5,-41(s0)
    80200c20:	0007879b          	sext.w	a5,a5
    80200c24:	40f707bb          	subw	a5,a4,a5
    80200c28:	0007871b          	sext.w	a4,a5
    80200c2c:	fdc42783          	lw	a5,-36(s0)
    80200c30:	0007879b          	sext.w	a5,a5
    80200c34:	fae7cee3          	blt	a5,a4,80200bf0 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200c38:	fe842783          	lw	a5,-24(s0)
    80200c3c:	fff7879b          	addiw	a5,a5,-1
    80200c40:	fcf42c23          	sw	a5,-40(s0)
    80200c44:	03c0006f          	j	80200c80 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200c48:	fd842783          	lw	a5,-40(s0)
    80200c4c:	ff078793          	addi	a5,a5,-16
    80200c50:	008787b3          	add	a5,a5,s0
    80200c54:	fc87c783          	lbu	a5,-56(a5)
    80200c58:	0007871b          	sext.w	a4,a5
    80200c5c:	fa843783          	ld	a5,-88(s0)
    80200c60:	00070513          	mv	a0,a4
    80200c64:	000780e7          	jalr	a5
        ++written;
    80200c68:	fe442783          	lw	a5,-28(s0)
    80200c6c:	0017879b          	addiw	a5,a5,1
    80200c70:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200c74:	fd842783          	lw	a5,-40(s0)
    80200c78:	fff7879b          	addiw	a5,a5,-1
    80200c7c:	fcf42c23          	sw	a5,-40(s0)
    80200c80:	fd842783          	lw	a5,-40(s0)
    80200c84:	0007879b          	sext.w	a5,a5
    80200c88:	fc07d0e3          	bgez	a5,80200c48 <print_dec_int+0x2ac>
    }

    return written;
    80200c8c:	fe442783          	lw	a5,-28(s0)
}
    80200c90:	00078513          	mv	a0,a5
    80200c94:	06813083          	ld	ra,104(sp)
    80200c98:	06013403          	ld	s0,96(sp)
    80200c9c:	07010113          	addi	sp,sp,112
    80200ca0:	00008067          	ret

0000000080200ca4 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200ca4:	f4010113          	addi	sp,sp,-192
    80200ca8:	0a113c23          	sd	ra,184(sp)
    80200cac:	0a813823          	sd	s0,176(sp)
    80200cb0:	0c010413          	addi	s0,sp,192
    80200cb4:	f4a43c23          	sd	a0,-168(s0)
    80200cb8:	f4b43823          	sd	a1,-176(s0)
    80200cbc:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200cc0:	f8043023          	sd	zero,-128(s0)
    80200cc4:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200cc8:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200ccc:	7a40006f          	j	80201470 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200cd0:	f8044783          	lbu	a5,-128(s0)
    80200cd4:	72078e63          	beqz	a5,80201410 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200cd8:	f5043783          	ld	a5,-176(s0)
    80200cdc:	0007c783          	lbu	a5,0(a5)
    80200ce0:	00078713          	mv	a4,a5
    80200ce4:	02300793          	li	a5,35
    80200ce8:	00f71863          	bne	a4,a5,80200cf8 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200cec:	00100793          	li	a5,1
    80200cf0:	f8f40123          	sb	a5,-126(s0)
    80200cf4:	7700006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200cf8:	f5043783          	ld	a5,-176(s0)
    80200cfc:	0007c783          	lbu	a5,0(a5)
    80200d00:	00078713          	mv	a4,a5
    80200d04:	03000793          	li	a5,48
    80200d08:	00f71863          	bne	a4,a5,80200d18 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200d0c:	00100793          	li	a5,1
    80200d10:	f8f401a3          	sb	a5,-125(s0)
    80200d14:	7500006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200d18:	f5043783          	ld	a5,-176(s0)
    80200d1c:	0007c783          	lbu	a5,0(a5)
    80200d20:	00078713          	mv	a4,a5
    80200d24:	06c00793          	li	a5,108
    80200d28:	04f70063          	beq	a4,a5,80200d68 <vprintfmt+0xc4>
    80200d2c:	f5043783          	ld	a5,-176(s0)
    80200d30:	0007c783          	lbu	a5,0(a5)
    80200d34:	00078713          	mv	a4,a5
    80200d38:	07a00793          	li	a5,122
    80200d3c:	02f70663          	beq	a4,a5,80200d68 <vprintfmt+0xc4>
    80200d40:	f5043783          	ld	a5,-176(s0)
    80200d44:	0007c783          	lbu	a5,0(a5)
    80200d48:	00078713          	mv	a4,a5
    80200d4c:	07400793          	li	a5,116
    80200d50:	00f70c63          	beq	a4,a5,80200d68 <vprintfmt+0xc4>
    80200d54:	f5043783          	ld	a5,-176(s0)
    80200d58:	0007c783          	lbu	a5,0(a5)
    80200d5c:	00078713          	mv	a4,a5
    80200d60:	06a00793          	li	a5,106
    80200d64:	00f71863          	bne	a4,a5,80200d74 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200d68:	00100793          	li	a5,1
    80200d6c:	f8f400a3          	sb	a5,-127(s0)
    80200d70:	6f40006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200d74:	f5043783          	ld	a5,-176(s0)
    80200d78:	0007c783          	lbu	a5,0(a5)
    80200d7c:	00078713          	mv	a4,a5
    80200d80:	02b00793          	li	a5,43
    80200d84:	00f71863          	bne	a4,a5,80200d94 <vprintfmt+0xf0>
                flags.sign = true;
    80200d88:	00100793          	li	a5,1
    80200d8c:	f8f402a3          	sb	a5,-123(s0)
    80200d90:	6d40006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200d94:	f5043783          	ld	a5,-176(s0)
    80200d98:	0007c783          	lbu	a5,0(a5)
    80200d9c:	00078713          	mv	a4,a5
    80200da0:	02000793          	li	a5,32
    80200da4:	00f71863          	bne	a4,a5,80200db4 <vprintfmt+0x110>
                flags.spaceflag = true;
    80200da8:	00100793          	li	a5,1
    80200dac:	f8f40223          	sb	a5,-124(s0)
    80200db0:	6b40006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200db4:	f5043783          	ld	a5,-176(s0)
    80200db8:	0007c783          	lbu	a5,0(a5)
    80200dbc:	00078713          	mv	a4,a5
    80200dc0:	02a00793          	li	a5,42
    80200dc4:	00f71e63          	bne	a4,a5,80200de0 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200dc8:	f4843783          	ld	a5,-184(s0)
    80200dcc:	00878713          	addi	a4,a5,8
    80200dd0:	f4e43423          	sd	a4,-184(s0)
    80200dd4:	0007a783          	lw	a5,0(a5)
    80200dd8:	f8f42423          	sw	a5,-120(s0)
    80200ddc:	6880006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200de0:	f5043783          	ld	a5,-176(s0)
    80200de4:	0007c783          	lbu	a5,0(a5)
    80200de8:	00078713          	mv	a4,a5
    80200dec:	03000793          	li	a5,48
    80200df0:	04e7f663          	bgeu	a5,a4,80200e3c <vprintfmt+0x198>
    80200df4:	f5043783          	ld	a5,-176(s0)
    80200df8:	0007c783          	lbu	a5,0(a5)
    80200dfc:	00078713          	mv	a4,a5
    80200e00:	03900793          	li	a5,57
    80200e04:	02e7ec63          	bltu	a5,a4,80200e3c <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200e08:	f5043783          	ld	a5,-176(s0)
    80200e0c:	f5040713          	addi	a4,s0,-176
    80200e10:	00a00613          	li	a2,10
    80200e14:	00070593          	mv	a1,a4
    80200e18:	00078513          	mv	a0,a5
    80200e1c:	88dff0ef          	jal	ra,802006a8 <strtol>
    80200e20:	00050793          	mv	a5,a0
    80200e24:	0007879b          	sext.w	a5,a5
    80200e28:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200e2c:	f5043783          	ld	a5,-176(s0)
    80200e30:	fff78793          	addi	a5,a5,-1
    80200e34:	f4f43823          	sd	a5,-176(s0)
    80200e38:	62c0006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200e3c:	f5043783          	ld	a5,-176(s0)
    80200e40:	0007c783          	lbu	a5,0(a5)
    80200e44:	00078713          	mv	a4,a5
    80200e48:	02e00793          	li	a5,46
    80200e4c:	06f71863          	bne	a4,a5,80200ebc <vprintfmt+0x218>
                fmt++;
    80200e50:	f5043783          	ld	a5,-176(s0)
    80200e54:	00178793          	addi	a5,a5,1
    80200e58:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200e5c:	f5043783          	ld	a5,-176(s0)
    80200e60:	0007c783          	lbu	a5,0(a5)
    80200e64:	00078713          	mv	a4,a5
    80200e68:	02a00793          	li	a5,42
    80200e6c:	00f71e63          	bne	a4,a5,80200e88 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200e70:	f4843783          	ld	a5,-184(s0)
    80200e74:	00878713          	addi	a4,a5,8
    80200e78:	f4e43423          	sd	a4,-184(s0)
    80200e7c:	0007a783          	lw	a5,0(a5)
    80200e80:	f8f42623          	sw	a5,-116(s0)
    80200e84:	5e00006f          	j	80201464 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200e88:	f5043783          	ld	a5,-176(s0)
    80200e8c:	f5040713          	addi	a4,s0,-176
    80200e90:	00a00613          	li	a2,10
    80200e94:	00070593          	mv	a1,a4
    80200e98:	00078513          	mv	a0,a5
    80200e9c:	80dff0ef          	jal	ra,802006a8 <strtol>
    80200ea0:	00050793          	mv	a5,a0
    80200ea4:	0007879b          	sext.w	a5,a5
    80200ea8:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200eac:	f5043783          	ld	a5,-176(s0)
    80200eb0:	fff78793          	addi	a5,a5,-1
    80200eb4:	f4f43823          	sd	a5,-176(s0)
    80200eb8:	5ac0006f          	j	80201464 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200ebc:	f5043783          	ld	a5,-176(s0)
    80200ec0:	0007c783          	lbu	a5,0(a5)
    80200ec4:	00078713          	mv	a4,a5
    80200ec8:	07800793          	li	a5,120
    80200ecc:	02f70663          	beq	a4,a5,80200ef8 <vprintfmt+0x254>
    80200ed0:	f5043783          	ld	a5,-176(s0)
    80200ed4:	0007c783          	lbu	a5,0(a5)
    80200ed8:	00078713          	mv	a4,a5
    80200edc:	05800793          	li	a5,88
    80200ee0:	00f70c63          	beq	a4,a5,80200ef8 <vprintfmt+0x254>
    80200ee4:	f5043783          	ld	a5,-176(s0)
    80200ee8:	0007c783          	lbu	a5,0(a5)
    80200eec:	00078713          	mv	a4,a5
    80200ef0:	07000793          	li	a5,112
    80200ef4:	30f71263          	bne	a4,a5,802011f8 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200ef8:	f5043783          	ld	a5,-176(s0)
    80200efc:	0007c783          	lbu	a5,0(a5)
    80200f00:	00078713          	mv	a4,a5
    80200f04:	07000793          	li	a5,112
    80200f08:	00f70663          	beq	a4,a5,80200f14 <vprintfmt+0x270>
    80200f0c:	f8144783          	lbu	a5,-127(s0)
    80200f10:	00078663          	beqz	a5,80200f1c <vprintfmt+0x278>
    80200f14:	00100793          	li	a5,1
    80200f18:	0080006f          	j	80200f20 <vprintfmt+0x27c>
    80200f1c:	00000793          	li	a5,0
    80200f20:	faf403a3          	sb	a5,-89(s0)
    80200f24:	fa744783          	lbu	a5,-89(s0)
    80200f28:	0017f793          	andi	a5,a5,1
    80200f2c:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200f30:	fa744783          	lbu	a5,-89(s0)
    80200f34:	0ff7f793          	zext.b	a5,a5
    80200f38:	00078c63          	beqz	a5,80200f50 <vprintfmt+0x2ac>
    80200f3c:	f4843783          	ld	a5,-184(s0)
    80200f40:	00878713          	addi	a4,a5,8
    80200f44:	f4e43423          	sd	a4,-184(s0)
    80200f48:	0007b783          	ld	a5,0(a5)
    80200f4c:	01c0006f          	j	80200f68 <vprintfmt+0x2c4>
    80200f50:	f4843783          	ld	a5,-184(s0)
    80200f54:	00878713          	addi	a4,a5,8
    80200f58:	f4e43423          	sd	a4,-184(s0)
    80200f5c:	0007a783          	lw	a5,0(a5)
    80200f60:	02079793          	slli	a5,a5,0x20
    80200f64:	0207d793          	srli	a5,a5,0x20
    80200f68:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200f6c:	f8c42783          	lw	a5,-116(s0)
    80200f70:	02079463          	bnez	a5,80200f98 <vprintfmt+0x2f4>
    80200f74:	fe043783          	ld	a5,-32(s0)
    80200f78:	02079063          	bnez	a5,80200f98 <vprintfmt+0x2f4>
    80200f7c:	f5043783          	ld	a5,-176(s0)
    80200f80:	0007c783          	lbu	a5,0(a5)
    80200f84:	00078713          	mv	a4,a5
    80200f88:	07000793          	li	a5,112
    80200f8c:	00f70663          	beq	a4,a5,80200f98 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200f90:	f8040023          	sb	zero,-128(s0)
    80200f94:	4d00006f          	j	80201464 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200f98:	f5043783          	ld	a5,-176(s0)
    80200f9c:	0007c783          	lbu	a5,0(a5)
    80200fa0:	00078713          	mv	a4,a5
    80200fa4:	07000793          	li	a5,112
    80200fa8:	00f70a63          	beq	a4,a5,80200fbc <vprintfmt+0x318>
    80200fac:	f8244783          	lbu	a5,-126(s0)
    80200fb0:	00078a63          	beqz	a5,80200fc4 <vprintfmt+0x320>
    80200fb4:	fe043783          	ld	a5,-32(s0)
    80200fb8:	00078663          	beqz	a5,80200fc4 <vprintfmt+0x320>
    80200fbc:	00100793          	li	a5,1
    80200fc0:	0080006f          	j	80200fc8 <vprintfmt+0x324>
    80200fc4:	00000793          	li	a5,0
    80200fc8:	faf40323          	sb	a5,-90(s0)
    80200fcc:	fa644783          	lbu	a5,-90(s0)
    80200fd0:	0017f793          	andi	a5,a5,1
    80200fd4:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80200fd8:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80200fdc:	f5043783          	ld	a5,-176(s0)
    80200fe0:	0007c783          	lbu	a5,0(a5)
    80200fe4:	00078713          	mv	a4,a5
    80200fe8:	05800793          	li	a5,88
    80200fec:	00f71863          	bne	a4,a5,80200ffc <vprintfmt+0x358>
    80200ff0:	00001797          	auipc	a5,0x1
    80200ff4:	12878793          	addi	a5,a5,296 # 80202118 <upperxdigits.1>
    80200ff8:	00c0006f          	j	80201004 <vprintfmt+0x360>
    80200ffc:	00001797          	auipc	a5,0x1
    80201000:	13478793          	addi	a5,a5,308 # 80202130 <lowerxdigits.0>
    80201004:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201008:	fe043783          	ld	a5,-32(s0)
    8020100c:	00f7f793          	andi	a5,a5,15
    80201010:	f9843703          	ld	a4,-104(s0)
    80201014:	00f70733          	add	a4,a4,a5
    80201018:	fdc42783          	lw	a5,-36(s0)
    8020101c:	0017869b          	addiw	a3,a5,1
    80201020:	fcd42e23          	sw	a3,-36(s0)
    80201024:	00074703          	lbu	a4,0(a4)
    80201028:	ff078793          	addi	a5,a5,-16
    8020102c:	008787b3          	add	a5,a5,s0
    80201030:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80201034:	fe043783          	ld	a5,-32(s0)
    80201038:	0047d793          	srli	a5,a5,0x4
    8020103c:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201040:	fe043783          	ld	a5,-32(s0)
    80201044:	fc0792e3          	bnez	a5,80201008 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201048:	f8c42783          	lw	a5,-116(s0)
    8020104c:	00078713          	mv	a4,a5
    80201050:	fff00793          	li	a5,-1
    80201054:	02f71663          	bne	a4,a5,80201080 <vprintfmt+0x3dc>
    80201058:	f8344783          	lbu	a5,-125(s0)
    8020105c:	02078263          	beqz	a5,80201080 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201060:	f8842703          	lw	a4,-120(s0)
    80201064:	fa644783          	lbu	a5,-90(s0)
    80201068:	0007879b          	sext.w	a5,a5
    8020106c:	0017979b          	slliw	a5,a5,0x1
    80201070:	0007879b          	sext.w	a5,a5
    80201074:	40f707bb          	subw	a5,a4,a5
    80201078:	0007879b          	sext.w	a5,a5
    8020107c:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201080:	f8842703          	lw	a4,-120(s0)
    80201084:	fa644783          	lbu	a5,-90(s0)
    80201088:	0007879b          	sext.w	a5,a5
    8020108c:	0017979b          	slliw	a5,a5,0x1
    80201090:	0007879b          	sext.w	a5,a5
    80201094:	40f707bb          	subw	a5,a4,a5
    80201098:	0007871b          	sext.w	a4,a5
    8020109c:	fdc42783          	lw	a5,-36(s0)
    802010a0:	f8f42a23          	sw	a5,-108(s0)
    802010a4:	f8c42783          	lw	a5,-116(s0)
    802010a8:	f8f42823          	sw	a5,-112(s0)
    802010ac:	f9442783          	lw	a5,-108(s0)
    802010b0:	00078593          	mv	a1,a5
    802010b4:	f9042783          	lw	a5,-112(s0)
    802010b8:	00078613          	mv	a2,a5
    802010bc:	0006069b          	sext.w	a3,a2
    802010c0:	0005879b          	sext.w	a5,a1
    802010c4:	00f6d463          	bge	a3,a5,802010cc <vprintfmt+0x428>
    802010c8:	00058613          	mv	a2,a1
    802010cc:	0006079b          	sext.w	a5,a2
    802010d0:	40f707bb          	subw	a5,a4,a5
    802010d4:	fcf42c23          	sw	a5,-40(s0)
    802010d8:	0280006f          	j	80201100 <vprintfmt+0x45c>
                    putch(' ');
    802010dc:	f5843783          	ld	a5,-168(s0)
    802010e0:	02000513          	li	a0,32
    802010e4:	000780e7          	jalr	a5
                    ++written;
    802010e8:	fec42783          	lw	a5,-20(s0)
    802010ec:	0017879b          	addiw	a5,a5,1
    802010f0:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802010f4:	fd842783          	lw	a5,-40(s0)
    802010f8:	fff7879b          	addiw	a5,a5,-1
    802010fc:	fcf42c23          	sw	a5,-40(s0)
    80201100:	fd842783          	lw	a5,-40(s0)
    80201104:	0007879b          	sext.w	a5,a5
    80201108:	fcf04ae3          	bgtz	a5,802010dc <vprintfmt+0x438>
                }

                if (prefix) {
    8020110c:	fa644783          	lbu	a5,-90(s0)
    80201110:	0ff7f793          	zext.b	a5,a5
    80201114:	04078463          	beqz	a5,8020115c <vprintfmt+0x4b8>
                    putch('0');
    80201118:	f5843783          	ld	a5,-168(s0)
    8020111c:	03000513          	li	a0,48
    80201120:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201124:	f5043783          	ld	a5,-176(s0)
    80201128:	0007c783          	lbu	a5,0(a5)
    8020112c:	00078713          	mv	a4,a5
    80201130:	05800793          	li	a5,88
    80201134:	00f71663          	bne	a4,a5,80201140 <vprintfmt+0x49c>
    80201138:	05800793          	li	a5,88
    8020113c:	0080006f          	j	80201144 <vprintfmt+0x4a0>
    80201140:	07800793          	li	a5,120
    80201144:	f5843703          	ld	a4,-168(s0)
    80201148:	00078513          	mv	a0,a5
    8020114c:	000700e7          	jalr	a4
                    written += 2;
    80201150:	fec42783          	lw	a5,-20(s0)
    80201154:	0027879b          	addiw	a5,a5,2
    80201158:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    8020115c:	fdc42783          	lw	a5,-36(s0)
    80201160:	fcf42a23          	sw	a5,-44(s0)
    80201164:	0280006f          	j	8020118c <vprintfmt+0x4e8>
                    putch('0');
    80201168:	f5843783          	ld	a5,-168(s0)
    8020116c:	03000513          	li	a0,48
    80201170:	000780e7          	jalr	a5
                    ++written;
    80201174:	fec42783          	lw	a5,-20(s0)
    80201178:	0017879b          	addiw	a5,a5,1
    8020117c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201180:	fd442783          	lw	a5,-44(s0)
    80201184:	0017879b          	addiw	a5,a5,1
    80201188:	fcf42a23          	sw	a5,-44(s0)
    8020118c:	f8c42703          	lw	a4,-116(s0)
    80201190:	fd442783          	lw	a5,-44(s0)
    80201194:	0007879b          	sext.w	a5,a5
    80201198:	fce7c8e3          	blt	a5,a4,80201168 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    8020119c:	fdc42783          	lw	a5,-36(s0)
    802011a0:	fff7879b          	addiw	a5,a5,-1
    802011a4:	fcf42823          	sw	a5,-48(s0)
    802011a8:	03c0006f          	j	802011e4 <vprintfmt+0x540>
                    putch(buf[i]);
    802011ac:	fd042783          	lw	a5,-48(s0)
    802011b0:	ff078793          	addi	a5,a5,-16
    802011b4:	008787b3          	add	a5,a5,s0
    802011b8:	f807c783          	lbu	a5,-128(a5)
    802011bc:	0007871b          	sext.w	a4,a5
    802011c0:	f5843783          	ld	a5,-168(s0)
    802011c4:	00070513          	mv	a0,a4
    802011c8:	000780e7          	jalr	a5
                    ++written;
    802011cc:	fec42783          	lw	a5,-20(s0)
    802011d0:	0017879b          	addiw	a5,a5,1
    802011d4:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    802011d8:	fd042783          	lw	a5,-48(s0)
    802011dc:	fff7879b          	addiw	a5,a5,-1
    802011e0:	fcf42823          	sw	a5,-48(s0)
    802011e4:	fd042783          	lw	a5,-48(s0)
    802011e8:	0007879b          	sext.w	a5,a5
    802011ec:	fc07d0e3          	bgez	a5,802011ac <vprintfmt+0x508>
                }

                flags.in_format = false;
    802011f0:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802011f4:	2700006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802011f8:	f5043783          	ld	a5,-176(s0)
    802011fc:	0007c783          	lbu	a5,0(a5)
    80201200:	00078713          	mv	a4,a5
    80201204:	06400793          	li	a5,100
    80201208:	02f70663          	beq	a4,a5,80201234 <vprintfmt+0x590>
    8020120c:	f5043783          	ld	a5,-176(s0)
    80201210:	0007c783          	lbu	a5,0(a5)
    80201214:	00078713          	mv	a4,a5
    80201218:	06900793          	li	a5,105
    8020121c:	00f70c63          	beq	a4,a5,80201234 <vprintfmt+0x590>
    80201220:	f5043783          	ld	a5,-176(s0)
    80201224:	0007c783          	lbu	a5,0(a5)
    80201228:	00078713          	mv	a4,a5
    8020122c:	07500793          	li	a5,117
    80201230:	08f71063          	bne	a4,a5,802012b0 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201234:	f8144783          	lbu	a5,-127(s0)
    80201238:	00078c63          	beqz	a5,80201250 <vprintfmt+0x5ac>
    8020123c:	f4843783          	ld	a5,-184(s0)
    80201240:	00878713          	addi	a4,a5,8
    80201244:	f4e43423          	sd	a4,-184(s0)
    80201248:	0007b783          	ld	a5,0(a5)
    8020124c:	0140006f          	j	80201260 <vprintfmt+0x5bc>
    80201250:	f4843783          	ld	a5,-184(s0)
    80201254:	00878713          	addi	a4,a5,8
    80201258:	f4e43423          	sd	a4,-184(s0)
    8020125c:	0007a783          	lw	a5,0(a5)
    80201260:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201264:	fa843583          	ld	a1,-88(s0)
    80201268:	f5043783          	ld	a5,-176(s0)
    8020126c:	0007c783          	lbu	a5,0(a5)
    80201270:	0007871b          	sext.w	a4,a5
    80201274:	07500793          	li	a5,117
    80201278:	40f707b3          	sub	a5,a4,a5
    8020127c:	00f037b3          	snez	a5,a5
    80201280:	0ff7f793          	zext.b	a5,a5
    80201284:	f8040713          	addi	a4,s0,-128
    80201288:	00070693          	mv	a3,a4
    8020128c:	00078613          	mv	a2,a5
    80201290:	f5843503          	ld	a0,-168(s0)
    80201294:	f08ff0ef          	jal	ra,8020099c <print_dec_int>
    80201298:	00050793          	mv	a5,a0
    8020129c:	fec42703          	lw	a4,-20(s0)
    802012a0:	00f707bb          	addw	a5,a4,a5
    802012a4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802012a8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802012ac:	1b80006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    802012b0:	f5043783          	ld	a5,-176(s0)
    802012b4:	0007c783          	lbu	a5,0(a5)
    802012b8:	00078713          	mv	a4,a5
    802012bc:	06e00793          	li	a5,110
    802012c0:	04f71c63          	bne	a4,a5,80201318 <vprintfmt+0x674>
                if (flags.longflag) {
    802012c4:	f8144783          	lbu	a5,-127(s0)
    802012c8:	02078463          	beqz	a5,802012f0 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    802012cc:	f4843783          	ld	a5,-184(s0)
    802012d0:	00878713          	addi	a4,a5,8
    802012d4:	f4e43423          	sd	a4,-184(s0)
    802012d8:	0007b783          	ld	a5,0(a5)
    802012dc:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    802012e0:	fec42703          	lw	a4,-20(s0)
    802012e4:	fb043783          	ld	a5,-80(s0)
    802012e8:	00e7b023          	sd	a4,0(a5)
    802012ec:	0240006f          	j	80201310 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    802012f0:	f4843783          	ld	a5,-184(s0)
    802012f4:	00878713          	addi	a4,a5,8
    802012f8:	f4e43423          	sd	a4,-184(s0)
    802012fc:	0007b783          	ld	a5,0(a5)
    80201300:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201304:	fb843783          	ld	a5,-72(s0)
    80201308:	fec42703          	lw	a4,-20(s0)
    8020130c:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201310:	f8040023          	sb	zero,-128(s0)
    80201314:	1500006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201318:	f5043783          	ld	a5,-176(s0)
    8020131c:	0007c783          	lbu	a5,0(a5)
    80201320:	00078713          	mv	a4,a5
    80201324:	07300793          	li	a5,115
    80201328:	02f71e63          	bne	a4,a5,80201364 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    8020132c:	f4843783          	ld	a5,-184(s0)
    80201330:	00878713          	addi	a4,a5,8
    80201334:	f4e43423          	sd	a4,-184(s0)
    80201338:	0007b783          	ld	a5,0(a5)
    8020133c:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201340:	fc043583          	ld	a1,-64(s0)
    80201344:	f5843503          	ld	a0,-168(s0)
    80201348:	dccff0ef          	jal	ra,80200914 <puts_wo_nl>
    8020134c:	00050793          	mv	a5,a0
    80201350:	fec42703          	lw	a4,-20(s0)
    80201354:	00f707bb          	addw	a5,a4,a5
    80201358:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020135c:	f8040023          	sb	zero,-128(s0)
    80201360:	1040006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201364:	f5043783          	ld	a5,-176(s0)
    80201368:	0007c783          	lbu	a5,0(a5)
    8020136c:	00078713          	mv	a4,a5
    80201370:	06300793          	li	a5,99
    80201374:	02f71e63          	bne	a4,a5,802013b0 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201378:	f4843783          	ld	a5,-184(s0)
    8020137c:	00878713          	addi	a4,a5,8
    80201380:	f4e43423          	sd	a4,-184(s0)
    80201384:	0007a783          	lw	a5,0(a5)
    80201388:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    8020138c:	fcc42703          	lw	a4,-52(s0)
    80201390:	f5843783          	ld	a5,-168(s0)
    80201394:	00070513          	mv	a0,a4
    80201398:	000780e7          	jalr	a5
                ++written;
    8020139c:	fec42783          	lw	a5,-20(s0)
    802013a0:	0017879b          	addiw	a5,a5,1
    802013a4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013a8:	f8040023          	sb	zero,-128(s0)
    802013ac:	0b80006f          	j	80201464 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    802013b0:	f5043783          	ld	a5,-176(s0)
    802013b4:	0007c783          	lbu	a5,0(a5)
    802013b8:	00078713          	mv	a4,a5
    802013bc:	02500793          	li	a5,37
    802013c0:	02f71263          	bne	a4,a5,802013e4 <vprintfmt+0x740>
                putch('%');
    802013c4:	f5843783          	ld	a5,-168(s0)
    802013c8:	02500513          	li	a0,37
    802013cc:	000780e7          	jalr	a5
                ++written;
    802013d0:	fec42783          	lw	a5,-20(s0)
    802013d4:	0017879b          	addiw	a5,a5,1
    802013d8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013dc:	f8040023          	sb	zero,-128(s0)
    802013e0:	0840006f          	j	80201464 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    802013e4:	f5043783          	ld	a5,-176(s0)
    802013e8:	0007c783          	lbu	a5,0(a5)
    802013ec:	0007871b          	sext.w	a4,a5
    802013f0:	f5843783          	ld	a5,-168(s0)
    802013f4:	00070513          	mv	a0,a4
    802013f8:	000780e7          	jalr	a5
                ++written;
    802013fc:	fec42783          	lw	a5,-20(s0)
    80201400:	0017879b          	addiw	a5,a5,1
    80201404:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201408:	f8040023          	sb	zero,-128(s0)
    8020140c:	0580006f          	j	80201464 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201410:	f5043783          	ld	a5,-176(s0)
    80201414:	0007c783          	lbu	a5,0(a5)
    80201418:	00078713          	mv	a4,a5
    8020141c:	02500793          	li	a5,37
    80201420:	02f71063          	bne	a4,a5,80201440 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201424:	f8043023          	sd	zero,-128(s0)
    80201428:	f8043423          	sd	zero,-120(s0)
    8020142c:	00100793          	li	a5,1
    80201430:	f8f40023          	sb	a5,-128(s0)
    80201434:	fff00793          	li	a5,-1
    80201438:	f8f42623          	sw	a5,-116(s0)
    8020143c:	0280006f          	j	80201464 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201440:	f5043783          	ld	a5,-176(s0)
    80201444:	0007c783          	lbu	a5,0(a5)
    80201448:	0007871b          	sext.w	a4,a5
    8020144c:	f5843783          	ld	a5,-168(s0)
    80201450:	00070513          	mv	a0,a4
    80201454:	000780e7          	jalr	a5
            ++written;
    80201458:	fec42783          	lw	a5,-20(s0)
    8020145c:	0017879b          	addiw	a5,a5,1
    80201460:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201464:	f5043783          	ld	a5,-176(s0)
    80201468:	00178793          	addi	a5,a5,1
    8020146c:	f4f43823          	sd	a5,-176(s0)
    80201470:	f5043783          	ld	a5,-176(s0)
    80201474:	0007c783          	lbu	a5,0(a5)
    80201478:	84079ce3          	bnez	a5,80200cd0 <vprintfmt+0x2c>
        }
    }

    return written;
    8020147c:	fec42783          	lw	a5,-20(s0)
}
    80201480:	00078513          	mv	a0,a5
    80201484:	0b813083          	ld	ra,184(sp)
    80201488:	0b013403          	ld	s0,176(sp)
    8020148c:	0c010113          	addi	sp,sp,192
    80201490:	00008067          	ret

0000000080201494 <printk>:

int printk(const char* s, ...) {
    80201494:	f9010113          	addi	sp,sp,-112
    80201498:	02113423          	sd	ra,40(sp)
    8020149c:	02813023          	sd	s0,32(sp)
    802014a0:	03010413          	addi	s0,sp,48
    802014a4:	fca43c23          	sd	a0,-40(s0)
    802014a8:	00b43423          	sd	a1,8(s0)
    802014ac:	00c43823          	sd	a2,16(s0)
    802014b0:	00d43c23          	sd	a3,24(s0)
    802014b4:	02e43023          	sd	a4,32(s0)
    802014b8:	02f43423          	sd	a5,40(s0)
    802014bc:	03043823          	sd	a6,48(s0)
    802014c0:	03143c23          	sd	a7,56(s0)
    int res = 0;
    802014c4:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    802014c8:	04040793          	addi	a5,s0,64
    802014cc:	fcf43823          	sd	a5,-48(s0)
    802014d0:	fd043783          	ld	a5,-48(s0)
    802014d4:	fc878793          	addi	a5,a5,-56
    802014d8:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    802014dc:	fe043783          	ld	a5,-32(s0)
    802014e0:	00078613          	mv	a2,a5
    802014e4:	fd843583          	ld	a1,-40(s0)
    802014e8:	fffff517          	auipc	a0,0xfffff
    802014ec:	11850513          	addi	a0,a0,280 # 80200600 <putc>
    802014f0:	fb4ff0ef          	jal	ra,80200ca4 <vprintfmt>
    802014f4:	00050793          	mv	a5,a0
    802014f8:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    802014fc:	fec42783          	lw	a5,-20(s0)
}
    80201500:	00078513          	mv	a0,a5
    80201504:	02813083          	ld	ra,40(sp)
    80201508:	02013403          	ld	s0,32(sp)
    8020150c:	07010113          	addi	sp,sp,112
    80201510:	00008067          	ret
