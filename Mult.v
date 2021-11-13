`timescale 1ns/1ns

module Mult (left, right, res);
parameter size = 8;
input [size-1:0] left, right;
output [size-1:0] res;

assign res = left * right;
    
endmodule