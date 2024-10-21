
module CSR(
    input clk,
    input rst,
    // input in_valid,
    input stall,
    input flush,

    input [11:0] csrop,

    output reg [31:0] out_data
);
//==============================================================
//                     parameter & integer
//==============================================================
parameter RDINSTRETH = 12'hC82;
parameter RDINSTRET = 12'hC02;
parameter RDCYCLEH = 12'hC80;
parameter RDCYCLE = 12'hC00;
//==============================================================
//                       reg & wire
//==============================================================
reg [63:0] mcycle;
reg [63:0] minstret;
reg [63:0] mcycle_temp;
reg [63:0] minstret_temp;


//==============================================================
//                         Desgin
//==============================================================
assign mcycle_temp   = mcycle - 1;
assign minstret_temp = minstret - 1;
always@(*) begin
    case(csrop)
        RDINSTRETH: out_data = minstret_temp[63:32];
        RDINSTRET:  out_data = minstret_temp[31:0];
        RDCYCLEH:   out_data = mcycle_temp[63:32];
        RDCYCLE:    out_data = mcycle_temp[31:0];
        default:    out_data = 32'd0;
    endcase
end

always@(posedge clk or posedge rst) begin
    if(rst) mcycle <= 0;
    else begin
        mcycle <= mcycle + 1;
    end
end
always@(posedge clk or posedge rst) begin
    if(rst) minstret <= 0;
    else begin
        if(flush)
            minstret <= minstret - 1;
        else if(stall)
            minstret <= minstret;
        else 
            minstret <= minstret + 1;
    end
end

endmodule