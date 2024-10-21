`include "PC.sv"
`include "PC_Ctrl.sv"
`include "Adder.sv"
`include "Hazard_detector.sv"
`include "Forwarding.sv"
`include "Controller.sv"
`include "RegFile.sv"
`include "FP_RegFile.sv"
`include "ImmGen.sv"
`include "CSR.sv"
`include "ALU.sv"
`include "FP_Adder.sv"
`include "Branch.sv"
`include "LSU.sv"
`include "MUX2to1.sv"
`include "MUX4to1.sv"


module CPU(
    input clk,
    input rst,

    //IM
    input [31:0] inst,
    output reg [31:0] inst_pc,

    //DM
    input      [31:0] data_load,
    output reg [31:0] data_store,
    output reg [31:0] data_addr,
    output reg [31:0] data_bweb,
    output            data_web
);

//==============================================================
//                       reg & wire 
//==============================================================
// //----------IF stage----------
wire [31:0] pc;
wire [31:0] pc_plus_4; 
reg [31:0] pc_next;
wire [1:0] pc_sel;
wire stall_PC_IF, stall_IF_ID, flush_IF_ID, flush_ID_EX;
wire flush_ID_EX_2;
// //----------IF/ID-------------
reg [31:0] ID_pc;
reg [31:0] ID_pc_plus_4;
// //----------ID stage----------
wire       ID_ALU_data1_sel;
wire       ID_ALU_data2_sel;
wire       ID_jal_en;
wire       ID_jalr_en;
wire       ID_regwrite;
wire       ID_fp_regwrite;
wire       ID_ex_result_sel;
wire       ID_mem_read;
wire       ID_mem_write;
wire       ID_mem_data_sel;
wire [1:0] ID_mem_rd_sel;
wire       ID_wb_rd_sel;
wire [3:0] ID_ALU_op;
wire       ID_FP_op;
wire ID_branch_type;
wire [2:0] ID_branch_op;
wire [2:0] ID_load_op;
wire [1:0] ID_store_op;
//forwarding
wire [1:0]  forwarding_EX_rs1  ;
wire [1:0]  forwarding_EX_rs2  ;
wire [1:0]  forwarding_EX_frs1 ;
wire [1:0]  forwarding_EX_frs2 ;
wire forwarding_ID_rs1 ;
wire forwarding_ID_rs2 ;
wire forwarding_ID_frs1;
wire forwarding_ID_frs2; 
wire [31:0] ID_rs1_data_result;
wire [31:0] ID_rs2_data_result;
wire [31:0] ID_frs1_data_result;
wire [31:0] ID_frs2_data_result;

//RegFile & FP_Reg_File
wire [31:0] ID_rs1_data, ID_rs2_data;
wire [31:0] ID_frs1_data, ID_frs2_data;
reg [ 4:0] ID_rd_addr       ;
reg [ 4:0] ID_frd_addr      ;
wire [4:0] ID_rs1_addr;
wire [4:0] ID_rs2_addr;
wire [4:0] ID_frs1_addr;
wire [4:0] ID_frs2_addr;
wire [31:0] ID_imm;
wire ID_branch_en;
wire [31:0] ID_csr_data;
reg [31:0] EX_csr_data;
// //----------ID/EXE------------
reg [31:0] EX_rs1_data      ;
reg [31:0] EX_rs2_data      ;
reg [31:0] EX_frs1_data     ;
reg [31:0] EX_frs2_data     ;
reg [31:0] EX_imm           ;
reg [ 4:0] EX_rd_addr       ;
reg [ 4:0] EX_frd_addr      ;
reg        EX_ALU_data1_sel ;
reg        EX_ALU_data2_sel ;
reg        EX_jal_en        ;
reg        EX_jalr_en       ;
reg        EX_regwrite      ;
reg        EX_fp_regwrite   ;
reg        EX_ex_result_sel ;
reg        EX_mem_read      ;
reg        EX_mem_write     ;
reg        EX_mem_data_sel  ;
reg [ 1:0] EX_mem_rd_sel    ;
reg        EX_wb_rd_sel     ;
reg [ 3:0] EX_ALU_op        ;
reg        EX_FP_op         ;
reg [ 3:0] EX_DM_op         ;
reg        EX_branch_en     ;
reg [31:0] EX_pc            ;
reg [31:0] EX_pc_plus_4     ;
reg [4:0] EX_rs1_addr ; 
reg [4:0] EX_rs2_addr ; 
reg [4:0] EX_frs1_addr; 
reg [4:0] EX_frs2_addr; 
reg       EX_branch_type;
reg [2:0] EX_branch_op;
reg [2:0] EX_load_op;
reg [1:0] EX_store_op;
// //----------EXE stage---------
wire [31:0] EX_ALU_data1;
wire [31:0] EX_ALU_data2;
wire [31:0] EX_ALU_result;
wire [31:0] EX_FP_result;
wire [31:0] EX_ALU_FP_result;
wire [31:0] EX_ALU_rs1_data;
wire [31:0] EX_ALU_rs2_data;
wire [31:0] EX_FP_frs1_data;
wire [31:0] EX_FP_frs2_data;
// //----------EXE/MEM-----------
reg [31:0] MEM_rs2_data      ;
reg [31:0] MEM_frs2_data     ;
reg [ 4:0] MEM_rd_addr       ;
reg [ 4:0] MEM_frd_addr      ;
// reg        MEM_jal_en        ;
// reg        MEM_jalr_en       ;
reg        MEM_regwrite      ;
reg        MEM_fp_regwrite   ;
reg        MEM_mem_read      ;
reg        MEM_mem_write     ;
reg        MEM_mem_data_sel  ;
reg [ 1:0] MEM_mem_rd_sel    ;
reg        MEM_wb_rd_sel     ;
reg [ 3:0] MEM_DM_op         ;
// reg        MEM_branch_en     ;
reg [31:0] MEM_pc_plus_4     ;
reg [31:0] MEM_ALU_FP_result ;
reg [31:0] MEM_csr_data      ;
reg [4:0] MEM_rs2_addr;
reg [4:0] MEM_frs2_addr;
reg [2:0] MEM_load_op ;
reg [1:0] MEM_store_op;
// //----------MEM stage---------
wire [31:0] MEM_store_data;
wire [31:0] WB_load_data;
wire [31:0] MEM_rd_result;
// //-----------MEM/WB-----------
reg [ 4:0] WB_rd_addr       ;
reg [ 4:0] WB_frd_addr      ;
reg        WB_jal_en        ;
reg        WB_jalr_en       ;
reg        WB_regwrite      ;
reg        WB_fp_regwrite   ;
reg        WB_wb_rd_sel     ;
reg        WB_branch_en     ;
reg [31:0] WB_rd_result     ;
reg        WB_mem_read;
reg [2:0]  WB_load_op;
// //----------WB stage-----------
wire [31:0] WB_data;
//==============================================================
//                         IF stage  
//==============================================================


PC_Ctrl u_PC_Ctrl(
    .branch_en(EX_branch_en),
    .jal_en(EX_jal_en),
    .jalr_en(EX_jalr_en),
    .pc_sel(pc_sel)
);

MUX4to1 u_MUX_PC(
    .sel(pc_sel),
    .i0 (pc_plus_4),
    .i1 (EX_ALU_result),
    .i2 ({EX_ALU_result[31:1], 1'b0}),
    .i3 ('d0),
    .out(pc_next)
);

PC u_PC(
    .clk(clk),
    .rst(rst),
    .pc_en(!stall_PC_IF),
    .pc_next(pc_next),
    .pc(pc)
);
assign inst_pc = stall_PC_IF? ID_pc:pc;

Adder u_PC_Adder_4(
    .data1(pc),
    .data2(32'd4),
    .result(pc_plus_4)
);

Hazard_detector u_Hazard_detector(
    .clk           (clk           ),
    .rst           (rst           ),
    .EX_mem_read   (EX_mem_read   ),
    .EX_regwrite   (EX_regwrite   ),
    .EX_fp_regwrite(EX_fp_regwrite),
    .EX_rd_addr    (EX_rd_addr    ),
    .EX_frd_addr   (EX_frd_addr    ),
    .ID_rs1_addr   (ID_rs1_addr   ),
    .ID_rs2_addr   (ID_rs2_addr   ),
    .ID_frs1_addr  (ID_frs1_addr  ),
    .ID_frs2_addr  (ID_frs2_addr  ),
    .branch_en     (EX_branch_en  ),
    .jalr_en       (EX_jalr_en    ),
    .jal           (EX_jal_en     ),

    .stall_PC_IF   (stall_PC_IF),
    .stall_IF_ID   (stall_IF_ID),
    .flush_IF_ID   (flush_IF_ID),
    .flush_ID_EX   (flush_ID_EX),
    .flush_ID_EX_2 (flush_ID_EX_2)
);
 
//==============================================================
//                         IF/ID  
//==============================================================

// reg in_valid;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        ID_pc        <= 0;
        ID_pc_plus_4 <= 0;
    end
    else begin
        if(!stall_IF_ID) begin
            ID_pc        <= pc;
            ID_pc_plus_4 <= pc_plus_4;
        end  
        else if(flush_IF_ID) begin
            ID_pc        <= 0;
            ID_pc_plus_4 <= 0;            
        end        
    end
end
reg in_valid;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        in_valid        <= 0;
    end
    else begin
        in_valid     <= 1;
    end
end

//==============================================================
//                         ID stage  
//==============================================================

//controller
Controller u_Controller(
    //input
    .in_valid(in_valid && !flush_IF_ID),
    .inst(inst),
    // .opcode(inst[6:0]),
    // .funct7(inst[31:25]),
    // .funct3(inst[14:12]),
    // .funct5(inst[31:27]),
    //output
    .ALU_data1_sel(ID_ALU_data1_sel),
    .ALU_data2_sel(ID_ALU_data2_sel),
    .jal_en       (ID_jal_en       ),
    .jalr_en      (ID_jalr_en      ),
    .regwrite     (ID_regwrite     ),
    .fp_regwrite  (ID_fp_regwrite  ),
    .ex_result_sel(ID_ex_result_sel),
    .mem_read     (ID_mem_read     ),
    .mem_write    (ID_mem_write    ),
    .mem_data_sel (ID_mem_data_sel ),
    .mem_rd_sel   (ID_mem_rd_sel   ),
    .wb_rd_sel    (ID_wb_rd_sel    ),
    .ALU_op       (ID_ALU_op       ),
    .FP_op        (ID_FP_op        ),
    // .DM_op        (ID_DM_op        ),
    .load_op      (ID_load_op      ),
    .store_op     (ID_store_op     ),
    .branch_type  (ID_branch_type  ),
    .branch_op    (ID_branch_op    ),
    .rs1          (ID_rs1_addr     ),
    .rs2          (ID_rs2_addr     ),
    .rd           (ID_rd_addr      ),
    .frs1         (ID_frs1_addr    ),
    .frs2         (ID_frs2_addr    ),
    .frd          (ID_frd_addr     )
);

RegFile u_RegFile(
    //input
    .clk     (clk),
    .rst     (rst),
    .rs1_addr(ID_rs1_addr),
    .rs2_addr(ID_rs2_addr),
    .rd_en   (WB_regwrite),
    .rd_addr (WB_rd_addr),
    .rd_data (WB_data),
    //output
    .rs1_data(ID_rs1_data),
    .rs2_data(ID_rs2_data)
);

FP_RegFile u_FP_RegFile(
    //input
    .clk      (clk),
    .rst      (rst),
    .frs1_addr(ID_frs1_addr),
    .frs2_addr(ID_frs2_addr),
    .frd_en   (WB_fp_regwrite),
    .frd_addr (WB_frd_addr),
    .frd_data (WB_data),
    //output
    .frs1_data(ID_frs1_data),
    .frs2_data(ID_frs2_data)
);

ImmGen u_ImmGen(
    .inst(inst),
    .immediate(ID_imm)
);


wire [31:0] csr_data;
CSR u_CSR(
    .clk   (clk),
    .rst   (rst),
    // .in_valid(in_valid),
    .stall(stall_PC_IF),
    .flush(flush_IF_ID),
    .csrop (inst[31:20]),
    .out_data(ID_csr_data)
);
 
Forwarding u_Forwarding(
    .MEM_regwrite    (MEM_regwrite   ),
    .MEM_fp_regwrite (MEM_fp_regwrite),
    .WB_regwrite     (WB_regwrite    ),
    .WB_fp_regwrite  (WB_fp_regwrite ),
    .MEM_rd_addr     (MEM_rd_addr    ),
    .WB_rd_addr      (WB_rd_addr     ),
    .MEM_frd_addr    (MEM_frd_addr   ),
    .WB_frd_addr     (WB_frd_addr    ),
    .EX_rs1_addr     (EX_rs1_addr    ),
    .EX_rs2_addr     (EX_rs2_addr    ),
    .EX_frs1_addr    (EX_frs1_addr   ),
    .EX_frs2_addr    (EX_frs2_addr   ),
    .ID_rs1_addr     (ID_rs1_addr    ),
    .ID_rs2_addr     (ID_rs2_addr    ),
    .ID_frs1_addr    (ID_frs1_addr   ),
    .ID_frs2_addr    (ID_frs2_addr   ),
    .WB_mem_read     (WB_mem_read    ),

 
    .forwarding_EX_rs1  (forwarding_EX_rs1  ), 
    .forwarding_EX_rs2  (forwarding_EX_rs2  ),
    .forwarding_EX_frs1 (forwarding_EX_frs1 ),
    .forwarding_EX_frs2 (forwarding_EX_frs2 ),
    .forwarding_ID_rs1  (forwarding_ID_rs1  ), 
    .forwarding_ID_rs2  (forwarding_ID_rs2  ),
    .forwarding_ID_frs1 (forwarding_ID_frs1 ),
    .forwarding_ID_frs2 (forwarding_ID_frs2 )

);


MUX2to1 u_MUX_ID_rs1(
    .sel(forwarding_ID_rs1),
    .i0 (ID_rs1_data),
    .i1 (WB_data),
    .out(ID_rs1_data_result)
);
MUX2to1 u_MUX_ID_rs2(
    .sel(forwarding_ID_rs2),
    .i0 (ID_rs2_data),
    .i1 (WB_data),
    .out(ID_rs2_data_result)
);
MUX2to1 u_MUX_ID_frs1(
    .sel(forwarding_ID_frs1),
    .i0 (ID_frs1_data),
    .i1 (WB_data),
    .out(ID_frs1_data_result)
);
MUX2to1 u_MUX_ID_frs2(
    .sel(forwarding_ID_frs2),
    .i0 (ID_frs2_data),
    .i1 (WB_data),
    .out(ID_frs2_data_result)
);
//==============================================================
//                         ID/EX  
//==============================================================

always@(posedge clk or posedge rst) begin
    if(rst) begin
        EX_rs1_data      <= 0;
        EX_rs2_data      <= 0;
        EX_frs1_data     <= 0;
        EX_frs2_data     <= 0;
        EX_rs1_addr      <= 0;
        EX_rs2_addr      <= 0;
        EX_frs1_addr     <= 0;
        EX_frs2_addr     <= 0;
        EX_imm           <= 0;
        EX_rd_addr       <= 0;
		EX_frd_addr      <= 0;
        EX_ALU_data1_sel <= 0;
        EX_ALU_data2_sel <= 0;
        EX_jal_en        <= 0;
        EX_jalr_en       <= 0;
        EX_regwrite      <= 0;
        EX_fp_regwrite   <= 0;
        EX_ex_result_sel <= 0;
        EX_mem_read      <= 0;
        EX_mem_write     <= 0;
        EX_mem_data_sel  <= 0;
        EX_mem_rd_sel    <= 0;
        EX_wb_rd_sel     <= 0;
        EX_ALU_op        <= 0;
        EX_FP_op         <= 0;
        // EX_DM_op         <= 0;
        EX_load_op       <= 0;
        EX_store_op      <= 0;
        // EX_branch_en     <= 0;
        EX_pc            <= 0;
        EX_pc_plus_4     <= 0;
        EX_csr_data      <= 0;
        EX_branch_type   <= 0;
        EX_branch_op     <= 0;
    end
    else begin 
        if(flush_ID_EX || flush_ID_EX_2) begin
            EX_rs1_data      <= 0;
            EX_rs2_data      <= 0;
            EX_frs1_data     <= 0;
            EX_frs2_data     <= 0;
            EX_rs1_addr      <= 0;
            EX_rs2_addr      <= 0;
            EX_frs1_addr     <= 0;
            EX_frs2_addr     <= 0;
            EX_imm           <= 0;
            EX_rd_addr       <= 0;
            EX_frd_addr      <= 0;
            EX_ALU_data1_sel <= 0;
            EX_ALU_data2_sel <= 0;
            EX_jal_en        <= 0;
            EX_jalr_en       <= 0;
            EX_regwrite      <= 0;
            EX_fp_regwrite   <= 0;
            EX_ex_result_sel <= 0;
            EX_mem_read      <= 0;
            EX_mem_write     <= 0;
            EX_mem_data_sel  <= 0;
            EX_mem_rd_sel    <= 0;
            EX_wb_rd_sel     <= 0;
            EX_ALU_op        <= 0;
            EX_FP_op         <= 0;
            EX_load_op       <= 0;
            EX_store_op      <= 0;
            // EX_DM_op         <= 0;
            // EX_branch_en     <= 0;
            EX_pc            <= 0;
            EX_pc_plus_4     <= 0;
            EX_csr_data      <= 0;
            EX_branch_type   <= 0;
            EX_branch_op     <= 0;
        end
        else begin
            EX_rs1_data      <= ID_rs1_data_result     ;
            EX_rs2_data      <= ID_rs2_data_result     ;
            EX_frs1_data     <= ID_frs1_data_result    ;
            EX_frs2_data     <= ID_frs2_data_result    ;
            EX_rs1_addr      <= ID_rs1_addr     ;
            EX_rs2_addr      <= ID_rs2_addr     ;
            EX_frs1_addr     <= ID_frs1_addr    ;
            EX_frs2_addr     <= ID_frs2_addr    ;
            EX_imm           <= ID_imm          ;
            EX_rd_addr       <= ID_rd_addr      ;
            EX_frd_addr      <= ID_frd_addr     ;
            EX_ALU_data1_sel <= ID_ALU_data1_sel;
            EX_ALU_data2_sel <= ID_ALU_data2_sel;
            EX_jal_en        <= ID_jal_en       ;
            EX_jalr_en       <= ID_jalr_en      ;
            EX_regwrite      <= ID_regwrite     ;
            EX_fp_regwrite   <= ID_fp_regwrite  ;
            EX_ex_result_sel <= ID_ex_result_sel;
            EX_mem_read      <= ID_mem_read     ;
            EX_mem_write     <= ID_mem_write    ;
            EX_mem_data_sel  <= ID_mem_data_sel ;
            EX_mem_rd_sel    <= ID_mem_rd_sel   ;
            EX_wb_rd_sel     <= ID_wb_rd_sel    ;
            EX_ALU_op        <= ID_ALU_op       ;
            EX_FP_op         <= ID_FP_op        ;
            // EX_DM_op         <= ID_DM_op        ;
            EX_load_op       <= ID_load_op       ;
            EX_store_op      <= ID_store_op      ;
            // EX_branch_en     <= ID_branch_en    ;
            EX_pc            <= ID_pc           ;
            EX_pc_plus_4     <= ID_pc_plus_4    ;
            EX_csr_data      <= ID_csr_data     ;
            EX_branch_type   <= ID_branch_type  ;
            EX_branch_op     <= ID_branch_op    ;
        end
    end
end




//==============================================================
//                         EX stage  
//==============================================================

//-------------ALU-----------------
MUX4to1 u_MUX_EX_rs1(
    .sel(forwarding_EX_rs1),
    .i0 (EX_rs1_data),
    .i1 (MEM_rd_result),
    .i2 (WB_data),
    .i3 ('d0),
    .out(EX_ALU_rs1_data)
);

MUX2to1 u_MUX_ALU_data1(
    .sel(EX_ALU_data1_sel),
    .i0 (EX_ALU_rs1_data),
    .i1 (EX_pc),
    .out(EX_ALU_data1)
);

MUX4to1 u_MUX_EX_rs2(
    .sel(forwarding_EX_rs2),
    .i0 (EX_rs2_data),
    .i1 (MEM_rd_result),
    .i2 (WB_data),
    .i3 ('d0),
    .out(EX_ALU_rs2_data)
);
MUX2to1 u_MUX_ALU_data2(
    .sel(EX_ALU_data2_sel),
    .i0 (EX_ALU_rs2_data),
    .i1 (EX_imm),
    .out(EX_ALU_data2)
);
ALU u_ALU(
    .data1   (EX_ALU_data1),
    .data2   (EX_ALU_data2),
    .ALU_op  (EX_ALU_op),
    .result  (EX_ALU_result)
);


//-------------FP_Adder-----------------

MUX4to1 u_MUX_EX_frs1(
    .sel(forwarding_EX_frs1),
    .i0 (EX_frs1_data),
    .i1 (MEM_rd_result),
    .i2 (WB_data),
    .i3 ('d0),
    .out(EX_FP_frs1_data)
);
MUX4to1 u_MUX_EX_frs2(
    .sel(forwarding_EX_frs2),
    .i0 (EX_frs2_data),
    .i1 (MEM_rd_result),
    .i2 (WB_data),
    .i3 ('d0),
    .out(EX_FP_frs2_data)
);


FP_Adder u_FP_Adder(
    .data1  (EX_FP_frs1_data),
    .data2  (EX_FP_frs2_data),
    .fpop   (EX_FP_op),
    .result (EX_FP_result)
);

//---------------------------------------
Branch u_Branch(
    .in_valid (EX_branch_type),
    .branch_op(EX_branch_op),
    .data1    (EX_ALU_rs1_data),
    .data2    (EX_ALU_rs2_data),
    .out_valid(EX_branch_en)
);


MUX2to1 u_MUX_EX_result(
    .sel(EX_ex_result_sel),
    .i0 (EX_ALU_result),
    .i1 (EX_FP_result),
    .out(EX_ALU_FP_result)
);

//==============================================================
//                         EXE/MEM  
//==============================================================
always@(posedge clk or posedge rst) begin
    if(rst) begin
        MEM_rs2_data      <= 0;
        MEM_frs2_data     <= 0;
        MEM_rs2_addr      <= 0;
        MEM_frs2_addr     <= 0;
        MEM_rd_addr       <= 0;
		MEM_frd_addr      <= 0;
        MEM_regwrite      <= 0;
        MEM_fp_regwrite   <= 0;
        MEM_mem_read      <= 0;
        MEM_mem_write     <= 0;
        MEM_mem_data_sel  <= 0;
        MEM_mem_rd_sel    <= 0;
        MEM_wb_rd_sel     <= 0;
        MEM_load_op       <= 0;
        MEM_store_op      <= 0;
        MEM_pc_plus_4     <= 0;
        MEM_ALU_FP_result <= 0;
        MEM_csr_data      <= 0;
    end
    else begin
        MEM_rs2_data      <= EX_ALU_rs2_data ;
        MEM_frs2_data     <= EX_FP_frs2_data ;
        MEM_rs2_addr      <= EX_rs2_addr     ;
        MEM_frs2_addr     <= EX_frs2_addr    ;
        MEM_rd_addr       <= EX_rd_addr      ;
		MEM_frd_addr      <= EX_frd_addr     ;
        MEM_regwrite      <= EX_regwrite     ;
        MEM_fp_regwrite   <= EX_fp_regwrite  ;
        MEM_mem_read      <= EX_mem_read     ;
        MEM_mem_write     <= EX_mem_write    ;
        MEM_mem_data_sel  <= EX_mem_data_sel ;
        MEM_mem_rd_sel    <= EX_mem_rd_sel   ;
        MEM_wb_rd_sel     <= EX_wb_rd_sel    ;
        MEM_load_op       <= EX_load_op     ;
        MEM_store_op      <= EX_store_op    ;
        MEM_pc_plus_4     <= EX_pc_plus_4    ;
        MEM_ALU_FP_result <= EX_ALU_FP_result;
        MEM_csr_data      <= EX_csr_data     ;
    end
end

//==============================================================
//                         MEM  
//==============================================================
MUX2to1 u_MUX_MEM_data(
    .sel(MEM_mem_data_sel),
    .i0 (MEM_rs2_data),
    .i1 (MEM_frs2_data),
    .out(MEM_store_data)
);

LSU u_LSU(
    .mem_read         (MEM_mem_read),
    .mem_write        (MEM_mem_write),
    // .DM_op            (MEM_DM_op),
    .store_op         (MEM_store_op),
    .load_op          (WB_load_op),
    .in_addr          (MEM_ALU_FP_result),
    .in_store_data    (MEM_store_data),
    .in_load_data     (data_load),

    .out_web          (data_web),
    .out_bweb         (data_bweb),
    .out_addr         (data_addr),
    .out_store_data   (data_store),
    .out_load_data    (WB_load_data)
); 

MUX4to1 u_MUX_MEM_rd(
    .sel(MEM_mem_rd_sel),
    .i0 (MEM_ALU_FP_result),
    .i1 (MEM_pc_plus_4),
    .i2 (MEM_csr_data),
    .i3 ('d0),
    .out(MEM_rd_result)
);

//==============================================================
//                         MEM/WB 
//==============================================================

always@(posedge clk or posedge rst) begin
    if(rst) begin
        WB_rd_addr       <= 0;
		WB_frd_addr      <= 0;
        WB_regwrite      <= 0;
        WB_fp_regwrite   <= 0;
        WB_wb_rd_sel     <= 0;
        WB_rd_result     <= 0;
        WB_mem_read      <= 0;
        WB_load_op       <= 0;
    end
    else begin
        WB_rd_addr       <= MEM_rd_addr		 ;
		WB_frd_addr      <= MEM_frd_addr     ;
        WB_regwrite      <= MEM_regwrite     ;
        WB_fp_regwrite   <= MEM_fp_regwrite  ;
        WB_wb_rd_sel     <= MEM_wb_rd_sel    ;
        WB_rd_result     <= MEM_rd_result    ;
        WB_mem_read      <= MEM_mem_read     ;
        WB_load_op       <= MEM_load_op      ;
    end
end


//==============================================================
//                           WB 
//==============================================================


MUX2to1 u_MUX_WB_rd(
    .sel(WB_wb_rd_sel),
    .i0 (WB_rd_result),
    .i1 (WB_load_data),
    .out(WB_data)
);


endmodule