# Windows MSYS2 环境

由于大部分同学使用 Windows 系统，在 Windows 平台体验 Linux 开发工具也是可以的。完成本节内容的学习，你应该能够尝试解决以下问题：

- 什么是 MSYS2？如何安装 MSYS2？
- 如何使用 `pacman` 包管理工具更新、安装、删除软件包？
- 如何修改 MSYS2 国内源？
- 如何使用 MSYS2 编译/运行 C 程序？

## 安装 MSYS2 开发工具

[MSYS2](https://www.msys2.org/) 提供了一个易于使用的类 Linux 环境来构建、安装和运行本机 Windows 软件。配合 VS Code 等开发工具，可以搭建一个较为轻量的开发环境。对于一些 POSIX 依赖不太严格的测试，比起使用 Linux 虚拟机更为直接、方便。

安装过程，有以下几点需要注意：

- 国内用户建议**断网安装**，避免中途出现更新密钥卡死的问题
- 安装完后，国内用户建议**修改国内软件源**，提高下载速度
- 后续软件体积较大，建议安装在非 C 盘根目录
- 建议使用 MSYS2 UCRT 子系统，和课程保持一致
- 优先安装 `mingw-w64-ucrt-x86_64-` 前缀的软件包

常用命令总结如下，方便后续使用查询，参考连接：[Package Management](https://www.msys2.org/docs/package-management/)

- 更新 MSYS2 组件，修改源后建议更新两次

    ```
    pacman -Suy
    ```

- 安装 `openssh` 可用于后续连接远程服务器

    ```
    pacman -S openssh
    ```

- 安装 `gcc`、`gdb`、`pkg-config` 等常用开发工具

    ```
    pacman -S mingw-w64-ucrt-x86_64-toolchain
    ```

- 安装 `make`，`cmake`，`ninja` 等构建工具

    ```
    pacman -S make mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja
    ```

## 编译运行 C 程序

在 MSYS2 当前目录创建一个 `hello.c` 文件，输入以下代码：

```c
#include <stdio.h>

int main(void) {
	printf("Hello World.\n");
	return 0;
}
```

使用以下命令编译你的第一个 C 程序：

```
gcc hello.c -o hello
```

运行该程序，需要以 `./` 开头执行以下命令：

```
./hello
```

前缀 `./` 表示在当前目录下寻找 `hello` 程序。
