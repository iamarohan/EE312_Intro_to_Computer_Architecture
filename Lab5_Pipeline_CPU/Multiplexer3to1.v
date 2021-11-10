module Multiplexer3to1(input_one,input_two,input_three,switch,out);
   input [31:0]input_one;
   input [31:0]input_two;
   input [31:0]input_three;
   input [1:0]switch;
   output reg [31:0]out;

always @(*) begin
   case(switch)
      2'b00: out = input_one;
      2'b01: out = input_two;
      2'b10: out = input_three;
      default: out = input_one;
   endcase
end
endmodule