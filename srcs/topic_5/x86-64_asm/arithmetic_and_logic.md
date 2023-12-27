# 算术与逻辑指令

x86-64 的一些算术和逻辑操作，大部分的指令都类似 `mov` 的结构和其变种。学习时注意知识的迁移，方便理解。

例如，加法指令同样可以分为四类：`addb` 、`addw`、`addl` 和 `addq`，分别是字节加法、字加法、双字加法和四字加法。

## 加载有效地址

**加载有效地址**（load effective address）指令 `leaq/leal` 是 `movq/movl` 指令的变形。

`lea` 指令区别于 `mov` 指令的地方在于如何处理源 Src，且 `lea` 指令的目的地 Dst 必须是寄存器。

| 指令      | 源 Src | 目的地 Dst | 示例                        | C         |
| --------- | ------ | ---------- | --------------------------- | --------- |
| leaq/leal | Mem    | Reg        | `leal 5(%rdi,%rdi,8), %eax` | `9*x + 5` |

内存上的字节包含两个信息，一个是该字节的内存地址，一个是该字节内部的位模式（数据）。

`lea` 指令计算出内存地址后，直接将该地址值存入 Dst；而 `mov` 指令计算出内存地址后，将该字节内部位模式（数据）存入 Dst。

`lea` 指令常用来**简化算术运算**，参见上述示例。这种情况与有效地址计算没有任何关系。

```{admonition} 注意
:class: attention

指令 `lea` 在 x86-64 架构中常见的有两种数据大小变种 `leaq` 和 `leal`，尝试修改[示例](https://godbolt.org/z/Ghf9s7GdK)的变量类型进行测试。
```

## 一元操作

一元操作（unary operation）只有一个操作数 D，既是源又是目的。这个操作数可以是一个寄存器，也可以是一个内存。

| 指令  | 效果    | 说明       |
| ----- | ------- | ---------- |
| inc D | D ← D+1 | Increment  |
| dec D | D ← D−1 | Decrement  |
| neg D | D ← -D  | Negate     |
| not D | D ← ~D  | Complement |

可以类比 C 中的自增/自减操作。

```
incq 16(%rax) // 使 16(%rax) 位置的内存值加 1
dec %rdx
not %rcx
```

## 二元操作

操作数 S 可以是立即数、寄存器或内存，操作数 D 可以是寄存器或内存。

```{admonition} 注意
:class: attention

S 和 D 不能同时为内存！（还记得原因吗？）
```

可以读作：把 D 中的值加上/减去 S 中的值。

| 指令      | 效果       | 说明         |
| --------- | ---------- | ------------ |
| add S, D  | D ← D + S  | Add          |
| sub S, D  | D ← D − S  | Subtract     |
| imul S, D | D ← D ∗ S  | Multiply     |
| xor S, D  | D ← D ^ S  | Exclusive-or |
| or S, D   | D ← D \| S | Or           |
| and S, D  | D ← D & S  | And          |

可以类比 C 中的赋值运算符，例如 `x -= y`。

```
addq %rcx,(%rax)
xorq $16,(%rax, %rdx, 8)
subq %rdx,8(%rax)
```

## 移位操作

**移位操作**（shift operation）中，第一项 k 为移位量，第二项 D 是要移位的数据值。可以进行逻辑位移，也可以进行算术位移。

- 移位量 k 可以是立即数，或者单字节寄存器 `%cl`，注意这里的单字节比较特殊。
- 数据值 D 可以是寄存器或内存。

| 指令     | 效果               | 说明                     |
| -------- | ------------------ | ------------------------ |
| sal k, D | D ← D << k         | Left shift               |
| shl k, D | D ← D << k         | Left shift (same as sal) |
| sar k, D | D ← D >>{sub}`A` k | Arithmetic right shift   |
| shr k, D | D ← D >>{sub}`L` k | Logical right shift      |

```
shll $3,(%rax)
shrl %cl,(%rax,%rdx,8)
sarl $4,8(%rax)
```

单字节寄存器 `%cl` 有 8 个位，理论上可以实现 0~255 种不同的移位量。但是，实际的移位量只会用到 `%cl` 低 $m$ 个位，且 $m$ 的值由移位的数据值决定。假设数据值的位宽是 $w$ ，则

$$m = log_2w$$

```{admonition} 补充
:class: note

此类指令有时也会省略 $k$，只有一个操作数，此时 $k$ 默认值为 1。
```

## 特殊算术运算

如果将两个 64 位的数相乘，得到的结果需要 128 位来保存。x86-64 指令集对 128 位数的操作提供了 `imulq/mulq` 两条指令。

此时，不同于上述双操作数的 `imul` 指令（乘积为 64 位值），这里的 `imulq/mulq` 是单操作数指令。之所以是单操作数，是因为这两条指令都要求使用 `%rax` 作默认的一个乘数，另一个乘数以 S 形式给出。乘积则分别存放在 `%rdx` （高 64 位）和 `%rax`（低 64 位）中，从而解决了大数乘积的问题。

注意，根据上述分析，`imulq` 可能出现两种形式，一种是双操作数，另一种是单操作数。 对此不用担心，汇编器会自行判断。


| 指令    | 效果                          | 说明                   |
| ------- | ----------------------------- | ---------------------- |
| imulq S | R[%rdx]:R[%rax] ← S × R[%rax] | Signed full multiply   |
| mulq S  | R[%rdx]:R[%rax] ← S × R[%rax] | Unsigned full multiply |

x86-64 支持 128 位的被除数。此时，`idivq/divq` 默认将 `%rdx`（高 64 位）和 `%rax`（低 64 位）构成的值当作被除数；除数则以 S 的形式给出。计算的结果，商存放在 `%rax` 中，模存放在 `%rdx` 中。

| 指令    | 效果                                                                | 说明            |
| ------- | ------------------------------------------------------------------- | --------------- |
| idivq S | R[%rdx] ← R[%rdx]:R[%rax] mod S; <br> R[%rax] ← R[%rdx]:R[%rax] ÷ S | Signed divide   |
| divq S  | R[%rdx] ← R[%rdx]:R[%rax] mod S; <br> R[%rax] ← R[%rdx]:R[%rax] ÷ S | Unsigned divide |

对于 64 位的被除数，此时仅需 `%rax` 就足以保存，`%rdx` 则根据情况补零（无符号）或补符号位（有符号）。

那么，对于有符号整型除法，如何将 `%rax` 的符号位填充到 `%rdx` 中呢？这个操作由 `cqto` 指令完成。该指令不需要操作数，默认读出 `%rax` 的符号位，并复制到 `%rdx` 的所有位中。

| 指令 | 效果                                  | 说明                |
| ---- | ------------------------------------- | ------------------- |
| cqto | R[%rdx]:R[%rax] ← SignExtend(R[%rax]) | Convert to oct word |
