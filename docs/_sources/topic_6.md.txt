# 堆分配器


```{toctree}
:hidden:

topic_6/lab_6/index
topic_6/final_project/index
```

本阶段主要目标是深入学习 `malloc/realloc/free` 的工作过程，尝试实现一个自己的版本，并对整个学期的内容作一个总结：

- 学习堆分配器（heap allocator）的限制、目标以及假设
- 理解吞吐量（throughput）和利用率（utilization）两个目标之间的冲突
- 学习堆分配器的几种不同的实现方式

为什么这很重要？设计堆分配器需要做出许多设计决策来尽可能优化它。没有完美的设计！所有语言都有一个“堆”，但都以不同的方式操作。
