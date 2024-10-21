module FP_RegFile(
    //-----------input port-------------
    input clk,
    input rst,
    input [4:0] frs1_addr,
    input [4:0] frs2_addr,
    //
    input frd_en,
    input [4:0] frd_addr,
    input [31:0] frd_data,
    //-----------output port-------------
    output [31:0] frs1_data,
    output [31:0] frs2_data
);
//==============================================================
//                     parameter & integer
//==============================================================
integer i;
//==============================================================
//                       reg & wire
//==============================================================
reg [31:0] core_freg [31:0];

//==============================================================
//                        Design
//==============================================================
always@(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0; i<32 ;i=i+1)
            core_freg[i] <= 0;
    end
    else begin
        if(frd_en)
            core_freg[frd_addr] <= frd_data;
    end
end
assign frs1_data = core_freg[frs1_addr];
assign frs2_data = core_freg[frs2_addr];

endmodule