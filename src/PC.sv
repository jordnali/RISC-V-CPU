module PC(
    //input port
    input        clk,
    input        rst,
    input        pc_en,
    input [31:0] pc_next,

    //output port
    // output reg [31:0] pc_next,
    output reg [31:0] pc
);

always@(posedge clk or posedge rst) begin
    if(rst) pc <= 32'h00000000;
    else begin
        if(pc_en)
            pc <= pc_next;
    end
end


endmodule