module ALU(
    //input ALU
    input [31:0] data1,
    input [31:0] data2,
    input [3:0] ALU_op,

    //
    output reg [31:0] result
);

//==============================================================
//                   parameter & integer
//==============================================================
//R-type
parameter  ALU_ADD    = 4'd0,
           ALU_SUB    = 4'd1,
           ALU_SLL    = 4'd2,
           ALU_SLT    = 4'd3, 
           ALU_SLTU   = 4'd4,
           ALU_XOR    = 4'd5, 
           ALU_SRL    = 4'd6, 
           ALU_SRA    = 4'd7, 
           ALU_OR     = 4'd8, 
           ALU_AND    = 4'd9,
           //LUI
           ALU_LUI    = 4'd10,
           //MUL
           ALU_MUL    = 4'd11,
           ALU_MULH   = 4'd12,
           ALU_MULHSU = 4'd13,
           ALU_MULHU  = 4'd14;



//==============================================================
//                       reg & wire 
//==============================================================
wire signed [31:0] data1_sign, data2_sign;

//mul
reg signed [32:0] datam1_sign, datam2_sign;
wire signed [63:0] result_sign;
//==============================================================
//                           ALU
//==============================================================
assign data1_sign = data1;
assign data2_sign = data2;

always@(*) begin
    case(ALU_op)
        ALU_ADD   :  result = data1 + data2;  
        ALU_SUB   :  result = data1 - data2;
        ALU_SLL   :  result = data1 << data2[4:0];
        ALU_SLT   :  result = data1_sign < data2_sign? 1:0;      //signed
        ALU_SLTU  :  result = (data1 < data2)? 1:0;
        ALU_XOR   :  result = data1 ^ data2;
        ALU_SRL   :  result = data1 >> data2[4:0];
        ALU_SRA   :  result = data1_sign >>> data2[4:0];       //signed
        ALU_OR    :  result = data1 | data2;
        ALU_AND   :  result = data1 & data2;
        //LUI
        ALU_LUI   :  result = data2;
        //MUL
        ALU_MUL   :  result = result_sign[31:0];
        ALU_MULH  :  result = result_sign[63:32];
        ALU_MULHSU:  result = result_sign[63:32];
        ALU_MULHU :  result = result_sign[63:32];
        default   :  result = 'd0;
    endcase
end

always@(*) begin
    case(ALU_op)
        ALU_MULHU:                       datam1_sign = {1'b0, data1};          //rs1(unsigned)
        ALU_MUL, ALU_MULH, ALU_MULHSU:   datam1_sign = {data1[31], data1};    //rs1(signed)
        default:                         datam1_sign = 'd0;
    endcase
end
always@(*) begin
    case(ALU_op)
        ALU_MULHSU, ALU_MULHU:   datam2_sign = {1'b0, data2};         //rs2(unsigned)
        ALU_MUL, ALU_MULH:       datam2_sign = {data2[31], data2};    //rs2(signed)
        default:                 datam2_sign = 'd0;
    endcase
end

assign result_sign = datam1_sign * datam2_sign;



endmodule