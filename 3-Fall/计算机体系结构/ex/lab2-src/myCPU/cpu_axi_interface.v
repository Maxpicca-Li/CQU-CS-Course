/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module cpu_axi_interface
(
    input         clk,
    input         resetn, 

    //inst sram-like sram从方
    input         inst_req     ,
    input         inst_wr      ,
    input  [1 :0] inst_size    ,
    input  [31:0] inst_addr    ,
    input  [31:0] inst_wdata   ,
    output [31:0] inst_rdata   ,
    output        inst_addr_ok ,
    output        inst_data_ok ,
    
    //data sram-like 
    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

    //axi 主方
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       
);
//addr
reg do_req;
reg do_req_or; //req is inst or data;1:data,0:inst 判断当前请求是data的还是inst的
reg        do_wr_r;
reg [1 :0] do_size_r;
reg [31:0] do_addr_r;
reg [31:0] do_wdata_r;
wire data_back;

// TODO 可以像lvf学长那样，把仲裁单独写一个模块，
// FIXME 但是这样，一次只能发送一个请求。。。没有利用好分通道这个特性
// NOTE 要利用多通道的话，可以分inst_rreq,data_rreq,data_wreq三种请求
// OHHH yfy学长他们直接将icache和dcache写成了axi接口，完美利用分通道特性，
// NOTE 但是也增大了cache的复杂度，不算太妥
// OHHH 类sram接口肯定实现不了多字的，因为len恒为1
// OHHH 才发现yfy学长他们的icache和dcache只实现了部分axi接口，妙！！！

// 类sram接口的仲裁处理
// 优先数据请求，再指令请求  ==> 其实可以优先指令请求，再数据请求，都试一下
assign inst_addr_ok = !do_req&&!data_req;  // 吐血，这个addr_ok这么草率的吗？不看看是否arready？或者awready？（是因为一直设置的为1，我去，这么草率的吗）
assign data_addr_ok = !do_req;
always @(posedge clk)
begin
    // 请求仲裁，请求会一直持续到数据返回
    do_req     <= !resetn                       ? 1'b0 : 
                  (inst_req||data_req)&&!do_req ? 1'b1 :
                  data_back                     ? 1'b0 : do_req;
    // 仲裁结果
    do_req_or  <= !resetn ? 1'b0 : 
                  !do_req ? data_req : do_req_or;
    // 写使能仲裁
    do_wr_r    <= data_req&&data_addr_ok ? data_wr :
                  inst_req&&inst_addr_ok ? inst_wr : do_wr_r;
    // 大小仲裁
    do_size_r  <= data_req&&data_addr_ok ? data_size :
                  inst_req&&inst_addr_ok ? inst_size : do_size_r;
    // 地址仲裁
    do_addr_r  <= data_req&&data_addr_ok ? data_addr :
                  inst_req&&inst_addr_ok ? inst_addr : do_addr_r;
    // 数据仲裁
    do_wdata_r <= data_req&&data_addr_ok ? data_wdata :
                  inst_req&&inst_addr_ok ? inst_wdata :do_wdata_r;
end

//inst sram-like  data_ok确保数据对应正确的请求
assign inst_data_ok = do_req&&!do_req_or&&data_back;
assign data_data_ok = do_req&& do_req_or&&data_back;
assign inst_rdata   = rdata;
assign data_rdata   = rdata;

//---axi
reg addr_rcv;
reg wdata_rcv;

assign data_back = addr_rcv && (rvalid&&rready||bvalid&&bready); // 一次访存结束，注意，这里的addr_rcv，握手成功后，一直会持续到数据返回，和cache中的有些不一样哦
always @(posedge clk)
begin
    // 地址握手和数据握手
    addr_rcv  <= !resetn          ? 1'b0 :
                //  a*valid和a*ready同时发生时，地址握手成功
                 arvalid&&arready ? 1'b1 : // 读请求
                 awvalid&&awready ? 1'b1 : // 写请求
                 data_back        ? 1'b0 : addr_rcv;
    wdata_rcv <= !resetn        ? 1'b0 :
                // 数据写成功的数据握手
                 wvalid&&wready ? 1'b1 :
                 data_back      ? 1'b0 : wdata_rcv;
end

// 类sram接口转axi
// 其实只有部分信号会使用到
//ar
assign arid    = 4'd0; // XXX 取指恒为0，取数恒为1
assign araddr  = do_addr_r;
assign arlen   = 8'd0;
assign arsize  = do_size_r;
assign arburst = 2'd0;
assign arlock  = 2'd0;
assign arcache = 4'd0;
assign arprot  = 3'd0;
assign arvalid = do_req&&!do_wr_r&&!addr_rcv; // 这边地址没有握手成功的前一段时间，一旦握手成功，立即拉下来
//r
assign rready  = 1'b1;

//aw
assign awid    = 4'd0;
assign awaddr  = do_addr_r;
assign awlen   = 8'd0;
assign awsize  = do_size_r;
assign awburst = 2'd0;
assign awlock  = 2'd0;
assign awcache = 4'd0;
assign awprot  = 3'd0;
assign awvalid = do_req&&do_wr_r&&!addr_rcv;
//w
assign wid    = 4'd0;
assign wdata  = do_wdata_r;
// 这个写法好妙啊！！！
assign wstrb  = do_size_r==2'd0 ? 4'b0001<<do_addr_r[1:0] :
                do_size_r==2'd1 ? 4'b0011<<do_addr_r[1:0] : 4'b1111;
assign wlast  = 1'd1;
assign wvalid = do_req&&do_wr_r&&!wdata_rcv;
//b
assign bready  = 1'b1;

endmodule

