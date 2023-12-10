typedef          char      unit_8; // 1byte, 8bit
typedef          short     unit_16; // 2bytes, 16bit
typedef          int       unit_32; // 4byte，32bit
typedef          long long unit_64; // 8bit, 64bit
typedef unsigned char      unit_u8; // 1byte, 8bit
typedef unsigned short     unit_u16; // 2bytes, 16bit
typedef unsigned int       unit_u32; // 4byte，32bit
typedef unsigned long long unit_u64; // 8bit, 64bit

typedef struct FrameHeader FrameHeader;
typedef struct Ipv4Header Ipv4Header;
typedef struct ICMPHeader ICMPHeader;

const int SizeFrameHeader = 22;
const int SizeIpv4Header = 20;
const int SizeICMPHeader = 8;

struct FrameHeader {
    unit_u64 leader;  // 0xaaaaaaaaaaaaaaab
    unit_u8 desMAC[6];  // 6bytes，目的地址
    unit_u8 srcMAC[6];  // 6bytes，源地址
    unit_u8 type[2];    // 2bytes，类型
};

struct Ipv4Header{
    unit_u8 version_ihl; // 1byte 4bits 版本，ipv4 = 0x4 和 4bits 首部长度，最短是5
    unit_u8 diffserve; // 1byte 区分服务
    unit_u16 tot_len; // 2bytes 总长度
    unit_u16 id; // 2bytes 标识
    unit_u16 frag_off; // 3bits [空 DF MF] + 13bits 片位移 = 16bits
    unit_u8 ttl; // 1byte 生存时间
    unit_u8 protocol; // 1byte 协议
    unit_u16 check; // 2bytes 首部校验核
    unit_u32 saddr; // 4bytes 源地址
    unit_u32 daddr; // 4bytes 目的地址
};

struct ICMPHeader{ // 2 word, 8字节
    unit_u8 type;  // 1byte
    unit_u8 code;  // 1byte
    unit_u16 check; // 2byte
    unit_u16 id;  // 2byte
    unit_u16 sequence; // 2byte
};