`include "defines.vh"
module branch_predict_global #(parameter PHT_DEPTH = 6) // 作为端口参数
(
    input wire clk, rst,
    
    input wire flushD,
    input wire stallD,
    input wire flushE,
    input wire flushM,

    input wire [31:0] pcF,
    input wire [31:0] pcM,
    
    input wire branchF,        // F阶段更新GHR
    input wire branchD,        // D阶段是否是跳转指令   
    input wire branchM,        // M阶段是否是分支指令
    input wire actual_takeM,   // 实际是否跳转

    output wire [(PHT_DEPTH-1):0] PHT_index, // 输出，作为CPHT的索引
    output wire [(PHT_DEPTH-1):0] update_PHT_index, // 输出，作为CPHT的索引
    output wire pred_takeD,      // 预测是否跳转
    output wire correct          // 预测是否正确
);
// 定义参数
    wire clear,ena;  // wire zero ==> branch跳转控制（已经升级到*控制冒险*）
    assign clear = 1'b0;
    assign ena = 1'b1;

// 定义结构
    reg [(PHT_DEPTH-1):0] GHR_Retire,GHR_Spec;
    reg [1:0] PHT [(1<<PHT_DEPTH)-1:0];
    
    integer i,j;
    wire predF,pred_takeD,pred_takeE,pred_takeM;
    wire [(PHT_DEPTH-1):0] PHT_indexF,PHT_indexD,PHT_indexE,PHT_indexM;

// ---------------------------------------预测逻辑---------------------------------------
// 取指阶段
    assign PHT_index = pcF[(PHT_DEPTH-1+2):2] ^ GHR_Spec[(PHT_DEPTH-1):0];
    assign predF = PHT[PHT_index][1];      // 在取指阶段预测是否会跳转，并经过流水线传递给译码阶段。
    assign pred_takeF = branchF & predF;

    // pipeline
    flopenrc #(1)         DFF_pred_takeD(clk,rst,flushD,~stallD,pred_takeF,pred_takeD);
    flopenrc #(PHT_DEPTH) DFF_PHT_indexD(clk,rst,flushD,~stallD,PHT_indexF,PHT_indexD);
    
    
    flopenrc #(1)         DFF_pred_takeE(clk,rst,flushE,ena,pred_takeD,pred_takeE);
    flopenrc #(PHT_DEPTH) DFF_PHT_indexE(clk,rst,flushE,ena,PHT_indexD,PHT_indexE);
    
    flopenrc #(1)         DFF_pred_takeM(clk,rst,flushM,ena,pred_takeE,pred_takeM);
    flopenrc #(PHT_DEPTH) DFF_PHT_indexM(clk,rst,flushM,ena,PHT_indexE,PHT_indexM);

    // assign PHT_index = PHT_indexF;
    // assign update_PHT_index = PHT_indexM;
    assign update_PHT_index = pcM[(PHT_DEPTH-1+2):2] ^ GHR_Retire[(PHT_DEPTH-1):0];
    
// GHR_Spec初始化及更新
    always@(posedge clk) begin
        if(rst) begin
            // 初始化
            GHR_Spec <= {PHT_DEPTH{1'b0}};
        end
        else if(branchF) begin
            // 预测阶段更新
            GHR_Spec <= {GHR_Spec[(PHT_DEPTH-2):0],pred_takeF};
        end
        else if(branchM & (!correct)) begin
            // 提交阶段更正
            GHR_Spec <= GHR_Retire;
        end
    end
    
// ---------------------------------------预测逻辑---------------------------------------


// ---------------------------------------GHR_Retire初始化以及更新---------------------------------------
    
    always@(posedge clk) begin
        if(rst) begin
            GHR_Retire <= {PHT_DEPTH{1'b0}};
        end
        else if(branchM) begin
            GHR_Retire <= {GHR_Retire[(PHT_DEPTH-2):0],actual_takeM};
        end
    end
// ---------------------------------------GHR_Retire初始化以及更新---------------------------------------


// ---------------------------------------PHT初始化以及更新---------------------------------------
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < (1<<PHT_DEPTH); i=i+1) begin
                PHT[i] <= `Weakly_taken;
            end
        end
        else if(branchM) begin
            case(PHT[update_PHT_index])
                // ********** 此处应该添加你的更新逻辑的代码 **********
                `Strongly_not_taken: PHT[update_PHT_index] <= actual_takeM ? `Weakly_not_taken : `Strongly_not_taken;
                `Weakly_not_taken  : PHT[update_PHT_index] <= actual_takeM ? `Weakly_taken     : `Strongly_not_taken;
                `Weakly_taken      : PHT[update_PHT_index] <= actual_takeM ? `Strongly_taken   : `Weakly_not_taken  ;
                `Strongly_taken    : PHT[update_PHT_index] <= actual_takeM ? `Strongly_taken   : `Weakly_taken      ;
            endcase 
        end
    end
// ---------------------------------------PHT初始化以及更新---------------------------------------

    // 译码阶段输出最终的预测结果
    assign PHT_index = PHT_indexF;
    assign update_PHT_index = PHT_indexM;
    assign correct = (actual_takeM  == pred_takeM)?1:0;
endmodule