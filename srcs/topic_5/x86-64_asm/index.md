# x86-64 指令

```{toctree}
:hidden:

data_move
arithmetic_and_logic
control
```

x86-64 汇编指令类型主要包含三类：

- 在内存和寄存器之间转移数据：
  - 从内存到寄存器称为**加载**（load），例如 `%reg = Mem[address]`
  - 从寄存器到内存称为**存储**（store），例如 `Mem[address] = %reg`
- 对寄存器或内存上的数据进行算术或逻辑运算
- 循环与控制：选择下一条需要执行的指令
  - 无状态跳转
  - 条件分支

## 认识硬件：寄存器文件

内存模型是学习 C 语言的核心，寄存器则是理解汇编语言的核心。相比内存，寄存器能够提供**更快**的数据访问。

寄存器文件是 CPU 内部的硬件，数量和类型由指令集定义。x86-64 架构包含 **16 个**通用寄存器，可以存储 **64 位的值**。每个寄存器都有固定的名称和不同的用途，并以 `%` 开头。CPU 工作过程中包含大量的数据移动和计算，在此过程中，寄存器用作**临时存放**区域，通常用于存储函数的参数、返回值等。

下表列出了 16 个 64 位寄存器的名称和用途。由于历史原因，每个寄存器还有一些其他的别名，从左到右依次是 32 位、16 位、8 位等。


| 寄存器 | 常规用法                        | 低 32 位 | 低 16 位 | 低 8 位 |
| ------ | ------------------------------- | -------- | -------- | ------- |
| %rax   | Return value, callee-owned      | %eax     | %ax      | %al     |
| %rdi   | 1st argument, callee-owned      | %edi     | %di      | %dil    |
| %rsi   | 2nd argument, callee-owned      | %esi     | %si      | %sil    |
| %rdx   | 3rd argument, callee-owned      | %edx     | %dx      | %dl     |
| %rcx   | 4th argument, callee-owned      | %ecx     | %cx      | %cl     |
| %r8    | 5th argument, callee-owned      | %r8d     | %r8w     | %r8b    |
| %r9    | 6th argument, callee-owned      | %r9d     | %r9w     | %r9b    |
| %r10   | Scratch/temporary, callee-owned | %r10d    | %r10w    | %r10b   |
| %r11   | Scratch/temporary, callee-owned | %r11d    | %r11w    | %r11b   |
| %rsp   | Stack pointer, caller-owned     | %esp     | %sp      | %spl    |
| %rbx   | Local variable, caller-owned    | %ebx     | %bx      | %bl     |
| %rbp   | Local variable, caller-owned    | %ebp     | %bp      | %bpl    |
| %r12   | Local variable, caller-owned    | %r12d    | %r12w    | %r12b   |
| %r13   | Local variable, caller-owned    | %r13d    | %r13w    | %r13b   |
| %r14   | Local variable, caller-owned    | %r14d    | %r14w    | %r14b   |
| %r15   | Local variable, caller-owned    | %r15d    | %r15w    | %r15b   |
