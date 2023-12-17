module d_cache_2waywb (
    input wire clk, rst, // except,no_cache,       // 这里不用实现 except 和 no_cache 两个接口
    //mips core --> cache
    input  wire        cpu_data_req     ,      //Mipscore发起读写请求  mips->cache
    input  wire        cpu_data_wr      ,      //代表当前请求是否是写请求
    input  wire [1 :0] cpu_data_size    ,      //确定数据的有效字节
    input  wire [31:0] cpu_data_addr    ,       
    input  wire [31:0] cpu_data_wdata   ,
    output wire [31:0] cpu_data_rdata   ,      //cache返回给mips的数据  cache->mips
    output wire        cpu_data_addr_ok ,      //Cache–>Mipscore  Cache 返回给 Mipscore 的地址握手成功
    output wire        cpu_data_data_ok ,

    //cache --> axi interface
    output wire        cache_data_req     ,    //Cache 发送的读写请求，可因为 cache 缺失或者脏的cacheline 被替换产生的写请求
    output wire        cache_data_wr      ,    //代表当前请求是否是写请求
    output wire [1 :0] cache_data_size    ,    //读数据的有效字节  // TODO axi burst传输需要
    output wire [31:0] cache_data_addr    ,    
    output wire [31:0] cache_data_wdata   ,
    input  wire [31:0] cache_data_rdata   ,    //从mem返回给cache的数据
    input  wire        cache_data_addr_ok ,    //成功收到地址数据
    input  wire        cache_data_data_ok      //数据成功
);
//Cache配置
    // cache数据容量为4KB不变时，增加一路，indec_width少1，tag位增1
    parameter  INDEX_WIDTH  = 9, OFFSET_WIDTH = 2, WAY_NUM = 2;   // TODO axi-burst 传输需要更改 offset
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
//Cache存储单元
    reg                 cache_lastused[CACHE_DEEPTH - 1 : 0]; // 每行cache都有1bit lastused标志，0:way1,1:way2
    reg                 cache_valid   [WAY_NUM-1 : 0][CACHE_DEEPTH - 1 : 0];
    reg                 cache_dirty   [WAY_NUM-1 : 0][CACHE_DEEPTH - 1 : 0];
    reg [TAG_WIDTH-1:0] cache_tag     [WAY_NUM-1 : 0][CACHE_DEEPTH - 1 : 0];
    reg [31:0]          cache_block   [WAY_NUM-1 : 0][CACHE_DEEPTH - 1 : 0];
    
//访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;

    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
    
//访问Cache line
    wire currused;
    wire c_valid;
    wire c_dirty;
    wire c_lastused;
    wire [TAG_WIDTH-1:0] c_tag;
    wire [31:0] c_block;
    assign currused = (cache_valid[1][index] & (cache_tag[1][index]==tag)) ? 1'b1 : 
                      (cache_valid[0][index] & (cache_tag[0][index]==tag)) ? 1'b0 : 
                      !c_lastused;
    assign c_valid = cache_valid[currused][index];
    assign c_tag   = cache_tag  [currused][index];
    assign c_block = cache_block[currused][index];        //数据
    assign c_dirty = cache_dirty[currused][index];
    assign c_lastused = cache_lastused[index];
    
//判断是否命中
    wire hit, miss;
    assign hit  = cpu_data_req & c_valid & (c_tag == tag);  //cache line的valid位为1，且tag与地址中tag相等
    assign miss = cpu_data_req & ~hit;

//读或写
    wire read, write;
    assign write = cpu_data_wr;
    assign read = ~write;

//FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:   state <= cpu_data_req & read & miss & !c_dirty ? RM :                            // 读缺失且该位没有被修改
                                 cpu_data_req & read & miss &  c_dirty ? WM :                            // 读缺失且该位修改过
                                 cpu_data_req & read & hit  ? IDLE :                                     // 读命中
                                 // cpu_data_req & write & miss & c_dirty & !write_miss_nodirty_save ? WM : // 写缺失并且dirty才写内存
                                 cpu_data_req & write & miss & c_dirty ? WM : // 写缺失并且dirty才写内存
                                 IDLE;   
                RM:     state <= read & cache_data_data_ok ? IDLE : RM;
                WM:     state <= read & miss & c_dirty & cache_data_data_ok ? RM :                              // 读缺失读脏，写存完毕后读存
                                 cache_data_data_ok ? IDLE :                                     // 写缺失写脏，写存完毕后恢复IDLE
                                 WM;
            endcase
        end
    end

//读内存
    //变量read_req, addr_rcv, read_finish用于构造类sram信号。
    wire read_req;      //一次完整的读事务，从发出读请求到结束;读取内存请求
    reg  addr_rcv;      //地址接收成功(addr_ok)后到结束,代表地址已经收到了
    wire read_finish;   //数据接收成功(data_ok)，即读请求结束
    assign read_req = state==RM ;
    assign read_finish = read & read_req & cache_data_data_ok;  // FIXME 需要考虑到 cache_data_data_ok 是否是上一个请求的data_ok信号
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    read & read_req & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : addr_rcv;
    end

//写内存 
    wire write_req;     
    reg  waddr_rcv;      
    wire write_finish;
    assign write_req = state==WM;
    assign write_finish = write & write_req & cache_data_data_ok;
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     write & write_req & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 : waddr_rcv;
    end
    
//output to mips core    
    wire no_mem;
    reg no_mem_save;
    assign no_mem = (cpu_data_req & read & hit) | (cpu_data_req & write & !(miss & c_dirty));
    // assign no_mem = (read | write) & cpu_data_req & (state==IDLE);
    always @(posedge clk) begin
        if(rst) no_mem_save <= 1'b0;
        else no_mem_save <= no_mem;
    end
    
    assign cpu_data_rdata   = hit ? c_block : cache_data_rdata;  //cache 返回给mips的数据
    assign cpu_data_addr_ok = no_mem | (((read & state==RM)|(write & state==WM)) & cache_data_req & cache_data_addr_ok);
    assign cpu_data_data_ok = no_mem | (((read & state==RM)|(write & state==WM)) & cache_data_data_ok);
                               

//output to axi interface
    // 读缺失读脏位
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;
    assign cache_data_wr    = (state==WM) ? 1'b1 : 1'b0;                         // 非写即0
    assign cache_data_size  = (state==WM) ? 2'b10: cpu_data_size;                // 非写即读
    assign cache_data_addr  = (state==WM) ? {c_tag,index,2'b00} : cpu_data_addr; // 非写即读
    assign cache_data_wdata = (state==WM) ? c_block : {32{1'b0}};                // 非写即0
    // Loogson cpu 可能错误的代码
    // assign cache_data_wr    = ((state==IDLE) & miss & c_dirty) ? 1'b1 : cpu_data_wr;
    // assign cache_data_size  = ((state==IDLE) & miss & c_dirty) ? 2'b10: cpu_data_size;
    // assign cache_data_addr  = ((state==IDLE) & miss & c_dirty) ? {c_tag,index,2'b00} : cpu_data_addr;
    // assign cache_data_wdata = ((state==IDLE) & miss & c_dirty) ? c_block : cpu_data_wdata;

//写入Cache
    //保存地址中的tag, index，防止addr发生改变
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    reg c_lastused_save;
    reg currused_save;
    always @(posedge clk) begin
        tag_save        <= rst ? 0 :
                         cpu_data_req ? tag : tag_save;
        index_save      <= rst ? 0 :
                         cpu_data_req ? index : index_save;
        c_lastused_save <= rst ? 0 :
                         cpu_data_req ? c_lastused : c_lastused_save;
        currused_save <= rst ? 0 :
                         cpu_data_req ? currused : currused_save;
    end

    // 通过掩码确认写入的数据
    wire [31:0] write_cache_data;
    wire [3:0] write_mask4;
    wire [31:0] write_mask32;
    //根据地址低两位和size，生成写掩码（针对sb，sh等不是写完整一个字的指令），4位对应1个字（4字节）中每个字的写使能
    assign write_mask4 = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);
    //掩码的使用：位为1的代表需要更新的。
    //位拓展：{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_mask32 = { {8{write_mask4[3]}}, {8{write_mask4[2]}}, {8{write_mask4[1]}}, {8{write_mask4[0]}} };
    assign write_cache_data = cache_block[currused][index] & ~write_mask32 | cpu_data_wdata & write_mask32; // 默认原数据，有写请求再写入读到的数据

    // 写cache
    integer t;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //刚开始将Cache置为无效
                cache_valid[0][t] <= 1'b0;
                cache_valid[1][t] <= 1'b0;
                cache_dirty[0][t] <= 1'b0; 
                cache_dirty[1][t] <= 1'b0; 
                cache_lastused[t] <= 1'b0;
            end
        end
        else begin
            // 缺失涉及到替换way，涉及到访存后再写的（**地址握手**），都需要使用_save信号
            if(read_finish) begin  // 读缺失，读存结束，此时**地址握手**已经完成
                // $display("读缺失读存结束"); 
                cache_valid[!c_lastused_save][index_save] <= 1'b1;             //将Cache line置为有效
                cache_tag  [!c_lastused_save][index_save] <= tag_save;
                cache_block[!c_lastused_save][index_save] <= cache_data_rdata; //写入Cache line
                cache_dirty[!c_lastused_save][index_save] <= 1'b0;
                cache_lastused[index_save] <= !c_lastused_save;
            end
            else if(read & cpu_data_req & hit) begin
                // $display("读命中"); 更新lastused
                cache_lastused[index] <= currused;
            end
            else if(write & cpu_data_req & hit) begin   // 写命中时需要写Cache
                // $display("写命中"); 直接写
                cache_block[currused][index] <= write_cache_data;             // 写入Cache line，使用index而不是index_save
                cache_dirty[currused][index] <= 1'b1;                         // 写命中时需要将脏位置为1
                cache_lastused[index] <= currused;
            end
            else if(write & (state==WM) & cache_data_data_ok) begin   // 写缺失会有一个写存，**地址握手**成功后cpu_data_req会拉下来
                // $display("写缺失写脏");
                cache_block[currused_save][index_save] <= write_cache_data;     
                cache_dirty[currused_save][index_save] <= 1'b1;
                cache_lastused[index_save] <= currused_save;
            end 
            else if(write & cpu_data_req & (state==IDLE)) begin   // 写缺失+干净后的直接写操作
                // $display("写缺失写干净"); 直接写
                cache_valid[!c_lastused][index] <= 1'b1;             //将Cache line置为有效
                cache_tag  [!c_lastused][index] <= tag;
                cache_block[!c_lastused][index] <= write_cache_data;
                cache_dirty[!c_lastused][index] <= 1'b1;
                cache_lastused[index] <= !c_lastused;
            end
        end
    end
endmodule