# 内存管理

<div class="toc"></div>

内存分配是为计算机程序和服务分配物理或虚拟内存空间的过程。内存分配在程序执行之前或执行时完成，分为

- 静态内存管理：由编译器在编译过程中确定
- 动态内存管理：在程序运行时才能够确定

## 静态内存分配

栈位于内存的顶部附近，地址较高。每次调用函数时，系统都会分配一些栈内存。当声明一个局部变量时，系统会为该函数分配更多的栈内存来存储该变量。这样的分配逻辑使栈向下增长。函数返回后，函数的栈内存将被释放，也就是说所有的局部变量都失效了。

栈内存的分配和释放是自动完成的。分配在栈上的变量称为栈变量，或自动变量。栈的增长和释放的行为类似于 ADT 中的栈，创建函数栈对应于压栈 `push`，收回函数栈对应于出栈 `pop`。从效率上讲，C 语言仅仅将指针移动到上一个函数栈，并不会对释放的函数栈作过多操作。

```c
int factorial(int n) {
    if (n == 1) {
      return 1;
    } else {
      return n * factorial(n - 1);
    }
}

int main() {
    printf("%d", factorial(3));
    return 0;
}
```

由于函数的栈内存在函数返回后被释放，因此无法保证存储在这些区域中的值保持不变。一个常见的错误是在辅助函数中返回指向当前栈变量的指针。调用者得到这个指针后，这个指针将变为**悬空指针**，可以随时覆盖无效的栈内存。

```c
char* create_string(char ch, int num) {
    char new_str[num + 1];
    for (int i = 0; i < num; i++) {
        new_str[i] = ch;
    }
    new_str[num] = '\0';
    return new_str;
}

int main(int argc, char* argv[]) {
    char* str = create_string('a', 4);
    printf("%s", str);  // want "aaaa"
    return 0;
}
```

## 动态内存分配

在上一节中我们看到函数不能返回栈变量的指针。要解决这个问题，我们可以通过复制返回，或者将值放在比栈内存更持久的地方——堆内存就是一个可选项。与栈内存不同，堆内存由程序员显式分配，并且在显式释放之前不会消失；另外，堆内存的地址向上增长。

掌握堆内存的动态管理有三个阶段：

- Step 1：学会使用 malloc、calloc、realloc、free 等常用接口。
- Step 2：防御性编程，即分配失败时，做好相应的防范处理。
- Step 3：防止内存泄漏，即不使用的内存要及时释放，使用中的内存不要误放。

堆内存属于**动态内存**（Dynamic Memory），即在运行时可以进行分配、调整、释放的内存。涉及到动态内存的错误，我们都称之为运行时错误，比如内存泄漏等。

---

在堆上分配内存，可以使用 `malloc` 函数。

```c
#include <stdlib.h>
void* malloc(size_t size);
```

- 只需要指定需要获取的字节数，系统会分配一块连续的字节块。
- 函数仅返回字节块的首地址。
- `void*` 是一个泛型指针，意味着可以赋值给任何类型的指针。
- 系统分配堆内存，并不会初始化，也不会清除原有信息。
- 如果没有足够空间，函数将返回 `NULL`。

---

堆内存需要程序员手动释放，可以使用 `free` 函数。

```c
#include <stdlib.h>
void free(void* ptr);
```

- 释放的是堆内存空间，而不是指针本身（自动变量指针在 Stack 内存区）
- 必须整体释放，不可以释放局部，比如 `free(bytes + 1)`

    ```c
    char* bytes = malloc(4);
    // ...
    free(bytes);
    ```
- 接收的参数必须为指向堆内存的指针（不要误用成指向栈地址的指针）

---

针对字符串这种特定的结构，使用 `strdup` 可以方便地在堆上创建以零字节结尾的字符数组。例如，

```c
#include <string.h>
char* strdup(char* s);
```

在堆上创建 "Hello, world!" 字符串：

```c
char* str = strdup("Hello, world!");  // on heap
// 对比
int len = strlen("Hello, world!");
char* str = malloc(len+1);
strcpy(str, "Hello, word!");
```

---

`calloc` 与 `malloc` 最大的区别是对分配的内存进行清零，相比 `malloc` 效率较低。``calloc`` 需要提供两个参数：元素个数、元素宽度。

```c
#include <stdlib.h>
void* calloc(size_t nmemb, size_t size);
```

分配 20 个 `int` 大小字节并清零：

```c
int* scores = calloc(20, sizeof(int));
// 类比
int* scores = malloc(20 * sizeof(int));
for (int i = 0; i < 20; i++) {
    scores[i] = 0;
}
```

----

`realloc` 用于调整已分配的堆内存大小。函数接收两个参数：指向已分配的堆内存指针（不要误用成指向栈地址的指针），需要重新分配的堆空间大小。函数返回重新分配后的堆内存地址。

```c
#include <stdlib.h>
void* realloc(void* ptr, size_t size);
```

一般来说，空间充足时 `realloc` 会直接追加内存，此时返回的地址和参数地址一致；空间不足时，才会将数据复制到新的内存区域，再返回新的内存地址。

## 防御性编程

堆内存不足时，堆内存分配函数将返回 `NULL`。利用这个信息，我们可以编写出更健壮的代码。使用 `assert` 检测返回值是否为 `NULL` 来终止程序。例如，

```c
int arr = malloc(sizeof(int) * 20);
assert(arr != NULL);

char* str = strdup("Hello");
assert(str != NULL);
```

在 `SimpleCSLib` 库中，也有类似的处理，比如 `GetBlock` 函数就是对 `malloc` 的封装：

```c
void* GetBlock(size_t nbytes) {
    void* result = malloc(nbytes);
    if (result == NULL)
        Error("No memory available");
    return (result);
}
```

## 内存安全

- **重复释放问题**：多个指针指向同一个内存区域，只需要释放一次。
- **释放后重复使用问题**：多个指针指向同一个内存区域，通过其中一个指针释放后，其他指针应该不允许再间接引用。
- **内存泄漏问题**：在程序结束时，堆内存仍未释放，这称为**内存泄漏**（Memory Leak）。小型程序中的内存泄漏可能看起来没什么大不了，但对于长时间运行的服务器来说，内存泄漏会降低整个机器的速度并最终导致程序崩溃。
