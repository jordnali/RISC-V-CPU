module Controller(
    input       in_valid,
    // input [ 6:0] opcode,
    // input [ 6:0] funct7,
    // input [ 2:0] funct3,
    // input [ 4:0] funct5,
    input    [31:0] inst,

    output reg       ALU_data1_sel,
    output reg       ALU_data2_sel,
    output reg       jal_en,
    output reg       jalr_en,
    output reg       regwrite,
    output reg       fp_regwrite,
    output reg       ex_result_sel,
    output reg       mem_read,
    output reg       mem_write,
    output reg       mem_data_sel,
    output reg [1:0] mem_rd_sel,
    output reg       wb_rd_sel,
    output reg [3:0] ALU_op,
    output reg       FP_op,
    // output reg [3:0] DM_op,
    output reg [2:0] load_op,
    output reg [1:0] store_op,
    output reg       branch_type,
    output reg [2:0] branch_op,
    output  [4:0] rs1 ,
    output  [4:0] rs2 ,
    output  [4:0] rd  ,
    output  [4:0] frs1,
    output  [4:0] frs2,
    output  [4:0] frd 
    // output reg       FP_rs1_type,
    // output reg       FP_rs1_type

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

//Load
parameter LW  = 3'd0,
          LB  = 3'd1,
          LH  = 3'd2,
          LBU = 3'd3,
          LHU = 3'd4,
          FLW = 3'd5;
//S-type
parameter SW  = 2'd0,
          SB  = 2'd1,
          SH  = 2'd2,
//F-type          
          FSW = 2'd3;

//branch
parameter BEQ  = 3'd0,
          BNE  = 3'd1,
          BLT  = 3'd2,
          BGE  = 3'd3,
          BLTU = 3'd4,
          BGEU = 3'd5;
//==============================================================
//                   Instruction format
//==============================================================
wire [ 6:0] opcode;
wire [ 6:0] funct7;
wire [ 2:0] funct3;
wire [ 4:0] funct5;
assign opcode  = inst[6:0];    
assign funct7  = inst[31:25];
assign funct3  = inst[14:12];
assign funct5  = inst[31:27];
assign rs1     = in_valid? ((opcode==OP_F_TYPE_ALU)? 5'b00000:inst[19:15]) :5'b00000;
assign rs2     = in_valid? ((opcode==OP_F_TYPE_ALU || opcode==OP_F_TYPE_FSW)? 5'b00000:inst[24:20]):5'b00000;
assign rd      = in_valid? ((opcode==OP_F_TYPE_ALU || opcode==OP_F_TYPE_FLW)? 5'b00000:inst[11:7]):5'b00000;
assign frs1    = in_valid? ((opcode==OP_F_TYPE_ALU)? inst[19:15]:5'b00000):5'b00000;
assign frs2    = in_valid? ((opcode==OP_F_TYPE_ALU || opcode==OP_F_TYPE_FSW)? inst[24:20]:5'b00000):5'b00000;
assign frd     = in_valid? ((opcode==OP_F_TYPE_ALU || opcode==OP_F_TYPE_FLW)? inst[11:7]:5'b00000):5'b00000;




//==============================================================
//                      ALU_data1_sel
//==============================================================
//0:rs1, 1:pc
always @(*) begin
    if(in_valid) begin
        case (opcode)
            // OP_R_TYPE      :    ALU_data1_sel = 0; 
            // OP_I_TYPE_LD   :    ALU_data1_sel = 0; 
            // OP_I_TYPE_imm  :    ALU_data1_sel = 0; 
            // OP_I_TYPE_JALR :    ALU_data1_sel = 0; 
            // OP_S_TYPE      :    ALU_data1_sel = 0; 
            OP_B_TYPE      :    ALU_data1_sel = 1; 
            OP_U_TYPE_AUIPC:    ALU_data1_sel = 1; 
            // OP_U_TYPE_LUI  :    ALU_data1_sel = 0; 
            OP_J_TYPE      :    ALU_data1_sel = 1; 
            // OP_F_TYPE_FLW  :    ALU_data1_sel = 0; 
            // OP_F_TYPE_FSW  :    ALU_data1_sel = 0; 
            // OP_F_TYPE_ALU  :    ALU_data1_sel = 0; 
            // OP_CSR         :    ALU_data1_sel = 0; 
            default        :    ALU_data1_sel = 0;
        endcase
    end
    else ALU_data1_sel = 0;
end
//==============================================================
//                      ALU_data2_sel
//==============================================================
//0:rs2, 1:imm
always @(*) begin
    if(in_valid) begin
        case (opcode)
            // OP_R_TYPE      :    ALU_data2_sel = 0; 
            OP_I_TYPE_LD   :    ALU_data2_sel = 1; 
            OP_I_TYPE_imm  :    ALU_data2_sel = 1; 
            OP_I_TYPE_JALR :    ALU_data2_sel = 1; 
            OP_S_TYPE      :    ALU_data2_sel = 1; 
            OP_B_TYPE      :    ALU_data2_sel = 1; 
            OP_U_TYPE_AUIPC:    ALU_data2_sel = 1; 
            OP_U_TYPE_LUI  :    ALU_data2_sel = 1; 
            OP_J_TYPE      :    ALU_data2_sel = 1; 
            OP_F_TYPE_FLW  :    ALU_data2_sel = 1; 
            OP_F_TYPE_FSW  :    ALU_data2_sel = 1; 
            // OP_F_TYPE_ALU  :    ALU_data2_sel = 0; 
            // OP_CSR         :    ALU_data2_sel = 0; 
            default        :    ALU_data2_sel = 0;
        endcase
    end
    else ALU_data2_sel = 0; 
end
//==============================================================
//                       jal_en
//==============================================================
always@(*) begin
    if(in_valid) jal_en = (opcode==OP_J_TYPE)? 1:0;
    else         jal_en = 0;
end


// assign jal_en = (opcode==OP_J_TYPE)? 1:0;
//==============================================================
//                       jalr_en
//==============================================================
always@(*) begin
    if(in_valid) jalr_en = (opcode==OP_I_TYPE_JALR)? 1:0;
    else         jalr_en = 0;
end
// assign jalr_en = (opcode==OP_I_TYPE_JALR)? 1:0;
//==============================================================
//                       regwrite
//==============================================================

always @(*) begin
    if(in_valid) begin
        case (opcode)
            OP_R_TYPE      :    regwrite = 1; 
            OP_I_TYPE_LD   :    regwrite = 1; 
            OP_I_TYPE_imm  :    regwrite = 1; 
            OP_I_TYPE_JALR :    regwrite = 1; 
            // OP_S_TYPE      :    regwrite = 0; 
            // OP_B_TYPE      :    regwrite = 0; 
            OP_U_TYPE_AUIPC:    regwrite = 1; 
            OP_U_TYPE_LUI  :    regwrite = 1; 
            OP_J_TYPE      :    regwrite = 1; 
            // OP_F_TYPE_FLW  :    regwrite = 0; 
            // OP_F_TYPE_FSW  :    regwrite = 0; 
            // OP_F_TYPE_ALU  :    regwrite = 0; 
            OP_CSR         :    regwrite = 1; 
            default        :    regwrite = 0;
        endcase
    end
    else regwrite = 0;
end

//==============================================================
//                    fp_regwrite
//==============================================================

always @(*) begin
    if(in_valid) begin
        case (opcode)
            // OP_R_TYPE      :    fp_regwrite = 0; 
            // OP_I_TYPE_LD   :    fp_regwrite = 0; 
            // OP_I_TYPE_imm  :    fp_regwrite = 0; 
            // OP_I_TYPE_JALR :    fp_regwrite = 0; 
            // OP_S_TYPE      :    fp_regwrite = 0; 
            // OP_B_TYPE      :    fp_regwrite = 0; 
            // OP_U_TYPE_AUIPC:    fp_regwrite = 0; 
            // OP_U_TYPE_LUI  :    fp_regwrite = 0; 
            // OP_J_TYPE      :    fp_regwrite = 0; 
            OP_F_TYPE_FLW  :    fp_regwrite = 1; 
            // OP_F_TYPE_FSW  :    fp_regwrite = 0; 
            OP_F_TYPE_ALU  :    fp_regwrite = 1; 
            // OP_CSR         :    fp_regwrite = 0; 
            default        :    fp_regwrite = 0;
        endcase
    end
    else fp_regwrite = 0;
end
//==============================================================
//                    ex_result_sel
//==============================================================

//0:ALU, 1:FP_Adder
always@(*) begin
    if(in_valid) ex_result_sel = (opcode==OP_F_TYPE_ALU)? 1:0;
    else         ex_result_sel = 0;
end
// assign ex_result_sel = (opcode==OP_F_TYPE_ALU)? 1:0;
//==============================================================
//                       mem_read
//==============================================================
always@(*) begin
    if(in_valid) mem_read = (opcode==OP_I_TYPE_LD || opcode==OP_F_TYPE_FLW)? 1:0;
    else         mem_read = 0;
end
// assign mem_read = (opcode==OP_I_TYPE_LD || opcode==OP_F_TYPE_FLW)? 1:0;

//==============================================================
//                       mem_write
//==============================================================
always@(*) begin
    if(in_valid) mem_write = (opcode==OP_S_TYPE || opcode==OP_F_TYPE_FSW)? 1:0;
    else         mem_write = 0;
end
// assign mem_write = (opcode==OP_S_TYPE || opcode==OP_F_TYPE_FSW)? 1:0;

//==============================================================
//                       mem_data_sel
//==============================================================
//0:rs2, 1:frs2
always@(*) begin
    if(in_valid) mem_data_sel = (opcode==OP_F_TYPE_FSW)? 1:0;
    else         mem_data_sel = 0;
end
// assign mem_data_sel = (opcode==OP_F_TYPE_FSW)? 1:0;
//==============================================================
//                        mem_rd_sel
//==============================================================

//0:ALU or FP_Adder, 1:pc+4, 2:csr
always@(*) begin
    if(in_valid) begin
        case (opcode)
            // OP_R_TYPE      :    mem_rd_sel = 'd0; 
            // OP_I_TYPE_LD   :    mem_rd_sel = 'd0; 
            // OP_I_TYPE_imm  :    mem_rd_sel = 'd0; 
            OP_I_TYPE_JALR :    mem_rd_sel = 'd1; 
            // OP_S_TYPE      :    mem_rd_sel = 'd0; 
            // OP_B_TYPE      :    mem_rd_sel = 'd0; 
            // OP_U_TYPE_AUIPC:    mem_rd_sel = 'd0; 
            // OP_U_TYPE_LUI  :    mem_rd_sel = 'd0; 
            OP_J_TYPE      :    mem_rd_sel = 'd1; 
            // OP_F_TYPE_FLW  :    mem_rd_sel = 'd0; 
            // OP_F_TYPE_FSW  :    mem_rd_sel = 'd0; 
            // OP_F_TYPE_ALU  :    mem_rd_sel = 'd0; 
            OP_CSR         :    mem_rd_sel = 'd2; 
            default        :    mem_rd_sel = 'd0;
        endcase
    end
    else mem_rd_sel = 'd0;
end
//==============================================================
//                        wb_rd_sel
//==============================================================
//0:load 1:other
always@(*) begin
    if(in_valid) wb_rd_sel = (opcode==OP_I_TYPE_LD || opcode==OP_F_TYPE_FLW)? 1:0;
    else         wb_rd_sel = 0;
end
// assign wb_rd_sel = (opcode==OP_I_TYPE_LD || opcode==OP_F_TYPE_FLW)? 1:0;

//==============================================================
//                        ALU_op
//==============================================================
always@(*) begin
    if(in_valid) begin
        case(opcode)
            OP_R_TYPE       : begin
                case(funct3)
                    3'b000: begin
                        if(funct7[0])      ALU_op = ALU_MUL;
                        else if(funct7[5]) ALU_op = ALU_SUB;
                        else               ALU_op = ALU_ADD;
                    end
                    3'b001: begin
                        if(funct7[0]) ALU_op = ALU_MULH;
                        else          ALU_op = ALU_SLL;
                    end
                    3'b010: begin
                        if(funct7[0]) ALU_op = ALU_MULHSU;
                        else          ALU_op = ALU_SLT;
                    end
                    3'b011: begin
                        if(funct7[0]) ALU_op = ALU_MULHU;
                        else          ALU_op = ALU_SLTU;
                    end
                    3'b100: ALU_op = ALU_XOR;
                    3'b101: ALU_op = funct7[5]? ALU_SRA:ALU_SRL;
                    3'b110: ALU_op = ALU_OR;
                    3'b111: ALU_op = ALU_AND;
                endcase
            end
            OP_I_TYPE_LD    : ALU_op = ALU_ADD;
            OP_I_TYPE_imm   : begin
                case(funct3)
                    3'b000: ALU_op = ALU_ADD;
                    3'b001: ALU_op = ALU_SLL;
                    3'b010: ALU_op = ALU_SLT;
                    3'b011: ALU_op = ALU_SLTU;
                    3'b100: ALU_op = ALU_XOR;
                    3'b101: ALU_op = funct7[5]? ALU_SRA:ALU_SRL;
                    3'b110: ALU_op = ALU_OR;
                    3'b111: ALU_op = ALU_AND;
                endcase
            end
            OP_I_TYPE_JALR  : ALU_op = ALU_ADD;
            OP_S_TYPE       : ALU_op = ALU_ADD;
            OP_B_TYPE       : ALU_op = ALU_ADD;
            OP_U_TYPE_AUIPC : ALU_op = ALU_ADD;
            OP_U_TYPE_LUI   : ALU_op = ALU_LUI;
            OP_J_TYPE       : ALU_op = ALU_ADD;
            OP_F_TYPE_FLW   : ALU_op = ALU_ADD;
            OP_F_TYPE_FSW   : ALU_op = ALU_ADD;
            // OP_F_TYPE_ALU   : ALU_op = 1'b0;
            // OP_CSR          : ALU_op = ALU_ADD;
            default         : ALU_op = ALU_ADD;
        endcase
    end
    else ALU_op = ALU_ADD;
end
//==============================================================
//                        FP_op
//==============================================================
//0:FADD 1:FSUB
always@(*) begin
    if(in_valid) begin
        case (opcode)
            // OP_R_TYPE      :    FP_op = 'd0; 
            // OP_I_TYPE_LD   :    FP_op = 'd0; 
            // OP_I_TYPE_imm  :    FP_op = 'd0; 
            // OP_I_TYPE_JALR :    FP_op = 'd0; 
            // OP_S_TYPE      :    FP_op = 'd0; 
            // OP_B_TYPE      :    FP_op = 'd0; 
            // OP_U_TYPE_AUIPC:    FP_op = 'd0; 
            // OP_U_TYPE_LUI  :    FP_op = 'd0; 
            // OP_J_TYPE      :    FP_op = 'd0; 
            // OP_F_TYPE_FLW  :    FP_op = 'd0; 
            // OP_F_TYPE_FSW  :    FP_op = 'd0; 
            OP_F_TYPE_ALU  : begin
                if(funct5==5'b00000) FP_op = 'd0;
                else                 FP_op = 'd1;
            end 
            // OP_CSR         :    FP_op = 'd0; 
            default        :    FP_op = 'd0;
        endcase
    end
    else FP_op = 'd0;
end

//==============================================================
//                        DM_op
//==============================================================

always@(*) begin
    if(in_valid) begin
        case (opcode)
            OP_I_TYPE_LD   : begin
                    case(funct3)
                    3'b010:   load_op = LW;
                    3'b000:   load_op = LB;
                    3'b001:   load_op = LH;
                    3'b100:   load_op = LBU;
                    3'b101:   load_op = LHU;
                    default:  load_op = 'd0;
                endcase
            end
            OP_F_TYPE_FLW  :  load_op = FLW; 
            default        :  load_op = 'd0;
        endcase
    end
    else load_op = 'd0;
end
always@(*) begin
    if(in_valid) begin
        case (opcode)
            OP_S_TYPE      : begin
                case(funct3)
                    3'b010:     store_op = SW;
                    3'b000:     store_op = SB;
                    3'b001:     store_op = SH;
                    default  :  store_op = 'd0;
                endcase
            end
            OP_F_TYPE_FSW  :    store_op = FSW; 
            default        :    store_op = 'd0;
        endcase
    end
    else store_op = 'd0;
end
//==============================================================
//                        branch_op
//==============================================================

always@(*) begin
    if(in_valid) branch_type = (opcode==OP_B_TYPE)? 1:0;
    else         branch_type = 0;
end
always@(*) begin
    if(in_valid || opcode==OP_B_TYPE) begin
        case(funct3)
            3'b000: branch_op = BEQ;
            3'b001: branch_op = BNE;
            3'b100: branch_op = BLT;
            3'b101: branch_op = BGE;
            3'b110:branch_op = BLTU;
            3'b111:branch_op = BGEU;
            default: branch_op = 3'b111;
        endcase
    end
    else 
        branch_op = 3'b111;
end

endmodule