`timescale 1ns/1ps
module hazard (
    input wire regwriteE,regwriteM,regwriteW,
    input wire memtoRegE,memtoRegM,
    input wire branchM,actual_takeM,pred_takeM,
    input wire [4:0]rsD,rtD,rsE,rtE,
    input wire [4:0]reg_waddrM,reg_waddrW,reg_waddrE,
    
    output wire stallF,stallD,
    output wire flushF,flushD,flushE,flushM,
    output wire forwardAD,forwardBD,
    output wire[1:0] forwardAE, forwardBE
);
    
    // 数据冒险
    assign forwardAE =  ((rsE != 5'b0) & (rsE == reg_waddrM) & regwriteM) ? 2'b10: // 前推计算结果
                        ((rsE != 5'b0) & (rsE == reg_waddrW) & regwriteW) ? 2'b01: // 前推写回结果
                        2'b00; // 原结果
    assign forwardBE =  ((rtE != 5'b0) & (rtE == reg_waddrM) & regwriteM) ? 2'b10: // 前推计算结果
                        ((rtE != 5'b0) & (rtE == reg_waddrW) & regwriteW) ? 2'b01: // 前推写回结果
                        2'b00; // 原结果 
    
    // 控制冒险产生的写冲突 
    // 0 原结果， 1 写回结果
    assign forwardAD = (rsD != 5'b0) & (rsD == reg_waddrM) & regwriteM;
    assign forwardBD = (rtD != 5'b0) & (rtD == reg_waddrM) & regwriteM;
    
    // 判断 decode 阶段 rs 或 rt 的地址是否是上一个lw 指令要写入的地址rtE；
    wire lwstall,branch_stall; 
    assign lwstall = ((rsD == rtE) | (rtD == rsE)) & memtoRegE;
    assign branch_stall = branchM & (actual_takeM != pred_takeM);
    
    assign stallF = lwstall | branch_stall;
    assign stallD = lwstall | branch_stall;
    assign flushF = branch_stall; // flushF 动态分支预测错误
    assign flushD = branch_stall; // lwstall | 
    assign flushE = lwstall | branch_stall;
    assign flushM = branch_stall; // lwstall | 

endmodule