  //-------700Hz-Cutoff Lowpass Filter (z+1)/(16z-14), fs=32kHz -------//
  //                    Remove noise from abs_theta                    //
module LPF(out16,in,clk);
  output [11:0] out16;
  input [7:0] in;
  input clk;
  
  wire [11:0] out16_temp;
  assign out16_temp = {{4{in[7]}},in} +{{4{in_d[7]}},in_d}
                      +out16-{{3{out16[11]}},out16[11:3]};
  reg [11:0] out16;
  reg [7:0] in_d;
  always @(posedge clk) begin
      in_d <= in;
		out16 <= out16_temp;
  end	
endmodule  
  