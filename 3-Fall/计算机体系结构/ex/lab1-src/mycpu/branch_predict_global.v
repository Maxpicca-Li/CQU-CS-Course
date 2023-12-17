`include "defines.vh"
module branch_predict_global #(parameter PHT_DEPTH = 6) // ��Ϊ�˿ڲ���
(
    input wire clk, rst,
    
    input wire flushD,
    input wire stallD,
    input wire flushE,
    input wire flushM,

    input wire [31:0] pcF,
    input wire [31:0] pcM,
    
    input wire branchF,        // F�׶θ���GHR
    input wire branchD,        // D�׶��Ƿ�����תָ��   
    input wire branchM,        // M�׶��Ƿ��Ƿ�ָ֧��
    input wire actual_takeM,   // ʵ���Ƿ���ת

    output wire [(PHT_DEPTH-1):0] PHT_index, // �������ΪCPHT������
    output wire [(PHT_DEPTH-1):0] update_PHT_index, // �������ΪCPHT������
    output wire pred_takeD,      // Ԥ���Ƿ���ת
    output wire correct          // Ԥ���Ƿ���ȷ
);
// �������
    wire clear,ena;  // wire zero ==> branch��ת���ƣ��Ѿ�������*����ð��*��
    assign clear = 1'b0;
    assign ena = 1'b1;

// ����ṹ
    reg [(PHT_DEPTH-1):0] GHR_Retire,GHR_Spec;
    reg [1:0] PHT [(1<<PHT_DEPTH)-1:0];
    
    integer i,j;
    wire predF,pred_takeD,pred_takeE,pred_takeM;
    wire [(PHT_DEPTH-1):0] PHT_indexF,PHT_indexD,PHT_indexE,PHT_indexM;

// ---------------------------------------Ԥ���߼�---------------------------------------
// ȡָ�׶�
    assign PHT_index = pcF[(PHT_DEPTH-1+2):2] ^ GHR_Spec[(PHT_DEPTH-1):0];
    assign predF = PHT[PHT_index][1];      // ��ȡָ�׶�Ԥ���Ƿ����ת����������ˮ�ߴ��ݸ�����׶Ρ�
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
    
// GHR_Spec��ʼ��������
    always@(posedge clk) begin
        if(rst) begin
            // ��ʼ��
            GHR_Spec <= {PHT_DEPTH{1'b0}};
        end
        else if(branchF) begin
            // Ԥ��׶θ���
            GHR_Spec <= {GHR_Spec[(PHT_DEPTH-2):0],pred_takeF};
        end
        else if(branchM & (!correct)) begin
            // �ύ�׶θ���
            GHR_Spec <= GHR_Retire;
        end
    end
    
// ---------------------------------------Ԥ���߼�---------------------------------------


// ---------------------------------------GHR_Retire��ʼ���Լ�����---------------------------------------
    
    always@(posedge clk) begin
        if(rst) begin
            GHR_Retire <= {PHT_DEPTH{1'b0}};
        end
        else if(branchM) begin
            GHR_Retire <= {GHR_Retire[(PHT_DEPTH-2):0],actual_takeM};
        end
    end
// ---------------------------------------GHR_Retire��ʼ���Լ�����---------------------------------------


// ---------------------------------------PHT��ʼ���Լ�����---------------------------------------
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < (1<<PHT_DEPTH); i=i+1) begin
                PHT[i] <= `Weakly_taken;
            end
        end
        else if(branchM) begin
            case(PHT[update_PHT_index])
                // ********** �˴�Ӧ�������ĸ����߼��Ĵ��� **********
                `Strongly_not_taken: PHT[update_PHT_index] <= actual_takeM ? `Weakly_not_taken : `Strongly_not_taken;
                `Weakly_not_taken  : PHT[update_PHT_index] <= actual_takeM ? `Weakly_taken     : `Strongly_not_taken;
                `Weakly_taken      : PHT[update_PHT_index] <= actual_takeM ? `Strongly_taken   : `Weakly_not_taken  ;
                `Strongly_taken    : PHT[update_PHT_index] <= actual_takeM ? `Strongly_taken   : `Weakly_taken      ;
            endcase 
        end
    end
// ---------------------------------------PHT��ʼ���Լ�����---------------------------------------

    // ����׶�������յ�Ԥ����
    assign PHT_index = PHT_indexF;
    assign update_PHT_index = PHT_indexM;
    assign correct = (actual_takeM  == pred_takeM)?1:0;
endmodule