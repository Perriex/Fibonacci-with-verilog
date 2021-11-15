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
            CALRET  : ns = Ready == 1 ? flag == 2   ?  PUSHBF    : START//ASSING // add contoller
                                    ;   CALRET;
           // ASSING  : ns = START;
            LESSONE : ns = START;
       endcase 
    end

    reg chooseN ;
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
        chooseN = 0;
        case(ps)
            INIT    :begin      end //extra
            START   :begin popSig  = 1;     end
            CALRES  :begin addsub  = 1; addrs = 2; addls = 0; fld = 1; fs =0;   end // cal mult
            PUSHBF  :begin pushSig = 1;     end
            NEXTN   :begin addsub  = 0; addrs = 0; addls = 1; nld = 1; ns =0; frst = 1;  end // may be problem
            PUSHAF  :begin pushSig = 1;     end
            CALRET  :begin chooseN = 1;     end // new state - controller
            //ASSING  :begin rets = 1; retld = 1;      end // it is extra
            LESSONE :begin rers = 0, retld = 1;      end
        endcase
        
    end

    // controller for deciding either n-1 * res or n - 2:
    parameter[1:0] NEW = 0, CALMULT = 1, CALADD = 2, MINN = 3;
    reg[3:0] ps2 = 0, ns2 = 0;
    reg Ready = 0;
    always @(posedge chooseN, gt, flag) begin
        case(ps2) // if 0 n*f else n-1*f
            NEW:    ns2 = chooseN == 1 ? gt ^ flag[0] ? MINN : CALMAT : NEW;
            MINN  : ns2 = CALMAT ;
            CALMAT: ns2 = CALADD ;
            CALADD: ns2 = NEW   ;
        case
    end

    always @(posedge chooseN) begin
        Ready = 0;
        case(ps2)
            NEW   :begin Ready = 1; end
            MINN  :begin addsub = 0; addls = 1; addrs = 2; nld = 1; ns =0;  end // n--
            CALMAT:begin       end // process to mult reg n and reg res
            CALADD:begin addls = 2; addrs = 1; rets = 1; retld = 1;  end // process to add reg res with ret
        case
    end

    always@(posedge clk)begin
		ps <= ns;
        ps2 <= ns2;
	end

endmodule