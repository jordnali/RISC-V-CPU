
module MUX2to1 #(parameter DATA_WIDTH = 32)
(
    //input port
    input sel,
    input [DATA_WIDTH - 1:0] i0,
    input [DATA_WIDTH - 1:0] i1,
    //output port
    output [DATA_WIDTH - 1:0] out
);

assign out = sel? i1:i0;


endmodule