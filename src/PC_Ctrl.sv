module PC_Ctrl(
    input branch_en,
    input jal_en,
    input jalr_en,
    
    output pc_jump,
    output [1:0] pc_sel
);

assign pc_sel = (branch_en | jal_en)? 2'b01:
                (jalr_en)?            2'b10:2'b00;

assign pc_jump = (branch_en | jal_en | jalr_en)? 1:0;

endmodule