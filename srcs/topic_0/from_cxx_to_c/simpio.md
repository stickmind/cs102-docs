# simpio.h

该接口导出几个函数来简化输入数据的读取。

## 接口

| 函数               | 功能                                                 |
| ------------------ | ---------------------------------------------------- |
| `GetInteger()`     | 从标准输入读取一行文本并将其作为 `int` 整数返回      |
| `GetLong()`        | 从标准输入读取一行文本并将其作为 `long` 整数返回     |
| `GetReal()`        | 从标准输入读取一行文本并将其作为 `double` 浮点数返回 |
| `GetLine()`        | 从标准输入读取一行文本并将其作为字符串返回           |
| `ReadLine(infile)` | 从输入文件中读取一行文本并将该行作为字符串返回       |

## 接口详情

```c
/*
 * Function: GetInteger
 * Usage: i = GetInteger();
 * ------------------------
 * GetInteger reads a line of text from standard input and scans
 * it as an integer.  The integer value is returned.  If an
 * integer cannot be scanned or if more characters follow the
 * number, the user is given a chance to retry.
 */

int GetInteger(void);

/*
 * Function: GetLong
 * Usage: l = GetLong();
 * ---------------------
 * GetLong reads a line of text from standard input and scans
 * it as a long integer.  The value is returned as a long.
 * If an integer cannot be scanned or if more characters follow
 * the number, the user is given a chance to retry.
 */

long GetLong(void);

/*
 * Function: GetReal
 * Usage: x = GetReal();
 * ---------------------
 * GetReal reads a line of text from standard input and scans
 * it as a double.  If the number cannot be scanned or if extra
 * characters follow after the number ends, the user is given
 * a chance to reenter the value.
 */

double GetReal(void);

/*
 * Function: GetLine
 * Usage: s = GetLine();
 * ---------------------
 * GetLine reads a line of text from standard input and returns
 * the line as a string.  The newline character that terminates
 * the input is not stored as part of the string.
 */

string GetLine(void);

/*
 * Function: ReadLine
 * Usage: s = ReadLine(infile);
 * ----------------------------
 * ReadLine reads a line of text from the input file and
 * returns the line as a string.  The newline character
 * that terminates the input is not stored as part of the
 * string.  The ReadLine function returns NULL if infile
 * is at the end-of-file position.
 */

string ReadLine(stream infile);
```