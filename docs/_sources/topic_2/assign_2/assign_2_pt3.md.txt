# 实现 scan_token

你的第二个任务是实现一个可以单独编写和测试的函数 `scan_token`，并将在稍后的作业中使用它。这个函数应该在 `util.c` 中实现，并在 `tokenize.c` 程序中使用。本次作业涉及到二级指针的使用，请确保理解这些概念。

在实验 2 中，我们研究了 `strtok` 的实现。这种通过分隔符将字符串拆分为词元的函数有很多应用场景，但标准的 `strtok` 存在设计上的缺陷，并且很难使用。函数 `scan_token` 和 `strtok` 的使用方式很像，但在设计上更为简洁。其原型是：

```c
bool scan_token(const char** p_input, const char* delimiters, 
                char buf[], size_t buflen);
```

该函数根据分隔符扫描输入字符串来确定下一个词元，然后将词元写入 `buf`，并保证词元以空字符 `\0` 结尾。如果词元成功写入 `buf`，则函数返回 `true`，否则返回 `false`。以下是该函数操作的具体细节：

- `scan_token` 的实现应该采用和 `strtok` 类似的方法，这意味着你应该使用通用的 `string.h` 函数，例如 `strspn` 和 `strcspn`，但要避免 `strtok` 中的不良设计。具体来说，它不应该使用静态变量、修改输入字符串、在调用之间存在状态转移（即每次调用都应该独立运行）。
- `scan_token` 采用和 `strtok` 相同的方式将输入字符串分隔为词元：该函数通过扫描输入字符串，先找到不在 `delimiters` 中的第一个字符，即词元的首字符。从该位置继续扫描，找到包含在 `delimiters` 中的第一个字符，即词元的结尾。如果找不到任何包含在 `delimiters` 中的字符，则输入字符串的结尾就是词元的结尾。
- `buf` 是一个固定长度的数组，用于存储词元，`buflen` 是数组的长度。 `scan_token` 写入的字符不应该超过 `buf` 的末尾。如果 `buf` 无法容纳整个词元，则该函数应该只将 `buflen - 1` 个字符写入 `buf`，并在 `buf` 的最后写入空字符表示结尾。此外，`p_input` 持有的指针应该更新为指向词元 `buflen - 1` 个字符之后的下一个字符。换句话说，下一个扫描的词元将从溢出 `buf` 的第一个字符处开始。
- 注意，参数 `p_input` 的类型是 `char**`，这是一个指向字符串的指针，充当了引用参数的作用。因为 `scan_token` 扫描输入字符串时需要更新该参数，以指向下一个字符，所以这是必须的。如果没有剩余字符可供扫描，则 `*p_input` 应指向输入字符串的结尾，即指向空字符 `\0`。

以下是一个循环扫描词元的示例：

```c
const char* input = "super-duper-awesome-magnificent";
char buf[10];
const char* remaining = input;

while (scan_token(&remaining, "-", buf, sizeof(buf))) {
	printf("Next token: %s\n", buf);
}
```

其输出结果应该如下：

```
Next token: super
Next token: duper
Next token: awesome
Next token: magnifice
Next token: nt
```

可以使用作业提供的 `tokenize.c` 程序测试该函数。如果执行 `./tokenize`，程序将使用你的 `scan_token` 函数统计几个单词的音节数。按以下格式执行该程序，你还可以指定测试的文本和分隔符等信息：

```shell
./tokenize <DELIMITERS> <TEXT> <BUFSIZE (OPTIONAL)>
```

例如，如果你想使用分隔符“`-`”和“` `”来分割文本“`hello I am a C-string`”，可以运行：

```
./tokenize " -" "hello I am a C-string"
```

第一个字符串包含用作分隔符的字符，第二个字符串是待处理的文本。该命令应该输出类似以下的内容：

```
./tokenize " -" "hello I am a C-string"
Tokenized: { "hello" "I" "am" "a" "C" "string" }
```

你还可以提供第三个参数，用于定义缓冲区的大小。如果不提供该参数，则缓冲区将默认有足够的空间来存储整个词元。

你不需要修改 `tokenize.c`，该程序只用于测试你的函数。为了确保实现的正确性，务必在 `custom_tests` 中添加完善的测试用例。

**可以作如下假设**：我们只会测试包含有效参数的函数。更具体地说，这意味着：

- `buf` 是可容纳 `buflen` 个字符的有效内存地址  
- `buflen > 1`  
- `p_input` 是一个有效的指针  
- `*p_input` 是一个格式化良好的 C 字符串（可能是空字符串）  
- `delimiters` 是一个格式化良好的 C 字符串，包含一个或多个分隔符（不可以是空字符串）

你可能想为你的函数做好防御性检查，例如，拒绝处理 `p_input` 为 `NULL` 的值，或者当客户端传递不匹配 `buflen` 的 `buf` 时输出错误警告。虽然你的初衷是好的，但要想实现百分之百的防御是不可能的。例如，判断一个指针是否有效，通常是无解的。`p_input == NULL` 只会准确捕获这一种情况，但对于其他非法地址，该测试却无法捕获。作为实现者，你别无选择，只能假设客户端提供有效的地址，并编写相应的代码。
