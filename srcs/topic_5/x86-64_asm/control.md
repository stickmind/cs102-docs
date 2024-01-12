# 控制指令

程序指令可以一条接着一条顺序执行，也可以通过条件测试改变执行的顺序。在 x86-64 汇编中，执行顺序的控制有两种实现方式：无条件跳转和有条件跳转。


## 认识硬件：程序计数器

程序计数器（program counter），通常简称 PC 寄存器，在 x86-64 汇编中使用 `%rip` 表示。

在计算机中，这是一个特别用途的寄存器，**用于记录下一条即将执行的指令的内存地址**。一旦处理器完成了当前指令的执行，PC 寄存器就会将保存的指令地址交给处理器继续执行，同时更新为下一条指令的地址。默认情况下，PC 寄存器会更新到紧接着的下一条指令，类似 `i++` 的操作。

既然 PC 寄存器记录了 CPU 接下来处理的指令，那么如果有方法可以**修改 PC 寄存器**的值，我们就能够改变 CPU 执行的指令顺序。

在 x86-64 汇编中，通过跳转指令可以改变机器指令执行的顺序，使程序切换到一个全新的位置。

## 无条件跳转

无条件跳转指令 `jmp` 可以*直接*进行跳转，跳转目的地常用 target 或指令地址指定；也可以*间接*跳转，跳转目的地通过寄存器或内存位置读取。

| 指令           | 条件  | 说明          |
| -------------- | :---: | ------------- |
| `jmp Label`    |   1   | Direct jump   |
| `jmp *Operand` |   1   | Indirect jump |

如下汇编示例中，当执行到指令 `jmp .L1` 处，程序会跳过 `movq` 指令，而从 `.L1` 标记的 `popq` 开始执行。

```asm
	movq $0,%rax
	jmp .L1             # 跳转到 .L1
	movq (%rax),%rdx    # 跳过
.L1:
	popq %rdx           # 跳转目标
```

常见的写法还有如下几种：

```asm
jmp 404f8 <loop+0xb>  # 跳转目标为 0x404f8
jmp *%rax             # 跳转目标为 %rax 的值
jmp *(%rax)           # %rax 的值定义了内存位置，跳转目标为内存的值
```

## 认识硬件：状态寄存器

在 C 中，有 `if`、`else`、`while` 等控制语句，这些语句会根据条件的真假来确定执行的语句块。

在 x86-64 汇编中，也提供了类似跳转指令，可以根据条件状态来确定跳转的目标。汇编层面的条件判断需要硬件来支持，这类硬件称为**状态寄存器**（condition code），其状态反映了最近的算术或逻辑操作的属性。

常见的条件码有如下几种：
- **CF**（Carry flag）最近的操作发生了溢出（无符号整型）
- **ZF**（Zero flag）最近的操作生成了 0 值
- **SF**（Sign flag）最近的操作生成了负值（有符号整型）
- **OF**（Overflow flag）最近的操作发生了溢出（有符号整型）

## 比较和测试

`cmp` 指令和 `sub` 指令行为类似，`test` 指令和 `and` 指令行为类似。这两个指令都不保存结果，仅影响条件码。

| 指令          | 基于      |  说明   |
| ------------- | --------- | :-----: |
| `cmp S1, S2`  | `S2 - S1` | Compare |
| `test S1, S2` | `S1 & S2` |  Test   |

`test` 指令可以利用前面介绍的位运算，实现一些典型的用途：

- 判断正负：两个操作数一致，可以检查该操作数是正数还是负数
- 判断位模式：其中一个操作数使用掩码，可以测试某些位的状态

根据字节长度的变体形式，和 `mov` 指令相同，例如 `cmpq` 表示 8 字节，`testl` 表示 4 字节。

## 条件跳转

条件跳转指令会根据条件码的某种状态或组合，决定是否跳转到标签所指的位置。以 `je` 指令为例，即“当相等时跳转”，当 `a == b` 时，得到 `t = 0`，此时 `ZF` 置 1 就表示相等。

| 指令         | 同类指令 |        条件        | 说明                         |
| ------------ | -------- | :----------------: | ---------------------------- |
| `je target`  | `jz`     |        `ZF`        | Equal / zero                 |
| `jne target` | `jnz`    |       `~ZF`        | Not equal / not zero         |
| `js target`  |          |        `SF`        | Negative                     |
| `jns target` |          |       `~SF`        | Nonnegative                  |
| `jg target`  | `jnle`   | `~(SF ^ OF) & ~ZF` | Greater (signed >)           |
| `jge target` | `jnl`    |    `~(SF ^ OF)`    | Greater or equal (signed >=) |
| `jl target`  | `jnge`   |     `SF ^ OF`      | Less (signed <)              |
| `jle target` | `jng`    | `(SF ^ OF) \| ZF`  | Less or equal (signed <=)    |
| `ja target`  | `jnbe`   |    `~CF & ~ZF`     | Above (unsigned >)           |
| `jae target` | `jnb`    |       `~CF`        | Above or equal (unsigned >=) |
| `jb target`  | `jnae`   |        `CF`        | Below (unsigned <)           |
| `jbe target` | `jna`    |     `CF \| ZF`     | Below or equal (unsigned <=) |

在汇编层面，通常需要两条指令配合才能决定执行的位置，常见的模式如下：

- 一条指令设置条件状态，例如 `cmp S1, S2`
- 一条指令基于条件跳转，例如 `je [target]`

```asm
cmp $2, %edi
jg [target]

cmp $1, %edi
jle [target]
```

```{admonition} 小节
:class: tip

- 对于大多数算术运算，不管是有符号还是无符号，在位级别的处理上完全一致。也就是说，机器代码不会将数据值和数据类型进行关联。
- 少数计算，例如逻辑右移和算术右移，会提供不同的指令分别处理有符号和无符号数值。
- 可以发现，跳转指令处理有符号和无符号是通过 `SF ^ OF` 和 `CF` 的几种组合决定。
```

## 设置字节

设置指令可以根据条件码的某种组合，将一个字节设置为 0 或 1。

- 其变种的名称/跳转条件和条件跳转指令一致
- 操作数 D 可以是单字节寄存器，也可以是单字节内存地址

当操作数为寄存器时，不会影响其他字节。但通常情况，该指令会搭配 `movzbl` 指令进行零扩展操作，所以这种情况下，高字节会被设置为零。

| 指令      | 同类指令 |          效果          | 说明                         |
| --------- | -------- | :--------------------: | ---------------------------- |
| `sete D`  | `setz`   |        `D ← ZF`        | Equal / zero                 |
| `setne D` | `setnz`  |       `D ← ~ZF`        | Not equal / not zero         |
| `sets D`  |          |        `D ← SF`        | Negative                     |
| `setns D` |          |       `D ← ~SF`        | Nonnegative                  |
| `setg D`  | `setnle` | `D ← ~(SF ^ OF) & ~ZF` | Greater (signed >)           |
| `setge D` | `setnl`  |    `D ← ~(SF ^ OF)`    | Greater or equal (signed >=) |
| `setl D`  | `setnge` |     `D ← SF ^ OF`      | Less (signed <)              |
| `setle D` | `setng`  | `D ← (SF ^ OF) \| ZF`  | Less or equal (signed <=)    |
| `seta D`  | `setnbe` |    `D ← ~CF & ~ZF`     | Above (unsigned >)           |
| `setae D` | `setnb`  |       `D ← ~CF`        | Above or equal (unsigned >=) |
| `setb D`  | `setnae` |        `D ← CF`        | Below (unsigned <)           |
| `setbe D` | `setna`  |     `D ← CF \| ZF`     | Below or equal (unsigned <=) |

## 条件数据移动

`cmov` 指令可以根据条件码状态，有选择地将源 $S$ 中的数据移动到目的地 $R$ 中。

- 根据条件状态，寄存器 $D$ 要么改变，要么保持不变
- 这里的 $S$ 可以是内存地址或寄存器，而 $D$ 只能是寄存器
- 对于一些简单的条件判断表达式，执行效率相比较跳转指令更快

| 指令          | 同类指令  |        条件        | 说明                         |
| ------------- | --------- | :----------------: | ---------------------------- |
| `cmove S, R`  | `cmovz`   |        `ZF`        | Equal / zero                 |
| `cmovne S, R` | `cmovnz`  |       `~ZF`        | Not equal / not zero         |
| `cmovs S, R`  |           |        `SF`        | Negative                     |
| `cmovns S, R` |           |       `~SF`        | Nonnegative                  |
| `cmovg S, R`  | `cmovnle` | `~(SF ^ OF) & ~ZF` | Greater (signed >)           |
| `cmovge S, R` | `cmovnl`  |    `~(SF ^ OF)`    | Greater or equal (signed >=) |
| `cmovl S, R`  | `cmovnge` |     `SF ^ OF`      | Less (signed <)              |
| `cmovle S, R` | `cmovng`  | `(SF ^ OF) \| ZF`  | Less or equal (signed <=)    |
| `cmova S, R`  | `cmovnbe` |    `~CF & ~ZF`     | Above (unsigned >)           |
| `cmovae S, R` | `cmovnb`  |       `~CF`        | Above or equal (unsigned >=) |
| `cmovb S, R`  | `cmovnae` |        `CF`        | Below (unsigned <)           |
| `cmovbe S, R` | `cmovna`  |     `CF \| ZF`     | Below or equal (unsigned <=) |

现代处理器采用**分支预测**进行条件跳转，以保证流水线包含连续指令。但实际上，现代处理器的预测率只能达到 50%，一旦预测失败，就会浪费大约 15 到 30 个时钟周期。

对于一些较为简单的条件表达式，例如 `expr ? then : else`，可以使用条件数据移动指令，替代条件跳转指令，以避免预测失败造成严重的性能下降。

```{admonition} 状态寄存器的读写
:class: tip

**设置条件码**：除了 `leaq` 外，大部分算术逻辑操作都会影响条件码的状态，一些特殊的规则如下：

- 逻辑操作，CF 和 OF 都会置 0
- 移位操作，CF 设置为最后一个被移出的位，OF 置 0
- `inc` 和 `dec` 操作，ZF 和 OF 都会置 1，CF 保持不变
  
还有两类指令只改变条件码，不改变任何其他寄存器。例如，`cmp` 和 `sub` 行为类似，`test` 和 `and` 行为类似，区别是 `cmp/test` 只设置条件码，而 `sub/and` 会将结果写回目的寄存器。

**访问条件码**：条件码通常不会直接读取，常用的方法有三种：

- 根据条件码的某种组合，将一个字节设置为 0 或 1，例如 `set` 指令
- 根据条件码状态，跳转到程序的某个其他部分，例如 `je` 指令
- 有条件地传送数据，例如 `cmov` 指令
```
