`timescale 1ns/1ns

module EnRegister (clk, pi, po, en, rst);
parameter size = 8;
input clk, en, rst;
input [size-1:0] pi;
output reg [size-1:0] po = 0;

always @(posedge clk) begin
    if (rst)
        po <= 0;
    else if (en)
        po <= pi;
end
    
endmodule