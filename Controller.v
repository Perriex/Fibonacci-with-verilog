`timescale 1ns/1ns

module Controller(clk, 
    addsub,
    ress, resld, resrst,
    retld, retrst,
    ns, nld, nrst,
    fs, fld, frst,
    rets,
    lt, gt, eq,
    flag, n,
    pushSig, popSig);

    input clk, readySig;// ready signal from stack
    
    input lt, gt, eq;            // for n < N / 2 result

    input[7:0] flag, n;             // check for states

    output reg  addsub,          // choose to flag++ or n-flag or ret+res
            ress, resld, resrst, // selector for reg res and enable and reset
            retld, retrst,       // enable load reg return and reset
            ns, nld, nrst,       // selector for reg n and enable and reset
            fs, fld, frst,       // selector for reg flag and enable and reset
            pushSig, popSig      // signals for stack controller
            ;                

    output[1:0] rets,            // ret reg entry selector
            addrs, addls;        // controll entries to adder

    reg[3:0] ps = 0, ns = 0;

    parameter [2:0] 
        INIT   = 0, START  = 1, CALRES = 2, PUSHBF  = 3, NEXTN = 4,
        PUSHAF = 5, CALRET = 6, ASSING = 7, LESSONE = 8;

    always@(ps)begin
       case(ps)
            INIT    : ns = START;
            START   : ns = readySig == 1 ? CALRES   : START;
            CALRES  : ns =  n    <= 1   ? LESSONE   :
                            flag == 1   ? PUSHBF    :
                                          CALRET;
            PUSHBF  : ns = NEXTN;
            NEXTN   : ns = PUSHAF;
            PUSHAF  : ns = START;
            CALRET  : ns = flag == 2    ? PUSHBF    : ASSING;
            ASSING  : ns = START;
            LESSONE : ns = START;
       endcase 
    end

    always @(ps) begin
        { addsub,
          ress, resld, resrst,
          retld, retrst,
          ns, nld, nrst,
          fs, fld, frst,
          pushSig, popSig 
          addrs, addls,
          rets
        } = 0;
        case(ps)
            INIT    :begin      end
            START   :begin popSig = 1;     end
            CALRES  :begin addsub = 1; addrs = 2; addls = 0; fld = 1; fs =0;   end // cal mult
            PUSHBF  :begin      end
            NEXTN   :begin      end
            PUSHAF  :begin      end
            CALRET  :begin      end
            ASSING  :begin      end
            LESSONE :begin      end
        endcase
        
    end

    always@(posedge clk)begin
			ps <= ns;
	end

endmodule