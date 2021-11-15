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
    , ss                    // stack input selector for push
    );                      

input clk, push, pop, addsub
    , ress, resld, resrst
    , retld, retrst
    , ns, nld, nrst
    , fs, fld, frst
    ;

input [1:0] rets, addrs, addls, ss;

output lt, gt, eq;
output [7:0] n, f;

reg [7:0] N = 8'b10;

wire [7:0] din, dout, addr, multr;
wire [7:0] nin, nout;
/*
    0 : adder result
    1 : stack data
*/
Mux nmux(.s(ns)
    , .a(addr)
    , .b(dout)
    , .c(nin)
    );
EnRegister nreg(.clk(clk)
    , .pi(nin)
    , .po(nout)
    , .en(nld)
    , .rst(nrst)
    );
assign n = nout;

wire [7:0] fin, fout, fincres;

Inc finc(fout, fincres);
Mux fmux(.s(fs)
    , .a(fincres) // 0 : flag + 1
    , .b(dout) // 1 : stack data
    , .c(fin)
    );
EnRegister freg(.clk(clk)
    , .pi(fin)
    , .po(fout)
    , .en(fld)
    , .rst(frst)
    );
assign f = fout;

wire [7:0] resin, resout;
Mux resmux(.s(ress) // need to add from mult *
    , .a(addr) // 0 : adder result
    , .b(dout) // 1 : stack data
    , .c(resin)
    );
EnRegister resreg(.clk(clk)
    , .pi(resin)
    , .po(resout)
    , .en(resld)
    , .rst(resrst)
    );

wire [7:0] retin, retout;
Mux4to1 retmux(.s(rets)
    , .in0(8'b1)  // 0 : 1
    , .in1(addr)  // 1 : adder result
    , .in2(multr) // 2 : mult result // it is exta *
    , .in3(8'b0)  // 3 : none (0)
    , .c(retin)
    );
EnRegister retreg(.clk(clk)
    , .pi(retin)
    , .po(retout)
    , .en(retld)
    , .rst(retrst)
    );

Mux4to1 smux(.s(ss)
    , .in0(fout)   // 0 : flag
    , .in1(nout)   // 1 : argument n
    , .in2(resout) // 2 : result
    , .in3(8'b0)   // 3 : none(0)
    , .c(din)
    );
Stack stack(
    .clk(clk),
    .din(din), 
    .dout(dout), 
    .push(push), 
    .pop(pop)
);


wire [7:0] addlop, addrop;
Mux4to1 addlmux(.s(addls)
    , .in0(8'b0)   // 0 : none(0)
    , .in1(nout)   // 1 : argument n
    , .in2(resout) // 2 : result
    , .in3(8'b0)   // 3 : none (0)
    , .c(addlop)
    );
Mux4to1 addrmux(.s(addrs) // change from addls to addrs *
    , .in0(fout)   // 0 : flag
    , .in1(retout) // 1 : return value
    , .in2(8'b1)   // 2 : 1
    , .in3(8'b10)  // 3 : 2
    , .c(addrop)
    );
AddSub alu(.left(addlop) // can get from res and ret and push in ret *
    , .right(addrop)
    , .res(addr)
    , .addsub(addsub)
    );

Mult mult(.left(resout) // get from res and n and push in res *
    , .right(addr) //change to n *
    , .res(multr)
    );

Comp comp(.left(n)
    , .right({0, N[6:0]})
    , .gt(gt)
    , .eq(eq)
    , .lt(lt));

endmodule