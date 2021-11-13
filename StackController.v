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
            START   :begin readySig   = 1;                   end
            POPFLAG :begin pop        = 1; enF       = 1;    end
            POPRET  :begin pop        = 1; enRes     = 1;    end
            POPN    :begin pop        = 1; enN       = 1;    end
            PUSHFLAG:begin push       = 1; pushSrc   = 0;    end
            PUSHRET :begin push       = 1; pushSrc   = 2;    end
            PUSHN   :begin push       = 1; pushSrc   = 1;    end
            CONFIRM :begin readySig   = 1;                   end
        endcase
        
    end

    always@(posedge clk)begin
			ps <= ns;
	end

endmodule