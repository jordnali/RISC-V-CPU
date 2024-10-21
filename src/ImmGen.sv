module ImmGen(
    input [31:0] inst,
    output reg [31:0] immediate
);
//==============================================================
//                   parameter & integer
//==============================================================
parameter   OP_R_TYPE        = 7'b0110011,
            OP_I_TYPE_LD     = 7'b0000011,
            OP_I_TYPE_imm    = 7'b0010011,
            OP_I_TYPE_JALR   = 7'b1100111,
            OP_S_TYPE        = 7'b0100011,
            OP_B_TYPE        = 7'b1100011,
            OP_U_TYPE_AUIPC  = 7'b0010111,
            OP_U_TYPE_LUI    = 7'b0110111,
            OP_J_TYPE        = 7'b1101111,
            OP_F_TYPE_FLW    = 7'b0000111,
            OP_F_TYPE_FSW    = 7'b0100111,
            OP_F_TYPE_ALU    = 7'b1010011,
            OP_CSR           = 7'b1110011;
//==============================================================
//                       reg & wire 
//==============================================================
wire [6:0] opcode;

//==============================================================
//                       immediate
//==============================================================
assign opcode = inst[6:0];

always@(*) begin
    case(opcode)
        //I-TYPE
        OP_I_TYPE_LD, OP_I_TYPE_imm, OP_I_TYPE_JALR, OP_F_TYPE_FLW:begin
                         immediate = {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
        end
        //S-TYPE
        OP_S_TYPE, OP_F_TYPE_FSW:       
                         immediate = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
        //B-TYPE
        OP_B_TYPE:       immediate = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        //U-TYPE
        OP_U_TYPE_AUIPC, OP_U_TYPE_LUI:begin
                         immediate = {inst[31:12], 12'd0};
        end
        //J-TYPE
        OP_J_TYPE:       immediate = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
        default:         immediate = 'd0;
    endcase
end

endmodule