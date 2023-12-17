module branch_predict (
    input wire clk, rst,
    
    input wire flushD,
    input wire stallD,
    input wire flushE,
    input wire flushM,

    input wire [31:0] pcF,
    input wire [31:0] pcM,
    
    input wire branchF,        // Ԥ��׶θ���GHR_Spec
    input wire branchD,        // ����׶��Ƿ�����תָ��   
    input wire branchM,         // M�׶��Ƿ��Ƿ�ָ֧��
    input wire actual_takeM,    // ʵ���Ƿ���ת

    
    output wire pred_takeD      // Ԥ���Ƿ���ת
);

// �������
    parameter PHT_DEPTH = 6;  
    parameter BHT_DEPTH = 10;
    parameter Strongly_GP = 2'b00,Weakly_GP = 2'b01, Weakly_BP = 2'b11, Strongly_BP = 2'b10;
    integer i;

// ����ṹ
    wire Gpred_takeD,Bpred_takeD;
    wire correctG,correctB;

    reg  [1:0] CPHT [(1<<PHT_DEPTH)-1:0];
    wire [(PHT_DEPTH-1):0] GPHT_index;  // CPHT��index��Դ�� GPHT_index = PC ^ GHT
    wire [(PHT_DEPTH-1):0] update_GPHT_index;

// GHT��BHTԤ��͸���
    branch_predict_global #(.PHT_DEPTH(PHT_DEPTH))
    GHT(
        .clk(clk), 
        .rst(rst),
        .flushD(flushD),
        .stallD(stallD),
        .flushE(flushE),
        .flushM(flushM),
        .pcF(pcF),
        .pcM(pcM),
        .branchF(branchF),
        .branchD(branchD),
        .branchM(branchM), 
        .actual_takeM(actual_takeM),        
        
        .PHT_index(GPHT_index),
        .update_PHT_index(update_GPHT_index),
        .pred_takeD(Gpred_takeD),
        .correct(correctG)
    );
    
    branch_predict_local #(.PHT_DEPTH(PHT_DEPTH),.BHT_DEPTH(BHT_DEPTH))
    BHT(
        .clk(clk), 
        .rst(rst),
        .flushD(flushD),
        .stallD(stallD),
        .flushE(flushE),
        .flushM(flushM),
        .pcF(pcF),
        .pcM(pcM),
        .branchD(branchD),
        .branchM(branchM), 
        .actual_takeM(actual_takeM),        
        
        .pred_takeD(Bpred_takeD),
        .correct(correctB)
    );

// CPHT��ѡ��
    assign pred_takeD = CPHT[GPHT_index][1] ? Bpred_takeD : Gpred_takeD;

// CPHT�ĳ�ʼ���͸���
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < (1<<PHT_DEPTH); i=i+1) begin
                CPHT[i] <= Weakly_GP;
            end
        end
        else if(branchM) begin
            case(CPHT[update_GPHT_index])
                // Strongly_GP: begin
                //     if(correctG >= correctB)       CPHT[update_GPHT_index] <= Strongly_GP;
                //     else                           CPHT[update_GPHT_index] <= Weakly_GP;
                // end
                // Weakly_GP  : begin
                //     if(correctG > correctB)        CPHT[update_GPHT_index] <= Strongly_GP;
                //     else if (correctG == correctB) CPHT[update_GPHT_index] <= Weakly_GP;
                //     else                           CPHT[update_GPHT_index] <= Weakly_BP;
                // end
                // Weakly_BP  : begin
                //     if(correctG > correctB)        CPHT[update_GPHT_index] <= Weakly_GP;
                //     else if (correctG == correctB) CPHT[update_GPHT_index] <= Weakly_BP;
                //     else                           CPHT[update_GPHT_index] <= Strongly_BP;
                // end
                // Strongly_BP: begin
                //     if(correctG <= correctB)       CPHT[update_GPHT_index] <= Strongly_BP;
                //     else                           CPHT[update_GPHT_index] <= Weakly_BP;
                // end
                Strongly_GP: CPHT[update_GPHT_index] <= (!correctG &&  correctB) ? Weakly_GP  : Strongly_GP;
                Weakly_GP  : CPHT[update_GPHT_index] <= ( correctG && !correctB) ? Strongly_GP: 
                                                        (!correctG &&  correctB) ? Weakly_BP  : Weakly_GP;
                Weakly_BP  : CPHT[update_GPHT_index] <= ( correctG && !correctB) ? Weakly_GP  : 
                                                        (!correctG &&  correctB) ? Strongly_BP: Weakly_BP;
                Strongly_BP: CPHT[update_GPHT_index] <= ( correctG && !correctB) ? Weakly_BP  : Strongly_BP;
            endcase 
        end
    end
endmodule