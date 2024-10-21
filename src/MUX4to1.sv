
module MUX4to1 #(parameter DATA_WIDTH = 32)
(
    //input 
    input [1:0] sel,
    input [DATA_WIDTH - 1:0] i0,
    input [DATA_WIDTH - 1:0] i1,
    input [DATA_WIDTH - 1:0] i2,
    input [DATA_WIDTH - 1:0] i3,
    //output
    output [DATA_WIDTH - 1:0] out
);

assign out = (sel==2'b00)? i0:
             (sel==2'b01)? i1:
             (sel==2'b10)? i2:
                           i3;


endmodule