问题记录：

1、输入变量中无反变量提供的组合逻辑电路设计（*第四章组合逻辑电路的设计*P37）

正沿触发：时钟脉冲(CP)从1开始变化

2、维持阻塞正沿触发D触发器（维阻正DFF），不是特别懂，考吗？呜呜呜~*书 P136，PPT触发器_46*

3、触发器的应用举例+时序分析（传输延迟，建立时间和保持时间）*PPT67页，书 P164*



阻塞赋值：

非阻塞赋值：



## Verilog程序

[word详细总结](D:\2020study\1.课程学习\数字逻辑\00数字逻辑复习\数字逻辑复习\Verilog.docx)

==**四大部分：**模块端口声明、IO端口定义、信号类型声明、功能描述==

<img src="%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201228010202132.png" alt="image-20201228010202132" style="zoom:50%;" />

信号类型：19种数据类型，最常见的四种：wire（不能存储值）\reg（memory数组）\parameter\integer

逻辑功能定义：

1、<code>assign</code>：**连续赋值语句（组合逻辑）**

2、元件例化：**门**元件例化，**模块**元件例化<code>元件名 实例名（端口列表）</code>

> 门关键字：not，and，nand，or，nor，xor，xnor，buf，
>
> bufif1，bufif0，notif1，notif0（各种三态门）

**门**元件例化：每个实例元件的名字必须唯一！以避免与其它调用元件的实例相混淆。（例化元件名也可以省略！）

**模块**元件例化：

- 模块实例化时实例**必须有一个名字**。

- 使用**位置映射**时，端口次序与模块的说明相同。

- 使用**名称映射**时，端口次序与位置无关

- 没有连接的输入端口初始化值为**x**。

3、<code>always</code>结构说明语句

注1：“always” 块语句常用于描述时序逻辑，也可描述组合逻辑。

注2：“always” 块可用多种手段来表达逻辑关系，如用**过程赋值语句**、if-else、case、for、while、repeat、task、function。

注3： “always” 块语句与assign语句是并发执行的， assign语句一定要放在“always” 块语句之外！





wire：线网(nets型变量)，默认值为z，表示assign关键字指定的组合逻辑信号，verilog中输入输出信号缺省时自动定义为wire类型，可做**任何方程式的输入、assign语句或实例元件的输出**（输出始终随输入的变化而变化的变量）

reg：通常表示存储数据的空间，并不严格对应于电路上的存储单元，默认初始值为x。register型变量与nets型变量的根本区别是： register型变量需要被明确地赋值，并且在被重新赋值前一直保持原值。register型变量必须通过**过程赋值语句赋值**！不能通过assign语句赋值！**在过程块内被赋值的每个信号必须定义成register型**。



memory型：reg型变量建立数组，以对存储器建模，可描述RAM型存储器，ROM存储器和reg文件。数组中的每一个单元通过一个**数组索引**进行寻址。memory型数据是通过扩展**reg型数据的地址范围**来生成的。进行寻址的地址索引可以是表达式，这样就可以对存储器中的不同单元进行操作。表达式的值可以取决于电路中其它的寄存器的值。

在同一个数据类型声明语句里，可以同时定义存储器型数据和reg型数据。

```verilog
parameter wordsize=16, //定义二个参数。
memsize=256;
reg [wordsize-1:0] mem[memsize-1:0],writereg, readreg;

//注意：一个由n个1位寄存器构成的存储器组是不同于一个n位的寄存器的。
reg [n-1:0] rega; //一个n位的寄存器
reg mema [n-1:0]; //一个由n个1位寄存器构成的存储器组
// 不同之处：一个n位的寄存器可以在一条赋值语句里进行赋值，而一个完整的存储器则不行。如果想对memory中的存储单元进行读写操作，必须指定该单元在存储器中的地址。
rega =0; //合法赋值语句
mema =0; //非法赋值语句
mema[3]=0; //给memory中的第3个存储单元赋值为0。
```



共同点：在定义时要设置位宽，缺省为1位

reg: 存储单元

wire: 物理连线

```verilog
module display_7seg(
	input CLK,
    input SW_in,
    output [10:0] display_out
	);
    reg [19:0]count=0;
    reg [2:0]sel=0;
    parameter T1MS=5000;
    always@(posedge CLK) //posedge?
        begin
            if(SW_in==0)
                begin 
                    case(sel)
                    0:display_out<=11'b0111_1001111;
                    1:display_out<=11'b1011_0010010;
                    2:display_out<=11'b1101_0000110;
                    3:display_out<=11'b1110_1001100;
                    default:display_out<=11'b1111_1111111;
                    endcase
.......未完待续
  
    
```

运算符及表达式

> 运算符按其功能可分为以下几类
>
> 1) 算术运算符(+,－,×，/,％)
>
> 2) 赋值运算符(=,<=)
>
> 3) 关系运算符(>,<,>=,<=)
>
> 4) 逻辑运算符(&&,||,!)
>
> 5) 条件运算符(?:)
>
> 6) 位运算符(\~,|,\^**按位异或**,&,\^~**按位同或**)
>
> 7) 移位运算符(<<,>>)
>
> 8) 拼接运算符({ })
>
> 9) 其它

![image-20201226153401312](%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201226153401312.png)

![image-20201226153420900](%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201226153420900.png)

![image-20201226153511776](%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201226153511776.png)

![image-20201226154231614](%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201226154231614.png)

![image-20201226154303324](%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201226154303324.png)

![image-20201226154513987](%E6%95%B0%E5%AD%97%E9%80%BB%E8%BE%91%E7%AC%94%E8%AE%B0_lyq.assets/image-20201226154513987.png)

避免生成锁存器的原则： 

如果用到if语句，最好写上else项，且else项也不能写成q=q（即不能写成保持原值的逻辑，这样还是会生成一个锁存器）； 

如果用到case语句，最好写上default项。

**循环语句**：

forever

repeat

while

for

**结构说明语句**

<code>initial</code>:一开始就执行，只执行一次

<code>always</code>：一开始就执行，不断重复

**边沿触发**：综合可自动转换为**寄存器组+门级组合逻辑结构**，描述时序行为，如有限状态机

**电平触发**：综合可自动转换为**门级组合逻辑结构/带锁存器的组合组合逻辑结构**，描述组合逻辑行为

<code>task、function</code>

Verilog描述

行为模块（从行为和功能的角度描述电路模块）系统级、算法级、RTL级

结构模块（从电路结构的角度描述电路）门级、开关级

所有综合器都支持门级、RTL级HDL程序综合为标准门级结构网表

##### 串口和并口的区别

串口变并口，并行存取

变量——变化频率，变化来源，变化规律，不要统称“变量”

基本器件——>基本器件组合——>寄存器、计数器



# 组合逻辑电路设计

## **设计步骤**

- 逻辑抽象成true table
  - 确定input 和output变量
  - 定义**逻辑状态**含义
  - 因果关系列出**真值表**，一般是==成真赋值分析==

- 实现满足要求的逻辑控制电路
- 选定器件类型：**SSI、MSI、PLD等**
- 逻辑函数化简得到函数式（根据器件类型）
- 根据函数式画出逻辑电路图

> **问题记录**
>
> 1、与非门？

## 竞争与冒险现象

**竞争**：两个==相反==变化，存在时间差异

**冒险**：因为竞争可能产生的输出干扰脉冲

**竞争：当一个逻辑门的两个输入端的信号同时向相反方向变化，而变化的时间有差异的现象。**

**冒险：两个输入端的信号取值的变化方向是相反时，如门电路输出端的逻辑表达式简化成两个互补信号相乘或者相加，由竞争而可能产生输出干扰脉冲的现象。**

*有竞争不一定有冒险*

**检查竞争－冒险现象** 

1、可通过逻辑函数式判断组合逻辑电路中是否有竞 争－冒险存在。只要输出端的逻辑函数在一定条件下能化简成 $Y=A+\overline{A}$ 或 $Y = A\cdot\overline{A}$ 的形式，则可判定存在竞争 －冒险（此方法适用于任何瞬间只可能有一个输入变量改 变状态的情况）。 

2、如果是“与或式”（积之和，SOP），得到最小项，画卡诺图的**已有圈**，如果**已有圈**相切（即由变化不连续覆盖），则由冒险现象

3、用计算机辅助分析，运行数字电路的模拟程序。 

4、用实验检查

**消除竞争-冒险现象**

1)接入滤波电容

2)引入选通脉冲

3)增加冗余项的方法消除竞争－冒险现象。

**门路实例化**

```Vhdl
module muxtwo(out,a,b,sl); 
input  a,b,sl; 
output  out; 
reg out; 
always @ (sl or a or b) 
    if(!sl)  out=a; 
    else  out=b; 
endmodule
```

```verilog
module mux4_1(out,in1,in2,in5,in4,cntrl1,cntrl2); 		
output out;
input in1,in2,in5,in4,cntrl1,cntrl2; 		
assign out= cntrl1 ? (cntrl2 ? in4 :in5) : (cntrl2 ? in2 :in1) ; 
endmodule 
```

# FSM三段式

```verilog
// 状态声明
parameter s0=2'b00,s1=2'b01,s2=2'b10,s3=2'b11;
reg[1:0] curr,next;
// 第一段，状态保存
always@(posedge clk or posedge rst) begin
    if(rst) curr<=s0;
    else curr<=next;
end
// 第二段，状态切换
always@(din,curr) begin
    case(curr)
        s0:
        s1:
        s2:
        s3:
		default:
    endcase
end
// 第三段，输出
always@(din,curr,rst) begin // mealy
    ......
end
always@(curr,rst)begin // moore
    ......
end  
```

触发器：



















# 学习参考

整理以下器件的基本工作原理、用途、对应的Verilog代码（对于有位数的，可以以4位的为具体例子，但要考虑扩展问题，可以在网上先学习、找到相关资料），以文档形式整理好，这是一个长期的作业，需要不断积累，先布置给大家，应该是几周以后会收，目前由于Verilog语言还没有开始，得等等了。
1、编码器
2、译码器
3、BCD七段数码管字符译码器
4、数据分配器（DEMUX）
5、数据选择器（MUX）
6、数值比较强
7、全加器

> https://hdlbits.01xz.net/wiki/Problem_sets
>
> http://www.digilent.com.cn/study.html?class=26
>
> https://mp.weixin.qq.com/s/SMyVQ_EbBzRhcXafubbg-A





















![img](https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1165931948,167592321&fm=26&gp=0.jpg)

![img](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1602236286752&di=008b24206333cdfdf205ed86f9c06e42&imgtype=0&src=http%3A%2F%2Fp5.qhmsg.com%2Fdmsmty%2F849_888_%2Ft01368c086293084bc7.jpg)

写出输出函数和激励函数表达式

做出状态转移真值表

做出状态图和状态表

做状态响应序列和时序图



同步时序逻辑电路设计

小规模集成电路：尽可能少的触发器和门电路

1、建立原始状态图

2、原始状态图简化---->等效状态图<kbd>观察法化简，隐含表化简</kbd>

最小化状态表（最小闭覆盖）：覆盖性、最小性、闭合性

设计电路的时候：

选定一个触发器，根据触发器的现次态公式和根据功能推出的状态表（已知现次态），推出触发器激励信号的函数（激励函数）

- 写一个程序，自动带入解决上述的问题，自动求出即可。
- 一个一个带入计算嘛，反正最多四种情况
- 写现次态的卡诺图计算呀~直接带入求解，很快！！