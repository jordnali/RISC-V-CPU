module Forwarding(
    input       MEM_regwrite,
    input       MEM_fp_regwrite,
    input       WB_regwrite,
    input       WB_fp_regwrite,
    input [4:0] MEM_rd_addr,
    input [4:0] WB_rd_addr,
    input [4:0] MEM_frd_addr,
    input [4:0] WB_frd_addr,
    input [4:0] EX_rs1_addr,
    input [4:0] EX_rs2_addr,
    input [4:0] EX_frs1_addr,
    input [4:0] EX_frs2_addr,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [4:0] ID_frs1_addr,
    input [4:0] ID_frs2_addr,
    input       WB_mem_read,
    // input [4:0] MEM_rs2_addr,
    // input [4:0] MEM_frs2_addr,

    // input EX_regwrite,
    // input [4:0] EX_rd_addr,
    // input EX_fp_regwrite,
    // input [4:0] EX_frd_addr,

    output reg [1:0] forwarding_EX_rs1,
    output reg [1:0] forwarding_EX_rs2,
    output reg [1:0] forwarding_EX_frs1,
    output reg [1:0] forwarding_EX_frs2,
    output reg       forwarding_ID_rs1,
    output reg       forwarding_ID_rs2,
    output reg       forwarding_ID_frs1,
    output reg       forwarding_ID_frs2
);

//--------------EX hazard and MEM hazard---------------
//RegFile
always@(*) begin
    if(MEM_regwrite && MEM_rd_addr!=0 && (MEM_rd_addr==EX_rs1_addr))
        forwarding_EX_rs1 = 2'b01;
    else if(WB_regwrite && WB_rd_addr!=0 && (WB_rd_addr==EX_rs1_addr))
        forwarding_EX_rs1 = 2'b10;
    else 
        forwarding_EX_rs1 = 2'b00;
end
always@(*) begin
    if(MEM_regwrite && MEM_rd_addr!=0 && (MEM_rd_addr==EX_rs2_addr))
        forwarding_EX_rs2 = 2'b01;
    else if(WB_regwrite && WB_rd_addr!=0 && (WB_rd_addr==EX_rs2_addr))
        forwarding_EX_rs2 = 2'b10;
    else 
        forwarding_EX_rs2 = 2'b00;
end  
//FP_RegFile  
always@(*) begin
    if(MEM_fp_regwrite && (MEM_frd_addr==EX_frs1_addr))
        forwarding_EX_frs1 = 2'b01;
    else if(WB_fp_regwrite  && (WB_frd_addr==EX_frs1_addr))
        forwarding_EX_frs1 = 2'b10;
    else 
        forwarding_EX_frs1 = 2'b00;
end
always@(*) begin
    if(MEM_fp_regwrite && (MEM_frd_addr==EX_frs2_addr))
        forwarding_EX_frs2 = 2'b01;
    else if(WB_fp_regwrite && (WB_frd_addr==EX_frs2_addr))
        forwarding_EX_frs2 = 2'b10;
    else 
        forwarding_EX_frs2 = 2'b00;
end 

//------------load use hazard-------------

always@(*) begin
    if(WB_regwrite && WB_rd_addr!=0 && (WB_rd_addr==ID_rs1_addr))
        forwarding_ID_rs1 = 1'b1;
    else 
        forwarding_ID_rs1 = 1'b0;
end
always@(*) begin
    if(WB_regwrite && WB_rd_addr!=0 && (WB_rd_addr==ID_rs2_addr))
        forwarding_ID_rs2 = 1'b1;
    else 
        forwarding_ID_rs2 = 1'b0;
end  
//FP_RegFile  
always@(*) begin
    if(WB_fp_regwrite  && (WB_frd_addr==ID_frs1_addr))
        forwarding_ID_frs1 = 1'b1;
    else 
        forwarding_ID_frs1 = 1'b0;
end
always@(*) begin
    if(WB_fp_regwrite && (WB_frd_addr==ID_frs2_addr))
        forwarding_ID_frs2 = 1'b1;
    else 
        forwarding_ID_frs2 = 1'b0;
end 

//--------------store---------------
// //RegFile
// always@(*) begin
//     if(WB_regwrite && WB_rd_addr!=0 && (WB_rd_addr==MEM_rs2_addr))
//         forwarding_data = 1'b1; 
//     else 
//         forwarding_data = 1'b0;
// end
// //FP_RegFile 
// always@(*) begin
//     if(WB_fp_regwrite  && (WB_frd_addr==MEM_frs2_addr))
//         forwarding_fdata = 1'b1; 
//     else 
//         forwarding_fdata = 1'b0; 
// end

endmodule