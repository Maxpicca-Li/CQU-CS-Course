**目录**

> [TOC]
>

## GPIO

lab1，控制LED开关与颜色

```c
#include "TExaS.h"
#include "tm4c123gh6pm.h"
// 初始化port F的例子，要求如下
// PF4 and PF0 are input SW1 and SW2 respectively
// PF3,PF2,PF1 are outputs to the LED
// Inputs: None
// Outputs: None
void PortF_Init(void){
  volatile unsigned long delay;
  SYSCTL_RCGC2_R |= 0x00000020;    // 1) 启用数字端口F的时钟，0b10_0000即5th bit
  delay = SYSCTL_RCGC2_R;          // delay
  GPIO_PORTF_LOCK_R = 0x4C4F434B;  // 2) unlock PortF(貌似只有F才需要解锁)
  GPIO_PORTF_CR_R = 0x1F;          // allow changes to PF4-0
  GPIO_PORTF_AMSEL_R = 0x00;       // 3) 禁用模拟功能
  GPIO_PORTF_PCTL_R = 0x00000000;  // 4) GPIO clear bit PCTL
  GPIO_PORTF_DIR_R = 0x0E;         // 5) PF4,PF0 input, PF3,PF2,PF1 output，0b0_1110
  GPIO_PORTF_AFSEL_R = 0x00;       // 6) 没有替代功能
  GPIO_PORTF_PUR_R = 0x11;         // PF4和PF0为negative logic,需要使能PF4和PF0上拉电阻，0b1_0001
  GPIO_PORTF_DEN_R = 0x1F;         // 7) 开启数字端口PF4-PF0
}
```

## PLL

### 基本概念

锁相环路：简称锁相环( PLL )，是一种输出一定频率信号的振电路，也称为相位同步环( 回路)。该回路利用外部施加的基准信号与PLL 回路内的振荡器输出的相位差恒定的反馈控制来产生振荡信号。电子设备在正常工作时,通常需要外部的输入信号与内部的振荡信号同步，利用锁相环路就可以实现这个目的。 

PLL可以用于设定系统时钟。

![image-20220608044714866](https://neesky-1304497077.cos.ap-chongqing.myqcloud.com/202206080447922.png)

![image-20220608090814284](https://upload-images.jianshu.io/upload_images/24714066-f736509b8d130f60.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 配置系统频率

```c
 /*如果想知道其他配置的意思，可以看视频3的讲解，其实就是用板载晶振正确的频率与PLL进行比对，从而调整PLL的频率。*/
#include "PLL.h"

// The #define statement SYSDIV2 in PLL.h
// initializes the PLL to the desired frequency.

// bus frequency is 400MHz/(SYSDIV2+1) = 400MHz/(4+1) = 80 MHz
// see the table at the end of this file

#define SYSCTL_RIS_R            (*((volatile unsigned long *)0x400FE050))
#define SYSCTL_RIS_PLLLRIS      0x00000040  // PLL Lock Raw Interrupt Status
#define SYSCTL_RCC_R            (*((volatile unsigned long *)0x400FE060))
#define SYSCTL_RCC_XTAL_M       0x000007C0  // Crystal Value
#define SYSCTL_RCC_XTAL_6MHZ    0x000002C0  // 6 MHz Crystal
#define SYSCTL_RCC_XTAL_8MHZ    0x00000380  // 8 MHz Crystal
#define SYSCTL_RCC_XTAL_16MHZ   0x00000540  // 16 MHz Crystal
#define SYSCTL_RCC2_R           (*((volatile unsigned long *)0x400FE070))
#define SYSCTL_RCC2_USERCC2     0x80000000  // Use RCC2
#define SYSCTL_RCC2_DIV400      0x40000000  // Divide PLL as 400 MHz vs. 200
                                            // MHz
#define SYSCTL_RCC2_SYSDIV2_M   0x1F800000  // System Clock Divisor 2
#define SYSCTL_RCC2_SYSDIV2LSB  0x00400000  // Additional LSB for SYSDIV2
#define SYSCTL_RCC2_PWRDN2      0x00002000  // Power-Down PLL 2
#define SYSCTL_RCC2_BYPASS2     0x00000800  // PLL Bypass 2
#define SYSCTL_RCC2_OSCSRC2_M   0x00000070  // Oscillator Source 2
#define SYSCTL_RCC2_OSCSRC2_MO  0x00000000  // MOSC
// initializes the PLL to the desired frequency.
#define SYSDIV2 4
// bus frequency is 400MHz/(SYSDIV2+1) = 400MHz/(4+1) = 80 MHz
// see the table at the end of this file
void PLL_Init(void);

// configure the system to get its clock from the PLL
void PLL_Init(void){
  // 0) configure the system to use RCC2 for advanced features
  //    such as 400 MHz PLL and non-integer System Clock Divisor
  SYSCTL_RCC2_R |= SYSCTL_RCC2_USERCC2;
  // 1) 初始化的时候，绕开PLL
  SYSCTL_RCC2_R |= SYSCTL_RCC2_BYPASS2;
  // 2) select the crystal value and oscillator source
  SYSCTL_RCC_R &= ~SYSCTL_RCC_XTAL_M;   // clear XTAL field
  SYSCTL_RCC_R += SYSCTL_RCC_XTAL_16MHZ;// configure for 16 MHz crystal
  SYSCTL_RCC2_R &= ~SYSCTL_RCC2_OSCSRC2_M;// clear oscillator source field
  SYSCTL_RCC2_R += SYSCTL_RCC2_OSCSRC2_MO;// configure for main oscillator source
  // 3) activate PLL by clearing PWRDN
  SYSCTL_RCC2_R &= ~SYSCTL_RCC2_PWRDN2;
  // 4) set the desired system divider and the system divider least significant bit
  SYSCTL_RCC2_R |= SYSCTL_RCC2_DIV400;  // use 400 MHz PLL
  SYSCTL_RCC2_R = (SYSCTL_RCC2_R&~ 0x1FC00000)  // clear system clock divider
                  + (SYSDIV2<<22);      //当SYSDIV为4的时候，PLL实际频率为400/(4+1) = 80MHZ.当SYSDIV=127为127的时候，PLL实际频率为400/(127+1)=3.125MHZ，依次类推
  // 5) 等待PLL稳定，如果稳定，SYSCTL_RIS_R&SYSCTL_RIS_PLLLRIS将为1
  while((SYSCTL_RIS_R&SYSCTL_RIS_PLLLRIS)==0){};
  // 6) 启用PLL
  SYSCTL_RCC2_R &= ~SYSCTL_RCC2_BYPASS2;
}


/*
SYSDIV2  Divisor  Clock (MHz)
 0        1       reserved
 1        2       reserved
 2        3       reserved
 3        4       reserved
 4        5       80.000
 5        6       66.667
 6        7       reserved
 7        8       50.000
 8        9       44.444
 9        10      40.000
 10       11      36.364
 11       12      33.333
 12       13      30.769
 13       14      28.571
 14       15      26.667
 15       16      25.000
 16       17      23.529
 17       18      22.222
 18       19      21.053
 19       20      20.000
 20       21      19.048
 21       22      18.182
 22       23      17.391
 23       24      16.667
 24       25      16.000
 25       26      15.385
 26       27      14.815
 27       28      14.286
 28       29      13.793
 29       30      13.333
 30       31      12.903
 31       32      12.500
 32       33      12.121
 33       34      11.765
 34       35      11.429
 35       36      11.111
 36       37      10.811
 37       38      10.526
 38       39      10.256
 39       40      10.000
 40       41      9.756
 41       42      9.524
 42       43      9.302
 43       44      9.091
 44       45      8.889
 45       46      8.696
 46       47      8.511
 47       48      8.333
 48       49      8.163
 49       50      8.000
 50       51      7.843
 51       52      7.692
 52       53      7.547
 53       54      7.407
 54       55      7.273
 55       56      7.143
 56       57      7.018
 57       58      6.897
 58       59      6.780
 59       60      6.667
 60       61      6.557
 61       62      6.452
 62       63      6.349
 63       64      6.250
 64       65      6.154
 65       66      6.061
 66       67      5.970
 67       68      5.882
 68       69      5.797
 69       70      5.714
 70       71      5.634
 71       72      5.556
 72       73      5.479
 73       74      5.405
 74       75      5.333
 75       76      5.263
 76       77      5.195
 77       78      5.128
 78       79      5.063
 79       80      5.000
 80       81      4.938
 81       82      4.878
 82       83      4.819
 83       84      4.762
 84       85      4.706
 85       86      4.651
 86       87      4.598
 87       88      4.545
 88       89      4.494
 89       90      4.444
 90       91      4.396
 91       92      4.348
 92       93      4.301
 93       94      4.255
 94       95      4.211
 95       96      4.167
 96       97      4.124
 97       98      4.082
 98       99      4.040
 99       100     4.000
 100      101     3.960
 101      102     3.922
 102      103     3.883
 103      104     3.846
 104      105     3.810
 105      106     3.774
 106      107     3.738
 107      108     3.704
 108      109     3.670
 109      110     3.636
 110      111     3.604
 111      112     3.571
 112      113     3.540
 113      114     3.509
 114      115     3.478
 115      116     3.448
 116      117     3.419
 117      118     3.390
 118      119     3.361
 119      120     3.333
 120      121     3.306
 121      122     3.279
 122      123     3.252
 123      124     3.226
 124      125     3.200
 125      126     3.175
 126      127     3.150
 127      128     3.125
*/

```



## 定时器

### C语言内部时钟-递减器

```c
// 等待100ms
// Inputs: None
// Outputs: None
void Delay(void){
  unsigned long volatile time;
  time = 727240 * 200 / 91; // 100ms
  while (time) time--;
}
```

### SysTick-busy wait策略

![QQ图片20220608043525](https://neesky-1304497077.cos.ap-chongqing.myqcloud.com/202206080435670.png)

实验三（只采用systick计时）【无SysTick_handler】

```c
#include "tm4c123gh6pm.h"
// Initialize SysTick with busy wait running at bus clock.
void SysTick_Init(void){ 
  NVIC_ST_CTRL_R = 0;               // 关闭systick计时器
  NVIC_ST_CTRL_R = 0x00000005;      // 打开时钟源和使能位（即在 SysTick上使用系统时钟，禁用中断101中的0），关闭中断（即没有SysTick_Handler）
}
// 时间延迟使用busy wait（忙等策略）
// 延迟参数以核心时钟为单位。 （80 MHz 时钟的单位为 12.5 纳秒）
void SysTick_Wait(unsigned long delay){
  NVIC_ST_RELOAD_R = delay-1;   // 需要等待的时间数
  NVIC_ST_CURRENT_R = 0;       // 清空现有的值
  while((NVIC_ST_CTRL_R&0x00010000)==0){} //等待计时器COUNT到0
}

// 假设系统时钟为 80 MHz。
// 10000us equals 10ms
void SysTick_Wait10ms(unsigned long delay){
  unsigned long i;
  for(i=0; i<delay; i++){
    SysTick_Wait(800000);  // wait 10ms
  }
}
```

### Systick-中断策略

实验四（采用systick生成中断）【有SysTick_handler】

```C
#include "TExaS.h"
#include "tm4c123gh6pm.h"
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void WaitForInterrupt(void);  // low power mode
unsigned long Switch=0; // 播放声音的开关设置
unsigned long action=0;
// 初始化设置：input from PA3, output from PA2, SysTick interrupts
void Sound_Init(void){ 
  unsigned long volatile delay;
  SYSCTL_RCGC2_R |= 0x00000001; // activate port A
  delay = SYSCTL_RCGC2_R;
  GPIO_PORTA_AMSEL_R &= ~0x0C;      // no analog 0b1100
  GPIO_PORTA_PCTL_R &= ~0x00F00000; // regular function
  GPIO_PORTA_DIR_R |= 0x04;     // make PA2 out ,PA3 in
  GPIO_PORTA_DR8R_R |= 0x04;    // can drive up to 8mA out
  GPIO_PORTA_AFSEL_R &= ~0x0C;  // disable alt funct on PA2
  GPIO_PORTA_DEN_R |= 0x0C;     // enable digital I/O on PA2
  // =========================SysTick_Init=========================
  NVIC_ST_CTRL_R = 0;           // 关闭中断
  NVIC_ST_RELOAD_R = 90908;     // reload value for 500us (assuming 80MHz)，根据PLL设置，一次-1是80MHZ
  /* 
  重点：中断触发机制、频率计算
  要求：需要一个440HZ频率的发声器
  因为这里的一次中断是上下边缘都会算，而声音的周期是一次上边缘和下边缘，所以实际频率  为440HZ*2=880HZ
  所以1/880HZ=1.1363636ms,又因为一次减少是80MHZ（基础频率）也就是12.5ns
  所以 NVIC_ST_RELOAD_R=1.1363636*10^6/12.5-1 = 90908
      -1: 从1到0触发
      1: 从0到1触发
  方法二：题目给了，中断处理程序频率 = 系统主频/(2x音频)-1
  
  该数字最大为：16,777,216（如果超了请用PLL降频率）
  */
  NVIC_ST_CURRENT_R = 0;        // 为了下一次直接装载，所以先清0
  NVIC_SYS_PRI3_R = NVIC_SYS_PRI3_R&0x00FFFFFF; // 系统中断优先级最高         
  NVIC_ST_CTRL_R = 0x00000007;  // 启用时钟源 中断 开启使能
  EnableInterrupts();
}

/* called at 880 Hz
复写函数，然后每一次产生中断，就会调用这个程序，本质上是一个上边缘触发。
最开始时候：Switch和action全0,不按下PA3,无变化。
按下PA3，0->1：Switch和action全1。此时发出声波
松开PA3，1->0：Switch为0但action为0，依旧发出声波
等待再一次按下PA3，重新发出声波
*/
void SysTick_Handler(void){
	if(Switch==0){
		Switch|=GPIO_PORTA_DATA_R;
		Switch&=0x08;
		if(Switch>0)
			action^=0x01;
	};
	Switch=GPIO_PORTA_DATA_R&0x08;
	if(action>0)
        GPIO_PORTA_DATA_R ^= 0x04;     // toggle PA2
}
/* 实现方法二
void SysTick_Handler(void){
  Switch = GPIO_PORTA_DATA_R & 0x08;
  if(Switch!=0){
    GPIO_PORTA_DATA_R ^= 0x04; // toggle PA2
  }、
} 
*/

int main(void){// activate grader and set system clock to 80 MHz
  TExaS_Init(SW_PIN_PA3, HEADPHONE_PIN_PA2,ScopeOn); 
  Sound_Init();    // enable after all initialization are done   
  while(1){
    // main program is free to perform other tasks
    // do not use WaitForInterrupt() here, it may cause the TExaS to crash
  }
}
```

## FSM

### 数据结构型-交通红绿灯

**ppt中的案例**

需求：为两条同样繁忙的单行道的交叉路口设计交通灯控制器。目标是最大限度地提高交通流量，最大限度地减少红灯处的等待时间，并避免事故。

![image-20220608094752538](https://upload-images.jianshu.io/upload_images/24714066-4cc5068a2f48829a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```c
// （1）定义状态
const struct State {
  uint32_t Out; 
  uint32_t Time;  // 10 ms units
  const struct State *Next[4];
}; 
typedef const struct State STyp;
// （2）设定状态
#define goN   &FSM[0]
#define waitN &FSM[1]
#define goE   &FSM[2]
#define waitE &FSM[3]
STyp FSM[4] = {
 {0x21,3000,{goN,waitN,goN,waitN}}, 
 {0x22, 500,{goE,goE,goE,goE}},
 {0x0C,3000,{goE,goE,waitE,waitE}},
 {0x14, 500,{goN,goN,goN,goN}}
};

void main(void) {
  STyp *Pt;  // state pointer
  uint32_t Input; 
  // （3）初始化时间、端口
  PLL_init();
  SysTick_init();
  PortA_init();
  // （4）初始化状态
  Pt = goN;
  // （5）具体流程
  while(1) {
    GPIO_PORTA_DATA_R = Pt->Out;  // 设置输出
    SysTick_Wait10ms(Pt->Time);   // 等待延迟
    Input = GPIO_PORTA_DATA_R&0x03;  // 读取输入
    Pt = Pt->Next[Input];  // 状态改变
  }
}
```

### 数组型-跑马灯

```c
long state[3] = {
  0x21,0x12,0x0c  // 0b0010_0001, 0b0001_0010, 0b0000_1100
};
char fsmIndex=0;
// 利用SysTick设置系统时钟，并利用中断进行处理
void SysTick_Handler(void){
  // 中断中的内容，写到这里就可以了
  GPIO_PORTE_DATA_R = state[fsmIndex];
  fsmIndex = (fsmIndex+1)%3;  // 模3最好写为 &0x07
}
```

## UART

【注意】cyy的代码感觉更全一些

**重点：计算波特率**

```c
// 初始化 the UART for 115,200 波特率 (assuming 80 MHz UART 时钟频率),
// 比特率=频率/（16*波特率），80Mhz/(16*115.2kb/s)) = (80000000)/(16*115200)=43.40278，直接取整数部分
UART1_IBRD_R = 43; 
// IBRD_R值的小数部分0.40278, round(0.40278 * 64) = 26，保证5%以内的误差		
UART1_FBRD_R = 26; 
```

**信号说明：**

```c
#define UART_FR_TXFF            0x00000020  // URAT 的FIFO队列当前状态为满信号
#define UART_FR_RXFE            0x00000010  // URAT 的FIFO队列当前状态为空信号
#define UART_LCRH_WLEN_8        0x00000060  // 8 bit word length
#define UART_LCRH_FEN           0x00000010  // UART Enable FIFOs
#define UART_CTL_UARTEN         0x00000001  // UART Enable
#define SYSCTL_RCGC1_UART1      0x00000002  // UART1 时钟控制信号
#define SYSCTL_RCGC2_GPIOC      0x00000004  // port C 时钟控制信号
```

**代码**

```c
// U1Rx connected to PC4
// U1Tx connected to PC5
// standard ASCII symbols
#define CR   0x0D
#define LF   0x0A
#define BS   0x08
#define ESC  0x1B
#define SP   0x20
#define DEL  0x7F

//------------UART_Init------------
// 初始化 the UART for 115,200 波特率 (assuming 80 MHz UART 时钟频率),
// 8 位字长，无奇偶校验位，一个停止位，启用 FIFO
// Input: none
// Output: none
void UART_Init(void){
  SYSCTL_RCGC1_R |= SYSCTL_RCGC1_UART1; // 激活 UART1 ==> UART时钟控制
  SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOC; // 激活 port C ==> 数字端口时钟控制
  UART1_CTL_R &= ~UART_CTL_UARTEN;      // 初始化URAT时禁用 UART ==> UARTx_CTL_R包含UART启用（UARTEN）、Tx（TXE）和Rx启用（RXE）
  UART1_IBRD_R = 43;                    // 比特率=频率/（16*波特率），80Mhz/(16*115.2kb/s)) = (80000000)/(16*115200)=43.40278，  
  UART1_FBRD_R = 26;                    // IBRD_R值的小数部分0.40278, round(0.40278 * 64) = 26，保证5%以内的误差
  UART1_LCRH_R = (UART_LCRH_WLEN_8|UART_LCRH_FEN); // 置位以激活激活，8 bit word length (没有奇偶校验位,没有停止位的FIFOs)
  UART1_CTL_R |= UART_CTL_UARTEN;       // 初始化UART结束后启用 UART
  GPIO_PORTC_AFSEL_R |= 0x30;           // enable alt funct on PC5-4
  GPIO_PORTC_DEN_R |= 0x30;             // 在PC4与PC5端口启用I/O 
  GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R&0xFF00FFFF)+0x00220000;  // 配置PC4与PC5为UART1，即第1+4位和第1+5位，置为1+UART1（注意都是以0开头）
  GPIO_PORTC_AMSEL_R &= ~0x30;          // 禁用PC4与PC5的模拟信号功能
}

//------------UART_InChar------------
// 等待新的串行端口输入
// Input: none
// Output: ASCII code for key typed
unsigned char UART_InChar(void){
  while((UART1_FR_R&UART_FR_RXFE) != 0);     // RXFE为1，FIFO有数据
  return((unsigned char)(UART1_DR_R&0xFF));  // 后8位为Data
}
//------------UART_OutChar------------
// 输出 8 位至串行端口
// Input: letter is an 8-bit ASCII character to be transferred
// Output: none
void UART_OutChar(unsigned char data){
  while((UART1_FR_R&UART_FR_TXFF) != 0); // TXFF为1，FIFO没有满
  UART1_DR_R = data; // 数据置位
}

//------------UART_InCharNonBlocking------------
// 另一种方法，不常用。如果没有数据，则获取最旧的串行端口输入并立即返回
// Input: none
// Output: ASCII code for key typed or 0 if no character
unsigned char UART_InCharNonBlocking(void){
  if((UART1_FR_R&UART_FR_RXFE) == 0) return((unsigned char)(UART1_DR_R&0xFF));
  else return 0;
}
```

## DAC

lab13 数字钢琴

DAC直接使用GPIO端口的数字模式

```c
// **************DAC_Init*********************
// Initialize 4-bit DAC 
// Input: none
// Output: none
void DAC_Init(void){
  unsigned long volatile delay;
  SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOB; // activate port B
  delay = SYSCTL_RCGC2_R;               // allow time to finish activating
  GPIO_PORTB_AMSEL_R &= ~0x0F;          // no analog 4 bits
  GPIO_PORTB_PCTL_R &= ~0x0000FFFF;     // regular GPIO configure on PB3-0
  GPIO_PORTB_DIR_R |= 0x0F;             // make PB3-0 out
  GPIO_PORTB_DR8R_R |= 0x0F;            // enable 8 mA drive on PB3-0
  GPIO_PORTB_AFSEL_R &= ~0x0F;          // disable alt funct on PB3-0
  GPIO_PORTB_DEN_R |= 0x0F;             // enable digital I/O on PB3-0
}

// **************DAC_Out*********************
// output to DAC
// Input: 4-bit data, 0 to 15 
// Output: none
void DAC_Out(unsigned long data){
  GPIO_PORTB_DATA_R = data;
}
```



## ADC

### 寄存器说明

**寄存器：**

![img](https://upload-images.jianshu.io/upload_images/24714066-533f7bda705013aa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**选择端口**

![选择端口](https://neesky-1304497077.cos.ap-chongqing.myqcloud.com/202206092145914.png)

**触发方式**

![image-20220609214700972](https://neesky-1304497077.cos.ap-chongqing.myqcloud.com/202206092147007.png)

### 初始化

```C
// This initialization function sets up the ADC 
// Max sample rate: <=125,000 samples/second
// SS3 triggering event: software trigger
// SS3 1st sample source:  channel 1
// SS3 interrupts: enabled but not promoted to controller
void ADC0_Init(void){ 
  volatile unsigned long delay;
  SYSCTL_RCGC2_R |= 0x00000010;   // 1) 激活端口E
  delay = SYSCTL_RCGC2_R;         //    allow time for clock to stabilize
  GPIO_PORTE_DIR_R &= ~0x04;      // 2) PE2 input
  GPIO_PORTE_AFSEL_R |= 0x04;     // 3) enable alternate function on PE2
  GPIO_PORTE_DEN_R &= ~0x04;      // 4) PE2非数字信号
  GPIO_PORTE_AMSEL_R |= 0x04;     // 5) PE2为模拟信号
  SYSCTL_RCGC0_R |= 0x00010000;   // 6) 打开ADC0
  // 以下参考embeding system书第206页 
  delay = SYSCTL_RCGC2_R;         
  SYSCTL_RCGC0_R &= ~0x00000300;  // 7) 最大频率125K
  ADC0_SSPRI_R = 0x0123;          // 8) 数字越小优先级越高
  ADC0_ACTSS_R &= ~0x0008;        // 9) disable sample sequencer 3 
  ADC0_EMUX_R &= ~0xF000;         // 10) 选择触发方式为软件触发
  ADC0_SSMUX3_R = (ADC0_SSMUX3_R&0xFFFFFFF0)+1; // 11) channel Ain1 (PE2)
  ADC0_SSCTL3_R = 0x0006;         // 12) no TS0 D0, yes IE0 END0       
  ADC0_ACTSS_R |= 0x0008;         // 13) enable sample sequencer 3 
}

//------------ADC0_In------------
// Busy wait模式，模数转换
// Input: none
// Output: 12-bit result of ADC conversion
unsigned long ADC0_In(void){  
  unsigned long re;
  ADC0_PSSI_R = 0x0008;            // 1) 开始监听
  while((ADC0_RIS_R&0x08)==0){};   // 2) 等待数据读取
  re = ADC0_SSFIFO3_R&0xFFF;   // 3) 读取数据（12位）
  ADC0_ISC_R = 0x0008;             // 4) 通知完成
  return re; // replace this line with proper code
}

//------------使用示例：利用中断控制获取数据-------------
// Initialize SysTick interrupts to trigger at 40 Hz, 25 ms
void SysTick_Init(unsigned long period){
  NVIC_ST_CTRL_R = 0;           // disable SysTick during setup
  NVIC_ST_RELOAD_R = period-1;     // reload value for 40Hz (assuming 80MHz) MATH: 1/(40)/(1/80000000)-1 = 1999999
  NVIC_ST_CURRENT_R = 0;        // any write to current clears it
  NVIC_SYS_PRI3_R = NVIC_SYS_PRI3_R&0x00FFFFFF; // priority 0               
  NVIC_ST_CTRL_R = 0x00000007;  // enable with core clock and interrupts
}
// executes every 25 ms, collects a sample, converts and stores in mailbox
void SysTick_Handler(void){ 
  Flag = 0;    //Reset the flag until we have a new valid input
  ADCdata = ADC0_In();  //Retrieve our measurement from the ADC
  Distance = Convert(ADCdata);  //Convert ADC raw data to a measurement in centimeters.
}
```

## 实验

### LAB1-控制LED开关与颜色

```c
// 实验说明
// LaunchPad硬件配置
// SW1 left switch is negative logic PF4 on the Launchpad
// SW2 right switch is negative logic PF0 on the Launchpad
// red LED connected to PF1 on the Launchpad
// blue LED connected to PF2 on the Launchpad
// green LED connected to PF3 on the Launchpad
// Color    LED(s) PortFB
// dark     ---    0
// red      R--    0x02 ==> PF1
// blue     --B    0x04 ==> PF2
// green    -G-    0x08 ==> PF3
// yellow   RG-    0x0A
// sky blue -GB    0x0C
// white    RGB    0x0E
// pink     R-B    0x06

#include "TExaS.h"
#include "tm4c123gh6pm.h"

unsigned long In;   // input from PF4
unsigned long Out; // outputs to PF3,PF2,PF1 (multicolor LED)

void EnableInterrupts(void); // 空声明

// 初始化port F的例子，要求如下
// PF4 and PF0 are input SW1 and SW2 respectively
// PF3,PF2,PF1 are outputs to the LED
// Inputs: None
// Outputs: None
void PortF_Init(void){
  volatile unsigned long delay;
  SYSCTL_RCGC2_R |= 0x00000020;    // 1) 启用数字端口F的时钟，0b10_0000即5th bit
  delay = SYSCTL_RCGC2_R;          // delay
  GPIO_PORTF_LOCK_R = 0x4C4F434B;  // 2) unlock PortF(貌似只有F才需要解锁)
  GPIO_PORTF_CR_R = 0x1F;          // allow changes to PF4-0
  GPIO_PORTF_AMSEL_R = 0x00;       // 3) 禁用模拟功能
  GPIO_PORTF_PCTL_R = 0x00000000;  // 4) GPIO clear bit PCTL
  GPIO_PORTF_DIR_R = 0x0E;         // 5) PF4,PF0 input, PF3,PF2,PF1 output，0b0_1110
  GPIO_PORTF_AFSEL_R = 0x00;       // 6) 没有替代功能
  GPIO_PORTF_PUR_R = 0x11;         // PF4和PF0为negative logic,需要使能PF4和PF0上拉电阻，0b1_0001
  GPIO_PORTF_DEN_R = 0x1F;         // 7) 开启数字端口PF4-PF0
}

// 等待100ms
// Inputs: None
// Outputs: None
void Delay(void){
  unsigned long volatile time;
  time = 727240 * 200 / 91; // 100ms
  while (time) time--;
}

int main(void){
  TExaS_Init(SW_PIN_PF40, LED_PIN_PF321);  // this initializes the TExaS grader lab 2
  PortF_Init();                            // Call initialization of port PF4 PF2
  EnableInterrupts();                      // The grader uses interrupts
  while (1){
    In = GPIO_PORTF_DATA_R & 0x01; // read PF0 into In
    if (In == 0x00){               // zero means SW is pressed
      GPIO_PORTF_DATA_R = 0x08;    // LED is green, PF3
    }
    else{                          // 0x10 means SW is not pressed
      GPIO_PORTF_DATA_R = 0x02;    // LED is red
    }
    Delay();                       // wait 0.1 sec
    GPIO_PORTF_DATA_R = 0x04;      // LED is blue
    Delay();                       // wait 0.1 sec
  }
}
```



### LAB3-灯状态传输

```c
//  red, yellow, green, light blue, blue, purple,  white,  dark
const long ColorWheel[8] = {0x02,0x0A,0x08,0x0C,0x04,0x06,0x0E,0x00};
int main(void){ 
  unsigned long SW1,SW2;
  long prevSW1 = 0;        // SW1的先值
  long prevSW2 = 0;        // SW2的先值
  unsigned char inColor;   // 其他实验板传入的颜色的值
  unsigned char color = 0; // 当前LED灯的颜色
  PLL_Init();              // 设置系统时钟为80 MHz
  SysTick_Init();          // 初始化systick，利用systick来计时
  UART_Init();             // initialize UART
  PortF_Init();            // initialize buttons and LEDs on Port F
  while(1){
    SW1 = GPIO_PORTF_DATA_R&0x10; // Read SW1
    if((SW1 == 0) && prevSW1){    // falling of SW1?
      color = (color+1)&0x07;     // 在按下开关SW1时进入ColorWheel的下一种颜色，与上0b111,即取模
    }
    prevSW1 = SW1; // 当前按下的是SW1 
    SW2 = GPIO_PORTF_DATA_R&0x01; // Read SW2
    if((SW2 == 0) && prevSW2){    // falling of SW2?
      UART_OutChar(color+0x30);   // 在按下开关SW2时发送颜色值的ASCII码，as '0' - '7'，ascii(0)=48=0x30
    }
    prevSW2 = SW2; // 当前按下的是SW2
    inColor = UART_InCharNonBlocking();
    if(inColor){ // FIFO是否有新到达的数据
      color = inColor&0x07;     // 更新当前实验板的颜色
    }
    GPIO_PORTF_DATA_R = ColorWheel[color];  // 更新LED灯
    SysTick_Wait10ms(2);        // 防止开关反跳，即在20ms之内按下两次
  }
}
```

### LAB4-中断发声音

见**3.3 Systick-中断策略**



### LAB5-跑马灯

```c
#include "tm4c123gh6pm.h"
#include "PLL.h"

void EnableInterrupts(void);  // Enable interrupts
void WaitForInterrupt(void);  // low power mode
void PortE_Init(void){
  volatile unsigned long delay;
  SYSCTL_RCGC2_R |= 0x00000010;    
  delay = SYSCTL_RCGC2_R;          
  GPIO_PORTE_CR_R = 0x3F;           
  GPIO_PORTE_AMSEL_R = 0x00;        
  GPIO_PORTE_PCTL_R = 0x00000000;  
  GPIO_PORTE_DIR_R = 0x3F;          
  GPIO_PORTE_AFSEL_R = 0x00;      
  GPIO_PORTE_PUR_R = 0x3F;                
  GPIO_PORTE_DEN_R = 0x3F;   
  
  NVIC_ST_CTRL_R = 0;           // disable SysTick during setup
  NVIC_ST_RELOAD_R = 3125000;     // reload value for 500us (assuming 80MHz)

  NVIC_ST_CURRENT_R = 0;        // any write to current clears it
  NVIC_SYS_PRI3_R = NVIC_SYS_PRI3_R&0x00FFFFFF; // priority 0               
  NVIC_ST_CTRL_R = 0x00000007;  // enable with core clock and interrupts
  EnableInterrupts();
}

long state[3] = {
  0x21,0x12,0x0c  // 0b0010_0001, 0b0001_0010, 0b0000_1100
};
char fsmIndex=0;
// 利用SysTick设置系统时钟，并利用中断进行处理
void SysTick_Handler(void){
  // 中断中的内容，写到这里就可以了
  GPIO_PORTE_DATA_R = state[fsmIndex];
  fsmIndex = (fsmIndex+1)%3;  // 模3最好写为 &0x07
}

int main(void){ 
    PLL_Init();
    PortE_Init();
    while(1){
      WaitForInterrupt();
    }
}
```

## 编程题

### 串口

#### 初始化串口

【注意】cyy的代码感觉更全一些

```C
#include "TExaS.h"
#include "tm4c123gh6pm.h"

#define UART_FR_TXFF            0x00000020  // URAT 的FIFO队列当前状态为满信号
#define UART_FR_RXFE            0x00000010  // URAT 的FIFO队列当前状态为空信号
#define UART_LCRH_WLEN_8        0x00000060  // 8 bit word length
#define UART_LCRH_FEN           0x00000010  // UART Enable FIFOs
#define UART_CTL_UARTEN         0x00000001  // UART Enable
#define SYSCTL_RCGC1_UART1      0x00000002  // UART1 时钟控制信号
#define SYSCTL_RCGC2_GPIOC      0x00000004  // port C 时钟控制信号
// U1Rx connected to PC4
// U1Tx connected to PC5
// standard ASCII symbols
#define CR   0x0D
#define LF   0x0A
#define BS   0x08
#define ESC  0x1B
#define SP   0x20
#define DEL  0x7F

//------------UART_Init------------
// 初始化 the UART for 115,200 波特率 (assuming 80 MHz UART 时钟频率),
// 8 位字长，无奇偶校验位，一个停止位，启用 FIFO
// Input: none
// Output: none
void UART_Init(void){
  SYSCTL_RCGC1_R |= SYSCTL_RCGC1_UART1; // 激活 UART1 ==> UART时钟控制
  SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOC; // 激活 port C ==> 数字端口时钟控制
  UART1_CTL_R &= ~UART_CTL_UARTEN;      // 初始化URAT时禁用 UART ==> UARTx_CTL_R包含UART启用（UARTEN）、Tx（TXE）和Rx启用（RXE）
  UART1_IBRD_R = 43;                    // 比特率=频率/（16*波特率），80Mhz/(16*115.2kb/s)) = (80000000)/(16*115200)=43.40278，  
  UART1_FBRD_R = 26;                    // IBRD_R值的小数部分0.40278, round(0.40278 * 64) = 26，保证5%以内的误差
  UART1_LCRH_R = (UART_LCRH_WLEN_8|UART_LCRH_FEN); // 置位以激活激活，8 bit word length (没有奇偶校验位,没有停止位的FIFOs)
  UART1_CTL_R |= UART_CTL_UARTEN;       // 初始化UART结束后启用 UART
  GPIO_PORTC_AFSEL_R |= 0x30;           // enable alt funct on PC5-4
  GPIO_PORTC_DEN_R |= 0x30;             // 在PC4与PC5端口启用I/O 
  GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R&0xFF00FFFF)+0x00220000;  // 配置PC4与PC5为UART1，即第1+4位和第1+5位，置为2(即选择UART1)【详细UART进行选择】
  GPIO_PORTC_AMSEL_R &= ~0x30;          // 禁用PC4与PC5的模拟信号功能
}

//------------UART_InChar------------
// Wait for new serial port input
// Input: none
// Output: ASCII code for key typed
unsigned char UART_InChar(void){
  while((UART1_FR_R&UART_FR_RXFE) != 0);
  return((unsigned char)(UART1_DR_R&0xFF));
}

//------------UART_InCharNonBlocking------------
// Get oldest serial port input and return immediately
// if there is no data.
// Input: none
// Output: ASCII code for key typed or 0 if no character
unsigned char UART_InCharNonBlocking(void){
  if((UART1_FR_R&UART_FR_RXFE) == 0){
    return((unsigned char)(UART1_DR_R&0xFF));
  } else{
    return 0;
  }
}

//------------UART_OutChar------------
// Output 8-bit to serial port
// Input: letter is an 8-bit ASCII character to be transferred
// Output: none
void UART_OutChar(unsigned char data){
  while((UART1_FR_R&UART_FR_TXFF) != 0);
  UART1_DR_R = data;
}
```

#### 传数据和输入输出

```c
#include "UART.h"
#include "TExaS.h"

void EnableInterrupts(void);  // Enable interrupts
// do not edit this main
// your job is to implement the UART_OutUDec UART_OutDistance functions 
int main(void){ unsigned long n;
  TExaS_Init();             // initialize grader, set system clock to 80 MHz
  UART_Init();              // initialize UART
  EnableInterrupts();       // needed for TExaS
  UART_OutString("Running Lab 11");
  while(1){
    UART_OutString("\n\rInput:");
    n = UART_InUDec();
    UART_OutString(" UART_OutUDec = ");
    UART_OutUDec(n);     // your function
    UART_OutString(",  UART_OutDistance ~ ");
    UART_OutDistance(n); // your function
  }
}
```

### 中断

#### 灯泡每隔0.1s转换状态

```C
#include "TExaS.h"
#include "tm4c123gh6pm.h"
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void WaitForInterrupt(void);  // low power mode
unsigned long Switch=0; // 播放声音的开关设置
unsigned long action=0;
// 初始化设置：input from PA3, output from PA2, SysTick interrupts
void LED_Init(void){ 
  unsigned long volatile delay;
  SYSCTL_RCGC2_R |= 0x00000001; // activate port A
  delay = SYSCTL_RCGC2_R;
  GPIO_PORTA_AMSEL_R &= ~0x0C;      // no analog 0b1100
  GPIO_PORTA_PCTL_R &= ~0x00F00000; // regular function
  GPIO_PORTA_DIR_R |= 0x04;     // make PA2 out ,PA3 in
  GPIO_PORTA_DR8R_R |= 0x04;    // can drive up to 8mA out
  GPIO_PORTA_AFSEL_R &= ~0x0C;  // disable alt funct on PA2
  GPIO_PORTA_DEN_R |= 0x0C;     // enable digital I/O on PA2
  // GPIO_PORTA_PDR_R &= 0x08;     // 上拉设置(可以不要的)
  NVIC_ST_CTRL_R = 0;           // disable SysTick during setup
  NVIC_ST_RELOAD_R = 7999999;     // reload value for 500us (assuming 80MHz)
/* 
重点：中断触发机制、频率计算
	要求：需要一个440HZ频率的发声器
	因为这里的一次中断是上下边缘都会算，而声音的周期是一次上边缘和下边缘，所以实际频率为440HZ*2=880HZ
	所以1/880HZ=1.1363636ms,又因为一次减少是80MHZ（基础频率）也就是12.5us
	所以 NVIC_ST_RELOAD_R=1.1363636*10^6/12.5-1 = 90908
    -1: 从1到0触发
    1: 从0到1触发
    
    该数字最大为：16,777,216，如果该数字超了，需要改变PLL的值
*/
  NVIC_ST_CURRENT_R = 0;        // 为了下一次直接装载，所以先清0
  NVIC_SYS_PRI3_R = NVIC_SYS_PRI3_R&0x00FFFFFF; // 系统中断优先级最高         
  NVIC_ST_CTRL_R = 0x00000007;  // 启用时钟源 中断 开启使能
  EnableInterrupts();
}

/* called at 880 Hz
复写函数，然后每一次产生中断，就会调用这个程序，本质上是一个上边缘触发。
最开始时候：Switch和action全0,不按下PA3,无变化。
按下PA3，0->1：Switch和action全1。此时发出声波
松开PA3，1->0：Switch为0但action为0，依旧发出声波
等待再一次按下PA3，重新发出声波
*/
void SysTick_Handler(void){
   GPIO_PORTA_DATA_R ^= 0x04;     // toggle PA2
}

int main(void){// activate grader and set system clock to 80 MHz
  TExaS_Init(SW_PIN_PA3, HEADPHONE_PIN_PA2,ScopeOn); 
  LED_Init();    // enable after all initialization are done   
  while(1){
    // main program is free to perform other tasks
    // do not use WaitForInterrupt() here, it may cause the TExaS to crash
  }
}
```

### 跑马灯

#### 中断

LED 0  0.1s -> LED 1  0.2s -> LED 2  0.2s -> LED 3  0.1s

```C
#include "TExaS.h"
#include "tm4c123gh6pm.h"
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void WaitForInterrupt(void);  // low power mode
//-------中断初始化--------
void LED_Init(void){ 
   //----GPIO F设置-----
    volatile unsigned long delay;
  SYSCTL_RCGC2_R |= 0x00000020;    // 1) 启用数字端口F的时钟，0b10_0000即5th bit
  delay = SYSCTL_RCGC2_R;          // delay
  GPIO_PORTF_LOCK_R = 0x4C4F434B;  // 2) unlock PortF(貌似只有F才需要解锁)
  GPIO_PORTF_CR_R = 0x0F;          // allow changes to PF4-0
  GPIO_PORTF_AMSEL_R = 0x00;       // 3) 禁用模拟功能
  GPIO_PORTF_PCTL_R = 0x00000000;  // 4) GPIO clear bit PCTL
  GPIO_PORTF_DIR_R = 0x0F;         // 5) all output
  GPIO_PORTF_AFSEL_R = 0x00;       // 6) 没有替代功能
  GPIO_PORTF_DEN_R = 0x0F;         // 7) 开启数字端口PF3-PF0  
 
   //----中断设置-----
  NVIC_ST_CTRL_R = 0;           // disable SysTick during setup
  NVIC_ST_RELOAD_R = 7999999;     // reload value for 500us (assuming 80MHz)
/* 
重点：中断触发机制、频率计算
	要求：需要一个440HZ频率的发声器
	因为这里的一次中断是上下边缘都会算，而声音的周期是一次上边缘和下边缘，所以实际频率为440HZ*2=880HZ
	所以1/880HZ=1.1363636ms,又因为一次减少是80MHZ（基础频率）也就是12.5us
	所以 NVIC_ST_RELOAD_R=1.1363636*10^6/12.5-1 = 90908
    -1: 从1到0触发
    1: 从0到1触发
    
    该数字最大为：16,777,216，如果该数字超了，需要改变PLL的值
*/
  NVIC_ST_CURRENT_R = 0;        // 为了下一次直接装载，所以先清0
  NVIC_SYS_PRI3_R = NVIC_SYS_PRI3_R&0x00FFFFFF; // 系统中断优先级最高         
  NVIC_ST_CTRL_R = 0x00000007;  // 启用时钟源 中断 开启使能
  EnableInterrupts();
}
//-------状态机--------
const struct State {
  uint32_t Out; 
  uint32_t Time;  
}; 
typedef const struct State STyp;

STyp FSM[4] = {
 {0x01,1}, 
 {0x02,2},
 {0x04,2},
 {0x08,1}
};
int index = 0;
//-------中断程序--------
void SysTick_Handler(void){
   NVIC_ST_RELOAD_R = FSM[index].Time * 7999999;
   GPIO_PORTF_DATA_R =FSM[index].Out;
   index = (index+1)%4;
}
int main()
{
     LED_Init();
     while(1){}
}
```

#### 中断+PLL

LED 0  1s -> LED 1  2s -> LED 2  2s -> LED 3  1s

```C
#include "TExaS.h"
#include "tm4c123gh6pm.h"
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void WaitForInterrupt(void);  // low power mode
//-------中断初始化--------
void LED_Init(void){ 
   //----GPIO F设置-----
    volatile unsigned long delay;
  SYSCTL_RCGC2_R |= 0x00000020;    // 1) 启用数字端口F的时钟，0b10_0000即5th bit
  delay = SYSCTL_RCGC2_R;          // delay
  GPIO_PORTF_LOCK_R = 0x4C4F434B;  // 2) unlock PortF(貌似只有F才需要解锁)
  GPIO_PORTF_CR_R = 0x0F;          // allow changes to PF4-0
  GPIO_PORTF_AMSEL_R = 0x00;       // 3) 禁用模拟功能
  GPIO_PORTF_PCTL_R = 0x00000000;  // 4) GPIO clear bit PCTL
  GPIO_PORTF_DIR_R = 0x0F;         // 5) all output
  GPIO_PORTF_AFSEL_R = 0x00;       // 6) 没有替代功能
  GPIO_PORTF_DEN_R = 0x0F;         // 7) 开启数字端口PF3-PF0  
 
   //----中断设置-----
  NVIC_ST_CTRL_R = 0;           // disable SysTick during setup
  NVIC_ST_RELOAD_R = 3125000;     // reload value for 500us (assuming 80MHz)
/* 
重点：中断触发机制、频率计算
	要求：需要一个440HZ频率的发声器
	因为这里的一次中断是上下边缘都会算，而声音的周期是一次上边缘和下边缘，所以实际频率为440HZ*2=880HZ
	所以1/880HZ=1.1363636ms,又因为一次减少是80MHZ（基础频率）也就是12.5us
	所以 NVIC_ST_RELOAD_R=1.1363636*10^6/12.5-1 = 90908
    -1: 从1到0触发
    1: 从0到1触发
    
    该数字最大为：16,777,216，如果该数字超了，需要改变PLL的值
*/
  NVIC_ST_CURRENT_R = 0;        // 为了下一次直接装载，所以先清0
  NVIC_SYS_PRI3_R = NVIC_SYS_PRI3_R&0x00FFFFFF; // 系统中断优先级最高         
  NVIC_ST_CTRL_R = 0x00000007;  // 启用时钟源 中断 开启使能
  EnableInterrupts();
}
//-------状态机--------
const struct State {
  uint32_t Out; 
  uint32_t Time;  
}; 
typedef const struct State STyp;

STyp FSM[4] = {
 {0x01,1}, 
 {0x02,2},
 {0x04,2},
 {0x08,1}
};
int index = 0;
//-------中断程序--------
void SysTick_Handler(void){
   NVIC_ST_RELOAD_R = FSM[index].Time * 3125000;
   GPIO_PORTF_DATA_R =FSM[index].Out;
   index = (index+1)%4;
}

//------PLL设置-------
#include "PLL.h"
// bus frequency is 400MHz/(SYSDIV2+1) = 400MHz/(4+1) = 80 MHz
// configure the system to get its clock from the PLL
void PLL_Init(void){
  // 0) configure the system to use RCC2 for advanced features
  //    such as 400 MHz PLL and non-integer System Clock Divisor
  SYSCTL_RCC2_R |= SYSCTL_RCC2_USERCC2;
  // 1) 初始化的时候，绕开PLL
  SYSCTL_RCC2_R |= SYSCTL_RCC2_BYPASS2;
  // 2) select the crystal value and oscillator source
  SYSCTL_RCC_R &= ~SYSCTL_RCC_XTAL_M;   // clear XTAL field
  SYSCTL_RCC_R += SYSCTL_RCC_XTAL_16MHZ;// configure for 16 MHz crystal
  SYSCTL_RCC2_R &= ~SYSCTL_RCC2_OSCSRC2_M;// clear oscillator source field
  SYSCTL_RCC2_R += SYSCTL_RCC2_OSCSRC2_MO;// configure for main oscillator source
  // 3) activate PLL by clearing PWRDN
  SYSCTL_RCC2_R &= ~SYSCTL_RCC2_PWRDN2;
  // 4) set the desired system divider and the system divider least significant bit
  SYSCTL_RCC2_R |= SYSCTL_RCC2_DIV400;  // use 400 MHz PLL
  SYSCTL_RCC2_R = (SYSCTL_RCC2_R&~ 0x1FC00000)  // clear system clock divider
                  + (127<<22);      //当SYSDIV为4的时候，PLL实际频率为400/(4+1) = 80MHZ.当SYSDIV=127为127的时候，PLL实际频率为400/(127+1)=3.125MHZ，依次类推
  // 5) 等待PLL稳定，如果稳定，SYSCTL_RIS_R&SYSCTL_RIS_PLLLRIS将为1
  while((SYSCTL_RIS_R&SYSCTL_RIS_PLLLRIS)==0){};
  // 6) 启用PLL
  SYSCTL_RCC2_R &= ~SYSCTL_RCC2_BYPASS2;
}
int main()
{
     LED_Init();
     while(1){}
}
```



