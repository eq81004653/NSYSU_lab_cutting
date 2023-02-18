  //-------350Hz-Cutoff Lowpass Filter (z+1)/(32z-30), fs=32kHz -------//

module LPF2(out,in,clk);
  output [7:0] out;
  input [7:0] in;
  input clk;
  
  wire [12:0] out32_temp;
  assign out32_temp = {{5{in[7]}},in} +{{5{in_d[7]}},in_d}
                      +out32-{{3{out32[12]}},out32[12:3]};
  reg [12:0] out32;
  reg [7:0] in_d;
  always @(posedge clk) begin
      in_d <= in;
		out32 <= out32_temp[12:5];
  end	
  wire [7:0] out;
  assign out=out32[12:5];
endmodule  
  