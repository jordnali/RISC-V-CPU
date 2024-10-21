module LSU(
    input mem_read,
    input mem_write,
    // input [3:0] DM_op,
    input [2:0] load_op,
    input [1:0] store_op,
    input [31:0] in_addr,
    input [31:0] in_store_data,
    input [31:0] in_load_data,

    output            out_web,
    output reg [31:0] out_bweb,
    output     [31:0] out_addr,
    output reg [31:0] out_store_data,
    output reg [31:0] out_load_data
);
//==============================================================
//                   parameter & integer
//==============================================================
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
//==============================================================
//                         out_web
//==============================================================
assign out_web = mem_write? 0:1;
//==============================================================
//                         out_addr
//==============================================================
assign out_addr = (mem_write || mem_read)? in_addr:'d0;
//==============================================================
//                         out_bweb
//==============================================================
always@(*) begin
    case(store_op)
        SW, FSW:        out_bweb = 32'h00000000;
        SB: begin
            case(in_addr[1:0])
                2'b00:  out_bweb = 32'hFFFFFF00;
                2'b01:  out_bweb = 32'hFFFF00FF;
                2'b10:  out_bweb = 32'hFF00FFFF;
                2'b11:  out_bweb = 32'h00FFFFFF;
            endcase
        end
        SH: begin
            case(in_addr[1:0])
                2'b00:  out_bweb = 32'hFFFF0000;  
                2'b01:  out_bweb = 32'hFFFF0000;
                2'b10:  out_bweb = 32'h0000FFFF;
                2'b11:  out_bweb = 32'h0000FFFF;
            endcase
        end 
        default:        out_bweb = 32'hFFFFFFFF;
    endcase
end


//==============================================================
//                         out_bweb
//==============================================================
always@(*) begin
    case(store_op)
        SW, FSW:        out_store_data = in_store_data;
        SB: begin
            case(in_addr[1:0])
                2'b00:  out_store_data = {24'd0, in_store_data[7:0]};
                2'b01:  out_store_data = {16'd0, in_store_data[7:0], 8'd0};
                2'b10:  out_store_data = {8'd0, in_store_data[7:0], 16'd0};
                2'b11:  out_store_data = {in_store_data[7:0], 24'd0};
            endcase
        end
        SH: begin
            case(in_addr[1:0])
                2'b00:  out_store_data = {16'd0, in_store_data[15:0]};  
                2'b01:  out_store_data = {16'd0, in_store_data[15:0]};
                2'b10:  out_store_data = {in_store_data[15:0], 16'd0};
                2'b11:  out_store_data = {in_store_data[15:0], 16'd0};
            endcase
        end 
        default:        out_store_data = 'd0;
    endcase
end

//==============================================================
//                        Load
//==============================================================
always@(*) begin
    case(load_op)
        LW, FLW:  out_load_data = in_load_data;
        LB:       out_load_data = {{24{in_load_data[7]}}, in_load_data[7:0]};
        LH:       out_load_data = {{16{in_load_data[15]}}, in_load_data[15:0]};
        LBU:      out_load_data = {24'd0, in_load_data[7:0]};
        LHU:      out_load_data = {16'd0, in_load_data[15:0]};
        default:  out_load_data = 32'd0;
    endcase
end


endmodule