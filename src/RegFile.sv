
module RegFile(
    //-----------input port-------------
    input clk,
    input rst,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    //
    input rd_en,
    input [4:0] rd_addr,
    input [31:0] rd_data,
    //-----------output port-------------
    output [31:0] rs1_data,
    output [31:0] rs2_data
);
//==============================================================
//                     parameter & integer
//==============================================================
integer i;
//==============================================================
//                       reg & wire
//==============================================================
reg [31:0] core_reg [31:0];

//==============================================================
//                        Design
//==============================================================
always@(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0; i<32 ;i=i+1)
            core_reg[i] <= 0;
    end
    else begin
        if(rd_en && (rd_addr != 0))
            core_reg[rd_addr] <= rd_data;
    end
end
assign rs1_data = core_reg[rs1_addr];
assign rs2_data = core_reg[rs2_addr];

endmodule
