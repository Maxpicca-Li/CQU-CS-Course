1、文件目录说明
├─README
│      README.txt		文档说明
│      输入前.png		输入前输出示意图
│      输入后.png		输入后结果示意图
│
└─src
        CRC.h			
        datatype.h		数据类型定义，包括FrameHeader、Ipv4Header、ICMPHeader
        FrameToIPdatagram.c	封装和解封装Frame和Datagram的源文件
        FrameToIPdatagram.exe	封装和解封装Frame和Datagram的执行文件
        log.txt			具体的代码输出log文件

2、环境说明
①系统：Windows
②模式：小端存储
③编译环境：TDM-GCC 4.9.2 64-bit Debug

3、执行说明
①命令行执行
gcc FrameToIPdatagram.c -lwsock32 -o FrameToIPdatagram
 .\FrameToIPdatagram.exe  
②直接执行
双击 FrameToIPdatagram.exe 即可

4、输入说明
格式形如下述即可：
20-03-11-26-13-26
20-01-01-18-12-00
0800

