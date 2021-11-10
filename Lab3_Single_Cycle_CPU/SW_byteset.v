// Store instructions
`define   OP_SB     3'b000
`define   OP_SH     3'b001
`define   OP_SW     3'b010

module SW_byteset(Input_data,func3,Output_data);
  input [31:0]Input_data;
  input [2:0]func3;
  output reg [31:0]Output_data;
  reg b;

  integer i;

  initial begin
    Output_data = Input_data;
  end

  always @(*) begin
    if (func3 == `OP_SB) begin
      b = Input_data[7];
      for (i = 31; i >= 8; i=i-1) begin
        Output_data[i] = b;
      end
    end
    else if (func3 == `OP_SH) begin
      b = Input_data[15];
      for (i = 31; i >= 16; i=i-1) begin
        Output_data[i] = b;
      end
    end
    else if (func3 == `OP_SW) begin
      Output_data = Input_data;
    end
  end
endmodule