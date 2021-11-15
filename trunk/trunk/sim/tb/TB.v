`timescale 1ns/1ns

module TB ();

 parameter wordsize = 32;
 reg clk = 1'b0 , rst = 1'b0;
 wire [wordsize-1: 0] result;
 wire ready;
 always #5 clk = ~clk;

 Fib #(wordsize) uut(clk, rst, ready, result);

 reg[7:0] n = 8'b1000;

 initial begin
   rst = 1; #20;
   n = 8'b100; // 11
   uut.datapath.nreg.po = n;
   uut.datapath.N = n;
   rst = 0;
   #4400;

   rst = 1; #20;
   n = 8'b101; // 53
   uut.datapath.nreg.po = n;
   uut.datapath.N = n;
   rst = 0;
   #3900;

   rst = 1; #20;
   n = 8'b110; // 309
   uut.datapath.nreg.po = n;
   uut.datapath.N = n;
   rst = 0;
   #6500;

   rst = 1; #20;
   n = 8'b1001; //125361 
   uut.datapath.nreg.po = n;
   uut.datapath.N = n;
   rst = 0;
   #28000 $stop;
 end
    
endmodule

// reg[3:0] testcount = 5;
//  always @(posedge ready) begin
//     if (testcount <= 0)
//       $stop;

//     testcount = testcount - 1;
//     rst = 1;
//     # 20;
//     n = $random%15;
//     uut.datapath.nreg.po = n;
//     uut.datapath.N = n;

//     rst = 0;
//  end