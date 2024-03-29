# 理解 `*p` 的特殊性


指针是用于存储变量内存地址的数据类型。除了基本类型外，指针还可以存储复合数据类型变量的地址，例如数组、结构体等。

每个基本类型都对应一个指针类型，例如 `char` 对应 `char*`，`int` 对应 `int*` 等。所有指针类型占用的内存大小都是一个**字**（word），在 64 位系统下就是 8 个字节。从内存分配的行为上，指针类型和基本类型没有区别。

## 基本类型

当声明一个变量 `int x = 101;` 时，系统会在内存上分配 4 个字节的空间。

下图假设内存位置为 `0xe364`，则该地址连续 4 个字节的位模式解释为整型 `101`。

```
            x
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│     │     │ 101 │     │     │     │     │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┘
low      0xe364                          high
```

通过变量名 `x`，我们可以任意操作 `0xe364` 内存区域：

- 读取内存中的值，例如 `int y = x;` 会将 `101` 拷贝到 `y` 的内存中
- 修改内存中的值，例如 `x = 102;` 会将内存中的信息改成 `102`
- 读取内存的地址，例如表达式 `&x` 的值就是地址值 `0xe364`
- 计算内存的字节数，例如 `sizeof(x)` 的值就是 `4`，表示 4 个字节

## 基本类型的指针类型

当把基本类型变量的地址存入某个指针类型变量中，例如

```c
int* p = &x;
```

那么类似基本类型，系统会给指针类型变量 `p` 分配 8 个字节的空间，并存入变量 `x` 的地址：

```
            x     p           y
┌─────┬─────┬─────┬───────────┬─────┬─────┐
│     │     │ 101 │  0xe364   │     │     │
└─────┴─────┴─────┴───────────┴─────┴─────┘
low     0xe364 0xe368      0xe370       high
```

类似上述针对变量 `x` 的操作，通过变量 `p` 也能操作 `0xe368` 内存区域：

- 读取内存中的值，例如 `int* q = p;` 会将 `0xe364` 拷贝到 `q` 的内存中
- 修改内存中的值，例如 `p = &y;` 会将内存中的信息改成 `0xe370`
- 读取内存的地址，例如表达式 `&p` 的值就是地址值 `0xe368`
- 计算内存的字节数，例如 `sizeof(p)` 的值就是 `8`，表示 8 个字节

问题在于：完成了上述变量初始化后，对于 `0xe364` 的内存区域，**除了变量 `x` 可以操纵外，还有一个特殊的存在 `*p`**。我们可以将其当作普通变量名对待，例如上述 `x` 相关的操作，使用特殊名称 `*p` 也可以直接完成：

- 读取内存中的值，例如 `int y = *p;` 会将 `101` 拷贝到 `y` 的内存中
- 修改内存中的值，例如 `*p = 102;` 会将内存中的信息改成 `102`
- 读取内存的地址，例如表达式 `&*p` 的值就是地址值 `0xe364`
- 计算内存的字节数，例如 `sizeof(*p)` 的值就是 `4`，表示 4 个字节

```{admonition} 思考：为什么说 C/C++ 是天生不安全的编程语言？
:class: note

同一个字节块，除了 `x` 可以操作，`*p` 也可以操作。极大的灵活性（优点），也造成了内存安全问题（缺点）。
```

```{admonition} 补充：关键字 const
:class: note 

关键字 `const` 可以限定指针指向的内存区域，防止修改内存中的内容。

例如，加上 `const` 后表示 `p` 指向的是一块只读内存，通过 `*p` 无法修改 `x` 中的内容；形成对比的是，`x` 是变量标识符，表示可修改的内存区域，所以可以通过标识符 `x` 修改内存中的内容。

利用这个特性，可以在函数中限定指针参数。这样既避免了数据的拷贝，提升效率，又可以防止被调函数意外修改主调函数中的内容。

[*Demo Link*](https://godbolt.org/z/zWWGxzfq4)
```

## 数组类型

当声明一个数组 `int arr[] = {101, 102, 103};` 时，系统会在内存上依次分配 3 个整型。

下图假设内存位置为 `0xe364`，则从该地址连续分配 3 个整型，即 12 个字节空间。

```
         arr   0     1     2
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│     │     │ 101 │ 102 │ 103 │     │     │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┘
low     0xe364 0xe368 0xe36c             high
```

通过数组名 `arr`，我们可以任意操作该内存区域：

- 通过索引读取每个整型值，例如 `int y = arr[0];` 会将 `101` 拷贝到 `y` 的内存中
- 修改内存中的值，例如 `arr[0] = 100;` 会将第一个元素改成 `100`
- 读取内存地址，例如 `arr` 即表示首元素的地址值 `0xe364`
- 计算内存字节数，例如 `sizeof(arr)` 计算整个数组占用的字节，`sizeof(arr[0])` 计算一个元素占用的字节

> **注意**
> 
> 数组类型是一个复合数据类型。不同于基本类型，没必要使用 `&arr` 来获取数组地址。对于 `arr` 和 `&arr` 的异同可以表述为：
> 
> 两者都表示数组首个元素的地址，但是编译器将 `arr` 的类型当作首元素的指针 `int*` 对待，而将 `&arr` 的类型当作特殊的 `int(*)[]` 对待。
> 
> 简言之，在实践中，没必要使用 `&arr` 获取数组的地址。

## 数组类型的指针类型

数组类型变量的地址，也可以使用指针类型存储。如前所述，数组变量不需要通过 `&` 运算符获取数组地址：

```c
int* p = arr;
```

该声明初始化后，系统会分配 8 个字节空间给 `p` 并存放数组 `arr` 首个元素的地址。

```
          arr  0     1     2  p
┌─────┬─────┬─────┬─────┬─────┬───────────┐
│     │     │ 101 │ 102 │ 103 │  0xe364   │
└─────┴─────┴─────┴─────┴─────┴───────────┘
low     0xe364 0xe368 0xe36c 0xe370       high
```

此时变量 `p` 依然可以任意操作 `0xe370` 处的内存。也同样存在一个特殊的 `*p` 可以任意操作数组首个元素的内存，即 `0xe364` 开始的 4 个字节。

利用数组索引 `arr[N]`，我们可以操作任意元素位置的内存。这里需要特别注意的是，C/C++ 没有范围检查，`N` 可以超出范围 `[0, 2]`，例如 `-1`，`10` 等。

利用指针运算，也可以将 `*p` 演变为 `*(p+N)`，例如，对于 `0xe368` 处的内存，除了可以用 `arr[1]` 进行操作，还可以使用特殊的名称 `*(p+1)` 进行同样的操作。

