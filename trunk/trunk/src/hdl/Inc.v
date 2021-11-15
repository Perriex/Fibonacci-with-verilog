`timescale 1ns/1ns

module Inc(in, res);
parameter size = 8;

input [size-1:0] in;
output [size-1:0] res;

assign res = in + 1'b1;
    
endmodule