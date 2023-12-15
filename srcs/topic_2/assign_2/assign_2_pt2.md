# 实现 get_env_value

你的第一个任务是实现一个可以单独编写和测试的函数 `get_env_value`，并将在稍后的作业中使用它。这个函数应该在 `util.c` 中实现，并在 `myprintenv.c` 程序中使用。

函数 `get_env_value` 将环境变量数组和环境变量名作为参数，并返回环境变量数组中找到的变量名的值；如果在数组中找不到，则返回 `NULL`。

```c
const char* get_env_value(const char* envp[], const char* varname);
```

数组 `envp` 中的每个条目都是 `VARNAME=VALUE` 形式的字符串，你可以假设 `VARNAME` 和 `VALUE` 都不包含 `=`。注意，最后一个条目后面是 `NULL` 指针，用于标记该数组的结尾。你的函数应该迭代环境变量数组中的每个条目并查找匹配的项。

例如，如果 `envp` 包含条目 `USER=stickmind`，则变量 `USER` 的关联值为 `stickmind`。你的函数不需要复制字符串，它只是返回一个指向 `=` 字符后面的指针，从而得到原字符串的一个部分。

使用作业提供的 `myprintenv.c` 程序来测试该函数。如果执行 `./myprintenv`，它应该像 `printenv` 一样打印出所有的环境变量；此命令不依赖你的 `get_env_value` 函数。如果指定一个或多个命令行参数，它将打印出环境中每个参数的值；此命令将依赖你的 `get_env_value` 函数。

你不需要修改 `myprintenv.c`，该程序只用于测试你的函数。为了确保实现的正确性，务必在 `custom_tests` 中添加完善的测试用例。

**特别说明**：`_` 是一个特殊的环境变量，无需担心 `myprintenv` 的输出不一致。也就是说，如果将 `_` 传递给 `get_env_value`，函数应该能够正确返回一个值，但 `./myprintenv _` 的输出可能与示例程序的结果不一样。

**限制**：`get_env_value` 不应调用 `getenv/secure_getenv` 函数。为了实现目的，该函数必须遍历通过参数传递的环境变量数组 `envp` 。

**测试**：尝试使用 `env` 临时更改环境变量并确保能够正确打印。例如，如果执行：

```shell
env USER=otheruser ./myprintenv USER
```

那么对于本次执行的 `myprintenv`，该命令会将 `USER` 环境变量更改为 `otheruser`，而不是你的用户名。请确保 `myprintenv` 打印出正确的值 `otheruser`。

另外，自定义测试 `custom_tests` 无法将 `env` 作为测试命令的一部分——自定义测试必须以 `myprintenv` 开头。如果你想使用 `env` 进行测试，必须手动进行。

如果想让 `env` 与 `gdb` 一起使用，请以 `env` 为前缀启动 `gdb`，然后正常运行。例如：

```Shell
env USER=otheruser gdb myprintenv
```
