# 结构体

<div class="toc"></div>

结构体是一个或多个变量的集合，和数组一样，也是一种复合数据类型。结构体将不同数据类型的变量组合到一个名称中，不管是逻辑上还是编程操作上都比较便利，常用于创建较为复杂的数据结构。

## 声明和定义

结构体可以利用基本数据类型来自定义新的数据类型。通过结构体变量访问成员，可以使用点 `.` 操作符；通过结构体变量的指针访问成员变量，可以使用间接引用 `*` 操作符，也可以使用成员访问 `->` 操作符。

```c
struct point {  // declaring a struct type
    int x;
    int y;  // members of each date structure
};

struct point pt;
pt.x = 1;
pt.y = 2;
// or
struct point pt2 = {1, 2};

struct point* ptPtr = &pt;
(*ptPtr).x = 3;
// or
ptPtr->x = 3;
```

## typedef 别名

上述定义方式，每次都要添加 `struct` 关键字，使用 `typedef` 可以定义类型的别名，避免这个问题。

```c
typedef struct point {
    int x;
    int y;
} point;

typedef struct point* point_ptr;

point pt = {1, 2};
point_ptr pt_p = &pt;

printf("pt(%d, %d)\n", pt.x, pt.y);
printf("pt(%d, %d)\n", pt_p->x, pt_p->y);
```

## 函数参数——传值 or 传地址

将结构体传递给函数，和基本类型一致，都是传值。这一定要区别于数组。

为了避免数组拷贝造成的性能问题，可以通过传递指针的方式解决。

```c
void add_points(point_ptr lhs, point_ptr rhs) {
    lhs->x += rhs->x;
    lhs->y += rhs->y;
}

int main(int argc, char* argv[]) {
    point pt = {1, 2};
    point pt2 = {2, 1};
    add_points(&pt, &pt2);
    printf("pt(%d, %d)\n", pt.x, pt.y); // pt(3, 3)
    return 0;
}
```

上述方式，通过指针传递结构体，虽然避免了拷贝，但是却修改了 `lhs` 的值。某些情况下，这是一种不太好的设计。

## 函数返回值

C 允许通过函数返回结构体，所以上述案例可以通过返回值创建一个新的结构体，并利用 `const` 关键字防止修改参数的实体。

```c
point add_points(const point_ptr lhs, const point_ptr rhs) {
    point pt;
    pt.x = lhs->x + rhs->x;
    pt.y = lhs->y + rhs->y;
    return pt;
}

int main(int argc, char* argv[]) {
    point pt1 = {1, 2};
    point pt2 = {2, 1};
    point pt3 = add_points(&pt1, &pt2);
    printf("pt3(%d, %d)\n", pt3.x, pt3.y);

    return 0;
}
```

## 结构体字节宽度

使用 `sizeof` 可以计算整个结构体占用的字节数。

```c
typedef struct date {
    int month;
    int day;       
} date;

int main(int argc, char *argv[]) {
    int size = sizeof(date);    
    printf("size = %d\n", size); // size = 8
    return 0;
}
```

## 嵌套数据类型

数组可以使用结构体作为元素，结构体也可以在内部包含数组成员。

```c
typedef struct date {
    int month;
    int day;       
} date;

data array_of_struct[5];
array_of_struct[0] = (date){3, 1};
```
