# 函数参数

在 C 语言中，如果将一个值作参数传递，那么 C 会传递该值的一个拷贝。不管是普通数据类型还是指针类型，都是将其值拷贝到函数调用栈中。

```c
void myFunction(int x) {
    // …
}

int main(int argc, char* argv[]) {
    int num = 4;
    // passes copy of 4
    myFunction(num);  
}
```

```c
void myFunction(int* x) {
    // …
}

int main(int argc, char* argv[]) {
    int num = 4;
    // passes copy of e.g. 0xffed63
    myFunction(&num);  
}
```

## 指针——实现引用传参

在 C++ 中，对于容器等较大的抽象数据类型，我们可以使用引用参数传递给函数。

但是在 C 中，函数参数是以传值的方式传递给**被调函数**（Callee）的，这将造成被调函数不能直接修改**主调函数**（Caller）中的值。

例如，以下错误的交换两个变量的函数，直接调用 `swap(a, b)` 并不能交换 `a`、`b` 两个变量的值。

如果想修改主函数中的值，我们可以使用指针作为函数参数，从而实现引用传递参数的效果。

```c
/* WRONG */ 
void swap(int x, int y) {  
    int temp; 
    temp = x; 
    x = y; 
    y = temp; 
} 
```

```c
/* RIGHT */
void swap(int* px, int* py) { 
    int temp; 
    temp = *px; 
    *px = *py; 
    *py = temp; 
} 
```

## 数组——退化为指针

和字符串一样，数组作为参数时，编译器会将其退化为指针来处理。我们可以认为这是编译器设计者为了避免数据拷贝，利用指针对数组结构进行的一种优化操作。

但这也意味着，数组大小的信息将会丢失。在函数内部，我们无法再使用 `sizeof` 获取数组的长度。所以，一个好的接口设计应该如下述示例所示：

```c
// n 用于确定输出的元素个数
void print_arr(int arr[], int n);
void print_arr(int* arr, int n); // the same

// max 定义最大元素数，sentinel 定义结束标记
void init_arr(int arr[], int max, int sentinel); 
void init_arr(int* arr, int max, int sentinel);  // the same
```

## 总结

1. 对某个数据实体（参数）进行一些操作（函数调用）时，
   - 如果不需要改变其内容，那么传递该数据的值 data；
   - 如果需要改变其内容，那么传递该数据的地址 address。
2. 如果函数接收的参数是一个地址（指针），那么在函数调用栈内，可以通过该地址间接访问栈外的内存块，进行读写操作。例如，`*p = new_data`。
3. 如果将数组（指针）传递给函数，那么在函数内的修改将会影响外部数组本身。例如，`arr[0] = new_data;`。
