module Hazard_detector(
    input clk, rst,
    input EX_mem_read,
    input EX_regwrite,
    input EX_fp_regwrite,
    input [4:0] EX_rd_addr,
    input [4:0] EX_frd_addr,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [4:0] ID_frs1_addr,
    input [4:0] ID_frs2_addr,

    input branch_en, jalr_en, jal,

    output reg stall_PC_IF,
    output reg stall_IF_ID,
    output reg flush_IF_ID,
    output reg flush_ID_EX,
    output reg flush_ID_EX_2
);
wire load_use_rd_valid;
wire load_use_frd_valid;
wire branch_jump_valid;
assign load_use_rd_valid = (EX_mem_read && EX_regwrite && EX_rd_addr!=0 && (EX_rd_addr==ID_rs1_addr || EX_rd_addr==ID_rs2_addr))? 1:0;
assign load_use_frd_valid = (EX_mem_read && EX_fp_regwrite && (EX_frd_addr==ID_frs1_addr || EX_frd_addr==ID_frs2_addr))? 1:0;
assign branch_jump_valid = (branch_en || jalr_en || jal)? 1:0;
//Load use Data Hazard
always@(*) begin
    if(load_use_rd_valid || load_use_frd_valid)
        stall_PC_IF = 1;
    else
        stall_PC_IF = 0;
end

always@(*) begin
    if(load_use_rd_valid || load_use_frd_valid)
        stall_IF_ID = 1;
    else
        stall_IF_ID = 0;
end

//control hazard
always@(*) begin
    if(branch_jump_valid) 
        flush_IF_ID = 1;
    else
        flush_IF_ID = 0;
end
always@(*) begin
    if(branch_jump_valid || load_use_rd_valid || load_use_frd_valid) 
        flush_ID_EX = 1;
    else
        flush_ID_EX = 0;
end
always@(posedge clk or posedge rst) begin
    if(rst) flush_ID_EX_2 <= 0;
    else begin
        if(branch_jump_valid) flush_ID_EX_2 <= 1;
        else                  flush_ID_EX_2 <= 0;
    end
end


endmodule