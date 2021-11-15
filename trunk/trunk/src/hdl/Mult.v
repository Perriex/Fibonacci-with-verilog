`timescale 1ns/1ns

module Mult (left, right, res);
parameter size = 8;
input [size-1:0] left, right;
output [size-1:0] res;

wire [size* 2 - 1: 0] calcres;
assign calcres = left * right;
assign res = calcres[size-1:0];

endmodule