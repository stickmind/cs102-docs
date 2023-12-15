# 整数的表示

在计算机中，数字的表示可以大致分为三类，分别是：

- 无符号整型（unsigned integer）：表示正数和 0，例如 \\(0\\)，\\(1\\)，\\(2\\)，……，\\(255\\)
- 有符号整型（signed integer）：表示正数、负数和 0，例如 \\(-128\\)，\\(-127\\)，……，\\(0\\)，\\(1\\)，\\(2\\)
- 浮点数（floating point number）：表示实数，例如 \\(3.14\\)，\\(1.5*10^{12}\\)

在 C 语言中分别有对应的基本数据类型用于表示这些数字：

| Types  | Bytes（32 Bit） | Bytes（64 Bit） |
| :------: | :---------------: | :---------------: |
| `char`   | 1               | 1               |
| `short`  | 2               | 2               |
| `int`    | 4               | 4               |
| `long`   | 4               | 8               |
| `float`  | 4               | 4               |
| `double` | 8               | 8               |
| `char*`  | 4               | 8               |

32 位和 64 位代表计算机的**字长**（word size），表示指针的大小。虚拟地址是以字来编码的，所以字长决定了计算机虚拟地址空间的大小。对于 32 位系统来说，能够支持的最大虚拟地址空间为 4 GB。

目前，大部分计算设备都已经从 32 位迁移到 64 位，但在嵌入式领域这些转变才刚刚开始。以树莓派为首的嵌入式平台，已经开启了 64 位转移之路，推荐阅读：

- [It's official: Raspberry Pi OS goes 64-bit](https://www.jeffgeerling.com/blog/2022/its-official-raspberry-pi-os-goes-64-bit)
- [CS107E: Computer Systems from the Ground Up](http://cs107e.github.io/)
