# 实验 2. 数组和指针

话题 2 开始接触标准库——封装好的标准函数集合。[Guide to C stdlib functions](https://web.stanford.edu/class/archive/cs/cs107/cs107.1206/guide/stdlib) 针对 C 标准库中可用的函数提供了一份很好的概述。

许多程序员只是将标准库看作一个“黑匣子”——按文档说明使用函数，但对底层的实现并不清楚。鉴于本课程的目标是让大家**真正了解系统的内部运作方式**，所以我们将进行更深入的研究。

为此，我们提供了一些练习，深入研究标准库的代码。通过研究工业级代码，并反思其在设计、可读性和效率之间的权衡，我们可以学到很多东西。深入了解这些函数的底层实现，我们还可以更好地使用这些函数，并避免一些陷阱和误用。

这些知识也可能会激发你写出自己的 `isdigit` 或 `strncpy` 函数，并集成到你的程序中，但最佳实践是**尽可能选择标准库函数**。这些函数已经编写完成，并且经过了充分的调试和验证——有什么理由不去使用它们呢？我们从代码中学习这些函数的实现，对一些不好的设计提出自己的见解和批评，但在以后使用它们时，也应该心存感激。

本次实验进一步练习使用 `gdb` 和 `Valgrind`、学习 `string.h` 接口以及将 C 字符串作为原始数组/指针进行操作。以下一些问题用于检测你的理解，并让你进一步思考这些概念：

- 对 `strncpy` 的调用，在什么情况下会以空字符 `NUL`（`\0`）作为目标字符串的结尾，在什么情况下不会？使用未以 `NUL` 字符结尾的字符串会产生哪些后果？
- 一个程序直接运行时看起来没什么问题，但是在 `Valgrind` 下运行时，它会报告错误。你的伙伴认为 `Valgrind` 的报告大错特错，而且非常偏执地认为程序运行正常就说明没有问题。向他们解释为什么访问不属于你的内存时会造成问题，并进一步描述即便发生了错误，为什么内存错误可以无症状地潜伏在程序中。  
- 编写一个 C 表达式判断给定的 `char*` 是否包含 `N` 个字符长的前缀/后缀。请务必利用 `string.h` 库函数。如果使用比字符串长度更长的 `N` 值来计算表达式，会发生什么情况？  
- 函数 `atoi/strtol` 将数字字符串转换为十进制数字，但没有标准函数可以反向转换。描述一种可用于将数字转换为等效字符串的技术。

## 学习目标

- 研究数组和指针在 C 中如何工作
- 阅读并分析操作 C 字符和字符串的代码  
- 使用 `gdb` 和 `Valgrind` 检测和调试内存错误  

## 初始代码

你的个人用户目录下应该已经有 `cs102` 这个文件夹了，通过下面的命令拷贝初始代码到该目录中：

```Shell
cp -r /home/cs102-shared/labs/lab2 ~/cs102
```

## 任务 1：GDB 探究指针和数组

首先，我们将研究指针和数组语法以及两者之间的异同。为此，我们将使用 `code.c` 程序，这个示例程序展示了数组和指针的各种行为。

构建程序，在 `gdb` 下启动它，并在 `main` 处设置断点。当程序在断点处停止时，使用 `info locals` 查看未初始化的栈变量状态。该命令列出当前函数中所有局部变量的值。单步执行初始化语句并再次使用 `info locals`。注意，当 `gdb` 报告执行在第 N 行时，第 N 行尚未执行。

下面表达式都引用了局部变量 `arr`。对于每个表达式，先尝试弄清楚该表达式的结果是什么，然后在 `gdb` 中验证你的理解是否正确。

```c
(gdb) p *arr
(gdb) p arr[1]
(gdb) p &arr[1]
(gdb) p *(arr + 2)
(gdb) p &arr[3] - &arr[1]

(gdb) p sizeof(arr)
(gdb) p arr = arr + 1
```

函数 `main` 将 `ptr` 初始化为 `arr`。栈上的数组名和指向该数组的指针几乎可以互换，但又不完全可以互换。尝试用 `ptr` 替换 `arr` 重新计算上述表达式。前五个表达式的计算结果相同，但后两个表达式的结果却不同。数组大小是多少？指针的大小又是多少？最后一个表达式是最难理解的。为什么可以给 `ptr` 赋值，但不能给 `arr` 赋值？

执行 `p ptr = ptr - 1` 将 `ptr` 重置为其原始值。使用 `step` 命令进入 `binky(arr, ptr)` 调用栈。 `step` 与 `next` 类似，但它不是执行整行并移至下一行，而是进入当前执行的行。进入 `binky` 后，使用 `info args` 查看两个参数的值。利用变量 `a` 和 `b`，打印你能想到的任何表达式，它们将得出相同的结果。对于上面最后两个表达式：`sizeof` 报告 `a` 和 `b` 的大小相同，并且两者都允许赋值。参数传递过程中发生了什么情况才能实现这一点？尝试画出内存示意图来阐明这个问题。

在 `change_char` 上设置断点并使用命令 `continue` 继续执行。当 `gdb` 在断点处停止时，使用 `info args` 可以查看当前函数栈 `change_char` 的参数。

使用 `backtrace` 可以查看当前位置的函数调用栈帧列表。使用 `frame` 命令可以选择不同的栈帧。在 `backtrace` 命令的输出中，函数栈帧由内到外从 0 开始编号。尝试使用命令 `frame 1` 来选择 `change_char` 的上一层栈帧，然后使用 `info locals` 来查看 `winky` 的状态。也可以使用简写命令，`up` 可以进入上一层栈帧，`down` 可以进入下一层栈帧。最后，执行 `frame 0` 返回到调试器停止的位置。

单步执行 `change_char` 并检查每行之前和之后的状态。使用 `info args` 查看当前栈帧的参数，然后使用 `up` 和 `info locals` 查看上一层栈帧中变量发生的变化。仔细观察每条赋值语句的效果。

单步执行 `change_ptr` 并进行相同的观察。哪些赋值语句对 `winky` 具有持久效果，哪些没有？你能解释为什么吗？

## 任务 2：探究 atoi

在作业 0 中，我们使用 `atoi` 函数将字符串参数转换为整数，该函数名来自 **ascii to integer** 的首字母。正如你在作业 0 中了解到的那样，`atoi` 使用起来非常方便，但却容易出错。在实际项目中，基本都被 `strtol` 函数取代了。本次作业就会迁移到这个新函数。函数 `strtol` 提供了更多的功能，但使用起来也更复杂。

在 `atoi.c` 程序中包含了一份 `atoi` 的实现，该实现改编自 [musl](https://musl.libc.org/) 库。你可以先编译并运行它。请注意，该程序的代码风格并不全都值得你效仿——我们的目的仅仅是通过此份代码理解该函数底层的实现逻辑。

以下列出的一些问题，用于引导你阅读 `musl_atoi` 的代码：

- 第 13 行：表达式 `*s` 计算后的值是什么？该表达式的另一种替代写法是什么？（或许替代的写法可读性更好……）
- 第 14 行：表达式 `s++` 对 `s` 做了什么？
- 第 17~23 行：如果字符串以减号 `-` 字符开头，那么哪行代码会让 `s` 跳过该字符？这很微妙！（`switch` 语句的 `fallthrough` 行为可能会令人非常惊讶，并且通常是由异常触发的，所以对于故意不写 `break` 语句的地方，最好能写清楚注释，但是……）
- 该代码有两处针对字符串的循环遍历，但却都没有使用 `NUL` 终止字符进行显式测试。为什么这样的测试是没必要的？
- 如何将单个数字字符转换为对应的数值？该值又如何与目前为止所构建的值进行结合？
- 第 28 行：关于 `s++` 的一个奇怪现象是，该表达式不仅修改 `s`，还会计算出 `s` 的原始值。关于该行为，推荐阅读 [Stack Overflow](https://stackoverflow.com/questions/7031326/what-is-the-difference-between-prefix-and-postfix-operators) 上的问题。换句话说，`s++` 会将 `s` 进行自增操作，但表达式的值不是自增后的值，而是原来的值。代码是如何利用该特性让字符串处理更简洁的？
- 第 25~31 行：该循环先将 `number` 建立为负值，然后再将其取负。注释表明这个决定可以避免在 `INT_MIN` 处发生溢出。为什么有必要将 `INT_MIN` 作为特殊情况？为什么程序将 `number` 构造为负数而不是正数？
- 当输入字符串包含非数字字符时会发生什么？如果该非数字字符是第一个字符又将如何？
- 第 31 行：三元表达式使用“`CONDITION ? IF_TRUE : IF_FALSE`”的形式进行计算。尝试解释 `return` 语句。

接下来编译 `atoi` 程序并做一些测试。选择一些感兴趣的输入，首先手动跟踪函数将如何处理，然后在 `gdb` 中逐步执行程序来验证你的理解是否正确。尝试一些可以成功转换的输入，例如 `./atoi 107 0 -12`，然​​后再尝试一些有问题或格式错误的输入，例如 `./atoi 3.14 binky @55 --8`。如果输入超出整数可以表示的范围，结果将会如何？溢出？饱和？返回 0？引发错误？还是完全执行其他操作？

## 任务 3：使用 Valgrind

每个实验室都会花一些时间来练习工具的使用。上周，是 `sanitycheck` 和 `gdb`。本周，我们介绍 Valgrind。

从现在开始，我们将大量使用指针，我们的程序出现内存错误的风险也将变得更大。这些错误很难追踪，此时学习 Valgrind 工具将很有必要。 Valgrind 是一个帮助检测内存错误的工具。[Valgrind Memcheck](https://web.stanford.edu/class/archive/cs/cs107/cs107.1206/resources/valgrind) 是关于 Valgrind 的一份很好的指南。

下面让我们尝试使用 Valgrind 来修复程序。

- 阅读 `buggy.c` 中的代码，查看两个植入的内存错误。我们从错误 1 开始。
- 运行 `./buggy 1`，你应该可以看到 **Segmentation fault (core dumped)**。段错误是由于尝试读/写无法访问/无效的地址而导致的。好了，现在你知道程序中有个内存错误。
- 在 `gdb` 下再次运行该程序，你应该观察到相同的段错误。此时，尝试使用 `backtrace` 命令来定位程序崩溃时执行的位置。这个信息非常有用，但我们还需要更多！
- 退出 `gdb` 并在 Valgrind 下运行程序：`valgrind ./buggy 1`. Valgrind 的报告提供了更多详细的信息，包括内存错误的类型、执行的调用栈以及无效地址的值。此外，Valgrind 还检测到了段错误之前的一个问题——**Use of uninitialised value of size 8** 发生在 **Invalid read of size 1** 之前，前者是指针的大小，后者是 `char` 类型的大小。这个重要的信息可以引导你找到错误的根源！
- 重复上述过程，尝试解决错误 2 中的错误。错误 1 中的问题可能比较明显，但错误 2 中的问题仅凭肉眼很难发现——Valgrind 将非常有用！

针对程序中的错误，Valgrind 使用的术语和报告可能很难理解。这需要一些练习来熟悉，你练习的目标应该是将 Valgrind 报告的错误与代码中的位置和根源联系起来。

我们选择这些特殊案例来进一步证明内存错误的棘手性。这两个错误都来自某种形式的内存错误，但观察到的后果却不同。 错误 1 每次都会因段错误而崩溃，而错误 2 的输出有时正确有时不正确，但它不会崩溃。

内存错误可能不会造成明显的损害，但这并不意味着程序是正确的，它只是这次“幸运”而已。使用 Valgrind 可以检测到这些潜在的错误，避免后续产生不可挽回的损失。

检查完这些错误后，请回答以下问题：处理字符串时，什么错误可能是 Valgrind 报告的“**Conditional jump or move depends on uninitialised value(s)**”的根本原因？这是你在作业 2 中可能会犯的错误，因此现在了解其原因很有必要！

> **启示** 进行 Valgrind 例行检查
>
> 鉴于此，我们建议你在编写作业代码时，应该尽早并经常运行 Valgrind。每当 Valgrind 报告任何内存错误时，你就应该停下来并尝试解决它，然后再继续完成作业。让 Valgrind 的例行检查成为你的工作流的一部分，尤其是遇到错误时！

## 任务 4：探究 strtok

一种常见的字符串处理模式是将字符串拆分为“词元”或“token”。这些词元是由一个或多个分隔字符分隔出来的，例如将句子按空格拆分为单词或将文件路径按斜杠拆分为独立的组件。

C 标准库提供了一个 `strtok` 函数，但其​​笨拙的设计使得该函数的使用变得较为混乱且容易出错。我们将研究这个函数及其存在的问题，以此作为一个警示。在作业 2 中，你将编写一个改进的 `tokenize` 函数，在编写过程中要注意避免此类错误！

我们首先以用户身份来使用 `strtok` 函数。可以通过 `man strtok` 熟悉其操作，注意 BUGS 部分中对该函数设计的批评。

与 C++ 等其他语言中类似的函数不同，只调用一次 `strtok` 并不会返回一个格式化好的类似 `vector` 一样的词元容器。相反，你必须重复调用 `strtok`，每次只能返回一个词元。直到 `strtok` 返回 `NULL` 时，才表示没有多余的词元。以下是一个常见的编程习语：

```c
char* token = strtok(input, delims);
while (token != NULL) {
    printf("%s\n", token);
    token = strtok(NULL, delims);
}
```

关于 `strtok` 的诟病主要体现在两个方面，其一是它破坏性地修改了输入，其二是它一次只能处理一个词元。下面我们分别探讨下这些问题：

**设计问题  1：`strtok` 修改了传入的参数**。 `strtok` 没有为每个词元创建一个新的子字符串，而是使用空字符 `NUL` 覆盖原字符串中的分割符，并返回指向首个词元的指针。该函数有效地将输入字符串分割成一系列词元，某种程度上，它重新利用了现有字符串，避免将字符复制到其他位置。例如字符串 `red-green-blue\0`，重复调用 `strtok` 以 `-` 进行分割后，该字符串将变为 `red\0green\0blue\0`。

**设计问题 2：`strtok` 不允许常量输入**。该函数不仅破坏了输入参数，而且这种设计还无法处理字符串常量（只读）。程序 `token.c` 有一个示例，它将字符串常量作为输入传递给 `strtok`。取消该部分的代码注释，尝试编译并运行程序，看看 `strtok` 在处理字符串常量时的报错信息。

**设计问题 3：`strtok` 一次只能处理一个词元**。在第一次调用 `strtok` 时，第一个参数是待处理的字符串。但在后续调用中，第一个参数将变为 `NULL`，这是告诉 `strtok` 要从上一次调用的中断处，继续处理同一个字符串。在内部实现中，`strtok` 使用了一个全局变量来保存第一次调用时的原始输入字符串，并在后续调用中更新该变量。天哪！此行为与典型的函数调用形成了鲜明对比，典型的函数调用应该完全独立，不应该与任何先前或将来的调用相关联。这不仅让调试变得更困难，而且一次最多只能处理一个词元。该函数有一个状态变量，可以供所有调用共享。每次调用，函数都会将状态保存至该变量，再次调用函数时，会用新的值覆盖该变量。

在 `token.c` 中包含了一份 `strtok` 的实现，该实现改编自 [musl](https://musl.libc.org/) 库。有很多谜题需要我们逐一揭开！绘制内存图并跟踪 `s` 和 `p` 在调用期间的变化，或者在 `gdb` 下运行该程序可能会有所帮助。

- 第 12 行：关于[静态变量](https://en.wikipedia.org/wiki/Static_variable)的维基百科页面提供了一些背景信息和静态局部变量的示例。 `static` 有什么作用？为什么要在这里使用它？
  请注意，静态变量的初始化方式与非静态局部变量不同。尽管该函数看起来每次调用时都会声明一个新变量 `p` 并初始化，但**静态变量只能被声明和初始化一次**。在多次调用之间，`p` 的值将会保留，不会收回。
- 第 14~19 行：当 `NULL` 作为第一个参数传递时，`s` 如何获取值？
- 第 21 和 27 行：函数 `strspn` 和 `strcspn` 有何作用？
- 第 21 行：在这一行的执行过程中 `s` 是如何更新的？
- 第 22 行：表达式 `*s` 的计算结果是什么？这个表达式的另一种替代写法是什么？ （为了可读性，这种替代写法或许更好，但是唉……）
- 第 24 行：什么情况下函数会通过第 24 行退出？
- 第 27 行：执行完这一行后，`p` 指向哪里？
- 第 29 行：搞清楚这行代码的赋值操作，看它是如何改变输入参数的。该行执行结束后，`p` 指向哪里？
- 第 29 和 32 行：这两行似乎有些相似，都将 `0` 赋值给 `p`，但它们的目的却存在着重大差异。`p = NULL`，`*p = '\0' `与 `p = ""` 这些表达式有什么区别？
