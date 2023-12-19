# 作业 0：使用 Linux 和 C

Linux 的使用和命令行操作需要不断地练习。熟练使用这些工具，才能更好地完成作业练习。但要注意的是，这些内容不需要刻意去记忆，经过一段时间的重复使用，自然可以掌握。

在开始作业之前，确保你已经能够：

- 登陆课程服务器
- 管理文件，浏览服务器文件系统
  - 能够找到实验、作业的初始项目
  - 能够合理地管理课程代码，避免杂乱无章
- 通过 VS Code 等编辑器修改服务器上的文件
- 逐步适应 Shell 和命令行的工作流
  - 遇到不熟悉的命令，知道去哪里学习
  - 会用 `tab`、上下键等快捷操作避免输入太多命令

本次作业目的是检验大家是否熟练使用 Linux 开发环境，能够适应编辑、构建、运行、测试 C 程序的工作流。

## 初始项目

建议在个人目录创建一个 `cs102` 的文件夹，用于管理课程所有的代码。然后可以使用下面的命令，将作业的初始文件复制到该目录。

```
cp -r /home/cs102-shared/assignments/assign0 ~/cs102
```

别忘了通过 VS Code 将文件同步到本地查看、编辑。

## 任务 1：入侵者检测

> 在该任务中，你将调查一起模拟的入侵攻击并回答 `readme.txt` 中的几个小问题。每个问题只需要简短的几句话即可，描述你用了什么样的 Linux 命令解决的。

入侵者访问了我们的服务器，并删除了很多文件。幸运的是，这些文件在服务器上都有备份，但在恢复文件之前，你要调查一下入侵者的身份并看看他们做了哪些破坏性操作。

在 `assign0/samples/server_files` 中包含了一些核心的文件，使用文件操作命令查看有哪些内容。

你需要先调查攻击者的身份。服务器可以供多个用户使用，每个用户的名字都在上述路径的 `home` 子目录中。例如，用户 `bob` 的路径是 `/home/bob`。文件 `users.list` 包含了认证用户的列表，`home` 子目录中的用户目录应该和该文件中的用户名一一对应。入侵者是未认证用户，所以他的名字不会出现在`users.list` 列表中。

你的任务就是找出这个入侵用户名！由于用户列表很多，通过手工比对不太现实，合适的命令行工具可以更快地完成这个任务。**Q1**：入侵者的名字是什么呢？你是用什么命令发现的？

<details>
  <summary><b>提示</b></summary>

  ----

  - 可以考虑创建一个临时文件用于存储中间数据，但更推荐使用管道来优化操作。
  - 自学 `diff` 命令的用法，看有没有什么启发。

  ----

</details>

如果你已经知道入侵者的名字，那么检查一下他的用户目录，看看有什么新的发现。虽然入侵者删除了目录下的文件，但似乎这个目录依然占用了一部分空间。想一想这是为什么？用命令行工具验证一下。

对了，以 `.` 开头的文件在 Linux 系统中属于隐藏文件，显示这些文件需要一些特殊的参数。**Q2**：在这些隐藏的文件中，有一个文件记录了入侵者所有的活动记录，这个文件是什么呢？它包含了什么内容？

如果想对系统实施破坏行为，必须使用 `sudo` 权限执行某些命令。在上述文件中，你会发现整个活动记录非常长，很难发现哪些命令用到了特权权限。**Q3**：用什么命令可以方便地提取出这些信息？入侵者使用 `sudo` 执行了哪些命令？

## 任务 2：谢尔宾斯基分形

> 通过该任务，我们可以练习远程开发工作流：编辑、构建、运行、测试。

在 `assign0` 文件夹中，输入 `make` 将构建名为 `triangle` 的程序。运行该程序看看它做了什么：

```
./triangle
```

此时应该会输出谢尔宾斯基三角形的 ASCII 表示形式——太酷了！尝试再次运行 `make`：

```
$ make
make: Nothing to be done for `all'.
```

该输出并不是错误提示，只是意味着程序的源代码没有任何变化，因此不需要重新编译任何内容。

在 VS Code 中打开 `triangle.c`，将 `main` 中变量 `nlevels` 的值从 3 更改为 5。保存文件后，修改会自动同步到服务器。**源码修改后，必须使用 `make` 重新构建程序**，然后才能运行新构建的程序来显示更大的三角形。如果忘记重新运行 `make`，将运行修改前的程序！

起始代码使用固定常量来表示要打印的层数。你的任务是扩展程序，提供可选的命令行参数，允许用户指定层数。如果没有参数，`./triangle` 应默认为 3 层。如果提供参数，例如 `./triangle 4` 或 `./triangle 2`，则层数由参数指定。

如果给定的层数不合法（大于 8 或负数），程序应该拒绝绘制图形，并打印一条有用的解释性消息，通知用户如何纠正错误，然后以状态 1 提前终止程序（这表明程序执行出现问题）。实现该任务的最佳函数是 `error` 函数；查看手册（[`man error`](https://man7.org/linux/man-pages/man3/error.3.html)），获取有关此函数的更多信息。需要注意的是，你应该指定 `errnum` 为 0，因为我们不需要打印出与特定错误代码相对应的错误消息。其余参数的值可以通过文档尝试确定。

你的实现必须和 `samples` 中的示例程序完全匹配。

```{admonition} 提示
:class: hint

可以假设用户只输入整数值，不必担心处理非整数的参数。如果用户指定多个命令行参数，则应仅使用第一个参数。
```

你应该在程序中定义常量，而不是使用“魔法数字”——硬编码到程序中的数字。

为了完成该任务，程序需要将用户的参数（以字符串形式提供）转换为整数。 C 标准库函数 `atoi` 可以用于执行此操作。查看手册 (`man atoi`) 或在线文档自行学习该函数。

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

课程服务器上提供了一个方便的测试工具 `sanitycheck`，并提供了一些默认的测试案例供你测试作业代码。该工具会比较你的结果和 `samples` 中示例程序的结果。你也可以在 `custom_tests` 文件中添加自己的测试案例。

切换到作业文件夹目录中，执行 `sanitycheck` 并且不带任何参数，此操作将会执行默认的测试案例：

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

参考 `custom_tests` 默认的测试格式，添加自己的测试案例，并通过如下命令执行自定义测试：

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

在输出结果中，如果出现 `MISMATCH`，表明你的程序执行完成，但结果和示例不匹配。如果出现 `NOT OK`，表明你的程序没有成功地执行，或发生了致命错误，输出结果当然也和示例不匹配。

## 作业提交

回答 `readme.txt` 中的问题，正确修改 `triangle.c` 和 `custom_tests` 后，可以提交作业。

课程服务器同样提供了 `submit` 工具，切换到作业文件夹目录，执行如下命令：

```
$ submit
This tool submits the assignment in the current directory for grading.
Current directory is ~/cs102/assign0

OK to submit project assign0 (y or n)? y

make clean
rm -f triangle *.o

COMPLETED: xuehao submitted assign0 Thu Jan 12 12:07 pm.
```

需要注意的是，每份作业最多可以提交 5 次。提交之前，记得仔细检查，完善测试案例，避免遗漏。
