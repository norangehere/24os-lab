<div class="cover" style="page-break-after:always;width:100%;height:100%;border:none;margin: 0 auto;text-align:center;">
    <div style="width:60%;margin: 0 auto;height:0;padding-bottom:10%;">
        </br>
        <img src="https://raw.githubusercontent.com/Keldos-Li/pictures/main/typora-latex-theme/ZJU-name.svg" alt="校名" style="width:100%;"/>
    </div>
    </br></br></br></br></br>
    <div style="width:60%;margin: 0 auto;height:0;padding-bottom:40%;">
        <img src="https://raw.githubusercontent.com/Keldos-Li/pictures/main/typora-latex-theme/ZJU-logo.svg" alt="校徽" style="width:100%;"/>
    </div>
    </br></br></br></br></br></br></br></br>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-size:14px; margin: 0 auto;">
    <tbody style="font-size:12pt;">
        <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">课程名称</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;"> 操作系统原理与实践</td>     </tr>
        <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">题　　目</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">Lab 1: RV64 内核引导与时钟中断处理</td>     </tr>
        <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">授课教师</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">申文博</td>     </tr>
         <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">助　　教</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">王鹤翔、陈淦豪、许昊瑞</td>     </tr>
        <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">姓　　名</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">潘潇然</td>     </tr>
        <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">学　　号</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">3220106049</td>     </tr>
         <tr style="font-weight:normal;"> 
            <td style="width:20%;text-align:right;">地　　点</td>
            <td style="width:2%">：</td> 
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">32舍367</td>     </tr>
</tbody>              
</table></div>



## 一、实验过程与步骤

### RV64内核引导

1. 完善Makefile脚本，补充`lib/Makefile`。这里我们直接使用`init`目录下的Makefile。接下来将对Makefile的内容做出解释

- ` $(wildcard *.c)`：获取当前目录下所有`.c`文件
- `$(sort ...)`：对传入文件列表按字母序排列，并去除重复项。因此第一行获取当前目录下所有`.c`文件并排序
- `$(patsubst %.c,%.o,$(C_SRC))`：将上述的`.c`文件名转成`.o`文件名，即我们需要生成的目标
- `${GCC}`：以下内容在根目录的Makefile可以找到对应定义，指代`riscv64-linux-gnu-gcc`
- `CFLAG = ${CF} ${INCLUDE}`
  - 其中`INCLUDE = -I $(shell pwd)/include -I $(shell pwd)/arch/riscv/include`，将当前目录下两个指定路径的文件作为头文件
  - `CF = -march=$(ISA) -mabi=$(ABI) -mcmodel=medany -fno-builtin -ffunction-sections -fdata-sections -nostartfiles -nostdlib -nostdinc -static -lgcc -Wl,--nmagic -Wl,--gc-sections -g `，包含了一系列编译选项，包括指定目标架构，指定应用二进制接口，禁用内置函数，不使用标准启动文件、标准库、头文件路径，使用静态链接，生成调试信息等等

综上，以上Makefile获取当前目录所有`.c`文件进行编译，因此在后续过程中即使增删文件，也不需要对Makefile进行修改

```makefile
C_SRC       = $(sort $(wildcard *.c))
OBJ		    = $(patsubst %.c,%.o,$(C_SRC))

all:$(OBJ)
	
%.o:%.c
	${GCC} ${CFLAG} -c $<
clean:
	$(shell rm *.o 2>/dev/null)
```

2. 编写`head.S`

- 将`.space`设为4096，即4KB
- 之后将栈指针指向`boot_stack_top`，并跳转到`start_kernel`

```assembly
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    
    la a0, boot_stack_top  
    mv sp, a0    
    jal start_kernel             

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top:
```

3. 补充`sbi.c`,在此部分补充完成了`sbi_ecall`, `sbi_set_timer`, `sbi_debug_console_write_byte`, `sbi_system_reset`这四个函数

- `sbi_ecall`：这里使用内联汇编，依次存储`eid`, `fid`, `arg[0~5]`到`a0~a7`，之后调用`ecall`进入M模式，让OpenSBI完成相关操作。之后从`a0`, `a1`取出`error code`和`value`作为函数的返回结果
  - 其中`%0`表示输入输出操作数部分的第1个，从输出开始计算，其余同理
- 其他函数：直接根据不同的Extension ID、Function ID和输入调用`sbi_ecall`即可

```c
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
```

4. 修改`defs`，参考`csr_write`的宏定义对`csr_read`进行宏定义

```c
#define csr_read(csr)                                        \
  ({                                                         \
    uint64_t __v;                                            \
    asm volatile("csrr %0, " #csr : "=r"(__v) : : "memory"); \
    __v;                                                     \
  })
```

5. 运行`make`，发现根目录下成功生成了`vmlinux`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240925200313490.png" alt="image-20240925200313490" style="zoom: 67%;" /></div>

6. 运行`make run`，正确启动并显示了`2024 ZJU operating system`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240925223144525.png" alt="image-20240925223144525" style="zoom:67%;" /><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240925223153063.png" alt="image-20240925223153063" style="zoom: 67%;" /></div>

### RV64 时钟中断处理

1. 修改 `vmlinux.lds` 以及 `head.S`，这一部分文档中已经提供了修改内容，不再赘述
2. 开启trap处理

- 首先利用`la`指令将`_traps`所表示的地址写入`a0`，之后利用csr指令`csrw`将`a0`的值写入`stvec`
- 之后我们要设置`sie`寄存器的`STIE`位为1，查询可知对应`sie[5]`，因此对应十六进制为`0x20`，因此我们先利用`csrr`指令将`sie`值取出，同时将`a0`通过`ori`指令设置为`0x20`，使用位运算可以提高运算效率，最后再将`a0`存回`sie`
- 设置第一次时钟中断，这里我们调用`sbi_set_timer`完成。即首先利用`rdtime`获取当前时间，之后加上1秒钟(由于QEMU时钟频率是10MHz，因此1秒钟相当于10000000个时钟周期)。之后将`a6`和`a7`设置为`sbi_set_timer`对应的Function ID和Extension ID，最后调用`ecall`就相当于调用`sbi_set_timer`
- 之后，类似第二步，查询可知`SIE`对应`sstatus[1]`，对应`0x2`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240925233544997.png" alt="image-20240925233544997" style="zoom: 80%;" /><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240925233637217.png" alt="image-20240925233637217" style="zoom:67%;" /></div>

```assembly
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
```

3. 实现上下文切换

- 首先将31个寄存器(`x0`不需要保存)和`sepc`保存到栈上，这里我通过`csrr`指令将`scause`和`sepc`存储到`a0`和`a1`，因此我先存储`a0`和`a1`原本的值，再获取这两个CSR寄存器的值。值得注意的是，由于是64位，因此每个寄存器大小8字节
- 接下来调用`trap_handler`函数
- 接下来从栈中读取31个寄存器和`sepc`的值，这里我同样先将`sepc`取出再取出`a1`，同时需要注意的是，由于`x2`即为`sp`，因此需要最后取出
- 最后调用`sret`从trap中返回，注意我们这里是Supervisor Mode，不能使用`mret`

```assembly
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
```

4. 实现trap处理函数

- `scause`最高位若为1则表示位interrupt，因此`scause`输入与`flag`进行与运算后若不为0，则说明为interrupt
- supervisor timer interrupt的exception code为5，因此将`scause`与`~flag`进行与运算就可以将最高位的1变成0，之后再和`0x5`进行比较，若相同则说明是timer interrupt，输出`[S] Supervisor Mode Timer Interrupt`
- 若不为timer interrupt则输出`[S] Supervisor Mode Other Interrupt`，并输出`scause`和`sepc`
- 若不为interrupt则输出`[S] Supervisor Mode Exception`，并输出`scause`和`sepc`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926001959314.png" alt="image-20240926001959314" style="zoom: 80%;" /></div>

```c
#include "printk.h"
#include "stdint.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
  // 通过 `scause` 判断 trap 类型
  // 如果是 interrupt 判断是否是 timer interrupt
  // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()`设置下一次时钟中断 
  // `clock_set_next_event()` 见 4.3.4 节 
  // 其他 interrupt /exception 可以直接忽略，推荐打印出来供以后调试
  uint64_t flag = 0x8000000000000000;  // 第一位是1
  uint64_t exception_code = 0x5;       // exception code for timer interrupt
  if (scause & flag)                   // if interrupt
    if ((scause & ~flag) == exception_code) {  // if timer interrupt
      printk("[S] Supervisor Mode Timer Interrupt\n");
      clock_set_next_event();
    } else
      printk("[S] Supervisor Mode Other Interrupt (scause: %lx, sepc: %lx).\n", scause, sepc);
  else
    printk("[S] Supervisor Mode Exception (scause: %lx, sepc: %lx).\n", scause, sepc);
}
```

5. 实现时钟中断相关函数

- `get_cycles`直接调用`rdtime`当前`cycle`数即可
- `clock_set_next_event`同样和之前在开启trap处理中进行类似的操作，将Function ID，Extension ID和`stime_value`设置好后`ecall`即可

```c
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
  // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime
  // 寄存器）的值并返回
  uint64_t cycles;
  // 使用 rdtime 获取 time 寄存器中的值
  __asm__ volatile("rdtime %0" : "=r"(cycles));
  return cycles;
}

void clock_set_next_event() {
  // 下一次时钟中断的时间点
  uint64_t next = get_cycles() + TIMECLOCK;

  // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
  __asm__ volatile(
      "la a6, 0x0\n"
      "la a7, 0x54494d45\n"
      "mv a0, %0\n"
      "ecall\n"
      :
      : "r"(next)
      : "a0", "a7");
}
```

6. 修改test函数成文档中的即可
7. 正如之前在Makefile部分提到的，此处Makefile不需进行任何修改
8. 编译测试：依次运行`make`和`make run`后出现以下输出

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926003708240.png" alt="image-20240926003708240" style="zoom: 67%;" /></div>

## 二、实验心得与体会

感觉这次实验接受的新知识还是比较多的，学习了内联汇编、时钟中断等，也复习了之前的Makefile以及计组的汇编，总体来讲收获很大。整个过程其实最不适应的就是从计组的32位到现在的64位，导致一开始栈的大小设置错误。然后一开始对不同mode的理解也出了问题，导致使用了`mret`命令产生了bug。

## 三、思考题

1. 请总结一下 RISC-V 的 calling convention，并解释 Caller/ Callee Saved Register 有什么区别？

- calling convention
  - 将函数参数存储到函数能访问的对应位置(`a0-a7, fa0-fa7`)
  - 利用`jal`指令跳转到函数开始位置
  - 获取函数需要的局部存储资源，按需保存寄存器
  - 运行函数中的指令
  - 将返回值存储到调用者能够访问到的位置，恢复寄存器，释放局部存储资源
  - 使用`ret`指令返回调用函数的位置
- Caller/ Callee Saved Register之间的区别在于当寄存器在函数中被修改时，如何保存该寄存器的值。我们假设函数F1调用函数F2。
  - Caller Saved Register是调用者保存寄存器，指的是函数在调用另一个函数之前需要保存的寄存器，如函数F1在调用函数F2之前先保存寄存器的值，再在函数F2调用完毕后恢复寄存器的值，如`t0-t6, a0-a7`
  - Callee Saved Register是被调用者保存寄存器，指的是被调用的函数在使用这些寄存器之前，必须保存它们的当前值，并在函数返回前恢复，如函数F2在使用对应寄存器前要先保存该寄存器值，并在函数F2返回前恢复值，如`s0-s11`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926141216044.png" alt="image-20240926141216044" style="zoom:50%;" /></div>

2. 编译之后，通过System.map查看vmlinux.lds中自定义符号的值并截图

- 编译后产生以下System.map，可以观察到我们的自定义符号，如`boot_stack`, `boot_stack_top`, `sbi_ecall`等等

```assembly
0000000080200000 t $x
0000000080200054 t $x
0000000080200170 t $x
0000000080200198 t $x
00000000802001f0 t $x
00000000802002c4 t $x
0000000080200350 t $x
00000000802003e0 t $x
000000008020047c t $x
0000000080200524 t $x
0000000080200568 t $x
00000000802005b8 t $x
0000000080200600 t $x
0000000080200660 t $x
00000000802008cc t $x
0000000080200954 t $x
0000000080200c5c t $x
000000008020144c t $x
0000000080200000 A BASE_ADDR
0000000080203000 D TIMECLOCK
0000000080203008 d _GLOBAL_OFFSET_TABLE_
0000000080205000 B _ebss
0000000080203008 D _edata
0000000080205000 B _ekernel
0000000080202129 R _erodata
00000000802014cc T _etext
0000000080204000 B _sbss
0000000080203000 D _sdata
0000000080200000 T _skernel
0000000080202000 R _srodata
0000000080200000 T _start
0000000080200000 T _stext
0000000080200054 T _traps
0000000080204000 B boot_stack
0000000080205000 B boot_stack_top
0000000080200198 T clock_set_next_event
0000000080200170 T get_cycles
0000000080200600 T isspace
0000000080202118 r lowerxdigits.0
0000000080200954 t print_dec_int
000000008020144c T printk
00000000802005b8 T putc
00000000802008cc t puts_wo_nl
0000000080200350 T sbi_debug_console_write_byte
00000000802001f0 T sbi_ecall
00000000802002c4 T sbi_set_timer
00000000802003e0 T sbi_system_reset
0000000080200524 T start_kernel
0000000080200660 T strtol
0000000080200568 T test
000000008020047c T trap_handler
0000000080202100 r upperxdigits.1
0000000080200c5c T vprintfmt
```

3. 用`csr_read`宏读取`sstatus`寄存器的值，对照RISC-V手册解释其含义并截图

- 我们在`test.c`中加入以下代码，重新`make`后`make run`，即可得到`sstatus value: 8000000200006002`

```c
...
#define csr_read(csr)                             \
  ({                                              \
    unsigned long __tmp;                          \
    __asm__ volatile("csrr %0, " #csr : "=r"(__tmp)); \
    __tmp;                                        \
  })
void test() {
  ...
  unsigned long sstatus_value = csr_read(sstatus);
  printk("sstatus value: %lx\n", sstatus_value);
  ...
}
```

- 对照手册可以发现以下信息
  - `SPP`位为0，说明trap来自user mode
  - `SIE`位为1，即supervisor mode下的全局中断使能位，即hart于user mode和supervisor mode运行时都打开中断全局
  - `SPIE`位为0，SPIE位记录的是在进入S-Mode之前S-Mode中断是否开启。进入trap时，系统会自动将SPIE位设置为SIE位，SIE设置为0；执行`sret`后，SPIE的值会重新放置到SIE位上来恢复原先的值，并且将SPIE的值置为1。

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240925233637217.png" alt="image-20240925233637217" style="zoom:67%;" /></div>

4. 用`csr_write`宏向`sscratch`寄存器写入数据，并验证是否写入成功并截图

- 对`test.c`添加如下内容，写入学号后八位

```c
...
#define csr_read(csr)                                 \
  ({                                                  \
    unsigned long __tmp;                              \
    __asm__ volatile("csrr %0, " #csr : "=r"(__tmp)); \
    __tmp;                                            \
  })

#define csr_write(csr, value) \
  __asm__ volatile("csrw " #csr ", %0" : : "r"(value))
    
void test() {
  ...
  unsigned long write_value = 0x20106049;
  csr_write(sscratch, write_value);
  unsigned long read_value = csr_read(sscratch);
  printk("write value: %lx\n", write_value);
  printk("sscratch value: %lx\n", read_value);
  ...
}
```

- 运行后发现成功写入

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926152602603.png" alt="image-20240926152602603" style="zoom:50%;" /></div>

5. 详细描述你可以通过什么步骤来得到 `arch/arm64/kernel/sys.i`，给出过程以及截图

- 首先安装`gcc-aarch64-linux-gnu`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926153641000.png" alt="image-20240926153641000" style="zoom:50%;" /></div>

- 之后在Linux内核根目录修改make的`defconfig`为`arm64`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926153758279.png" alt="image-20240926153758279" style="zoom:50%;" /></div>

- 之后编译`arch/arm64/kernel/sys.c`为`sys.i`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926153857651.png" alt="image-20240926153857651" style="zoom:50%;" /></div>

- 之后我们切换到对应目录可以观察到有对应文件

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240926153944669.png" alt="image-20240926153944669" style="zoom:50%;" /></div>

6. 寻找Linux v6.0中 `ARM32` `RV32` `RV64` `x86_64` 架构的系统调用表

- 这里由于我安装的是Linux6.11-rc7，因此以下系统调用表都来自此版本
- `ARM32`：切换到文件夹`/usr/linux-6.11-rc7/arch/arm/tools`，打开文件`syscall.tbl`，可以观察到系统调用表

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929213430267.png" alt="image-20240929213430267" style="zoom:67%;" /></div>

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929214001896.png" alt="image-20240929214001896" style="zoom: 80%;" /></div>

- `RV32`：系统调用表文件`sys_call_table.c`在目录`arch/riscv/kernel`下。这里首先需要把默认编译设置更改为32位，通过命令`make ARCH=riscvCROSS COMPILE=riscv64-linux-gnu-rv32 defconfig`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929215821151.png" alt="image-20240929215821151" style="zoom: 67%;" /></div>

之后编译`sys_call_table.c`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929215847140.png" alt="image-20240929215847140" style="zoom:67%;" /></div>

之后使用Vim查看并搜索关键词`sys_call_table`，可以找到对应的内容

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929215918979.png" alt="image-20240929215918979" style="zoom: 80%;" /></div>

- `RV64`：同样地，我们首先恢复默认配置

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929220041887.png" alt="image-20240929220041887" style="zoom: 80%;" /></div>

之后编译`sys_call_table.c`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929220135039.png" alt="image-20240929220135039" style="zoom:67%;" /></div>

用Vim查看并搜索`sys_call_table`，可以观察到对应内容

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929221408158.png" alt="image-20240929221408158" style="zoom: 80%;" /></div>

- `x86-64`：系统调用表在`arch/x86/entry/syscalls/syscall_64.tbl`，打开即可查看

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240929221825280.png" alt="image-20240929221825280" style="zoom: 67%;" /></div>

7. 阐述什么是ELF文件？尝试使用readelf和objdump来查看ELF文件，并给出解释和截图。运行一个ELF文件，然后通过`cat /proc/PID/maps`来给出其内存布局并截图

- ELF（Executable and Linkable Format）文件是一种用于存储可执行文件、目标代码和共享库的文件格式，由Header, Program Header Table和Section Header Table等几部分构成，其中Header中的Magic代表文件格式。ELF文件可以被操作系统直接执行，包含了程序运行所需的所有信息，如代码、数据和动态链接信息。ELF文件常用于Unix及Unix-like操作系统中。
- 接下来我们查看`test.o`相关信息，`readelf -a test.o`，Header中的Magic ` 7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00`即为标识文件格式的部分，同时我们可以看到Header还包括了Class, Data, OS/ABI, Machine等标识了文件基本信息的内容。同时Section Header列出了文件每个节的详细信息，包括编号、名称、类型、地址、偏移量、大小等信息。同时我们可以看到此`.o`文件无Program Header。

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240927005702504.png" alt="image-20240927005702504" style="zoom: 67%;" /><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240927010855042.png" alt="image-20240927010855042" style="zoom: 67%;" /></div>

- 接下来我们利用`objdump`查看此文件相关信息。首先可以看到此文件是适用于 64 位小端RISC-V架构的ELF文件，文件的标志位位于`0x00000011`，起始地址为`0x0`；其次我们看到`.text`段的反汇编，每行包括了指令的起始位置，指令的机器码，以及对应的汇编指令；接下来，`riscv64-linux-gnu-objdump -h test.o`返回了文件各个段的详细信息，包括对齐要求，文件偏移量，虚拟内存地址以及段特性等等；最后，`riscv64-linux-gnu-objdump -t test.o`可以查看文件符号表的信息，包括`.text`, `.data`, `.bss`, `.rodata`等符号，同时`l`表示这些符号仅在本文件中可见，`F`表示这是一个函数符号。

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240927095717932.png" alt="image-20240927095717932" style="zoom:50%;" /><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240927095731769.png" alt="image-20240927095731769" style="zoom:50%;" /><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240927095749053.png" style="zoom:50%;" /><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240927095928472.png" style="zoom:50%;" /></div>

- 最后我们对整个工程执行`make run`，即运行`vmlinux`。之后开启另一个终端，输入`echo $$`，输出进程号`71918`。之后再`cat /proc/71918/maps`即可得到内存布局。我们可以观察到内存布局最上方是关于zsh本身二进制文件的映射，之后内容则显示了其他内容。

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20241006161941958.png" alt="image-20241006161941958" style="zoom:67%;" /></div>

8. 解释运行`make run`后OpenSBI输出中的`MIDELEG` 和 `MEDELEG` 值的含义。

```bash
OpenSBI v1.5.1
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

...
Boot HART MIDELEG         : 0x0000000000000222
Boot HART MEDELEG         : 0x000000000000b109
```

- `MIDELEG`指的是machine interrupt delegation register，即机器中断委托寄存器；`MEDELEG`指的是machine exception delegation register，即机器异常委托寄存器。这两个寄存器可以通过置位将S或U态的trap转交给S态的trap处理程序
- 其中`MIDELEG`寄存器的值的含义与`mip`寄存器的一致，值`0x222`即`0010 0010 0010`表示将1,5,9位设为1
  - 1表示`SSIP`，将软件中断委托给S模式
  - 5表示`STIP`，将时钟中断委托给S模式
  - 9表示`SEIP`，将外部中断委托给S模式


<div align="center"><img src="https://i-blog.csdnimg.cn/blog_migrate/a5468056503da68d66d687f6c3387bce.png" alt="img" style="zoom:50%;" /></div>

- `MEDELEG`寄存器每一位的含义如下表。则值`0xb109`即`1011 0001 0000 1001`表示将0,3,8,12,13,15位设为1，分别表示：
  - 0表示委托指令访问未对齐异常
  - 3表示委托断点异常
  - 8表示委托来自U-Mode的环境调用
  - 12表示委托Instruction Page Fault
  - 13表示委托Load Page Fault
  - 15表示委托Store/AMO Page Fault异常


<div align="center"><img src="https://i-blog.csdnimg.cn/blog_migrate/c6bc33e4f08f204dcb5e0421af584d46.png" alt="img" style="zoom: 80%;" /></div>

