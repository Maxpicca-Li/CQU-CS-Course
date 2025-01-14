论述题（5分*6）

判断题（2分*10）

==3道编程题（20+20+10分）==

复习计划：不需要通看PPT(很痛苦)，只需要按照老师说的点，整理材料即可。

- 论述：
  - 什么是嵌入式
  - GPIO，什么是串口
  - 波特率的计算
    - 给一个整数部分、小数部分，求波特率
  - systick
  - 状态机
  - 中断
  - PWM:脉冲宽度调制，怎么切换的问题
- 判断：
  - 中断
  - AD转换
  - 串口通信
- 编程：
  - 串口
    - 初始化，输入输出
    - 怎么传数据
  - 中断
    - LED灯的中断，systick的设计，定时闪烁（如每隔5s闪烁）
  - 状态机的设计：综合考试，**跑马灯**
    **关键**：串口传输数据，systick，中断，状态机，GPIO，(AD转换)
    (灯1，灯2，灯3，灯4，灯2，灯3，灯4，灯1；灯1，灯2，灯3，灯4，灯2，灯3，灯4，灯1；……)
    - systick，灯亮的时间
    - 状态机
      - 输出→等待systick→输入→进入下一状态→循环1
      - 循环：利用模运算，确定每轮次的位置

> PPT的例子
>
> 两个开发板分别负责控制和执行，需要利用串口进行传输

----

- 嵌入式基本概念和认识

  - **特点，发展，趋势**
  - 基本概念 + 芯片落实时的工作模式
  - 嵌入式发展趋势：智能硬件，边缘计算（嵌入式及其衍生）
- 正逻辑和负逻辑
- GPIO，LR2，串口通信、UART、异步逻辑
  - 变成代码及其相关配置，写出实质
- 常见的位操作， & 和 | 典型的操作含义（嵌入式有特点的编程）
- 波特率设置
- 数模转换+模式转换 （主要用在传感器）
- **项目代码**
  - ==GPIO端口定义代码==
    - 输入输出
    - 模拟
  - AD转换，配置代码
  - system timer的设置，1ms → 10ms 
    - 利用系统时间，定时、定次
    - PLL的设置（始终偏移后的拉回），精确定时，初始化（时钟源的设置）
    - 通用定时器GPTM
  - ==UART代码==
    - **设置波特率**，针对串口通信，设置时钟，保证同步
    - 两个板子之间的通信，**数据流程图设计**
  - 有限状态机，做==**红绿灯**==
    - 基本概念、数据结构的设计
    - 函数意义，及其每个状态变化的点
    - ==算法==
  - 中断 Interrupt
    - 时钟中断 → 定时器
    - 中断的类型
    - 代码中，中断代码的识别
  - 一些基本概念
    - GPIO芯片的输入输出配置
    - DA转换(声音的输出)，AD转换，奈克思维采样定理
    - 根据某端口，利用C语言进行相关设置 → **把例子搞懂！！！**
    - **把7个实验都看懂，哪一个部分在干啥**

