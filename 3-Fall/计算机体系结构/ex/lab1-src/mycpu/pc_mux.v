`timescale 1ns/1ps
module pc_mux(
    // input  wire flushF,
    input  wire jumpD,
    input  wire branch_takeD,
    input  wire[31:0] pc_plus4F,
    input  wire[31:0] pc_branchD,
    // input  wire[31:0] pc_actualM,
    input  wire[31:0] pc_jumpD,

    output wire [31:0] pc_nextF
);

    // assign pc_nextF   = flushF       ? pc_actualM :   // 注意优先级依次降低
    //                     jumpD        ? pc_jumpD   :
    //                     branch_takeD ? pc_branchD :
    //                                    pc_plus4F  ;
    
    assign pc_nextF   = jumpD        ? pc_jumpD   :   // 注意优先级依次降低
                        branch_takeD ? pc_branchD :
                                       pc_plus4F  ;    

endmodule