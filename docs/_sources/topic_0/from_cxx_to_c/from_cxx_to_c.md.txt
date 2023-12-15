# 从 C++ 到 C

```{toctree}
:hidden:

simpio
strlib
pig_latin
```

本节我们会使用 C 语言复习 CS101 中的一些概念，并改写一些 C++ 程序，逐步上手 C 语言的开发。

相信大家还记得 CS101 库中的两个重要的接口工具 [`strlib.h`](https://cppdoc.stickmind.com/strlib.html) 和 [`filelib.h`](https://cppdoc.stickmind.com/filelib.html)。这些抽象接口极大地方便了我们编写字符串处理和文件 I/O 相关的程序。所以在本课程的教学方式上，我们依然遵循抽象思维的观念，避免较早地涉及底层的细节。在入门示例中，重点抽象了以下两个类型 `string` 和 `stream`，以便在不涉及指针的情况下，就能完成字符串和文件的处理工作。

希望通过这样的方式，方便大家对比学习，能够将现有的知识迁移到新的语境中。

```c
/*
 * Type: string
 * ------------
 * The type string is identical to the type char *, which is
 * traditionally used in C programs.  The main point of defining a
 * new type is to improve program readability.   At the abstraction
 * levels at which the type string is used, it is usually not
 * important to take the string apart into its component characters.
 * Declaring it as a string emphasizes this atomicity.
 */

typedef char* string;

/*
 * Type: stream
 * ------------
 * Like string, the stream type is used to provide additional
 * readability and is defined to be equivalent to FILE *
 * (which is particularly confusing because it violates
 * standard case conventions).
 */

typedef FILE* stream;
```

为了照顾部分编程基础较为薄弱的同学，本次课程也会引入 **CMake** 并介绍一种较为方便的 **VS Code** 开发工作流，方便大家课后自行练习、巩固。

## 练习

下载群文件中的 `230918-cslib/cslib.zip` 文件，尝试使用 **CMake** 工具，将 `.h` 和 `.c` 组成的文件集合打包成静态库。
