// ����ʵ�ֲο�:
// - [C����ʵ��MAC֡�ķ�װ����װ_Skycrab-CSDN����](https://blog.csdn.net/yueguanghaidao/article/details/7663489)
// - [ԭʼ�׽��ַ���IP���ݱ�_IDoubleTong�Ĳ���-CSDN����_ԭʼ�׽��ַ�������](https://blog.csdn.net/weixin_43206704/article/details/89327572)

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

    data_len = strlen(data); //�������β��\0
    printf("data_len = %d\n", data_len);
    
    // ��װip
    datagram_len = enpackIP(data, data_len,datagram);
    printf("datagram_len = %d\n", datagram_len);
    display(datagram, datagram_len,0);

    // ��װFrame
    frame_len = enpackFrame(datagram,datagram_len,frame);
    printf("frame_len = %d\n", frame_len);
    display(frame, frame_len,0);

    // ���װFrame
    frame_data_len = unpackFrame(frame,frame_len,frame_data);
    printf("frame_data_len = %d\n", frame_data_len);
    display(frame_data, frame_data_len,0);

    // ���װDatagram
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

    // ��С֡����
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
    printf("��С֡����: data_len = %d\n", data_len);
    
    FrameHeader fHeader;
    // 1��ǰ����
    fHeader.leader = 0xabaaaaaaaaaaaaaa; // unit_u64 С�˵�ַ 
    // 2����ַ
    printf("������MACĿ�ĵ�ַ:");
    for (int i = 0; i < 6;i++){ scanf("%02x-", fHeader.desMAC + i); }
    fflush(stdin);  // ���������
    printf("������MACԴ��ַ:");
    for (int i = 0; i < 6;i++){ scanf("%02x-", fHeader.srcMAC + i); }
    fflush(stdin); 
    // 3������
    printf("�����������ֶ�:");
    scanf("%02x%02x", fHeader.type, fHeader.type + 1);
    fflush(stdin); 
    
    // FCS[Ŀ�ĵ�ַ+Դ��ַ+����+����+32'b0]����У��
/*
    // ���ݽ�����������������õ�FCS�������ﲻ��CRCУ��
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
    FCS = htonl((unsigned long)FCS); // С�˴洢���ڲ��洢��ʽת��
*/
    
    // ��װ
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
    
    // 1����ȡ֡�����
    int p;
    for(p=0; p<frame_len; p++){
        if(frame[p]==0xab){
            p++;
            break;
        }
    }
    int data_len = frame_len - p - 6 - 6 - 2; // -4;

    // 2��check data
/*
    // ���ݽ�����������������õ�FCS�������ﲻ��CRCУ��
    unit_u8 checkdata[MFS];
    int check_len = frame_len - p;
    int FCS;
	memcpy(checkdata, frame+p, check_len);
    FCS = Reverse_Table_CRC(checkdata, check_len, Reverse_Table);
    printf("frame.FCS = %x\n", FCS);
    if(FCS!=0){
        printf("ERROR:֡��������\n!");
        return 0;
    }
*/
    
    // 3����ȡ����
    memcpy(frame_data, frame+SizeFrameHeader, data_len);
    
    // 4�������Ϣ
    printf("Destination: ");
    display(fHeader.desMAC, 6, 1);
    printf("Source: ");
    display(fHeader.srcMAC, 6, 1);
    if(fHeader.type[0]==0x08 && fHeader.type[1]==0x00){
        printf("Type: IPv4(%02x%02x)\n",fHeader.type[0], fHeader.type[1]);
    }else{
        printf("Type: %02x%02x\n",fHeader.type[0], fHeader.type[1]);
    }
    
    // 5����������
    return data_len;
}

int enpackIP(unit_u8 *data,int data_len, unit_u8 *datagram){
    if(data_len == 0) return 0;
    printf("===================enpackIP===================\n");
    static u_int sequenceNum = 0;
    sequenceNum += 1;

    // ip��װ
    Ipv4Header ipheader;
    ipheader.version_ihl = 0x45; // versionΪ4��ipv4����ihlΪ5WORD
    ipheader.diffserve = 0x00;
    ipheader.tot_len = 20 + 8 + data_len;  //20 ��Сiphdr + 8 ��Сicmp + dataLen ���ݳ���
    ipheader.id = 0x1000;
    ipheader.frag_off = 0x0000;
    ipheader.ttl = 128;
    ipheader.protocol = 0x01;
    ipheader.check = 0;
    // inet_addr: ���ʮ���� to host_long
    ipheader.saddr = inet_addr("192.168.43.34"); // ��ǰ�ҵ�ipv4
    ipheader.daddr = htonl(inet_addr("220.181.38.251"));  // baidu.com
    #if SendToNet // С�˴洢���ڲ��洢��ʽת��
    // htonl:host_long to u_long 
    ipheader.saddr = htonl(ipheader.saddr); 
    ipheader.daddr = htonl(ipheader.daddr); 
    #endif
    
    // ���к�У��
    ipheader.check = CalChecksum((unit_u8 *)&ipheader, SizeIpv4Header,0);
    printf("ipheader.check = %x\n", ipheader.check);
    #if !SendToNet// С�˴洢���ڲ��洢��ʽת��
    // htons: hostshort to networkshort
    ipheader.check = htons((unit_u16)ipheader.check);
    #endif
    

    // icmp��װ
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
    #if !SendToNet // С�˴洢���ڲ��洢��ʽת��
    icmpheader.check = htons(icmpheader.check);
    #endif

    // �������ݸ�ֵ
    memcpy(datagram, &ipheader, SizeIpv4Header);
    memcpy(datagram+SizeIpv4Header, &icmpheader, SizeICMPHeader);
    memcpy(datagram+SizeIpv4Header+SizeICMPHeader, data, data_len);
    int datagram_len = SizeIpv4Header + SizeICMPHeader + data_len;
    return datagram_len;
}

int unpackIP(unit_u8 *frame_data, int frame_data_len, unit_u8 *datagram_data){
    if(frame_data_len == 0) return 0;
    printf("===================unpackIP===================\n");

    // ip���װ
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
        printf("ERROR:ip�ײ�У���������!\n");
        return 0;
    }
    // check ICMP data
    unit_u8 checkdata[MAXSIZE];
    memcpy(checkdata, (unit_u8 *)&icmpheader, SizeICMPHeader);
    memcpy(checkdata+SizeICMPHeader, datagram_data, datagram_data_len);
    icmpheader.check = CalChecksum(checkdata, SizeICMPHeader + datagram_data_len, 0);
    printf("icmpheader.check = %x\n", icmpheader.check);
    if(icmpheader.check!=0){
        printf("ERROR:icmpУ���������!\n");
        return 0;
    }

    // ip�������
    struct in_addr saddr, daddr;
    memcpy(&saddr, &ipheader.saddr, 4);
    memcpy(&daddr, &ipheader.daddr, 4);
    printf("��Internet Protocol��\n");
    printf("version:%x\n", (ipheader.version_ihl >> 4));
    printf("Header Length:%d word\n", (ipheader.version_ihl & 0x0f));
    printf("Type of Service:%x\n", ipheader.diffserve);
    printf("Identification: %x\n", ipheader.id);
    printf("Flags:%x\n", ipheader.frag_off);
    printf("Time to Live: %d\n", ipheader.ttl);
    printf("Protocol:%x\n", ipheader.protocol);
    printf("Header Checksum:%d\n", ipheader.check);
    printf("[Header Checksum Status: Good]\n");
    // inet_ntoaֻ��printf����һ��:inet_ntoa����һ��char *,�����char *�Ŀռ�����inet_ntoa���澲̬����ģ�����inet_ntoa����ĵ��ûḲ����һ�εĵ���
    printf("Src: %s\n", inet_ntoa(saddr));
    printf("Des: %s\n", inet_ntoa(daddr));

    // icmp�������
    printf("��Internet Control Message Protocol��\n");
    printf("Type:%d\n", icmpheader.type);
    printf("Code:%d\n", icmpheader.code);
    printf("Checksum:%d\n", icmpheader.check);
    printf("[Checksum Status: Good]\n");
    printf("Identifier (BE): %d\n", icmpheader.id);
    printf("Sequence Number (BE): %d\n", icmpheader.sequence);

    // �������
    printf("��Data��\n");
    printf("%s\n",datagram_data);

    return datagram_data_len;
}