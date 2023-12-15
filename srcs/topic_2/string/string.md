# 字符串

本课程第二个话题是讨论计算机如何表示更复杂的数据类型。理解这个问题可以帮助我们更好地理解以下几个问题：

- 理解编程语言（C/C++等）如何表示字符串
- 更好地理解较为普遍的缓冲区溢出问题
- 理解字符串和数组/指针的关系

字符串在 C 中较为特殊，既可以通过数组来处理，也可以通过指针来处理。只有明白数组和指针之间的联系，才能更好地处理字符串相关的程序开发。所以本话题，我们会通过大量的字符串练习，帮助大家深刻理解数组、指针以及字符串等概念。关于数组和指针的基础知识，可以先参考下一章节。

计算机早期大多用来处理数字这样的基本数据类型，而现代计算机更多用于处理文本类的数据。从第一个程序 **Hello, World** 开始，我们就已经和字符串打过交道。在本章中，你将学习如何使用字符串库，并编写出更有创造性和趣味性的程序。

由于字符串是由独立的字符组成，因此了解字符的表示和工作原理也非常重要。本章将重点研究字符和字符串两种类型，并深入了解其内部的细节和潜在的安全问题。

## 字符

在 C 语言中，类型 `char` 用于表示单个字符，但其本质依然是整型。

```c
char letterA = 'A';
char plus = '+';
char zero = '0';
char space = ' ';
char newLine = '\n';
char tab = '\t';
char singleQuote = '\'';
char backSlash = '\\';
```

字符根据 ASCII 码表（[`man ascii`](https://man7.org/linux/man-pages/man7/ascii.7.html)），以整型存储到计算机中。ASCII 码表有以下几个特点

- 大写字母的整型值连续排列
- 小写字母的整型值连续排列
- 数字的整型值连续排列
- 大写字母位模式通过对第 6 个位取反得到小写字母位模式，所以小写字母的数值比大写字母的数值大 \\(2^5\\)

```c
char uppercaseA = 'A'; // Actually 65 -> 1000001
char lowercaseA = 'a'; // Actually 97 -> 1100001
char zeroDigit = '0';  // Actually 48
```

利用字符类型的本质是整型的特点，我们可以将整型操作应用到字符类型，例如比较、计算等。

```c
bool areEqual = 'A' == 'A';               // true
bool earlierLetter = 'f' < 'c';           // false
char uppercaseB = 'A' + 1;                // 'B'
int diff = 'c' - 'a';                     // 2
int numLettersInAlphabet = 'z' - 'a' + 1; // 26
int numLettersInAlphabet = 'Z' - 'A' + 1; // 26

// prints out every lowercase character
for (char ch = 'a'; ch <= 'z'; ch++) {
    printf("%c", ch);
}
```

通过 `#include <ctype.h>` 标准库提供了一些常用的字符处理函数，可以通过 `man` 手册查询这些函数的使用说明，例如 `man isalpha` 或 `man tolower` 等。也可以参考[在线文档](https://en.cppreference.com/w/c/string/byte)。

```c
bool isLetter = isalpha('A');   // true
bool capital = isupper('f');    // false
char uppercaseB = toupper('b'); // 'B'
bool isADigit = isdigit('4');   // true
```
