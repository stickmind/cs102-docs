# 字符串指针

> 本小节将以指针的观点来看待字符串！

上一小节，我们以字符数组的形式学习了 `string.h` 的常用接口，以数组来看待字符串符合其内存的表示形式。那为什么 `strchr/strrchr` 和 `strstr` 都返回 `char*`，前者表示字符指针，而后者却表示子字符串呢？系统内部是如何处理的？

以数组观点看待字符串，很可能写出如下代码：

```c
size_t mystrlen(char str[]) {
    size_t count = 0;
    for (size_t i = 0; str[i] != '\0'; i++) {
        count++;
    }
    return count;
}
```

但是，从 [`musl libc`](https://git.musl-libc.org/cgit/musl/tree/src/string/strlen.c) 的源码来看，其实现却是以指针的形式表示的。

```c
// from musl libc
size_t strlen(const char* s) {
    const char* a = s;
    for (; *s; s++);
    return s-a;
}
```

传统的做法鼓励 C 程序员使用指针编写大部分字符串处理函数。所以，如果想用好标准字符串接口，我们需要熟悉以指针的观点来看待字符串。
