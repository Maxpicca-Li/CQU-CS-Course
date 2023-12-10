#pragma once
#ifndef datatype_h_
#define datatype_h_
#include "datatype.h"
#include <string.h>
#endif
const unit_u32 POLY = 0x04c11db7; // 32 bits 生成多项式

unit_u32 CalChecksum(unit_u8* srcdata,int dataLen,unit_u32 checkSum){
    // 需要保证dataLen为2的整数倍
    unit_u8 data[1500];
    memcpy(data, srcdata, dataLen);
    if (dataLen%2){
        data[dataLen] = 0x00;
        dataLen += 1;
    }
    
/*  DEBUG所需
    printf("校验数据: ");
    for (int i = 0;i<dataLen;i++){
        if(i != 0) {
            printf(" ");
        }
        printf("%02x",data[i]);
    }
    printf("\n");
*/

    unit_u32 num;
	int i;
	for (i = 0; i <= dataLen-2; i += 2){ // 一次处理2字节
		num = (data[i] << 8) + data[i + 1]; // 组合成2字节
		checkSum += num;
		checkSum = (checkSum & 0xffff) + (checkSum >> 16);
	}
	checkSum = (~checkSum) & 0xffff;
    return checkSum;
}

// 位翻转函数  
unit_u64 Reflect(unit_u64 ref,unit_u8 ch)  
{     
    int i;  
    unit_u64 value = 0;  
    for( i = 1; i < ( ch + 1 ); i++ )  
    {  
        if( ref & 1 )  
            value |= 1 << ( ch - i );  
        ref >>= 1;  
    }  
    return value;  
}  
 
// 生成CRC32 普通表 , 第二项是04C11DB7  
void gen_direct_table(unit_u32 *table)  
{  
    unit_u32 gx = 0x04c11db7;  
    unsigned long i32, j32;  
    unsigned long nData32;  
    unsigned long nAccum32;  
    for ( i32 = 0; i32 < 256; i32++ )  
    {  
        nData32 = ( unsigned long )( i32 << 24 );  
        nAccum32 = 0;  
        for ( j32 = 0; j32 < 8; j32++ )  
        {  
            if ( ( nData32 ^ nAccum32 ) & 0x80000000 )  
                nAccum32 = ( nAccum32 << 1 ) ^ gx; 
            else  
                nAccum32 <<= 1;  
            nData32 <<= 1;  
        }  
        table[i32] = nAccum32;  
    }  
}  

// 生成CRC32 翻转表 第二项是77073096 
void gen_normal_table(unit_u32 *table)  
{  
    unit_u32 gx = 0x04c11db7;  
    unit_u32 temp,crc;  
    for(int i = 0; i <= 0xFF; i++)   
    {  
        temp=Reflect(i, 8);  
        table[i]= temp<< 24;  
        for (int j = 0; j < 8; j++)  
        {  
            unsigned long int t1,t2;  
            unsigned long int flag=table[i]&0x80000000;  
            t1=(table[i] << 1);  
            if(flag==0)  
            t2=0;  
            else  
            t2=gx;  
            table[i] =t1^t2 ;  
        }  
        crc=table[i];  
        table[i] = Reflect(table[i], 32);  
    }  
}  

unit_u32 crc32_bit(unit_u8 *ptr, unit_u32 len)  
{  
    unit_u32 gx = 0x04c11db7;  
    unit_u8 i;  
    unit_u32 crc = 0xffffffff;  
    while( len-- )  
    {  
        for( i = 1; i != 0; i <<= 1 )  
        {  
            if( ( crc & 0x80000000 ) != 0 )  
            {  
                crc <<= 1;  
                crc ^= gx;  
            }  
            else   
                crc <<= 1;  
            if( ( *ptr & i ) != 0 )   
                crc ^= gx;
        }  
        ptr++;  
    }  
    return ( Reflect(crc,32) ^ 0xffffffff );  
}  

unit_u32 DIRECT_TABLE_CRC(unit_u8 *ptr,int len, unit_u32 * table)   
{  
    unit_u32 crc = 0xffffffff;   
    unit_u8 *p= ptr;  
    int i;  
    for ( i = 0; i < len; i++ )  
        crc = ( crc << 8 ) ^ table[( crc >> 24 ) ^ (unit_u8)Reflect((*(p+i)), 8)];  
    return ~(unit_u32)Reflect(crc, 32) ;  
}  

unit_u32 Reverse_Table_CRC(unit_u8 *data, int len,unit_u32 *table)  
{  
    unit_u32 crc = 0xffffffff;    
    unit_u8 *p = data;  
    int i;  
    for(i=0; i <len; i++)  
        crc =  table[( crc ^( *(p+i)) ) & 0xff] ^ (crc >> 8);  
    return  ~crc ;   
}  