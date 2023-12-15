# 设计栈抽象数据类型

<div class="toc"></div>

编程不是学习语法，写一些简单的测试程序，而是创造一些能够改善生活，提高工作效率的软件。

C 语言提供的工具相比 C++ 来说非常简陋，没有容器、模板，没有很多高级技术可供直接使用。所以为了让编程的过程更简单，我们可以尝试创建一些通用的抽象数据类型，以库的形式供自己或他人使用，方便创建一些更高阶的应用程序。

例如，设计一个 RPN 计算器，如果有一个类似 C++ 中的 `stack` 容器，那么编程过程将会非常简单。

> 能写出抽象栈的程序员，并不一定能够写出一个 RPN 计算器。相反，能够写出 RPN 计算器的程序员，也不见得能够实现一个抽象栈。
> 
> 计算机是一个极度分层的系统，不同的人负责不同的组件，大家各司其职才能创建一套复杂的系统。

栈是一个抽象数据类型。在计算机科学中，栈有着标准的接口，通过研究该具体案例可以帮助我们理解接口的设计原则，与此同时，在实现代码的过程中还可以练习编程语言（例如 C 或 C++）的一些处理细节。

## Part 1. 定义栈的抽象类型

栈的**抽象类型**一般都是用直接的英文名称命名，例如 `stack` 或 `Stack`。我们希望用户可以使用类型 `stack` 定义数据对象：

```c
stack s1;
```

在 C 语言中，定义一个新的类型可以使用 `typedef`，所以我们可以使用如下语句定义栈的抽象类型：

```c
typedef ActualType stack;
```

注意：与抽象类型相对的是具体的**实现类型**，此处暂用 `ActualType` 表示。

> **设计原则**
> 
> 抽象类型属于接口部分，必须对用户可见，以上类型定义应该放在 `.h` 头文件中

在前置课程中，我们已经了解过，栈通常可以使用链表或动态数组来实现。在本案例中，我们选择使用链表来实现具体的数据表示，而动态数组相关的练习在作业 3 中已有体现。

遗憾的是，在 C 语言中，没有现成的链表类型可供使用。我们可以使用结构体尝试创建一个简单的链表表示：

```c
typedef double elem_t;  // 为什么要抽象出 elem_t？

struct cell_t {
    elem_t element;
    struct cell_t* link;
};

typedef struct cell_t node_t;

typedef node_t* list_t;
```

- 类型 `list_t` 是链表类型，本质上是一个指向节点的指针
- 类型 `node_t` 使用结构体定义了链表的结点，节点包含数据和一个指向下一个节点的指针
- 由于 C 没有模板类型，为了让容器支持更多元素类型，此处抽象出一个类型 `elem_t`  便于切换数据类型（在 RPN 应用中，使用 `double` 作为数据类型）

> **设计原则**
> 
> 不应该透露底层数据表示，以上定义应该放入 `.c` 实现文件中

### 编译问题

此时如果直接在头文件中修改 `struct` 定义，编译器将提示 “**error: unknown type name 'list'**” 错误：

```c
typedef list_t stack;
```

这是因为编译器是从上到下依次分析代码的。当导入头文件 `#include "stack.h"` 后 ，编译器读取到上述定义时发现系统中并没有 `list_t` 的定义，无法确定类型就没有办法确定内存的分配大小（该定义在 `.c` 实现文件中，对客户隐藏）。

在 C 语言中，避免该问题可以使用**结构体指针**，即便不知道结构体具体实现，其指针的大小也是固定的，即一个字（word）的大小。上述代码可以修改为：

```c
typedef struct stack_t* stack;
```

> 此处使用 `stack_t` 替换 `list_t`，避免暴露底层数据表示。

对应链表的实现部分，`list_t` 也应该调整为：

```c
typedef struct stack_t {
    node_t* start;
} list_t;
```

## Part 2. 定义栈的接口

由于接口隐藏了底层的数据表示，所以用户不能直接对 `s` 进行任何操作，即便是最基本的初始化（可能是链表初始化、可能是动态数组初始化、也可能……谁知道呢）。

> **设计原则**
> 
> 抽象数据类型必须通过接口操作底层数据结构。

在 C 语言中，我们必须通过一组函数集合来指向抽象数据类型的具体操作。参考前置课程中的 `Stack` 接口设计，我们定义了如下操作接口：

```c
// 构造和析构函数
stack new_stack(void);
void delete_stack(stack s);

// 修改函数
void push(stack s, elem_t element);
elem_t pop(stack s);
void clear_stack(stack s);

// 访问函数
elem_t peek(const stack s);
bool is_stack_empty(const stack s);
int stack_size(const stack s);
void print_stack(const stack s);
```

用户可以这样初始化/操作一个栈：

```c
stack s1 = new_stack();
push(s1, 3.14);
delete_stack(s1);
```

> **编译器警告**
> 
> 此时头文件没有 `elem_t`，我们可以将定义转移到头文件中

> **设计原则**
> 
> 虽然转移到头文件中可以方便用户修改具体数据类型，但却违背了接口设计原则。因为修改后需重新编译库文件，所以必须提供 `.c` 实现文件，这样就暴露了底层数据表示。
> 
> 以目前的知识储备，我们暂时没有两全其美的办法！（话题 4 再尝试解决这个问题）

## Part 3. 构造函数 new_stack

构造函数用于创建一个空栈，即一个简单的 `NULL` 指针。但是，下面的实现为什么欠考虑？

```c
stack new_stack(void){
      return NULL;
}
```

首先，从创建空栈的角度，该实现没有任何问题。栈抽象类型对象分配在栈内存上，并同时充当底层实现的链表头。

```
       栈内存                 堆内存

         s1         ->       node1 -> node2 -> NULL

```

但是，我们上述定义的接口函数，大多数参数都是 `stack` 类型。在 C 语言中，这样的函数调用称为**传值**调用，对数据的修改仅发生在调用栈内部。一旦调用栈收回，数据的修改将会消失，无法对 `s1` 进行持久性修改。

如果必须采用上述实现，更新对象的接口参数都必须修改为 `stack*`，以**传址**方式进行调用。

> **设计原则**
> 
> 以指针作参数，对用户的要求较高，特别是对初学者不太友好。
> 
> 类似 Java 的设计，隐藏了指针的设计，使用上更为便利。

所以，此处我们重新定义构造函数，增加一个嵌套层，将链表头节点放到堆内存上：

```c
stack new_stack(void) {
    stack s = malloc(sizeof(list_t));
    s->start = NULL;
    return (s);
}
```

> **设计原则**
> 
> 栈内存和堆内存配合使用，在实际项目中非常常见。

该操作会在栈内存上创建一个 `s1` 抽象类型对象，底层实现以链表的形式分配在堆内存上，利用指针进行关联。

```
       栈内存                 堆内存

         s1         ->        head -> node1 -> node2 -> NULL

```

## Part 4. 通用抽象接口

所谓“通用抽象接口”，就是不依赖底层表示的接口。不管底层表示是数组还是链表，这些接口的实现都不会改变。

### 析构函数 delete_stack

按上述设计，如果只是一个空栈，则只需要释放堆上的链表头：

```c
void delete_stack(stack s) {
    free(s);
}
```

如果不是空栈，则还需要释放底层链表的各个节点，可以在释放链表头之前，先使用清空栈的操作 `clear_stack`：

```c
void delete_stack(stack s) {
    clear_stack(s);
    free(s);
}
```

### 清空栈 clear_stack

清空栈就是依次 `pop` 出每个元素，所以可以这样实现：

```c
void clear_stack(stack s) {
    while (!is_stack_empty(s)) {
        (void)pop(s);
    }
}
```

注意，此处 `pop` 返回值不需要记录，所以为了避免返回值未使用的问题，转换为 `void` 防止编译器警告。

### 栈大小 stack_size

判断一个栈是否为空，即判断其元素个数是否为 0：

```c
bool is_stack_empty(const stack s) {
    return (!stack_size(s));
}
```

计算一个栈的大小，即元素个数，以链表来实现就是遍历整个链表：

```c
int stack_size(const stack s) {
    int n = 0;
    for (node_t* cp = s->start; cp != NULL; cp = cp->link) {
        n++;
    }
    return (n);
}
```

当然，更好的设计可以在链表头中添加一个成员变量，记录元素个数。

- 可以避免绑定底层表示
- 可以避免遍历造成的性能低下

```c
typedef struct stack_t {
    node_t* start;
    size_t count;
} list_t;

int stack_size(const stack s) {
    return (s->count);
}
```

注意 `pop` 和 `push` 内部需要对 `count` 成员进行更新。

## Part 5. 非通用接口

与上述通用接口相反，这些接口依赖于底层数据结构。如果后续更换底层表示，那么这些接口都要随之进行修改。

### 入栈 push

入栈操作，在链表表示的情况下，就是向链表头插入一个节点：

```c
void push(stack s, elem_t element) {
    node_t* cp = malloc(sizeof(node_t));
    cp->element = element;
    cp->link = s->start;
    s->start = cp;
}
```

### 出栈 pop

出栈的抽象定义是移除栈顶的元素，以链表实现时，移除栈顶元素就是移除链表头指向的第一个节点：

```c
elem_t pop(stack s) {
    if (is_stack_empty(s)) {
        fprintf(stderr, "Error: %s\n", "pop of an empty s");
        exit(1);
    }

    node_t* cp = s->start;
    elem_t result = cp->element;
    s->start = cp->link;
    free(cp);
    return (result);
}
```

注意，此处避免对空栈进行出栈操作，在执行前需要判断栈是否为空，做好防御性编程。

## Part 6. 调试接口

为了增强栈抽象类型的功能，可以提供一个**公有**的打印所有栈元素的接口，类似 C++ 版 `Stack` 的 `toString` 功能，方便客户验证栈对象的状态。

```c
void print_stack(const stack s) {
    printf("Stack: ");
    int size = stack_size(s);
    if (size == 0) {
        printf("empty\n");
    } else {
        for (int i = size - 1; i >= 0; i--) {
            if (i < size - 1) {
                printf(", ");
            }
            printf("%g", get_stack_elem(s, i));
        }
        printf("\n");
    }
}
```

为了调试的方便，可以设计一个**私有**的 `get_stack_elem` 接口，供开发过程中检查内存的布局情况。

```c
static elem_t get_stack_elem(const stack s, int size) {
    if (size < 0 || size >= stack_size(s)) {
        fprintf(stderr, "Error: %s\n", "Non-existent stack element");
        exit(1);
    }

    node_t* cp = s->start;
    for (int i = 0; i < size; i++) {
        cp = cp->link;
    }

    return (cp->element);
}
```

**在 C 中，私有性只能通过文件来管理**。在 `.c` 文件中使用 `static` 标记函数，则该函数只能在该 `.c` 文件内使用。
