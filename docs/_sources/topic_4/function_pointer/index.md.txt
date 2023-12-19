# 函数指针

在 C 语言中，使用函数可以封装一段可复用的逻辑或代码。编译完成后，函数就转换成一段以字为单位的 ISA 指令。在执行程序时，编译好的二进制可执行程序文件将被加载到内存的代码段中。在这段内存中，编译好的函数指令的第一条指令，可以通过函数名来获取。也就是说，函数名就是存储该指令内存的地址。

我们之前接触过的指针，存储的都是数值数据的地址，那么类似函数这样的**指令数据的地址**能否用指针来存储呢？答案是肯定的。函数指针可以用于存储函数指令的地址，这在 C 的编程中非常有用。

函数指针的声明形式为：

```c
returnType (*name)(parameters)
```

例如，`swap_int` 函数的地址可以赋值给一个函数指针 `fn`，该变量声明形式是 `void (*fn)(int*, int*)`。

为了与函数声明作区分

- 函数指针需要在函数名前加一个星号 `*` 并用括号包围。
- 函数指针声明时，参数名必须省略，仅保留参数类型。

```c
#include <stdio.h>

void swap_int(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int main () {
    void (*fn)(int*, int*) = &swap_int;  // 声明函数指针变量 fn 并初始化为 swap_int 地址
    //void (*fn)(int*, int*) = swap_int; 
    int value1 = 3, value2 = 4;
    (*fn)(&value1, &value2);             // 使用函数指针变量
    //fn(&value1, &value2);
    printf("%d, %d\n", value1, value2);  // 4, 3
    return 0;
}
```

```{admonition} 辨析：函数指针和普通指针
:class: tip

- 两者占用的内存大小一样，并且存储的都是内存的地址编号
- 函数指针在使用过程中无需使用 `&` 或 `*` 操作符，编译器会自动忽略
```

为了使用上的方便，我们也可以为函数指针定义一个类型别名：

```c
#include <stdio.h>

// 定义一个 fn_type 类型
typedef void (*fn_type)(int*, int*);

void swap_int(int *a, int *b) {
    ...
}

int main () {
    // 声明一个 fn_type 类型的变量 fn
    fn_type fn_ptr  = swap_int; // 可以省略 &
    
    int value1 = 3, value2 = 4;
    fn_ptr(&value1, &value2);
    
    printf("%d, %d\n", value1, value2);
    return 0;
}
```

```{admonition} 辨析：区分函数声明和函数指针声明
:class: tip

- `void *(*fn1)(int*, int*)` 表示声明一个函数指针 `fn1`，指向的函数返回 `void*` 类型
- `void *fn2(int*, int*)` 表示声明一个函数 `fn2`，返回 `void*` 类型

我们可以 `fn1 = fn2;` 将函数 `fn2` 的地址赋值给函数指针 `fn1`，但是不可以 `fn2 = fn1;`。
```

网站 [cdecl.org](https://cdecl.org/) 可以将 C 晦涩的声明转换成可读的英语。当试图解开一个难以理解的声明时，这个工具很方便。
