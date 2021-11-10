// Load instructions
`define   OP_LB     3'b000
`define   OP_LH     3'b001
`define   OP_LW     3'b010
`define   OP_LBU    3'b100
`define   OP_LHU    3'b101

module LW_byteset(Input_data,func3,Output_data);
  input [31:0]Input_data;
  input [2:0]func3;
  output reg [31:0]Output_data;
  reg b;

  integer i;

  initial begin
    Output_data = Input_data;
  end

  always @(*) begin
    if (func3 == `OP_LB) begin
      b = Input_data[7];
      for (i = 31; i >= 8; i=i-1) begin
        Output_data[i] = b;
      end
    end
    else if (func3 == `OP_LH) begin
      b = Input_data[15];
      for (i = 31; i >= 16; i=i-1) begin
        Output_data[i] = b;
      end
    end
    else if (func3 == `OP_LW) begin
      Output_data = Input_data;
    end
    else if (func3 == `OP_LBU) begin
      for (i = 31; i >= 8; i=i-1) begin
        Output_data[i] = 0;
      end
    end
    else if (func3 == `OP_LHU) begin
      for (i = 31; i >= 16; i=i-1) begin
        Output_data[i] = 0;
      end
    end
  end
endmodule