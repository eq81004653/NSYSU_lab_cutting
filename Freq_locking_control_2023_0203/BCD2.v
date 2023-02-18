//--------Binary to Binary-Coded Decimal (BCD)---------//
module BCD2(ten_thous,thousands,hundreds,tens,ones,in);
input [15:0] in;
output reg [3:0] ten_thous,thousands,hundreds, tens, ones;

// Internal variable for storing bits
reg [35:0] shift;   // 15+5*4=35
integer i;

always @(in) begin
	// Clear previous number and store new number in shift
	shift[35:16]=  0;
	shift[15:0]  = in;
	
	// Loop 16 times  // bit number of in
	for (i=0;i<16;i=i+1) begin
		if(shift[19:16]>=5) 	shift[19:16]=shift[19:16]+3;
		if(shift[23:20]>=5)	shift[23:20]=shift[23:20]+3;
		if(shift[27:24]>=5)	shift[27:24]=shift[27:24]+3;
		if(shift[31:28]>=5)	shift[31:28]=shift[31:28]+3;
		if(shift[35:32]>=5)	shift[35:32]=shift[35:32]+3;
			
		// Shift entire register left once
		shift = shift<<1;
	end
	
	// Push decimal numbers to output
	ones		= shift[19:16];
	tens		= shift[23:20];
	hundreds	= shift[27:24];
	thousands= shift[31:28];
	ten_thous= shift[35:32];
end

endmodule
	
			
				
