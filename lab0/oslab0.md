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
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">Lab 0: GDB & QEMU 调试 64 位 RISC-V LINUX</td>     </tr>
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

<font face="strong">

## 一、实验过程与步骤

1. 实验环境搭建

- 首先`sudo apt update`以更新环境内的软件包列表
- 之后运行`sudo apt install  gcc-riscv64-linux-gnu`和` sudo apt install  autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev git`以安装编译内核所需要的交叉编译工具链和用于构建程序的软件包

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/4.1.1.png" style="zoom:50%;" /></div>

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/4.1.2.png" style="zoom:50%;" /></div>

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/4.1.3.png" style="zoom:50%;" /></div>

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/4.1.4.png" alt="4.1.4" style="zoom:50%;" /></div>

- 运行`sudo apt install qemu-system-misc`以安装qemu

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/4.1.5.png" alt="4.1.5" style="zoom: 50%;" /></div>

- 运行`sudo apt install gdb-multiarch`以安装gdb进行调试工作

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/4.1.6.png" alt="4.1.6" style="zoom:50%;" /></div>

2. 获取 Linux 源码和已经编译好的文件系统

- 为了正常编译Linux内核，我们需要在linux内用wget获取最新Linux源码，同时不能放置在`/mnt`目录，此处放置在`/usr`目录，运行`sudo wget https://git.kernel.org/torvalds/t/linux-6.11-rc7.tar.gz`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911163112109.png" alt="image-20240911163112109" style="zoom:50%;" /></div>

- 之后解压文件`sudo tar -xzvf linux-6.11-rc7.tar.gz`，这里由于速度太快没截到图
- git clone实验指导仓库，之后观察到在`lab0`目录下有`rootfs.img`镜像

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911210540372.png" alt="image-20240911210540372"  /></div>

3. 编译Linux内核

- 使用默认配置(`defconfig`)

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911165500044.png" alt="image-20240911165500044" style="zoom:50%;" /></div>

- 为避免内存耗尽，同时避免过高并行度导致编译出错，因此使用8线程编译，`make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j8`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911165931153.png" alt="image-20240911165931153" style="zoom:50%;" /></div>

4. 使用QEMU运行内核

- 运行下图命令以运行内核，注意修改镜像文件的路径

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911173255860.png" alt="image-20240911173255860" style="zoom:50%;" /></div>

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911174447323.png" alt="image-20240911174447323" style="zoom:50%;" /></div>

5. 使用 GDB 对内核进行调试

- 这里需要打开两个terminal，一个使用QEMU启动Linux，另一个使用GDB与QEMU远程通信
- 首先打开一个terminal运行QEMU，注意与上一步不同的是，需要在命令最后加上`-S -s`，其中`-S`表示QEMU在启动后需要等待GDB连接，而不是立刻开始执行CPU，`-s`是`-gdb tcp::1234`的简写，告诉QEMU在tcp端口1234上启动一个GDB服务器。因此运行后不会立即产生任何输出

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911191335104.png" alt="image-20240911191335104" style="zoom:50%;" /></div>

- 之后开启另一个terminal，先输入`gdb-multiarch /usr/linux-6.11-rc7/vmlinux`启动gdb，之后利用gdb进行连接qemu，设置断点等操作，之后继续执行，最后退出gdb

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240911210841392.png" alt="image-20240911210841392" style="zoom:50%;" /></div>

6. 接下来，对一个具体的C语言程序利用gdb进行调试，练习gdb各项基本指令

- 首先编写一个有嵌套调用的程序，这里简单以一个计算斐波那契数列的函数作为例子

```c
#include <stdio.h>

int fn(int n) {
  if (n == 1 || n == 2) return 1;
  return fn(n - 1) + fn(n - 2);
}

int main() {
  int num, sum;

  printf("Input: ");
  scanf("%d", &num);

  sum = fn(num);

  printf("Sum: %d\n", sum);

  return 0;
}

```

- 之后运行`gcc -g test.c -o test`对此程序进行编译
- 运行`gdb test`进入调试
- 首先`layout asm`查看汇编代码

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916191901034.png" alt="image-20240916191901034" style="zoom:50%;" /></div>

- 之后`start`开始运行程序，将会停止在`main`函数开头

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916192212310.png" alt="image-20240916192212310" style="zoom:50%;" /></div>

- `b fn`在`fn`函数入口设立断点

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916192317037.png" alt="image-20240916192317037" style="zoom: 80%;" /></div>

- `c`(continue)执行到程序第一次遇到`fn`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916192540152.png" alt="image-20240916192540152" style="zoom:50%;" /></div>

- `display n`查看`n`值

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916192740252.png" alt="image-20240916192740252" style="zoom: 80%;" /></div>

- 之后我们可以通过反复`c`，嵌套调用`fn`函数，可以观察到`n`的值在不断变化

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916193202061.png" alt="image-20240916193202061" style="zoom: 80%;" /></div>

- 这时可以运行`bt`查看函数的调用的栈帧和层级关系

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916193430256.png" alt="image-20240916193430256" style="zoom:80%;" /></div>

- 最后运行`finish`，可以执行到函数末尾，而`n=6`的末尾自然就是执行`n=5`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240916193552104.png" alt="image-20240916193552104" style="zoom:67%;" /></div>

## 二、实验心得体会

这个实验总体还是比较顺利的，主要的问题就是一开始没有注意常见问题中提到的不能在`/mnt`目录下进行Linux源码的编译，导致编译了一两节课还没编译完，后面才发现此问题。这个实验做下来，整体对wsl的文件结构更熟悉了一些，同时也更熟悉了gdb的基本使用。

## 三、思考题

1. 为了后续操作，首先写一个简单的`.c`文件，主要内容是一个简单的从1到10的循环，并输出对应数字

```c
#include <stdio.h>

int main() {
    int i;
    for (i = 1; i <= 10; i++)  printf("%d\n", i);
    return 0;
}
```

2. 之后使用`riscv64-linux-gnu-gcc`编译此文件，之后利用`riscv64-linux-gnu-objdump`反编译前一步得到的编译产物并将输出重定向到`new.txt`文件中。其中`riscv64-linux-gnu-gcc`将C语言编译生成适用于RISC-V64位架构并在Linux上运行的可执行文件，`>`表示重定向

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/d42ebb364e8fcaadded1b48c242f531f.png" alt="img" style="zoom: 80%;" /></div>

3. 之后我们可以打开`new.txt`查看汇编代码，可以观察到以下汇编代码完成了循环条件的判断和`printf`

```assembly
 678:	fec42783          	lw	a5,-20(s0)
 67c:	85be                	mv	a1,a5
 67e:	00000517          	auipc	a0,0x0
 682:	03a50513          	addi	a0,a0,58 # 6b8 <_IO_stdin_used+0x8>
 686:	f1bff0ef          	jal	ra,5a0 <printf@plt>
 68a:	fec42783          	lw	a5,-20(s0)
 68e:	2785                	addiw	a5,a5,1
 690:	fef42623          	sw	a5,-20(s0)
 694:	fec42783          	lw	a5,-20(s0)
 698:	0007871b          	sext.w	a4,a5
 69c:	47a9                	li	a5,10
 69e:	fce7dde3          	bge	a5,a4,678 <main+0x10>
```

4. 接下来进行Linux调试，首先需要按实验步骤5打开两个terminal，将gdb与qemu连接，之后运行下述指令

- 运行`layout asm`显示汇编代码

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/5914683131464446690bbd3cd786a55a.png" alt="img" style="zoom:50%;" /></div>

- 在 `0x80000000` 处下断点并查看所有已下的断点，发现成功设置断点

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/73edfa0a37af4829fe0bb24dc63c358d.png" alt="img" style="zoom:87%;" /></div>

- 在 `0x80200000` 处下断点后清除`0x80000000` 处的断点，发现成功删除

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/5df4dc90f0db48ac9cdae4ca83137932.png" alt="img" style="zoom:80%;" /></div>

- 继续运行直到触发 `0x80200000` 处的断点，并单步调试一次。发现成功在断点处停止，同时单步调试成功

<div align="center">
<img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/09e326aa73627d6917b41fce5945ca02.png" alt="img" style="zoom:80%;" /></div>
- 


- 最后`quit`退出qemu

5. 使用 `make` 工具清除 Linux 的构建产物，我们进入`linux-6.11-rc7`目录，运行`make clean`

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20240912120934665.png" alt="image-20240912120934665" style="zoom:80%;" /></div>

6. `vmlinux`和`image`的联系和区别

- 区别：
  - `vmlinux`(其中`vm`指的是`virtual memory`，Linux支持虚拟内存)是编译Linux内核得到的最原始的内核文件，是`elf`格式(Executable and Linkable Format)的文件，未经压缩，文件比较大，多存放在PC上。`vmlinux`主要用于加载和运行Linux内核。计算机启动时，Boot Loader会加载`vmlinux`文件，首先将其复制到系统内存中，之后开始执行代码。`vmlinux`包含了Linux的所有代码和数据结构，还包含调试符号等信息(如函数名称、变量名称等)
  - `image`是Linux内核镜像文件，但仅包含可执行的二进制数据
- 联系：用户对Linux内核源码进行编译，会先生成`vmlinux`，之后由于此文件过大，要经过`objcopy`处理成只包含二进制数据的内核代码，去除掉不需要的文件信息，即`image`
