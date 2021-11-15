`timescale 1ns/1ns

module TB ();

 reg clk = 1'b0;
 always #5 clk = ~clk;

 Fib fib(clk);


 reg[7:0] n = 8'b101;

 initial begin
    fib.datapath.nreg.po = n;
    fib.datapath.N = n;
 end
    
endmodule