`timescale 1ns/1ns

module Comp (left, right, gt, eq, lt);
parameter size = 8;
input [size-1:0] left, right;
output gt, eq, lt;

assign gt = left > right;
assign eq = left == right;
assign lt = left < right;
    
endmodule