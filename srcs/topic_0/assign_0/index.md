# 作业 0：使用 Linux 和 C

熟练掌握 Linux 系统的运用及其命令行操作离不开持续的实践。只有通过频繁地运用这些工具，才能更有效地完成学习任务与练习。值得注意的是，这些知识与技能无需死记硬背，随着在日常中的反复应用，它们将自然而然地融入你的技能库中。

在着手进行作业之前，请确保你已经具备了以下能力：

- 成功登录课程专用的服务器；
- 熟练管理文件，并能自如地浏览服务器上的文件系统结构；
  - 能够迅速定位到实验与作业的起始项目文件；
  - 具备良好的课程代码管理能力，确保代码组织有序，避免混乱；
- 熟练运用 VS Code 等编辑器，编辑服务器上的文件；
- 逐步习惯并融入 Shell 与命令行的工作流程；
  - 面对不熟悉的命令时，知晓如何快速查找学习资源；
  - 灵活运用 Tab 键、上下箭头等快捷键，以减少命令输入的繁琐。

本次作业旨在全面检验同学们对 Linux 开发环境的熟悉程度，以及是否已能顺畅地执行编辑、构建、运行与测试 C 语言程序的全流程工作。

## 初始项目

为了有效管理课程相关的所有代码，我们建议你在个人目录下创建一个名为 `cs102` 的文件夹。这个专属文件夹将作为你课程代码的集中存放地，帮助你保持工作环境的整洁与有序。

接下来，你可以利用以下命令，将作业的初始文件复制到刚刚创建的 `cs102` 文件夹中：

```
cp -r /home/cs102-shared/assignments/assign0 ~/cs102
```

此命令会从服务器的共享目录中复制整个 `assign0` 作业文件夹到你的 `cs102` 文件夹内。

完成上述步骤后，别忘了利用 VS Code 这一强大的编辑器，将服务器上的文件同步至本地环境。这样，你就可以在更加熟悉和舒适的界面中进行代码的查看与编辑，享受 VS Code 提供的丰富功能与便捷操作。同步过程不仅确保了你随时拥有最新的代码副本，还便于你在离线状态下进行代码编写与调试。

## 任务 1：入侵者检测


> 在该挑战性任务中，你将深入探究一起精心设计的模拟入侵攻击事件，并解答 `readme.txt` 文件中提出的几个关键问题。每个问题的回答只需寥寥数语，概述你所采用的 Linux 命令及其成效。

不幸的是，我们的服务器遭遇了入侵者的恶意攻击，导致大量文件被非法删除。值得庆幸的是，得益于服务器的备份机制，这些文件得以保存。然而，在着手恢复之前，我们必须先揭开入侵者的神秘面纱，并深入了解其造成的破坏程度。

文件夹 `assign0/samples/server_files` 中保存着至关重要的核心文件，你可以利用文件操作命令轻松浏览其内容。

调查的首要任务是确定攻击者的真实身份。我们的服务器为多用户环境，每位用户的主目录均位于 `home` 子目录下。举例来说，用户 `bob` 的主目录路径为 `/home/bob`。同时，`users.list` 文件详细记录了所有合法用户的身份信息，`home` 子目录中的用户目录应与该文件中的用户名严格对应。由于入侵者并非合法用户，因此其用户名不会出现在 `users.list` 中。

你的核心使命就是揪出这个隐匿的入侵者！面对庞大的用户列表，手工比对显然不切实际，而高效的命令行工具则能助你迅速锁定目标。**Q1**：请问入侵者的用户名是什么？你又是通过哪个命令将其揪出的呢？

如果你已经掌握了入侵者的名字，接下来请深入检查他的用户目录，或许能从中发现新的线索。值得注意的是，尽管入侵者删除了目录下的部分文件，但该目录仍占用了一定的磁盘空间。这背后可能隐藏着怎样的秘密呢？不妨借助命令行工具来一探究竟。

在 Linux 系统中，以 `.` 开头的文件被视为隐藏文件，若要查看这些文件，需要设置特定的参数。**Q2**：在这些隐藏的文件里，有一个详尽记录了入侵者所有活动的日志文件。那么，这个神秘的文件究竟是什么呢？它又具体记录了哪些内容呢？

要对系统造成破坏，通常需要借助 `sudo` 权限来执行某些关键命令。在上述的日志文件中，活动记录冗长复杂，很难一眼识别出哪些命令涉及了特权权限的使用。**Q3**：有没有一种高效的命令，能够帮助我们迅速筛选出这些信息？入侵者究竟使用了哪些 `sudo` 命令呢？

<details>
  <summary><b>提示</b></summary>

  ----

  - 可以考虑创建一个临时文件用于存储中间数据，但更推荐使用管道来优化操作。
  - 自学 `diff` 命令的用法，看有没有什么启发。

  ----

</details>

## 任务 2：谢尔宾斯基分形

> 通过这项任务，我们将有机会实践远程开发的全过程，包括编辑、构建、运行以及测试等环节。

当你进入 `assign0` 文件夹，只需简单输入 `make` 命令，即可成功构建出一个名为 `triangle` 的程序。接下来，通过运行该程序，你将亲眼见证它所生成的谢尔宾斯基三角形的 ASCII 艺术呈现——这简直太棒了！然而，当你再次尝试运行 `make` 命令时，可能会看到如下输出：

```
$ make
make: Nothing to be done for `all'.
```

这并非错误提示，而是意味着程序的源代码维持原样，无需进行任何重新编译。

现在，让我们在 VS Code 中打开 `triangle.c` 文件，并尝试将 `main` 函数中 `nlevels` 变量的值从 3 修改为 5。保存文件后，这些更改将自动同步至服务器。但请注意，**在修改源代码后，你必须重新运行 `make` 命令以构建新的程序**，随后才能运行这个新构建的程序来查看更大的三角形。如果你忘记重新构建，那么运行的仍将是旧版本的程序！

原始代码中使用了一个固定的常量来确定要打印的层数。而你的任务则是扩展这个程序的功能，使其能够接受可选的命令行参数，从而允许用户自行指定层数。如果没有提供参数，`./triangle` 程序将默认打印 3 层。而如果提供了参数，例如 `./triangle 4` 或 `./triangle 2`，则程序将按照用户指定的层数进行打印。

若提供的层数不合法，即超出允许范围（大于 8 或为负数），程序应拒绝继续绘制图形，并向用户展示一条清晰且有用的解释性消息，指导用户如何纠正这一错误。随后，程序应以状态码 1 提前终止执行，以此表明程序执行过程中遇到了问题。为了高效实现这一功能，`error` 函数是最佳选择；你可以通过查阅手册 `man error` 来获取更多关于此函数的详细信息。在此需要注意的是，应将 `errnum` 参数设定为 0，因为我们无需打印与特定错误代码相关联的错误消息。对于其他参数的具体值，你可以参考相关文档进行尝试和确定。

你的实现方案必须与 `samples` 文件夹中的示例程序保持完全一致。

```{admonition} 提示
:class: hint

我们可以合理假设用户仅会输入整数值作为参数，因此无需担忧处理非整数参数的情况。若用户不慎提供了多个命令行参数，我们的程序将仅采纳第一个参数进行后续操作。
```

在编写程序时，应当定义常量来代替那些直接硬编码在程序中的“魔法数字”，以提高代码的可读性和可维护性。

为了成功完成当前任务，程序需要能够将用户输入的参数（这些参数以字符串的形式给出）转换成整数。C 标准库中提供了一个名为 `atoi` 的函数，可以方便地实现这一转换功能。你可以通过查阅手册（`man atoi`）或在线文档来深入了解该函数的用法和特性。

```{admonition} man 在线手册操作说明
:class: note

在命令行输入 `man error` 后，终端会进入 `error` 函数的在线手册文档。手册会列出函数名称、引入的头文件、函数原型、以及一些说明描述。

常用快捷键如下：

- `j` - 向下移动一行
- `k` - 向上移动一行
- `ctrl + f` - 向下翻一页
- `ctrl + b` - 向上翻一页
- `q` - 退出

参考阅读：

- https://www.howtoforge.com/linux-man-command/
- http://cn.linux.vbird.org/linux_basic/0160startlinux_3.php
```

## 测试

课程服务器上配备了一个实用的测试工具——`sanitycheck`，它内置了一些默认的测试案例，供你用来验证作业代码的正确性。这个工具会对比你的输出结果与 `samples` 文件夹中示例程序的预期结果。此外，你还拥有在 `custom_tests` 文件中自定义测试案例的灵活性。

当你身处作业文件夹内时，只需简单地运行 `sanitycheck` 命令（无需附带任何参数），即可触发这些默认的测试案例。

```
$ sanitycheck
Will run default sanity check for assign0 in current directory ~/cs102/assign0.

+++ Test A-Make on ~/cs102/assign0
Descr:   verify project builds cleanly
Command: make clean && make triangle
OK:  Clean build

+++ Test B-Triangle on ~/cs102/assign0
Descr:   print a triangle, no command-line argument should default to 3 levels
Command: ./triangle
OK:  Submission output matches sample
Matched output:
       *
      * *
     *   *
    * * * *
   *       *
...

LOVE IT! This project passes all of the default sanity check cases.
```

你可以参照 `custom_tests` 中默认的测试格式，自由地添加属于自己的测试案例。随后，通过执行以下命令来运行这些自定义的测试：

```
$ sanitycheck custom_tests
Will run custom sanity check for assign0 in current directory ~/cs102/assign0.
Reading custom test cases from file 'custom_tests'... found 1 test cases.

+++ Test BuildClean on ~/cs102/assign0
Descr:   verify project builds cleanly
Command: make
OK:  Clean build

Now running custom test cases against your program

+++ Test Custom-1 on ~/cs102/assign0
Command: ./triangle -1
MISMATCH:  Submission output does not match sample
Sample output:  ./triangle: the number of levels must be between 0 and 8.
Your output:
       *
      * *
     *   *
    * * * *
   *       *
  * *     * *
 *   *   *   *
* * * * * * * *

This project passes 0 of the 1 custom test cases read from file 'custom_tests'.
```

如果在测试的输出结果中出现了 `MISMATCH` 字样，这意味着你的程序虽然能够执行完毕，但其输出结果与预期的示例并不一致。相反，如果结果显示为 `NOT OK`，则表明你的程序在执行过程中可能遇到了某些问题，未能成功运行，或者发生了严重的错误，导致输出结果与示例不符。

## 作业提交

在准确回答 `readme.txt` 中的问题，并对 `triangle.c` 和 `custom_tests` 文件做出正确修改后，你就可以提交你的作业了。

为了方便大家提交作业，课程服务器上专门提供了 `submit` 工具。你只需切换到作业文件夹所在的目录，并执行以下命令即可完成提交：

```
$ submit
This tool submits the assignment in the current directory for grading.
Current directory is ~/cs102/assign0

OK to submit project assign0 (y or n)? y

make clean
rm -f triangle *.o

COMPLETED: xuehao submitted assign0 Thu Jan 12 12:07 pm.
```

**【重要提示】** 每份作业最多允许提交 5 次，因此，在提交之前，请务必仔细检查你的代码和测试案例，确保万无一失，避免遗漏任何重要环节。
