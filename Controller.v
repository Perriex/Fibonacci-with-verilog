`timescale 1ns/1ns

module Controller(clk, 
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

    input clk, readySig;// ready signal from stack
    
    input lt, gt, eq;            // for n < N / 2 result

    input[7:0] flag, n;             // check for states

    output reg  addsub,          // choose to flag++ or n-flag or ret+res
            resld, resrst, // selector for reg res and enable and reset
            retld, retrst,       // enable load reg return and reset
            nld, nrst,       // selector for reg n and enable and reset
            fld, frst,       // selector for reg flag and enable and reset
            pushSig, popSig      // signals for stack controller
            ;                

    output[1:0] rets,            // ret reg entry selector
            addrs, addls;        // controll entries to adder

    reg[3:0] ps = 1, ns = 0;     //start from START

    parameter [2:0] 
        INIT   = 0, START  = 1, CALRES = 2, PUSHBF  = 3, NEXTN = 4,
        PUSHAF = 5, CALRET = 6, ASSING = 7, LESSONE = 8;

    always@(ps, readySig, n, flag, Ready)begin
       case(ps)
            INIT    : ns = START; // extra
            START   : ns = readySig == 1 ? CALRES   : START;
            CALRES  : ns =  n    <= 1   ? LESSONE   :
                            flag == 1   ? PUSHBF    :
                                          CALRET;
            PUSHBF  : ns = readySig == 1 ? NEXTN    : PUSHBF;
            NEXTN   : ns = PUSHAF ;
            PUSHAF  : ns = readySig == 1 ? START    : PUSHAF;
            CALRET  : ns = flag == 2  ?  PUSHBF : ASSING; // add contoller
            ASSING  : ns = START;
            LESSONE : ns = START;
       endcase 
    end

    always @(ps) begin
        { addsub,
          resld, resrst,
          retld, retrst,
          nld, nrst,
          fld, frst,
          pushSig, popSig 
          addrs, addls,
          rets
        } = 0;
        case(ps)
            INIT    :begin      end //extra
            START   :begin popSig  = 1;     end
            CALRES  :begin addsub  = 0; addrs = {1'b1, flag[0] ^ gt}; addls = 1; retld = 1; rets = 2; fld = 1;  end // cal mult
            PUSHBF  :begin pushSig = 1;     end
            NEXTN   :begin addsub  = 0; addrs = 0; addls = 1; nld = 1; frst = 1;  end // may be problem
            PUSHAF  :begin pushSig = 1;     end
            CALRET  :begin addsub = 1; addrs = 1; addls = 2; resld = 1; end // new state - controller
            ASSING  :begin rets = 1; retld = 1;      end // it is extra
            LESSONE :begin rers = 0, retld = 1;      end
        endcase
        
    end

    always@(posedge clk)begin
		ps <= ns;
	end

endmodule