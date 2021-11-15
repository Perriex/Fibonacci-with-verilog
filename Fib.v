`timescale 1ns/1ns

module Fib (clk);

input clk;

wire [1:0] pushSrc;

wire pushSig, popSig;
wire readySig, enF, enN, enRes, pop, push;

StackController stackController(clk,
    pushSig, popSig, readySig,
    pop, push,                         
    enF, enN, enRes,                  
    pushSrc
    );

wire[7:0] flag, n;
wire[1:0] rets, addrs, addls; 

wire lt, gt, eq;
wire addsub,
    resld, resrst,
    retld, retrst,
    nld, nrst, 
    fld, frst,
    ;                

Controller controller(clk, 
    addsub,
    readySig,
    resld, resrst,
    retld, retrst,
    nld, nrst,
    fld, frst,
    rets,
    addrs, addls,
    lt, gt, eq,
    flag, n,
    pushSig, popSig);

Datapath datapath(clk
    , push, pop             
    , addsub                
    , ~readySig, resld | enRes, resrst   
    , rets, retld, retrst   
    , ~readySig, nld | enN, nrst         
    , ~readySig, fld | enF, frst         
    , addrs, addls          
    , lt, gt, eq            
    , flag, n                  
    , pushSrc
);
    
endmodule