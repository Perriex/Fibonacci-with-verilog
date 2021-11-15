`timescale 1ns/1ns

module Stack (clk, din, dout, push, pop, empty);
    
    parameter size = 8;
    input push, pop, clk;
    input [size-1:0] din;
    output empty;

    output reg [size-1:0] dout;
    
    reg [size-1:0] file[255:0];
    reg [7:0] top = 0;

    always @(posedge clk) begin
        if(push) begin
            top <= top + 1;
            file[top] <= din;
        end
        if(pop)
            top <= top - 1;
    end
    
    assign empty = top == 0;
    assign dout = file[top - 1];
endmodule
