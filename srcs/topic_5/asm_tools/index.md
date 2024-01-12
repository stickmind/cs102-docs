# 汇编工具

GDB 是逆向工程不可或缺的工具，熟练使用 GDB 命令也是下一次作业必备的技能。

## 学习目标

- 使用 `objdump` 进行反汇编
- 使用 `gdb` 追踪汇编指令

## objdump 反汇编

作为编译过程的一部分，汇编器（assembler）接收汇编代码并将其编码为机器指令形式。反汇编（disassembly）是一个相反的过程，将机器指令转换回便于阅读的汇编指令。`objdump` 就是这样的一个工具，它可以从目标文件（包含机器指令）中挖掘出各种信息，但更常见的用途是用作反汇编程序。一起来尝试一下吧！

- 调用 `objdump -d` 命令可以从目标文件中提取信息，并输出机器指令序列以及等效的汇编指令。从目标文件中提取出的指令称为“死亡列表”（deadlist），这里的“死亡”（dead）形象地描述了这个过程不是针对执行时“活动”（live）的代码进行研究的。使用 `make` 构建 `code.c` 程序，然后使用 `objdump -d code` 获取一份“死亡列表”。
- 服务器提供了一个自定义命令 `countops`，可以统计给定目标文件中最常用的汇编指令。尝试执行 `countops code`，该操作将按操作码统计指令，并报告最多的前 10 个指令。再尝试下 `countops /usr/bin/gcc` 或其他可执行程序。汇编指令的组合会因程序的不同而有较大差异吗？

```{admonition} 提示
:class: hint

可以使用 `objdump -d code > myfile.txt` 命令，保存输出结果。

汇编中的所有文字值都是十六进制的，这在阅读汇编代码时需要注意。
```

## GDB 汇编调试

下面介绍一些用于在汇编级别进行调试的 `gdb` 命令。

### 显示汇编指令

不带参数执行命令 `disassemble` 将打印当前正在执行的函数的反汇编指令。也可以提供可选参数，例如函数名称或代码地址。

```c
(gdb) disassemble myfn
Dump of assembler code for function myfn:
   0x000000000040051b <+0>: movl   $0x1,-0x20(%rsp)
   0x0000000000400523 <+8>: movl   $0x2,-0x1c(%rsp)
...
```

最左列中的十六进制数字是该指令在**内存中的地址**，尖括号中的值是该指令**相对于函数开头的偏移量**。

### 设置断点

你可以指定地址 `b *address` 或函数 `b *myfn+8` 的偏移量，在特定的汇编指令处设置断点。

```c
(gdb) b *0x400570      break at specified address
(gdb) b *myfn+8        break at instruction 8 bytes into myfn()
```

请注意，后者表示断点位置设置在 `main` 函数偏移量为 8 的指令处，如下所示：

```c
(gdb) disassemble myfn
Dump of assembler code for function myfn:
   0x000000000040051b <+0>: movl   $0x1,-0x20(%rsp)
=> 0x0000000000400523 <+8>: movl   $0x2,-0x1c(%rsp)
```

如果你不使用 `*` 前缀设置函数断点，则 `gdb` 会将其解释为函数名称，而不是特定的汇编指令的地址，所以要特别注意！

### 单步指令执行

命令 `stepi` 和 `nexti` 允许你单步执行汇编指令，类比源代码级的 `step` 和`next` 命令，可以缩写为 `si` 和 `ni`。

```c
(gdb) stepi            executes next single instruction
(gdb) nexti            executes next instruction (step over fn calls)
```

### 查看寄存器状态

命令 `info reg` 将打印所有整数寄存器。你可以按名称打印或设置寄存器的值。在 `gdb` 中，寄存器名称以 `$` 为前缀，而不是通常的 `%`。

```c
(gdb) info reg
rax            0x4005c1 4195777
rbx            0x0  0
....
(gdb) p $rax            show current value in %rax register
(gdb) set $rax = 9      change current value in %rax register
```

### 文本用户界面

命令 `tui`（文本用户界面）可以将调试界面分成多个窗口，以便同时查看 C 源代码、汇编指令以及当前寄存器的状态。命令 `layout <argument>` 也可以启动 `tui` 模式。参数可以指定为 `src`、`asm`、`regs`、`split` 或 `next`。

```c
(gdb) layout split
```

`tui` 模式非常适合跟踪代码的执行过程，在调试时，可以及时观察代码/寄存器的状态。有时 `tui` 界面可能会显示乱码，此时可以使用命令 `refresh` 尝试恢复，或者使用快捷键 `Ctrl-L`。如果无法恢复，尝试 `Ctrl-X A` 退出 `tui` 模式，返回到普通的界面。

### 检查栈帧

以下是之前实验、作业和课程中介绍过的一些命令，一起复习一下：

- 使用 `backtrace` 显示从当前函数到 `main` 的所有栈帧。使用参数 `N` 时，`backtrace N` 仅显示 `N` 个最内部的帧，而 `backtrace -N` 仅显示 `N` 个最外部的帧。
- `up`、`down` 和 `frame n` 命令允许你更改选定的帧。这些命令不会更改程序执行的状态（执行仍保持并停止在最顶层帧中的位置），但它们允许你从另一个栈帧检查当前运行时状态。例如，更改为 `main` 栈帧允许打印仅在该范围内可见的变量/参数。
- `info frame` 命令可以打印有关当前栈帧的一些信息。`info args` 和 `info locals` 分别提供有关参数和局部变量的信息。
- 你可以使用 `x` 命令操作 `$rsp`，来查看栈上的数据（请注意，`g` 表示一个“字”，即 8 个字节，`x` 表示“十六进制显示”）

```
(gdb) x/4gx $rsp   // 4 quadwords, in hex, read from top of stack
```

### 自动显示并打印寄存器值

`info reg` 命令显示所有整数寄存器的当前状态。使用类似 `p $rax` 打印单个寄存器值。在 GDB 中，对寄存器的访问是通过 `$name` 格式实现的，而不是课程中讲解的 `%name`。

寄存器被视为无类型的 8 字节值，当你要求 GDB 打印它时，它会显示十进制整数或十六进制地址。你可以通过在打印命令中添加 `/[format]` 或使用 C 类型转换来指定如何解释该值，例如：

```
(gdb) p $rax
$1 = 4196128
(gdb) p/t $rax
$2 = 10000000000011100100000
(gdb) p (char*)$rax
$3 = 0x400720 "Hello, world!\n"
```

`display` 命令可以方便地设置一个表达式，可以在单步执行时重复计算和打印结果。例如，尝试以下命令：

```
(gdb) display/2gx $rsp     // 2 quadwords, in hex, read from stack top
(gdb) display/3i $rip      // next 3 assembly instructions to execute
```

键入不带参数的 `display` 可以列出当前设置的所有要显示的表达式，`undisplay X` 可以取消显示某个表达式 `X`。灵活地使用 `display` 命令可以实现类似 `tui` 界面类似的效果，并且可以乱码的情况。

### 设置条件断点

可以将断点设置为仅在代码中的某些条件成立时触发。例如，假设你的代码中有以下循环：

```{code-block} c
:lineno-start: 1
for (int i = 0; i < count; i++) {
   ...
}
```

如果你想在循环内单步执行代码，那么可能要执行许多次循环条件才能到达要检查的位置。但是，GDB 允许你添加一个可选条件（与 C 语法相同），来指定断点何时停止：

```c
(gdb) break 2 if i == count - 1
```

格式为 `[BREAKPOINT] if [CONDITION]`。现在，第 2 行的断点只会在循环的最后一次被命中！你甚至可以在表达式中使用局部变量，如上面的 `i` 和 `count` 所示。尝试看看你还可以使用哪些其他有用的条件。

### 定制断点行为

你可以设置一系列命令，以便 GDB 可以在每次到达特定断点时执行。任何有效的 GDB 命令都是可以的——设置栈帧、启用/禁用其他断点、计算 C 表达式、更改寄存器中的值等等。你甚至可以使用断点命令从调试器中临时修补有错误的代码！

假设第 192 行分配的字节数比需要的少了一个：

```{code-block} c
:lineno-start: 192
s = malloc(strlen(t));         // oops, supposed to be len + 1
```

首先，我们在第 192 行设置断点。

```c
(gdb) break 192
Breakpoint 1 at 0x400a8d: file program.c, line 192.
```

接下来，我们向该断点添加命令，插入正确的分配数量，跳过有问题的代码行并继续执行。我们可以通过 `command` 命令来实现这一任务，该命令会提示我们给最近添加的断点设置一些执行命令。该命令可以持续输入命令，直到我们输入 `end` 结束：

```c
(gdb) commands
Type commands for breakpoint(s) 1, one per line.
End with a line saying just "end".
print s = malloc(strlen(t)+1)
jump 193
continue
end
```

每次执行到第 192 行时，断点命令都会介入，自动插入正确的分配数，跳过有问题的语句并继续执行。这是一个非常好用的功能，在后续二进制炸弹作业中将非常有用……

