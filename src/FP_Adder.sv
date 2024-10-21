
module FP_Adder(
    //input port 
    input fpop,
    input [31:0] data1,
    input [31:0] data2,

    //output port
    output [31:0] result
);

//==============================================================
//                     parameter & integer
//==============================================================
// parameter FADD = 0;
// parameter FSUB = 1;

//==============================================================
//                     reg & wire
//==============================================================
//
wire [31:0] datam;
//swap 
wire s1, s2;
wire [7:0] e1, e2;
wire [22:0] f1, f2;
//add the hidden bit
wire [27:0] f1_extension;
wire [27:0] f2_extension;
//use the exponent bits difference to align the fraction bits
wire [7:0] e_difference; 
wire [27:0] f2_shift;
//if the number is negative, take the complement
wire [27:0] f1_com, f2_com;
//calculation the result
wire [27:0] f_out_cal;
wire [27:0] f_out_com;
//Normalized
wire s_out;
wire [7:0] e_out;
wire [22:0] f_out;
//-----------------------
wire [4:0] f_out_shift;

//==============================================================
//                        Design
//==============================================================
//

assign datam = {fpop^data2[31], data2[30:0]};

//swap 
assign {s1, e1, f1} = (data1[30:23] > data2[30:23])? data1:datam;
assign {s2, e2, f2} = (data1[30:23] > data2[30:23])? datam:data1;

//add the hidden bit(LSB多一位)
assign f1_extension = {3'b001, f1, 2'b01};
assign f2_extension = {3'b001, f2, 2'b01};

//use the exponent bits difference to align the fraction bits
assign e_difference = e1 - e2;
assign f2_shift = f2_extension >> e_difference;

//if the number is negative, take the complement
assign f1_com = s1? ~f1_extension + 1:f1_extension;
assign f2_com = s2? ~f2_shift + 1:f2_shift;


//calculation the result
assign f_out_cal = f1_com + f2_com;
assign f_out_com = f_out_cal[27]? ~f_out_cal + 1:f_out_cal;


//Normalized
assign s_out = f_out_cal[27];
assign e_out = f_out_com[26]? e1 + 1:e1 - (25 - f_out_shift);
assign f_out = f_out_com[26]? f_out_com[25:3]:f_out_com[24:2] << (25 - f_out_shift);

//output
assign result = {s_out, e_out, f_out};



//-------------------------------------
assign f_out_shift = f_out_com[25]? 25:
                     f_out_com[24]? 24:
                     f_out_com[23]? 23:
                     f_out_com[22]? 22:
                     f_out_com[21]? 21:
                     f_out_com[20]? 20:
                     f_out_com[19]? 19:
                     f_out_com[18]? 18:
                     f_out_com[17]? 17:
                     f_out_com[16]? 16:
                     f_out_com[15]? 15:
                     f_out_com[14]? 14:
                     f_out_com[13]? 13:
                     f_out_com[12]? 12:
                     f_out_com[11]? 11:
                     f_out_com[10]? 10:
                     f_out_com[9]?   9:
                     f_out_com[8]?   8:
                     f_out_com[7]?   7:
                     f_out_com[6]?   6:
                     f_out_com[5]?   5:
                     f_out_com[4]?   4:
                     f_out_com[3]?   3:
                     f_out_com[2]?   2:
                     f_out_com[1]?   1:
                                     0;


endmodule

                     