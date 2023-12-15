# 开发环境

```{toctree}
:hidden:

topic_0/linux_intro/index
topic_0/command_line/linux_command
topic_0/from_cxx_to_c/from_cxx_to_c
topic_0/lab_0/index
topic_0/assign_0/index
```

Linux 和命令行工具是非常流行的工具，常用于运行程序（Web 服务器、Python 程序、远程程序……）、访问远程服务器（Amazon Web Services、Microsoft Azure、Heroku……）、嵌入式设备开发（Arduino、Raspberry Pi……）等等。

本阶段的目标是帮助你精通 Linux 开发环境的使用，很快你就会知道如何使用 `cd` 这样的命令。

![terminal](./topic_0/command_line/assets/terminal.png)

另一个目标是尽快让你上手用 C 语言编写程序，在进阶课程中 C 语言的重要性将会越来越明显。

```c
/* This program prints a welcome message to the user. */

#include <stdio.h> // for printf

int main(int argc, char *argv[]) { 
    printf("Hello, world!\n"); 
    return 0;
}
```
