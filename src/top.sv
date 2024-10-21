`include "CPU.sv"
`include "SRAM_wrapper.sv"


module top(
    input clk,
    input rst
);
//IM
wire [31:0] inst;
wire [31:0] inst_pc;
//DM
wire [31:0] data_load;
wire [31:0] data_store;
wire [31:0] data_addr;
wire [31:0] data_bweb;
wire        data_web;


CPU u_CPU(
    .clk(clk),
    .rst(rst),

    //IM
    .inst   (inst),
    .inst_pc(inst_pc),
    

    //DM
    .data_load (data_load),
    .data_store(data_store),
    .data_addr (data_addr),
    .data_bweb (data_bweb),
    .data_web  (data_web)

);

SRAM_wrapper IM1(
    .CLK (clk),
    .RST (rst),
    .CEB (1'b0),
    .WEB (1'b1),
    .BWEB(32'h00000000),
    .A   (inst_pc[15:2]),
    .DI  (32'h00000000),
    .DO  (inst)
);

SRAM_wrapper DM1 (
    .CLK (clk),
    .RST (rst),
    .CEB (1'b0),
    .WEB (data_web),
    .BWEB(data_bweb),
    .A   (data_addr[15:2]),
    .DI  (data_store),
    .DO  (data_load)
);

endmodule