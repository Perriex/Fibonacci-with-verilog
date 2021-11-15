`timescale 1ns/1ns

module StackController(clk,                 // system clk
         pushSig, popSig, readySig,         // signals go to main controller
         pop, push,                         // controller of stack
         enF, enN, enRes,                   // enable registers for n, result and flag
         pushSrc                            // selector for entry of stack
         );  

    input pushSig, popSig, clk;

    output reg [1:0] pushSrc;

    output reg  readySig,
                enF, enN, enRes,
                pop, push;

    reg[2:0] ps = 0, ns = 0;

    parameter [2:0] 
            START = 0, CONFIRM = 7, POPFLAG = 1, POPRES = 2,
            POPN = 3, PUSHFLAG = 4, PUSHRET = 5, PUSHN = 6;

    always@(ps, popSig, pushSig)begin
       case(ps)
            START   : ns = popSig == 1  ? POPFLAG  : // pop to flag reg
                           pushSig == 1 ? PUSHN :    // push n 
                           START;                    // no signal 
            POPFLAG : ns = POPRES;                   // pop to result reg
            POPRES  : ns = POPN;                     // pop to n reg
            POPN    : ns = CONFIRM;                  // goto start
            PUSHN   : ns = PUSHRET;                    // push n
            PUSHRET : ns = PUSHFLAG;                 // push flag
            PUSHFLAG: ns = CONFIRM;                  // go to start
            CONFIRM : ns = START;
       endcase 
    end

    always @(ps) begin
        {pushSrc, readySig, 
         enF, enN, enRes,
         pop, push } = 0;
        case(ps)
            START   :begin readySig   = 1;                   end
            POPFLAG :begin pop        = 1; enF       = 1;    end
            POPRES  :begin pop        = 1; enRes     = 1;    end
            POPN    :begin pop        = 1; enN       = 1;    end
            PUSHN   :begin push       = 1; pushSrc   = 1;    end
            PUSHRET :begin push       = 1; pushSrc   = 2;    end
            PUSHFLAG:begin push       = 1; pushSrc   = 0;    end
            CONFIRM :begin readySig   = 1;                   end
        endcase
        
    end

    always@(posedge clk)begin
			ps <= ns;
	end

endmodule