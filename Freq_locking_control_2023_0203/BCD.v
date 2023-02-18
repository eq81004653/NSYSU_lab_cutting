//--------Binary to Binary-Coded Decimal (BCD)---------//
module BCD(hundreds,tens,ones,in);
input [9:0] in;
output reg [3:0] hundreds, tens, ones;

// Internal variable for storing bits
reg [21:0] shift;
integer i;

always @(in) begin
	// Clear previous number and store new number in shift
	shift[21:10]=  0;
	shift[9:0]  = in;
	
	// Loop 10 times
	for (i=0;i<10;i=i+1) begin
		if(shift[13:10]>=5) 	shift[13:10]=shift[13:10]+3;
		if(shift[17:14]>=5)	shift[17:14]=shift[17:14]+3;
		if(shift[21:18]>=5)	shift[21:18]=shift[21:18]+3;
			
		// Shift entire register left once
		shift = shift<<1;
	end
	
	// Push decimal numbers to output
	ones		= shift[13:10];
	tens		= shift[17:14];
	hundreds	= shift[21:18];
end

endmodule
	
			
				
