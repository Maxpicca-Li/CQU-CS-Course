// 代码实现参考:
// - [C语言实现MAC帧的封装与解封装_Skycrab-CSDN博客](https://blog.csdn.net/yueguanghaidao/article/details/7663489)
// - [原始套接字发送IP数据报_IDoubleTong的博客-CSDN博客_原始套接字发送数据](https://blog.csdn.net/weixin_43206704/article/details/89327572)

#pragma comment(lib,"ws2_32.lib")
#include <stdlib.h>
#include <stdio.h>
#include <winsock2.h>
#include <windows.h>
#include "CRC.h"

#ifndef datatype_h_
#define datatype_h_
#include "datatype.h"
#include <string.h>
#endif

#define SendToNet 0
#define MINSIZE 46
#define MAXSIZE 1500
#define MFS 1526  // MaxFrameSize

void display(unit_u8 *data, int data_len, int type);
int enpackFrame(unit_u8* data, int data_len,unit_u8* frame);
int unpackFrame(unit_u8 *frame, int frame_len, unit_u8 *frame_data);
int enpackIP(unit_u8 *data,int data_len, unit_u8 *datagram);
int unpackIP(unit_u8 *frame_data, int frame_data_len, unit_u8 *datagram_data);

unit_u32 Reverse_Table[256];
int main(){
    gen_normal_table(Reverse_Table);
    int i;
    int data_len,datagram_len,frame_len,frame_data_len, datagram_data_len;
    
    unit_u8 data[] = "abcdefghijklmnopqrstuvwxyzabcdef";
    unit_u8 datagram[MAXSIZE];
    unit_u8 frame[MFS];
    unit_u8 frame_data[MAXSIZE];
    unit_u8 datagram_data[MAXSIZE];

    data_len = strlen(data); //不计算结尾的\0
    printf("data_len = %d\n", data_len);
    
    // 封装ip
    datagram_len = enpackIP(data, data_len,datagram);
    printf("datagram_len = %d\n", datagram_len);
    display(datagram, datagram_len,0);

    // 封装Frame
    frame_len = enpackFrame(datagram,datagram_len,frame);
    printf("frame_len = %d\n", frame_len);
    display(frame, frame_len,0);

    // 解封装Frame
    frame_data_len = unpackFrame(frame,frame_len,frame_data);
    printf("frame_data_len = %d\n", frame_data_len);
    display(frame_data, frame_data_len,0);

    // 解封装Datagram
    datagram_data_len = unpackIP(frame_data,frame_data_len,datagram_data);
    printf("datagram_data_len = %d\n", datagram_data_len);
    display(datagram_data, datagram_data_len,0);

    system("pause");
    return 0;
}

void display(unit_u8* data,int data_len, int type){
    for (int i = 0;i<data_len;i++){
        if(i != 0) {
            if(type) printf(":");
            else printf(" ");
        }
        printf("%02x",data[i]);
    }
    printf("\n");
}

int enpackFrame(unit_u8* src_data, int data_len, unit_u8* frame){
    if(data_len == 0){ return 0;}
    printf("===================enpackFrame===================\n");

    // 最小帧检验
    unit_u8 data[MAXSIZE];
    for (int i = 0;i<data_len;i++){
        data[i] = src_data[i];
    }
    if(data_len<MINSIZE){
        for (int i = data_len;i<MINSIZE;i++){
            data[i] = 0x00;
        }
        data_len = MINSIZE;
    }
    printf("最小帧检验: data_len = %d\n", data_len);
    
    FrameHeader fHeader;
    // 1、前导符
    fHeader.leader = 0xabaaaaaaaaaaaaaa; // unit_u64 小端地址 
    // 2、地址
    printf("请输入MAC目的地址:");
    for (int i = 0; i < 6;i++){ scanf("%02x-", fHeader.desMAC + i); }
    fflush(stdin);  // 清空输入流
    printf("请输入MAC源地址:");
    for (int i = 0; i < 6;i++){ scanf("%02x-", fHeader.srcMAC + i); }
    fflush(stdin); 
    // 3、类型
    printf("请输入类型字段:");
    scanf("%02x%02x", fHeader.type, fHeader.type + 1);
    fflush(stdin); 
    
    // FCS[目的地址+源地址+类型+数据+32'b0]进行校验
/*
    // 根据解析结果，发现无需用到FCS，故这里不做CRC校验
    unit_u8 checkdata[MFS];
    int check_len = 6 + 6 + 2 + data_len + 4;
    int FCS;
    memcpy(checkdata, fHeader.desMAC, 6);
    memcpy(checkdata+6, fHeader.srcMAC, 6);
    memcpy(checkdata+6+6, fHeader.type, 2);
    memcpy(checkdata+6+6+2, data, data_len);
    for (int i = 6 + 6 + 2 + data_len; i < check_len;i++){
        checkdata[i] = 0x00;
    }
    // FCS = Reverse_Table_CRC(checkdata, check_len, Reverse_Table);
    printf("frame.FCS = %x\n", FCS);
    FCS = htonl((unsigned long)FCS); // 小端存储，内部存储格式转换
*/
    
    // 封装
    memcpy(frame, &fHeader, SizeFrameHeader);
    printf("SizeFrameHeader=%d\n", SizeFrameHeader);
    memcpy(frame+SizeFrameHeader, data, data_len);
    // memcpy(frame+SizeFrameHeader+data_len, &FCS, 4);
    int frame_len = SizeFrameHeader + data_len; // + 4;
    return frame_len;
}   

int unpackFrame(unit_u8 *frame, int frame_len, unit_u8 *frame_data){
    if(frame_len == 0) return 0;
    printf("===================unpackFrame===================\n");

    FrameHeader fHeader;
    memcpy(&fHeader, frame, SizeFrameHeader);
    
    // 1、提取帧定界符
    int p;
    for(p=0; p<frame_len; p++){
        if(frame[p]==0xab){
            p++;
            break;
        }
    }
    int data_len = frame_len - p - 6 - 6 - 2; // -4;

    // 2、check data
/*
    // 根据解析结果，发现无需用到FCS，故这里不做CRC校验
    unit_u8 checkdata[MFS];
    int check_len = frame_len - p;
    int FCS;
	memcpy(checkdata, frame+p, check_len);
    FCS = Reverse_Table_CRC(checkdata, check_len, Reverse_Table);
    printf("frame.FCS = %x\n", FCS);
    if(FCS!=0){
        printf("ERROR:帧出错，丢弃\n!");
        return 0;
    }
*/
    
    // 3、提取数据
    memcpy(frame_data, frame+SizeFrameHeader, data_len);
    
    // 4、输出信息
    printf("Destination: ");
    display(fHeader.desMAC, 6, 1);
    printf("Source: ");
    display(fHeader.srcMAC, 6, 1);
    if(fHeader.type[0]==0x08 && fHeader.type[1]==0x00){
        printf("Type: IPv4(%02x%02x)\n",fHeader.type[0], fHeader.type[1]);
    }else{
        printf("Type: %02x%02x\n",fHeader.type[0], fHeader.type[1]);
    }
    
    // 5、返回数据
    return data_len;
}

int enpackIP(unit_u8 *data,int data_len, unit_u8 *datagram){
    if(data_len == 0) return 0;
    printf("===================enpackIP===================\n");
    static u_int sequenceNum = 0;
    sequenceNum += 1;

    // ip封装
    Ipv4Header ipheader;
    ipheader.version_ihl = 0x45; // version为4（ipv4），ihl为5WORD
    ipheader.diffserve = 0x00;
    ipheader.tot_len = 20 + 8 + data_len;  //20 最小iphdr + 8 最小icmp + dataLen 数据长度
    ipheader.id = 0x1000;
    ipheader.frag_off = 0x0000;
    ipheader.ttl = 128;
    ipheader.protocol = 0x01;
    ipheader.check = 0;
    // inet_addr: 点分十进制 to host_long
    ipheader.saddr = inet_addr("192.168.43.34"); // 当前我的ipv4
    ipheader.daddr = htonl(inet_addr("220.181.38.251"));  // baidu.com
    #if SendToNet // 小端存储，内部存储格式转换
    // htonl:host_long to u_long 
    ipheader.saddr = htonl(ipheader.saddr); 
    ipheader.daddr = htonl(ipheader.daddr); 
    #endif
    
    // 进行核校验
    ipheader.check = CalChecksum((unit_u8 *)&ipheader, SizeIpv4Header,0);
    printf("ipheader.check = %x\n", ipheader.check);
    #if !SendToNet// 小端存储，内部存储格式转换
    // htons: hostshort to networkshort
    ipheader.check = htons((unit_u16)ipheader.check);
    #endif
    

    // icmp封装
    ICMPHeader icmpheader;
	icmpheader.type = 0x08;
	icmpheader.code = 0x0;
	icmpheader.check = 0;
	icmpheader.id = 0x0001;
	icmpheader.sequence = sequenceNum;
    
    unit_u8 checkdata[MAXSIZE];
    memcpy(checkdata, (unit_u8 *)&icmpheader, SizeICMPHeader);
    memcpy(checkdata+SizeICMPHeader, data, data_len);
    icmpheader.check = CalChecksum(checkdata, SizeICMPHeader + data_len, 0);
    printf("icmpheader.check = %x\n", icmpheader.check);
    #if !SendToNet // 小端存储，内部存储格式转换
    icmpheader.check = htons(icmpheader.check);
    #endif

    // 返回数据赋值
    memcpy(datagram, &ipheader, SizeIpv4Header);
    memcpy(datagram+SizeIpv4Header, &icmpheader, SizeICMPHeader);
    memcpy(datagram+SizeIpv4Header+SizeICMPHeader, data, data_len);
    int datagram_len = SizeIpv4Header + SizeICMPHeader + data_len;
    return datagram_len;
}

int unpackIP(unit_u8 *frame_data, int frame_data_len, unit_u8 *datagram_data){
    if(frame_data_len == 0) return 0;
    printf("===================unpackIP===================\n");

    // ip解封装
    Ipv4Header ipheader;
    ICMPHeader icmpheader;
    int datagram_data_len = frame_data_len - SizeIpv4Header - SizeICMPHeader;
    memcpy(&ipheader, frame_data, SizeIpv4Header);
    memcpy(&icmpheader, frame_data+SizeIpv4Header, SizeICMPHeader);
    memcpy(datagram_data, frame_data+SizeIpv4Header+SizeICMPHeader,datagram_data_len);

    // check IP data
    ipheader.check = CalChecksum((unit_u8 *)&ipheader, SizeIpv4Header,0);
    printf("ipheader.check = %x\n", ipheader.check);
    if(ipheader.check!=0){
        printf("ERROR:ip首部校验出错，丢弃!\n");
        return 0;
    }
    // check ICMP data
    unit_u8 checkdata[MAXSIZE];
    memcpy(checkdata, (unit_u8 *)&icmpheader, SizeICMPHeader);
    memcpy(checkdata+SizeICMPHeader, datagram_data, datagram_data_len);
    icmpheader.check = CalChecksum(checkdata, SizeICMPHeader + datagram_data_len, 0);
    printf("icmpheader.check = %x\n", icmpheader.check);
    if(icmpheader.check!=0){
        printf("ERROR:icmp校验出错，丢弃!\n");
        return 0;
    }

    // ip解析结果
    struct in_addr saddr, daddr;
    memcpy(&saddr, &ipheader.saddr, 4);
    memcpy(&daddr, &ipheader.daddr, 4);
    printf("【Internet Protocol】\n");
    printf("version:%x\n", (ipheader.version_ihl >> 4));
    printf("Header Length:%d word\n", (ipheader.version_ihl & 0x0f));
    printf("Type of Service:%x\n", ipheader.diffserve);
    printf("Identification: %x\n", ipheader.id);
    printf("Flags:%x\n", ipheader.frag_off);
    printf("Time to Live: %d\n", ipheader.ttl);
    printf("Protocol:%x\n", ipheader.protocol);
    printf("Header Checksum:%d\n", ipheader.check);
    printf("[Header Checksum Status: Good]\n");
    // inet_ntoa只在printf运行一次:inet_ntoa返回一个char *,而这个char *的空间是在inet_ntoa里面静态分配的，所以inet_ntoa后面的调用会覆盖上一次的调用
    printf("Src: %s\n", inet_ntoa(saddr));
    printf("Des: %s\n", inet_ntoa(daddr));

    // icmp解析结果
    printf("【Internet Control Message Protocol】\n");
    printf("Type:%d\n", icmpheader.type);
    printf("Code:%d\n", icmpheader.code);
    printf("Checksum:%d\n", icmpheader.check);
    printf("[Checksum Status: Good]\n");
    printf("Identifier (BE): %d\n", icmpheader.id);
    printf("Sequence Number (BE): %d\n", icmpheader.sequence);

    // 数据输出
    printf("【Data】\n");
    printf("%s\n",datagram_data);

    return datagram_data_len;
}