# 实验 6. 优化和分析

本次实验的目的是让你探索如何分析 C 程序的效率，该项技能对于优化和分析堆分配器非常有用。

在实验中，你将学习如何使用 Valgrind 工具集中的 `callgrind` 来分析程序的效率和瓶颈。你还将检查生成的汇编代码并识别 GCC 的转换是如何让代码运行得更快的。你出色的汇编技能，在这里将发挥重要的作用！

以下一些问题用于检测你的理解，并让你进一步思考这些概念：

- **循环展开**（loop unrolling）是一项循环转换技术，以增加程序文件大小为代价来优化程序的执行速度。循环展开会降低/消除循环指令，从而降低跳转带来的消耗，进一步降低延迟。在什么情况下这能带来性能优势？
- 避免函数调用/返回产生的开销经常被认为是**内联函数**的设计动机（尽管内联函数在当前版本的 C 语言中并不是必需的）。预计可节省多少条指令数量？鉴于 GCC 执行的大多数转换发生在函数内部，而不是函数调用之间，内联还提供了额外的优化机会。从收益来讲，相比函数调用，内联是否有必要？

## 学习目标

- 尝试针对执行时间的不同计时机制
- 运行分析器来获取动态指令计数

## 初始代码

你的个人用户目录下应该已经有 `cs102` 这个文件夹了，通过下面的命令拷贝初始代码到该目录中：

```Shell
cp -r /home/cs102-shared/labs/lab6 ~/cs102
```

## 任务 1：计时工具

程序效率的一种常见衡量标准是**执行时间**（execution time），也称为运行时间（run time）。测量运行时间的一个简单方法是通过 Unix/Linux 的 `time` 命令使用系统进程计时器。这种测量相当粗略，仅限于对整个程序进行计时，但它很方便，因为你可以对任何程序进行计时，不需要获取甚至修改程序的源代码。现在就来尝试一下吧！

在初始项目的 `samples` 文件夹内包含来自作业 4 中的示例程序 `mysort_soln` 以及另一个程序 `bbsort`。`bbsort` 是 Busybox 项目中的一个排序程序，其界面和外部行为和 `mysort` 程序非常相似，都实现了 Unix/Linux 标准 `sort` 命令的简化版本。`samples`文件夹还包含一个随机数的输入文件。使用同一输入，参照如下命令，将这两个程序的执行时间与 Unix/Linux 标准 `sort` 命令进行比较。标记为“user”的时间是我们感兴趣的时间。

注意：命令末尾的 `>/dev/null` 将丢弃输出内容，以便更方便地查看计时信息。

```
time samples/mysort_soln -n samples/million >/dev/null
time samples/bbsort -n samples/million >/dev/null
time sort -n samples/million >/dev/null
```

三个排序程序的运行时间排名如何？结果应该表明 `bbsort` 和 `mysort` 的运行时间相当，但标准 `sort` 命令要快得多。让我们进一步调查一下！

**分析器**（profiler）是一种开发人员工具，通过观察正在执行的程序，收集有关资源消耗的详细统计信息，例如花费的时间、执行的指令、使用的内存等。目前我们使用 Valgrind 主要用来帮助查找内存错误和泄漏，但它也包含一个 Callgrind 分析器，用于计算指令和内存的访问次数。更多信息可以参考 [Guide to Callgrind](https://web.stanford.edu/class/archive/cs/cs107/cs107.1206/resources/callgrind)。

```
valgrind --tool=callgrind samples/mysort_soln -n samples/thousand >/dev/null
valgrind --tool=callgrind samples/bbsort -n samples/thousand >/dev/null
valgrind --tool=callgrind sort -n samples/thousand >/dev/null
```

使用 `callgrind` 命令运行三个排序程序，在输出中找到标有“**I refs**”的数字，这是执行的指令总数。你发现了什么？正如上述计时数据所预期的那样，`bbsort` 和 `mysort` 的指令数相当，但标准 `sort` 命令的工作量要少得多。

除了累加总指令数之外，`callgrind` 还将详细信息写入名为 `callgrind.out.pid` 的文件（其中 `pid` 是 `callgrind` 摘要左列中显示的进程号，例如 `==29240==`）。在当前目录执行 `ls` 命令，查看生成的这些文件。

你可以在输出文件上运行 `callgrind_annotate` 来解析该文件，并获取每个函数或每一行的指令计数。参照下面的命令，将 `pid` 替换为相应的进程号：

```
callgrind_annotate callgrind.out.[pid]
```

在 `mysort` 和 `bbsort` 的 `callgrind` 输出上运行注释器，你将看到某个函数占据了绝大多数的执行指令。它是哪个函数？该函数是否暗示了为什么标准 `sort` 命令执行如此之快？

## 任务 2：数学运算

程序 `trials` 中的函数 `two_to_power` 以多种方式实现 $2^n$ 的计算。

查看 `trials.c` 中的 C 代码，一起看看这些不同实现在指令数方面的差异。你认为这些版本孰优孰劣？

- 版本 A 和 B 使用数学库中的 `pow` 和 `exp2`。库函数计算很快，对吗？但是，数学库仅适用于 `float/double` 类型——可以大概浏览下 `pow` 在 [musl](https://git.musl-libc.org/cgit/musl/tree/src/math/pow.c) 中的实现。整数在这里不能直接使用，必须转换为浮点数并使用浮点指令进行操作，这可能很耗时！
- 版本 C 是一个迭代 `n` 次并乘以 2 的循环。查看该函数的汇编代码，看看是否有实际的 `mul` 指令，或者聪明的编译器是否提供了更好的东西？
- 版本 D 利用了位模式和二进制数之间的关系。这看起来很可能是最终的赢家。

使用 `objdump` 或 `gdb disassemble` 来获取每个函数的汇编代码并统计指令计数，这称为**静态计数**。哪个函数的指令最多？哪个最少？较短的静态指令数是否一定意味着函数会更快？

```{admonition} 指令 cvtsi2sd 和 cvttsd2si 是什么？
:class: note

这些是浮点汇编指令，浮点是汇编的一个完全不同的话题。

可以通过搜索引擎或参考书查询更多信息，但不了解这些也不影响这次实验。
```

使用 Callgrind 获取**动态计数**。以下命令中的选项 `--toggle-collect` 告诉 `callgrind` 只计算名称中包含 `power` 的函数的指令，以便提取我们感兴趣的部分：

```
valgrind --tool=callgrind --toggle-collect='*power*' ./trials
```

使用 `callgrind_annotate` 来分解每个函数/代码行的指令计数。

```
callgrind_annotate --auto=yes callgrind.out.[pid]
```

当使用选项 `--auto=yes` 调用时，注释器会显示原始 C 源文件，并用该行的汇编指令数来注释每一行。你可以浏览注释，找出那些计数较大的行来识别性能瓶颈。计数越大意味着该行生成的汇编指令越多，执行耗时也就越严重。**这些代码行称为该程序的“hot spots”，执行了大量指令，是急需优化以提高程序性能的热点部分。**

注意，在统计过程中，有些指令只用于**设置并调用函数**，并不是函数**实际执行时的指令计数**。例如，在下面的示例中，`callgrind` 告诉我们，设置并调用函数 `pow` 执行了 7 条指令，但函数实际执行的指令计数为 127 条。

```text
  1 ( 0.26%)  long two_to_power_A(unsigned int exp) {
  7 ( 1.83%)      return pow(2, exp);
127 (33.16%)  => ./math/./w_pow_template.c:pow@@GLIBC_2.29 (1x)
  2 ( 0.52%)  }
```

位运算版本只需几条指令，速度快到无可比拟！其他版本的实现涉及多少额外的工作？这是否让你感到惊讶？

## 任务 3：数据拷贝

程序 `copy` 演示了以不同方式拷贝大型数组的相对成本。拷贝的数据总量是恒定的，但改变每次迭代完成的工作量和迭代次数会对性能产生深远的影响。该程序尝试了多种方法：循环中逐块处理、循环中重复使用 `memcpy`、对整个数组调用一次 `memcpy` 或 `memmove`。

首先，查看 `copy.c` 中的 C 代码，并对不同拷贝函数的相对性能做出一些预测。你认为这些不同版本的性能孰优孰劣？

在 `callgrind` 下运行并注释程序：

```
valgrind --tool=callgrind --toggle-collect='copy*' ./copy

callgrind_annotate --auto=yes callgrind.out.[pid]
```

在 `char`、`int` 和 `long` 循环的指令计数中，使用 `int` 而不是 `char` 进行拷贝时，指令大约少了多少条？使用 `long` 比 `int` 少了多少？

拷贝较大的块演示了“循环展开”的价值，即通过在每次迭代中执行更多工作并减少迭代次数来分摊循环的开销。

接下来，比较 `long` 循环与 `memcpy` 循环的指令计数（每次迭代 `memcpy` 将拷贝 8 个字节，迭代次数与 `long` 循环相同）。由此可以看出，执行一次简单的赋值，使用 `memcpy` 将产生多少成本。直接用 `long` 而不使用 `memcpy` 进行拷贝时，大约少了多少条指令？

最后，查看对整个数组执行一次 `memcpy/memmove` 的指令计数。可以发现，确实有人在优化库函数方面下了很大的功夫！一次性拷贝整个数组比单独拷贝每个元素有一个数量级的提升。

注意：`memcpy` 相比 `memmove` 具有性能优势，因为 `memcpy` 可以忽略重叠区域，而 `memmove` 必须处理它们。但在本例中 `memmove` 与 `memcpy` 的指令计数却完全相同。复习实验 4 的内容，了解 `musl` 的实现是如何处理重叠部分的。它有什么作用？


```{admonition} 小节
:class: note

重写 C 标准库中已有的函数通常不是一个好主意。库函数已经完成编写、测试、调试并大幅优化——有什么理由不用呢？但是在工作中，你需要考虑如何选择正确的工具。

了解库函数的成本/收益以及编译器的优化能力，可以让你更好地将注意力集中在需要手动优化的代码段上，而不必担心库函数和 GCC 已经完成的部分。

另外记住，永远不应该使用浮点数学函数来执行简单的整数或位运算！

更多练习可以参考这篇文章 [Will It Optimize](http://ridiculousfish.com/blog/posts/will-it-optimize.html)。
```

## 任务 4：栈分配和堆分配

出于多种原因（类型安全、自动分配/释放等），栈分配优于堆分配，同时还提供显著的性能优势。让我们使用 Callgrind 来分析一个排序程序，探索使用栈和堆的相对运行时成本。

程序 `isort` 实现了插入排序，在对数组进行排序时，交换数组元素需要临时空间。程序尝试使用固定大小的栈缓冲区、可变长度栈缓冲区以及从堆内存分配临时空间，来探索不同内存对性能的影响。

查看 `isort.c` 中的 C 代码，对不同函数的相对性能做出一些预测。你认为这些不同版本的性能孰优孰劣？

在 `callgrind` 下运行并注释程序：

```
valgrind --tool=callgrind --toggle-collect='swap_*' ./isort

callgrind_annotate --auto=yes callgrind.out.[pid]
```

三个交换函数在三个 `memcpy` 调用中具有相同的指令数；要检查的问题是在设置 `tmp` 内存和清理内存时所花费的指令。

函数左/右大括号和变量声明相对应的行注释，是函数进入/退出时的指令计数。函数 `swap_fixedstack` 与 `swap_varstack` 进入和退出时执行的指令数有什么区别？

比较这两个函数的反汇编。设置和清理固定长度栈数组需要多少条指令？可变长度栈数组需要多少条额外指令？反汇编中额外指令的计数是否与 Callgrind 报告的已执行指令的计数相匹配？

现在查看 `swap_heap` 的指令计数。该注释表明设置并调用 `malloc/free` 的指令数量较少，而在 `malloc/free` 库函数中执行的指令数量较多。

每次调用 `malloc` 大约会产生多少条指令？每次调用 `free` 需要多少？相比栈内存，堆内存成本如何？
