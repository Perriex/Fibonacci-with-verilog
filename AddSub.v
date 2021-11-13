`timescale 1ns/1ns

module AddSub (left, right, res, addsub);
parameter size = 8;
input addsub;
input [size-1:0] left, right;
output [size-1:0] res;

assign res = addsub ? left + right : left - right;
    
endmodule