`timescale 1ns/1ns

module Datapath(clk         //system clock
    , push, pop             // stack controls
    , addsub                // alu control
    , ress, resld, resrst   // result register control for storage controller
    , rets, retld, retrst   // return value register controllers for main controller
    , ns, nld, nrst         // argument n register control for storage controller
    , fs, fld, frst         // flag register control for storage controller
    , addrs, addls          // alu left and right op selectors
    , lt, gt, eq            // n < N / 2 Results
    , f, n                  // flag and argument n values 
    , ss, ready             // stack input selector for push
    , result
    );                      

parameter wordsize = 8;
input clk, push, pop, addsub
    , ress, resld, resrst
    , retld, retrst
    , ns, nld, nrst
    , fs, fld, frst
    ;

input [1:0] rets, addrs, addls, ss;

output lt, gt, eq, ready;
output [wordsize-1:0] n, f, result;

reg [wordsize-1:0] zero = {wordsize{1'b0}};
reg [wordsize-1:0] one = {{(wordsize-1){1'b0}}, 1'b1};
reg [wordsize-1:0] two = {{(wordsize-2){1'b0}}, 2'b10};

reg [wordsize-1:0] N;

wire [wordsize-1:0] din, dout, addr, multr;
wire [wordsize-1:0] nin, nout;
/*
    0 : adder result
    1 : stack data
*/
Mux #(wordsize) nmux(.s(ns)
    , .a(addr)
    , .b(dout)
    , .c(nin)
    );
EnRegister #(wordsize) nreg(.clk(clk)
    , .pi(nin)
    , .po(nout)
    , .en(nld)
    , .rst(nrst)
    );
assign n = nout;

wire [wordsize-1:0] fin, fout, fincres;

Inc #(wordsize) finc(fout, fincres);
Mux #(wordsize) fmux(.s(fs)
    , .a(fincres) // 0 : flag + 1
    , .b(dout) // 1 : stack data
    , .c(fin)
    );
EnRegister #(wordsize) freg(.clk(clk)
    , .pi(fin)
    , .po(fout)
    , .en(fld)
    , .rst(frst)
    );
assign f = fout;

wire [wordsize-1:0] resin, resout;
Mux #(wordsize) resmux(.s(ress) // need to add from mult *
    , .a(addr) // 0 : adder result
    , .b(dout) // 1 : stack data
    , .c(resin)
    );
EnRegister #(wordsize) resreg(.clk(clk)
    , .pi(resin)
    , .po(resout)
    , .en(resld)
    , .rst(resrst)
    );

wire [wordsize-1:0] retin, retout;
Mux4to1 #(wordsize) retmux(.s(rets)
    , .in0(one)  // 0 : 1
    , .in1(addr)  // 1 : adder result
    , .in2(multr) // 2 : mult result // it is exta *
    , .in3(resout)  // 3 : result
    , .c(retin)
    );
EnRegister #(wordsize) retreg(.clk(clk)
    , .pi(retin)
    , .po(retout)
    , .en(retld)
    , .rst(retrst)
    );
assign result = retout;

Mux4to1 #(wordsize) smux(.s(ss)
    , .in0(fout)   // 0 : flag
    , .in1(nout)   // 1 : argument n
    , .in2(resout) // 2 : result
    , .in3(zero)   // 3 : none(0)
    , .c(din)
    );
Stack #(wordsize) stack(
    .clk(clk),
    .din(din), 
    .dout(dout), 
    .push(push), 
    .pop(pop),
    .empty(ready)
);


wire [wordsize-1:0] addlop, addrop;
Mux4to1 #(wordsize) addlmux(.s(addls)
    , .in0(zero)   // 0 : none(0)
    , .in1(nout)   // 1 : argument n
    , .in2(resout) // 2 : result
    , .in3(zero)   // 3 : none (0)
    , .c(addlop)
    );
Mux4to1 #(wordsize) addrmux(.s(addrs) // change from addls to addrs *
    , .in0(fout)   // 0 : flag
    , .in1(retout) // 1 : return value
    , .in2(one)   // 2 : 1
    , .in3(two)  // 3 : 2
    , .c(addrop)
    );
AddSub #(wordsize) alu(.left(addlop) // can get from res and ret and push in ret *
    , .right(addrop)
    , .res(addr)
    , .addsub(addsub)
    );

Mult #(wordsize) mult(.left(retout) // get from res and n and push in res *
    , .right(addr) //change to n *
    , .res(multr)
    );

Comp #(wordsize) comp(.left(n)
    , .right({1'b0, N[wordsize-1:1]})
    , .gt(gt)
    , .eq(eq)
    , .lt(lt));

endmodule