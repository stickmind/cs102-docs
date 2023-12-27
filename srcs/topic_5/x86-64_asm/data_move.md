# 数据传送指令

在 C 中，我们可以使用 `memcpy` 将某个字节块的信息拷贝到另一个地方；在汇编中，也有类似的存在。使用 `mov` 指令，可以把字节信息从某个源转移到目的地。

```asm
mov  src, dst    // a.k.a. dst = src
```

这里的操作数 `src/dst` 类型可以是：

- 立即数：整型常量数据，以 `$` 开头，例如 `$0x104`
- 寄存器：来自上文介绍的 16 个通用寄存器，例如 `%rbx`
- 内存地址：寻址模式较为复杂，主要是 **Imm(r{sub}`b`, r{sub}`i`, s)** 的变种，例如 `0x10(%rax,%rdx)`

常见的 `mov` 指令组合形式总结如下：

| 操作码 Op | 源 Src | 目的地 Dst | 示例                | C                |
| --------- | ------ | ---------- | ------------------- | ---------------- |
| mov       | Imm    | Reg        | `mov $0x4, %rax`    | `a = 4;`         |
| mov       | Imm    | Mem        | `mov $-147, (%rax)` | `*ptr_a = -147;` |
| mov       | Reg    | Reg        | `mov %rax, %rdx`    | `b = a;`         |
| mov       | Reg    | Mem        | `mov %rax, (%rdx)`  | `*ptr_b = a;`    |
| mov       | Mem    | Reg        | `mov (%rax), %rdx`  | `b = *ptr_a;`    |

```{admonition} 注意
:class: attention

**无法从某个内存直接转移数据到另一个内存**！这种情况需要两条指令：

- 第一条指令将源 Src 加载到寄存器中
- 第二条指令将该寄存器值写入目的地 Dst
```

## 数据大小

前面的课程已经学习过数据的表示。C 语言有多种不同的数据类型，每个类型占用的字节数也不同：

- 整型数据，例如 `char`、`short`、`unsigned int`、`char*` 等
- 浮点数据，例如 `float`、`double` 等
- 聚合类型，例如 `array`、`struct` 等，本质上是连续的字节块

x86-64 汇编语言针对不同的数据类型都有对应的指令，但其**数据大小术语**需要做些调整：

- Byte 表示 1 个字节，在指令集中，使用 `b` 作后缀
- Word 表示 2 个字节，在指令集中，使用 `w` 作后缀
- Double word 表示 4 个字节，在指令集中，使用 `l` 作后缀
- Quad word 表示 8 个字节，在指令集中，使用 `q` 作后缀

| C 类型 | Intel 类型       | 汇编后缀 | 字节大小 |
| ------ | ---------------- | -------- | -------- |
| char   | Byte             | b        | 1        |
| short  | Word             | w        | 2        |
| int    | Double word      | l        | 4        |
| long   | Quad word        | q        | 8        |
| char*  | Quad word        | q        | 8        |
| float  | Single precision | s        | 4        |
| double | Double precision | l        | 8        |

对于 `mov` 指令，不同的数据大小延申出如下几种变体：

| 操作码 Op | 源 Src | 目的地 Dst | 说明                    |
| --------- | ------ | ---------- | ----------------------- |
| movb      | Src    | Dst        | Move byte               |
| movw      | Src    | Dst        | Move word               |
| movl      | Src    | Dst        | Move double word        |
| movq      | Src    | Dst        | Move quad word          |
| movabsq   | Imm    | Reg        | Move absolute quad word |

对于立即数的源，常规的 `movq` 指令只能操作 32 位表示的 2 的补码数字，然后通过**符号扩展**得到 64 位的值。为了能够操作任意 64 位立即数，可以使用 `movabsq` 指令，并且目的位置必须是寄存器。例如，

```
movabsq $0x0011223344556677, %rax  // %rax: $0x0011223344556677
```

## 寄存器字节扩展

当以寄存器为目标时，即加载（load）数据时，需要注意以下一些规则。

如果值小于 8 个字节，常规的指令（`mov` 等）有两条规则：

  - 1 字节和 2 字节的值，将保持寄存器剩下的字节信息不变
  - 4 字节的值，会把寄存器高位 4 个字节设置为 0

如果想要明确将寄存器剩余字节填充为 0 或符号位，可以使用零扩展 `movz` 和符号扩展 `movs` 两类指令。

- 零扩展 `movz` 常见操作指令

    | 操作码 Op | 源 Src | 目的地 Dst | 说明                                   |
    | --------- | ------ | ---------- | -------------------------------------- |
    | movzbw    | Src    | Reg        | Move zero-extended byte to word        |
    | movzbl    | Src    | Reg        | Move zero-extended byte to double word |
    | movzwl    | Src    | Reg        | Move zero-extended word to double word |
    | movzbq    | Src    | Reg        | Move zero-extended byte to quad word   |
    | movzwq    | Src    | Reg        | Move zero-extended word to quad word   |

- 符号扩展 `movs` 常见操作指令，注意 `cltq` 只用于 `%eax` 和 `%rax`

    | 操作码 Op | 源 Src | 目的地 Dst | 说明                                        |
    | --------- | ------ | ---------- | ------------------------------------------- |
    | movsbw    | Src    | Reg        | Move sign-extended byte to word             |
    | movsbl    | Src    | Reg        | Move sign-extended byte to double word      |
    | movswl    | Src    | Reg        | Move sign-extended word to double word      |
    | movsbq    | Src    | Reg        | Move sign-extended byte to quad word        |
    | movswq    | Src    | Reg        | Move sign-extended word to quad word        |
    | movslq    | Src    | Reg        | Move sign-extended double word to quad word |
    | cltq      | %eax   | %rax       | Move sign-extended %eax to %rax             |

## 内存地址模式

内存寻址模式较为复杂，主要是根据 **Imm(r{sub}`b`, r{sub}`i`, s)** 演变出的变种：

- Imm 立即数偏移地址
- r{sub}`b` 基址寄存器，_必须是 64 位寄存器_
- r{sub}`i` 变址寄存器，_必须是 64 位寄存器_
- s 比例因子，_必须是 1、2、4、8_

常见的几种内存寻址模式：


| 地址类型  | 格式                     | 值                                      | 名称                |
| --------- | ------------------------ | --------------------------------------- | ------------------- |
| Immediate | $Imm                     | Imm                                     | Immediate           |
| Register  | r{sub}`a`                | R[r{sub}`a`]                            | Register            |
| Memory    | Imm                      | M[Imm]                                  | Absolute            |
| Memory    | (r{sub}`a`)              | M[R[r{sub}`a`]]                         | Indirect            |
| Memory    | Imm(r{sub}`b`)           | M[Imm + R[r{sub}`b`]]                   | Base + displacement |
| Memory    | (r{sub}`b`,r{sub}`i`)    | M[R[r{sub}`b`] + R[r{sub}`i`]]          | Indexed             |
| Memory    | Imm(r{sub}`b`,r{sub}`i`) | M[Imm + R[r{sub}`b`] + R[r{sub}`i`]]    | Indexed             |
| Memory    | (,r{sub}`i`,s)           | M[R[r{sub}`i`]. s]                      | Scaled indexed      |
| Memory    | Imm(,r{sub}`i`,s)        | M[Imm + R[r{sub}`i`]. s]                | Scaled indexed      |
| Memory    | (r{sub}`b`,r{sub}`i`,s)  | M[R[r{sub}`b`] + R[r{sub}`i`]. s]       | Scaled indexed      |
| Memory    | Imm(r{sub}`b`,ri,s)      | M[Imm + R[r{sub}`b`] + R[r{sub}`i`]. s] | Scaled indexed      |
