`timescale 1ns/1ns
module Mux(s, a, b, c );
	parameter n = 8;
	input s;
	input[n-1:0] a,b;
	output[n-1:0] c;	

	assign c = s ? b : a;
endmodule