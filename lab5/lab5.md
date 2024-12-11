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
            <td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;">Lab 5: RV64 缺页异常处理与 fork 机制</td>     </tr>
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

1. 在`user/Makefile`下进行修改。要注意是在`user`目录下进行修改，而不是根目录

   ```makefile
   TEST        = PFH1
   
   CFLAG		= ... -D$(TEST)
   ```

### 实现缺页异常处理

1. 在`defs.h`中加入以下内容

   ```c++
   #define VM_ANON 0x1
   #define VM_READ 0x2
   #define VM_WRITE 0x4
   #define VM_EXEC 0x8
   ```

2. 在`proc.h`中加入`vm_area_struct`和`mm_struct`的定义，并更新`task_struct`

3. 完成`find_vma`函数，实现对`vm_area_struct`的查找。我们根据传入的`addr`，遍历链表，查看`addr`是否落在某一块`vma`之中，若在则返回对应`vma`，否则返回`NULL`

   ```c++
   struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
     struct vm_area_struct *vma = mm->mmap;
     while (vma != NULL) {
       if (addr >= vma->vm_start && addr < vma->vm_end) {
         return vma;
       }
       vma = vma->vm_next;
     }
     return NULL;
   }
   ```

4. 完成`do_mmap`函数。这里我们需要根据`vm_area_struct`结构体的定义，对其赋值。完成赋值后，我们将其添加到链表之中。如果链表为空，那么我们直接将`mm->mmap`赋值为`new_vma`即可，否则我们将其遍历到末尾，并将`new_vma`连接到链表末尾。

   ```c++
   uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len,
                    uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
     struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
     new_vma->vm_start = addr;
     new_vma->vm_end = addr + len;
     new_vma->vm_flags = flags;
     new_vma->vm_pgoff = vm_pgoff;
     new_vma->vm_filesz = vm_filesz;
     new_vma->vm_next = NULL;
     new_vma->vm_prev = NULL;
     new_vma->vm_mm = mm;
     struct vm_area_struct *vma;
     for (vma = mm->mmap; vma && vma->vm_next; vma = vma->vm_next);
     if (vma) {
       vma->vm_next = new_vma;
       new_vma->vm_prev = vma;
     } else {
       mm->mmap = new_vma;
     }
   
     return addr;
   }
   ```

5. 修改`task_init`和`load_program`，因为这时我们在初始化阶段只需要建立一个VMA即可，其他操作在后面完成。这样，我们的`task_init`只需要在复制`swapper_pg_dir`后，调用`load_program`把elf的地址添加到vma链表中即可，同时调用结束后把用户栈对应地址添加到vma链表中即可。

   ```c++
   void load_program(struct task_struct *task) {
     ...
     for (int i = 0; i < ehdr->e_phnum; ++i) {
       Elf64_Phdr *phdr = phdrs + i;
       if (phdr->p_type == PT_LOAD) {
         uint64_t start_pg = phdr->p_vaddr;
         uint64_t pg_offset = phdr->p_vaddr & 0xfff;
         uint64_t size = phdr->p_memsz + pg_offset;
         uint64_t perm = ((phdr->p_flags & PF_X) << 3) |
                         ((phdr->p_flags & PF_W) << 1) |
                         ((phdr->p_flags & PF_R) >> 1);
         do_mmap(&task->mm, start_pg, phdr->p_memsz, phdr->p_offset,
                 phdr->p_filesz, perm);
         ...
       }
     }
     task->thread.sepc = (uint64_t)ehdr->e_entry;
   }
   void task_init() {
       ...
       memcpy((void *)task[i]->pgd, (void *)swapper_pg_dir, PGSIZE);
       // 将uapp所在的页面映射到每个进程的页表中
       load_program(task[i]);
       do_mmap(&task[i]->mm, USER_END - PGSIZE, PGSIZE, 0, PGSIZE,
               VM_READ | VM_WRITE | VM_ANON);
       // delete in lab5 for demand paging
       // 用户态栈
       // void *user_stack_page = kalloc();
       // if (!user_stack_page) {
       //   printk("kalloc failed\n");
       //   return;
       // }
       // create_mapping(task[i]->pgd, USER_END - PGSIZE,
       //                (uint64_t)user_stack_page - PA2VA_OFFSET, PGSIZE, 0x17);
       // end delete
     }
   
     printk("...task_init done!\n");
   }
   ```

   完成后我们运行就可以发现出现如下page fault，符合预期

   <div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20241204001656104.png" alt="image-20241204001656104" style="zoom: 80%;" /></div>

6. 实现`do_page_fault`函数及相关逻辑

   - 首先在`trap_handler`中添加判断`scause`若是page fault则调用此函数进行处理

     ```c++
     else if (scause == 0xc || scause == 0xd || scause == 0xf) {
           Log("[PID = %d PC = %lx] Valid page fault at [0x%lx] with cause %d",
               current->pid, regs->sepc, regs->stval, scause);
           do_page_fault(regs);
         }
     ```

   - 其次在`pt_regs`中添加`stval`以便后续调用，稍微修改`_traps`

     ```c++
     // proc.h
     struct pt_regs {
       uint64_t s[32];
       uint64_t sepc;
       uint64_t sstatus;
       uint64_t stval;
     };
     
     // entry.S
     _skip_init_traps:
         addi sp, sp, -280
         ...
         csrr t0, stval
         sd t0, 272(sp)
     
         ...
         ld t0, 272(sp)
         csrw stval, t0
         ...
         addi sp, sp, 280
     ```

   - 接下来我们首先通过`stval`获取出错的虚拟地址。之后我们在通过`find_vma`中寻找此虚拟地址，若不能找到输出对应错误。接下来，我们是否有合适的权限处理page fault，比如触发的是 instruction page fault 但 vma 权限不允许执行。处理好之后，我们分配一个新页。

     接下来我们判断`vma`，若当前为匿名空间，那么我们直接`create_mapping`映射`bad_address`所在页即可。否则，我们需要从ELF中读取数据，填充后再映射到用户空间。这里我们首先通过`PGROUNDDOWN`这个宏来判断bad_address是否在Segment的第一页或者最后一页。之后我们再分别计算`vm_start`在第一页的偏移量`begin_offset`以及该Segment在最后一页剩余的空间`end_remain`，因为我们需要通过这两个值计算需要映射的空间大小。

     如果bad_address同时在第一页和最后一页，即Segment只有一页，实际映射空间大小是一页的大小减去`begin_offset`和`end_remain`；若只在第一页，减去前者即可；若只在最后一页，减去后者即可；否则，正常映射一页即可。最后同样利用`create_mapping`进行映射。

     ```c++
     void do_page_fault(struct pt_regs *regs, uint64_t scause) {
       uint64_t bad_address = regs->stval;
       struct vm_area_struct *vma = find_vma(&current->mm, bad_address);
       if (!vma)
         Err("Fail to find vma when doing page fault at [0x%lx]\n", bad_address);
         
       if ((vma->vm_flags & VM_EXEC == 0) && scause == 0xc ||
           (vma->vm_flags & VM_READ == 0) && scause == 0xd ||
           (vma->vm_flags & VM_WRITE == 0) && scause == 0xf)
         Err("Catch wrong page fault at [0x%lx] with no permission, cause %lx\n",
             bad_address, scause);
         
       uint64_t page = (uint64_t)alloc_page();
       memset((void *)page, 0, PAGE_SIZE);
       if (!(vma->vm_flags & VM_ANON)) {
         uint64_t begin_offset = vma->vm_start & 0xfff;
         uint64_t end_remain = PGSIZE - (vma->vm_start + vma->vm_filesz) & 0xfff;
         uint64_t first_flag = 0, last_flag = 0;
         if (PGROUNDDOWN(bad_address) == PGROUNDDOWN(vma->vm_start)) first_flag = 1;
         if (PGROUNDDOWN(bad_address) ==
             PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1))
           last_flag = 1;
         if (first_flag && last_flag)
           memcpy((void *)(page + begin_offset),
                  (void *)((uint64_t)_sramdisk + begin_offset),
                  PGSIZE - begin_offset - end_remain);
         else if (first_flag)
           memcpy((void *)page + begin_offset,
                  (void *)((uint64_t)_sramdisk + begin_offset),
                  PGSIZE - begin_offset);
         else if (last_flag)
           memcpy((void *)page,
                  (void *)((uint64_t)_sramdisk + begin_offset +
                           PGROUNDDOWN(bad_address) - vma->vm_start),
                  PGSIZE - end_remain);
         else
           memcpy((void *)page,
                  (void *)((uint64_t)_sramdisk + begin_offset +
                           PGROUNDDOWN(bad_address) - vma->vm_start),
                  PGSIZE);
       }
       uint64_t perm = 0x11 | (vma->vm_flags & VM_EXEC) |
                       (vma->vm_flags & VM_WRITE) | (vma->vm_flags & VM_READ);
       create_mapping(current->pgd, PGROUNDDOWN(bad_address), page - PA2VA_OFFSET,
                      PGSIZE, perm);
     }
     ```

7. 测试缺页处理

   - `make run TEST=PFH1` 可以发现得到了和lab4中一样的结果。同时可以发现我们只在`set_up_final`函数中进行了三次映射。同时只有第一次进行每个进程才会触发page fault，

     <div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20241204003956068.png" alt="image-20241204003956068" style="zoom:67%;" /></div>

     <div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20241204004015883.png" alt="image-20241204004015883" style="zoom:75%;" /></div>

   - `make run TEST=PFH2` 可以发现映射的虚拟地址空间会缺少一页，符合预期。

     <div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20241204004343183.png" alt="image-20241204004343183" style="zoom:67%;" /></div>

### 实现fork系统调用

1. 修改`proc`相关代码，使其只初始化一个进程，其他进程保留为NULL等待fork创建。我们增加全局变量`nr_tasks`，并初始化为2，即一个idle线程加一个内核线程。在`task_init`和`schedule`函数中将所有`NR_TASKS`改成`nr_tasks`即可

2. 在`syscall.h`中添加`#define SYS_CLONE 220`。并在`sys_call`中增加对`SYS_CLONE`的判断

   ```c++
   void sys_call(struct pt_regs *regs) {
     //   printk("syscall %d\n", regs->s[17]);
     if (regs->s[17] == SYS_WRITE)
       sys_write(regs);
     else if (regs->s[17] == SYS_GETPID)
       sys_getpid(regs);
     else if (regs->s[17] == SYS_CLONE)
       do_fork(regs);
   }
   ```

3. 之后，我们逐步完成`do_fork`函数

   - 首先创建新`task_struct`变量并拷贝内核栈，设置对应值。我们首先将父进程所有信息复制到新进程上，也包括内核栈，因为内核栈和 `task_struct` 在同一个页的高低地址上。之后根据`nr_tasks`赋值`pid`，更新`task`数组，初始化`mm.mmap`为NULL。之后，我们将新进程的`thread.ra`设置为`_ret_from_fork`的地址，其中`_ret_from_fork`如下，使得子进程在离开函数后可以返回到`trap_handler`下一行，即会认为自己刚从trap中返回。之后，我们将`thread.sscratch`设置为当前`sccratch`的值，这是因为原本这其中就存着父进程用户栈指针的虚拟地址。

     在这之后，对于子进程，其`pt_regs`在`task_struct`中的偏移应该与父进程一致，这样我们就可以得到正确的`pt_regs`地址，而这个地址就是`thread.sp`的值。

     然后我们还要将子进程`pt_regs`的`s[10](a0)`设置为0，`sepc`加4，同时将`thread.sp`赋值给`s[2](sp)`

     ```c++
       struct task_struct *new_task = (struct task_struct *)kalloc();
       if (!new_task) {
         Err("kalloc new task failed");
       }
       memcpy((void *)new_task, (void *)current, PGSIZE);
       new_task->pid = nr_tasks;
       task[nr_tasks++] = new_task;
       new_task->state = TASK_RUNNING;
       new_task->thread.ra = (uint64_t)&__ret_from_fork;
       new_task->mm.mmap = NULL;
       new_task->thread.sscratch = csr_read(sscratch);
       struct pt_regs *child_regs =
           (struct pt_regs *)((uint64_t)new_task + (uint64_t)regs -
                              PGROUNDDOWN((uint64_t)regs));
       new_task->thread.sp = (uint64_t)child_regs;
       child_regs->s[10] = 0;
       child_regs->sepc += 4;
       child_regs->s[2] = new_task->thread.sp;
     ```

     ```assembly
     call trap_handler      
         .globl __ret_from_fork
     __ret_from_fork:
     ```

   - 之后我们创建子进程的页表。我们首先拷贝内核页表`swapper_pg_dir`。之后，我们遍历父进程(`current`)的vma。在遍历的第一步，我们先将父进程的每个vma添加到新进程的vma链表之中，这里的操作类似`do_mmap`中的操作。之后，我们按页访问每个vma对应的区域。对每一页，我们按我们在lab3中类似的方法walk页表，若遇到某一级页表Valid项为0，则说明该页未被映射，不需要继续后续处理。若存在对应的页表项，则复制此页表项内容并映射到新页表中。

     ```c++
     new_task->pgd = (uint64_t *)kalloc();
       if (!new_task->pgd) {
         Err("kalloc child pgd failed");
       }
       memcpy((void *)new_task->pgd, (void *)swapper_pg_dir, PGSIZE);
       struct vm_area_struct *vma = current->mm.mmap;
       while (vma) {
         struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
         if (!new_vma) {
           Err("kalloc new vma failed");
         }
         memcpy((void *)new_vma, (void *)vma, sizeof(struct vm_area_struct));
         new_vma->vm_prev = NULL;
         new_vma->vm_next = NULL;
         // 插入到子进程的 VMA 链表中
         if (new_task->mm.mmap == NULL) {
           new_task->mm.mmap = new_vma;
         } else {
           struct vm_area_struct *now = new_task->mm.mmap;
           while (now->vm_next) {
             now = now->vm_next;
           }
           now->vm_next = new_vma;
           new_vma->vm_prev = now;
         }
         // walk VMA 对应的每一页
         uint64_t addr = PGROUNDDOWN(vma->vm_start);
         while (addr < vma->vm_end) {
           uint64_t vpn2 = (addr >> 30) & 0x1ff;
           uint64_t vpn1 = (addr >> 21) & 0x1ff;
           uint64_t vpn0 = (addr >> 12) & 0x1ff;
           uint64_t *pte2 = &current->pgd[vpn2];
           if (!(*pte2 & PTE_V)) {
             addr += PGSIZE;
             continue;
           }
           uint64_t *pgtbl_lvl1;
           pgtbl_lvl1 = (uint64_t *)(((*pte2 >> 10) << 12) + PA2VA_OFFSET);
           uint64_t *pte1 = &pgtbl_lvl1[vpn1];
           if (!(*pte1 & PTE_V)) {
             addr += PGSIZE;
             continue;
           }
           uint64_t *pgtbl_lvl0;
           pgtbl_lvl0 = (uint64_t *)(((*pte1 >> 10) << 12) + PA2VA_OFFSET);
           uint64_t *pte = &pgtbl_lvl0[vpn0];
           if (*pte & PTE_V) {
             void *page = kalloc();
             if (!page) {
               Err("kalloc page failed");
             }
             memcpy(page, (void *)addr, PGSIZE);
             uint64_t perm = 0x11 | ((*pte) & 0xff);
             create_mapping(new_task->pgd, addr, (uint64_t)page - PA2VA_OFFSET,
                            PGSIZE, perm);
           }
           addr += PGSIZE;
         }
         vma = vma->vm_next;
       }
     ```

   - 最后，我们返回子进程的`pid`即可

     ```c++
     return new_task->pid;
     ```

4. 接下来，我们对fork进行测试

   - `make run TEST=FORK1` 观察输出可以发现，我们在每次fork的过程中，都对已有的页表项进行了复制和映射，同时每个进程的`global_variable`互不影响，并且page fault也都只对本进程中页表添加映射。

     ```c++
     ..setup_vm done!
     ...buddy_init done!
     ...mm_init done!
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80200000, 80204000) -> [ffffffe000200000, ffffffe000204000), perm: 0b
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80204000, 80205000) -> [ffffffe000204000, ffffffe000205000), perm: 03
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80205000, 88200000) -> [ffffffe000205000, ffffffe008200000), perm: 07
     ..setup_vm_final done
     ...task_init done!
     2024 ZJU Operating System
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [trap.c,34,trap_handler] [PID = 1 PC = 100e8] Valid page fault at [0x100e8] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d2000, 802d3000) -> [10000, 11000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 101ac] Valid page fault at [0x3ffffffff8] with cause 15
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d5000, 802d6000) -> [3ffffff000, 4000000000), perm: 17
     [vm.c,86,create_mapping] root: ffffffe0002d9000, [802db000, 802dc000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002d9000, [802df000, 802e0000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 2] forked from [PID = 1]
     
     [trap.c,34,trap_handler] [PID = 1 PC = 10228] Valid page fault at [0x122d0] with cause 13
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802e2000, 802e3000) -> [12000, 13000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 11114] Valid page fault at [0x11114] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802e3000, 802e4000) -> [11000, 12000), perm: 1f
     [U-PARENT] pid: 1 is running! global_variable: 0
     [U-PARENT] pid: 1 is running! global_variable: 1
     [U-PARENT] pid: 1 is running! global_variable: 2
     
     switch to [PID = 2 PRIORITY = 7 COUNTER = 7]
     [trap.c,34,trap_handler] [PID = 2 PC = 101e0] Valid page fault at [0x122d0] with cause 13
     [vm.c,86,create_mapping] root: ffffffe0002d9000, [802e4000, 802e5000) -> [12000, 13000), perm: 1f
     [trap.c,34,trap_handler] [PID = 2 PC = 11114] Valid page fault at [0x11114] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002d9000, [802e5000, 802e6000) -> [11000, 12000), perm: 1f
     [U-CHILD] pid: 2 is running! global_variable: 0
     [U-CHILD] pid: 2 is running! global_variable: 1
     [U-CHILD] pid: 2 is running! global_variable: 2
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     SET [PID = 2 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [U-PARENT] pid: 1 is running! global_variable: 3
     [U-PARENT] pid: 1 is running! global_variable: 4
     [U-PARENT] pid: 1 is running! global_variable: 5
     
     switch to [PID = 2 PRIORITY = 7 COUNTER = 7]
     [U-CHILD] pid: 2 is running! global_variable: 3
     [U-CHILD] pid: 2 is running! global_variable: 4
     [U-CHILD] pid: 2 is running! global_variable: 5
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     SET [PID = 2 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [U-PARENT] pid: 1 is running! global_variable: 6
     ```

   - `make run TEST=FORK2`在此测试中，父进程给`global_variable`自增了三次，并且为 `placeholder` 中赋值了字符串之后才 fork 出子进程。因此，我们在输出中可以看到`pid`为1的进程第一次执行时，`global_variable`从0开始增加，并且不输出字符串。在fork后的`pid`为2的进程第一次执行时，`global_variable`就从3开始增加，并且输出了对应字符串`ZJU OS Lab5`，并且后续和父进程互不影响。

     ```c++
     ..setup_vm done!
     ...buddy_init done!
     ...mm_init done!
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80200000, 80204000) -> [ffffffe000200000, ffffffe000204000), perm: 0b
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80204000, 80205000) -> [ffffffe000204000, ffffffe000205000), perm: 03
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80205000, 88200000) -> [ffffffe000205000, ffffffe008200000), perm: 07
     ..setup_vm_final done
     ...task_init done!
     2024 ZJU Operating System
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [trap.c,34,trap_handler] [PID = 1 PC = 100e8] Valid page fault at [0x100e8] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d2000, 802d3000) -> [10000, 11000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 101ac] Valid page fault at [0x3ffffffff8] with cause 15
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d5000, 802d6000) -> [3ffffff000, 4000000000), perm: 17
     [trap.c,34,trap_handler] [PID = 1 PC = 101d0] Valid page fault at [0x12518] with cause 13
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d8000, 802d9000) -> [12000, 13000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 112cc] Valid page fault at [0x112cc] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d9000, 802da000) -> [11000, 12000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 10434] Valid page fault at [0x14520] with cause 13
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802da000, 802db000) -> [14000, 15000), perm: 1f
     [U] pid: 1 is running! global_variable: 0
     [U] pid: 1 is running! global_variable: 1
     [U] pid: 1 is running! global_variable: 2
     [trap.c,34,trap_handler] [PID = 1 PC = 10228] Valid page fault at [0x13520] with cause 15
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802db000, 802dc000) -> [13000, 14000), perm: 1f
     [vm.c,86,create_mapping] root: ffffffe0002dd000, [802df000, 802e0000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002dd000, [802e2000, 802e3000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002dd000, [802e3000, 802e4000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002dd000, [802e4000, 802e5000) -> [13000, 14000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002dd000, [802e5000, 802e6000) -> [14000, 15000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002dd000, [802e7000, 802e8000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 2] forked from [PID = 1]
     
     [U-PARENT] pid: 1 is running! Message: ZJU OS Lab5
     [U-PARENT] pid: 1 is running! global_variable: 3
     [U-PARENT] pid: 1 is running! global_variable: 4
     [U-PARENT] pid: 1 is running! global_variable: 5
     
     switch to [PID = 2 PRIORITY = 7 COUNTER = 7]
     [U-CHILD] pid: 2 is running! Message: ZJU OS Lab5
     [U-CHILD] pid: 2 is running! global_variable: 3
     [U-CHILD] pid: 2 is running! global_variable: 4
     [U-CHILD] pid: 2 is running! global_variable: 5
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     SET [PID = 2 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [U-PARENT] pid: 1 is running! global_variable: 6
     [U-PARENT] pid: 1 is running! global_variable: 7
     [U-PARENT] pid: 1 is running! global_variable: 8
     
     switch to [PID = 2 PRIORITY = 7 COUNTER = 7]
     [U-CHILD] pid: 2 is running! global_variable: 6
     [U-CHILD] pid: 2 is running! global_variable: 7
     ```

   - `make run TEST=FORK3`

     - 首先测试程序如下，我们标记每次fork便于阐述

       ```c++
       #elif defined(FORK3)
       int global_variable = 0;
       
       int main() {
         printf("[U] pid: %ld is running! global_variable: %d\n", getpid(),
                global_variable++);
         fork(); // fork1
         fork(); // fork2
       
         printf("[U] pid: %ld is running! global_variable: %d\n", getpid(),
                global_variable++);
         fork(); // fork3
       
         while (1) {
           printf("[U] pid: %ld is running! global_variable: %d\n", getpid(),
                  global_variable++);
           wait(WAIT_TIME);
         }
       }
       ```

     - 接下来我们分析以下输出

       - 第一次`pid`为1的进程输出一次`global_variable`，并增加1。接下来马上就进行两次`fork`，分别对应`pid`为2和3的子进程，这两个进程的`global_variable`的值都为1。观察输出符合

         ```c++
         [syscall.c,122,do_fork] [PID = 2] forked from [PID = 1]
         [syscall.c,122,do_fork] [PID = 3] forked from [PID = 1]
         [U] pid: 2 is running! global_variable: 1
         [U] pid: 3 is running! global_variable: 1
         ```

       - 之后进程`pid=1`再输出一次`global_variable`，值为1，并增加1为2。接下来再进行`fork`，对应`pid`为4的子进程，`global_variable`初始值为2，符合预期。

         ```c++
         [syscall.c,122,do_fork] [PID = 4] forked from [PID = 1]
         [U] pid: 4 is running! global_variable: 2
         ```

       - 就此`pid=1`的进程完成所有`fork`，在运行完成进入`wait`后切换到`pid=2`的进程。前面提到过，此进程`global_variable`初始值为1。此进程从执行完`fork1`后一行开始执行，因此马上`fork`生成`pid=5`的进程，`global_variable`初始值同样也是1，因为没有自增。

         ```c++
         [syscall.c,122,do_fork] [PID = 5] forked from [PID = 2]
         [U] pid: 5 is running! global_variable: 1
         ```

       - 之后，`global_variable`自增一次变为2后，`fork`生成`pid=6`的进程，`global_variable`初始值为2，符合预期。

         ```c++
         [syscall.c,122,do_fork] [PID = 6] forked from [PID = 2]
         [U] pid: 6 is running! global_variable: 2
         ```

       - 之后`pid=3`的进程从执行完`fork2`后一行开始执行，自增1使得`global_variable`变成2后，`fork`生成`pid=7`的进程，`global_variable`为2，符合预期

         ```c++
         [syscall.c,122,do_fork] [PID = 7] forked from [PID = 3]
         [U] pid: 7 is running! global_variable: 2
         ```

       - 最后，`pid=5`的进程同样从执行完`fork2`后一行开始执行，自增1后同样`fork`生成`pid=8`的进程，`global_variable`为2，符合预期

         ```c++
         [syscall.c,122,do_fork] [PID = 8] forked from [PID = 5]
         [U] pid: 8 is running! global_variable: 2
         ```

       - 到此，所有进程程序都运行结束，均符合预期

     ```C++
     ..setup_vm done!
     ...buddy_init done!
     ...mm_init done!
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80200000, 80204000) -> [ffffffe000200000, ffffffe000204000), perm: 0b
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80204000, 80205000) -> [ffffffe000204000, ffffffe000205000), perm: 03
     [vm.c,86,create_mapping] root: ffffffe00020b000, [80205000, 88200000) -> [ffffffe000205000, ffffffe008200000), perm: 07
     ..setup_vm_final done
     ...task_init done!
     2024 ZJU Operating System
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [trap.c,34,trap_handler] [PID = 1 PC = 100e8] Valid page fault at [0x100e8] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d2000, 802d3000) -> [10000, 11000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 101ac] Valid page fault at [0x3ffffffff8] with cause 15
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d5000, 802d6000) -> [3ffffff000, 4000000000), perm: 17
     [trap.c,34,trap_handler] [PID = 1 PC = 101c8] Valid page fault at [0x122b0] with cause 13
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d8000, 802d9000) -> [12000, 13000), perm: 1f
     [trap.c,34,trap_handler] [PID = 1 PC = 11130] Valid page fault at [0x11130] with cause 12
     [vm.c,86,create_mapping] root: ffffffe0002cf000, [802d9000, 802da000) -> [11000, 12000), perm: 1f
     [U] pid: 1 is running! global_variable: 0
     [vm.c,86,create_mapping] root: ffffffe0002db000, [802dd000, 802de000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002db000, [802e0000, 802e1000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002db000, [802e1000, 802e2000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002db000, [802e3000, 802e4000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 2] forked from [PID = 1]
     
     [vm.c,86,create_mapping] root: ffffffe0002e7000, [802e9000, 802ea000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002e7000, [802ec000, 802ed000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002e7000, [802ed000, 802ee000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002e7000, [802ef000, 802f0000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 3] forked from [PID = 1]
     
     [U] pid: 1 is running! global_variable: 1
     [vm.c,86,create_mapping] root: ffffffe0002f3000, [802f5000, 802f6000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002f3000, [802f8000, 802f9000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002f3000, [802f9000, 802fa000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002f3000, [802fb000, 802fc000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 4] forked from [PID = 1]
     
     [U] pid: 1 is running! global_variable: 2
     [U] pid: 1 is running! global_variable: 3
     [U] pid: 1 is running! global_variable: 4
     
     switch to [PID = 2 PRIORITY = 7 COUNTER = 7]
     [vm.c,86,create_mapping] root: ffffffe0002ff000, [80301000, 80302000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002ff000, [80304000, 80305000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe0002ff000, [80305000, 80306000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe0002ff000, [80307000, 80308000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 5] forked from [PID = 2]
     
     [U] pid: 2 is running! global_variable: 1
     [vm.c,86,create_mapping] root: ffffffe00030b000, [8030d000, 8030e000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe00030b000, [80310000, 80311000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe00030b000, [80311000, 80312000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe00030b000, [80313000, 80314000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 6] forked from [PID = 2]
     
     [U] pid: 2 is running! global_variable: 2
     [U] pid: 2 is running! global_variable: 3
     [U] pid: 2 is running! global_variable: 4
     
     switch to [PID = 3 PRIORITY = 7 COUNTER = 7]
     [U] pid: 3 is running! global_variable: 1
     [vm.c,86,create_mapping] root: ffffffe000317000, [80319000, 8031a000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe000317000, [8031c000, 8031d000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe000317000, [8031d000, 8031e000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe000317000, [8031f000, 80320000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 7] forked from [PID = 3]
     
     [U] pid: 3 is running! global_variable: 2
     [U] pid: 3 is running! global_variable: 3
     [U] pid: 3 is running! global_variable: 4
     
     switch to [PID = 4 PRIORITY = 7 COUNTER = 7]
     [U] pid: 4 is running! global_variable: 2
     [U] pid: 4 is running! global_variable: 3
     [U] pid: 4 is running! global_variable: 4
     
     switch to [PID = 5 PRIORITY = 7 COUNTER = 7]
     [U] pid: 5 is running! global_variable: 1
     [vm.c,86,create_mapping] root: ffffffe000323000, [80325000, 80326000) -> [10000, 11000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe000323000, [80328000, 80329000) -> [11000, 12000), perm: 5f
     [vm.c,86,create_mapping] root: ffffffe000323000, [80329000, 8032a000) -> [12000, 13000), perm: df
     [vm.c,86,create_mapping] root: ffffffe000323000, [8032b000, 8032c000) -> [3ffffff000, 4000000000), perm: d7
     [syscall.c,122,do_fork] [PID = 8] forked from [PID = 5]
     
     [U] pid: 5 is running! global_variable: 2
     [U] pid: 5 is running! global_variable: 3
     [U] pid: 5 is running! global_variable: 4
     
     switch to [PID = 6 PRIORITY = 7 COUNTER = 7]
     [U] pid: 6 is running! global_variable: 2
     [U] pid: 6 is running! global_variable: 3
     [U] pid: 6 is running! global_variable: 4
     
     switch to [PID = 7 PRIORITY = 7 COUNTER = 7]
     [U] pid: 7 is running! global_variable: 2
     [U] pid: 7 is running! global_variable: 3
     [U] pid: 7 is running! global_variable: 4
     
     switch to [PID = 8 PRIORITY = 7 COUNTER = 7]
     [U] pid: 8 is running! global_variable: 2
     [U] pid: 8 is running! global_variable: 3
     [U] pid: 8 is running! global_variable: 4
     SET [PID = 1 PRIORITY = 7 COUNTER = 7]
     SET [PID = 2 PRIORITY = 7 COUNTER = 7]
     SET [PID = 3 PRIORITY = 7 COUNTER = 7]
     SET [PID = 4 PRIORITY = 7 COUNTER = 7]
     SET [PID = 5 PRIORITY = 7 COUNTER = 7]
     SET [PID = 6 PRIORITY = 7 COUNTER = 7]
     SET [PID = 7 PRIORITY = 7 COUNTER = 7]
     SET [PID = 8 PRIORITY = 7 COUNTER = 7]
     
     switch to [PID = 1 PRIORITY = 7 COUNTER = 7]
     [U] pid: 1 is running! global_variable: 5
     ```


### 写时复制COW

1. 首先按实验指导要求修改`mm.c`和`mm.h`

2. 接下来，我们首先新建`do_cow_fork`函数，此函数由`do_fork`函数直接复制而来，以避免在修改过程把原来的fork修改坏了。`do_cow_fork`与原先`do_fork`函数不同的是，当我们需要为子进程创建新页拷贝父进程内容时，我们只需要进行以下操作即可：首先将对应物理页的引用计数加一，之后将父进程对应页表项的`PTE_W`设置为0，并将修改后的权限设置给子进程。最后我们为子进程创建一个新的页表项，其映射关系和原先父进程完全相同。在完成所有修改后，我们利用`sfence.vma`进行页表刷新

   ```c++
   uint64_t do_cow_fork(struct pt_regs *regs) {
     ...
     struct vm_area_struct *vma = current->mm.mmap;
     while (vma) {
       ...
       uint64_t addr = PGROUNDDOWN(vma->vm_start);
       while (addr < vma->vm_end) {
         ...
         if (*pte & PTE_V) {
           uint64_t pa = (*pte >> 10) << 12;
           get_page((void *)(pa + PA2VA_OFFSET));
           *pte &= ~PTE_W;
           uint64_t perm = ((*pte) & 0xff) & (~PTE_W);
           create_mapping(new_task->pgd, addr, pa, PGSIZE, perm);
           Log(GREEN "Copy on write at [0x%lx]" CLEAR, addr);
         }
         addr += PGSIZE;
       }
       vma = vma->vm_next;
     }
     asm volatile("sfence.vma zero, zero");
     ...
   }
   
   ```

3. 之后，我们修改`do_page_fault`函数，在获取`vma`并判断是否有正确处理权限后加入对COW的判断和处理。首先我们判断该缺页异常是否由写操作触发，并且`vma`有对应写权限，如果满足说明该页有可能是需要进行COW处理的。接下来，我们walk页表，如果该地址建立了映射并且对应`pte`的`PTE_W`位是0，那么我们就可以判断这是一个COW的页面，进行COW的处理。处理过程也比较简单，我们首先获取对应物理页的引用次数，如果引用次数是1，那么为了简化操作我们直接将`PTE_W`位置为1即可。如果大于1，那么我们首先将原页面引用次数减1，之后创建一个新页，复制原页面内容后，将`PTE_W`设置为1后重新建立一个映射。

   ```c++
   void do_page_fault(struct pt_regs *regs, uint64_t scause) {
     ...
     // COW
     if ((vma->vm_flags & VM_WRITE == 0x4) && scause == 0xf) {
       Log(GREEN "may be cow" CLEAR);
       // get pte
       uint64_t vpn2 = (bad_address >> 30) & 0x1ff;
       uint64_t vpn1 = (bad_address >> 21) & 0x1ff;
       uint64_t vpn0 = (bad_address >> 12) & 0x1ff;
       uint64_t *pte2 = &current->pgd[vpn2];
       if (*pte2 & PTE_V) {
         uint64_t *pgtbl_lvl1;
         pgtbl_lvl1 = (uint64_t *)(((*pte2 >> 10) << 12) + PA2VA_OFFSET);
         uint64_t *pte1 = &pgtbl_lvl1[vpn1];
         if (*pte1 & PTE_V) {
           uint64_t *pgtbl_lvl0;
           pgtbl_lvl0 = (uint64_t *)(((*pte1 >> 10) << 12) + PA2VA_OFFSET);
           uint64_t *pte = &pgtbl_lvl0[vpn0];
           if ((*pte & PTE_V) && (*pte & ~PTE_W)) {  // 确认是COW
             uint64_t pa = ((*pte >> 10) << 12);
             uint64_t refcnt = get_page_refcnt((void *)(pa + PA2VA_OFFSET));
             Log(GREEN "Copy on write at [0x%lx] with refcnt: %d\n" CLEAR,
                 bad_address, refcnt);
             if (refcnt > 1) {
               put_page((void *)(pa + PA2VA_OFFSET));
               void *new_page = kalloc();
               memcpy(new_page, (void *)PGROUNDDOWN(bad_address), PGSIZE);
               uint64_t new_pa = ((uint64_t)new_page - PA2VA_OFFSET);
               create_mapping(current->pgd, bad_address, new_pa, PGSIZE, ((*pte) & 0xff) | PTE_W);
             } else {
               // 引用计数为 1，直接设置可写权限
               *pte |= PTE_W;
             }
             asm volatile("sfence.vma zero, zero");
             return;
           }
         }
       }
     }
     ...
   }
   ```

4. 修改完成后，我们即可以正常运行各项测试，以下只放出`make run TEST=FORK3`的截图，观察到引用次数的变化符合我们的预期。

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/d65d8d513c707bafbf2ec258b82a0a11.png" alt="img" style="zoom:67%;" /></div>

<div align="center">    <img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/5bed1eaf9a0fdd52ad4e47775fd0a1d0.png" alt="img" style="zoom:67%;" /> </div>

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/e57e002a1e489f7da9431d6dfb2ea459.png" alt="img" style="zoom:67%;" /></div>

## 二、实验心得

本次实验逻辑相对比较清晰，但是一旦函数中某一处地址设置错误，就很容易出现找不到对应`vma`的错误。在写COW的过程中，对整个框架的理解也更加清晰，但也发生了一些和上次实验很像的小错误，比如把`vma->vm_flags & VM_WRITE == 0x4`写成了`vma->vm_flags & VM_WRITE == 0x1`，导致需要进行COW相关处理的页面并没有进行正常的处理，导致错误。另外在COW过程中输出相关信息是很重要的，因为即使我们没有正确的减少原页面的引用次数，但我们仍然可以正常的运行程序，因此我们需要输出引用次数的信息来帮助我们判断。

## 三、思考题

1. 由于完成了COW机制，因此省略思考题1-4
5. 画图分析 `make run TEST=FORK3` 的进程 fork 过程，并呈现出各个进程的 `global_variable` 应该从几开始输出，再与你的输出进行对比验证。

<div align="center"><img src="https://pixe1ran9e.oss-cn-hangzhou.aliyuncs.com/image-20241205191724900.png" alt="image-20241205191724900" style="zoom:50%;" /></div>

- 上图与输出一致，同时已在输出部分分析过
