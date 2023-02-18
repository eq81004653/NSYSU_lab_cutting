// Estimate |theta| bwteen the binary waveforms I and V
// 
//  【Example】Given the driving frequency of 32 kHz
//  |theta|=5e6/32e3=156 corresponds to 180 degrees.

module phase_estimator(clk5MHz);//(I,V,cycle,clk5MHz);
  
  //output [7:0] abs_theta;
  //input I, V, cycle, clk5MHz;
  input clk5MHz;
  
// Generate a pulse at each positive edge of the cycle
// to signal the beginning of a new cycle 
/*  reg cycle_d1, cycle_d2;
  always @(negedge clk5MHz) begin
	 cycle_d2 <= cycle_d1;
	 cycle_d1 <= cycle;
  end
  wire pulse;
  assign pulse=cycle_d1&(~cycle_d2);

// Count the number of NOR(I,V)=1 for each period of cycle
  wire XOR_IV;
  assign XOR_IV=I^V;
  reg [7:0] accum=8'b0;
  wire [7:0] sum;
  assign sum = accum+XOR_IV;
 // reg [7:0] abs_theta;
  always @(posedge clk5MHz) begin
     if (pulse) begin
	//        abs_theta <= sum;
			  accum <=8'b0; 
	  end else
	        accum <= sum;
  end
*/
endmodule  
	  
      
	  
	  
	  


		  
	
	