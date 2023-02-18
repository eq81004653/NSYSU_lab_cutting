// To detect the phase bwteen the binary current I and voltage V
// Inputs: I & V, each containing 4 bits of data, updated at the posedge of clk1300kHz.
// Output: theta is the phase difference between I & V, ranging from -63 to 63, with
//         64 corresponding to 180 degree. A new estimate is updated at rst = high.

//assign V={V_1d75[13],V_1d5[13],V_1d25[13],V_1[13]};
//assign I={I_1d75[13],I_1d5[13],I_1d25[13],I_1[13]};


module phase_detector2(theta,I,V, rst,clk325kHz_d2);
input rst, clk325kHz_d2;
input [3:0] I, V;
output signed [7:0] theta;

// Four sampled data in a vector, with a delay of the 1/4 period
reg [3:0] I_shift0, I_shift1, I_shift2, I_shift3; // 4 unpacked array of size 4
always @(negedge clk325kHz_d2) begin
	I_shift3 <= I_shift2;
	I_shift2 <= I_shift1;
	I_shift1 <= I_shift0;
	I_shift0 <= I;
end

wire [3:0] XOR_IV, XOR_Idelay_V;
assign XOR_IV=I^V;
assign XOR_Idelay_V=I_shift3^V;

reg [6:0] accum1=7'b0,accum2=7'b0;
wire [6:0] sum1, sum2;
assign sum1 = accum1+{6'b0,XOR_IV[3]}+ {6'b0,XOR_IV[2]}+{6'b0,XOR_IV[1]}+{6'b0,XOR_IV[0]};
assign sum2 = accum2+{6'b0,XOR_Idelay_V[3]}+ {6'b0,XOR_Idelay_V[2]}+{6'b0,XOR_Idelay_V[1]}+{6'b0,XOR_Idelay_V[0]};
reg signed [7:0] theta;
always @(posedge clk325kHz_d2) begin
	if (rst) begin   // Reset for every 16 cycles, about a period of a 20kHz clock 
	   accum1 <= 7'b0;
		accum2 <= 7'b0;
		theta <=(sum2>7'b0011111)?{1'b1,~(sum1-1)}:{1'b0,sum1};
      // theta<0 when accum2 >= 64/2 (Current lags behind Voltage) 
   end 
	else	begin	
	   accum1 <= sum1;
		accum2 <= sum2;
	end
end

endmodule  
	  
      
	  
	  
	  


		  
	
	