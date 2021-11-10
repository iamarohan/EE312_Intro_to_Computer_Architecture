module Multiplexer(input_one,input_two,switch,out);
   input [31:0]input_one;
   input [31:0]input_two;
   input switch;
   output reg [31:0]out;

always @(*) begin
   case(switch)
      1'b0: out = input_one;
      1'b1: out = input_two;
      default: out = input_one;
   endcase
end
endmodule