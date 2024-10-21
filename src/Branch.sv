module Branch(
    //input port
    input in_valid,
    input [31:0] data1,
    input [31:0] data2,
    input [2:0]  branch_op,
    
    //output port
    output reg out_valid
);

//==============================================================
//                     parameter & integer
//==============================================================
//B-type
parameter BEQ  = 0;
parameter BNE  = 1;
parameter BLT  = 2;
parameter BGE  = 3;
parameter BLTU = 4;
parameter BGEU = 5;


//==============================================================
//                     reg & wire
//==============================================================
wire signed [31:0] data1_sign, data2_sign;

//==============================================================
//                         Desgin
//==============================================================
assign data1_sign = data1;
assign data2_sign = data2;

always@(*) begin
    if(in_valid)
        case(branch_op)
            BEQ :    out_valid = (data1==data2)? 1:0;
            BNE :    out_valid = (data1!=data2)? 1:0;
            BLT :    out_valid = (data1_sign < data2_sign)? 1:0;   //signed
            BGE :    out_valid = (data1_sign >= data2_sign)? 1:0;  //signed
            BLTU:    out_valid = (data1 < data2)? 1:0;
            BGEU:    out_valid = (data1 >= data2)? 1:0;
            default: out_valid = 0;
        endcase
    else out_valid = 0;
end

endmodule