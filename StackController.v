`timescale 1ns/1ns

// {par}Sig goes to Controller, otherwise control components

module StackController(clk, pushSig, popSig, readySig, pop, push, enF, enN, enRes, pushSrc);
    input pushSig, popSig, clk;
    output reg [1:0] pushSrc;
    output reg readySig, enF, enN, enRes, pop, push;

    reg[2:0] ps = 0, ns = 0;

    parameter [2:0] 
    START = 0 , CONFIRM = 7, POPFLAG = 1, POPRET = 2, POPN = 3
                , PUSHFLAG = 4, PUSHRET = 5, PUSHN = 6;

    always@(ps, popSig, pushSig)begin
       case(ps)
            START   : ns = popSig == 1 ? POPFLAG : pushSig == 1 ? PUSHFLAG : START;
            POPFLAG : ns = POPRET;
            POPRET  : ns = POPN;
            POPN    : ns = CONFIRM;
            PUSHFLAG: ns = PUSHRET;
            PUSHRET : ns = PUSHN;
            PUSHN   : ns = CONFIRM;
            CONFIRM : ns = START;
       endcase 
    end

    always @(ps) begin
        {pushSrc, readySig, enF, enN, enRes, pop, push} = 0;
        case(ps)
            START   : readySig   = 1;
            POPFLAG : pop        = 1; enF       = 1;
            POPRET  : pop        = 1; enRes     = 1;
            POPN    : pop        = 1; enN       = 1;
            PUSHFLAG: push       = 1; pushSrc   = 0;
            PUSHRET : push       = 1; pushSrc   = 2;
            PUSHN   : push       = 1; pushSrc   = 1;
            CONFIRM : readySig   = 1;
        endcase
        
    end

    always@(posedge clk)begin
			ps <= ns;
	end

endmodule