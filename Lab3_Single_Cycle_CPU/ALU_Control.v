// ALUOp signal types
`define   OP_R      3'b000
`define   OP_I      3'b001
`define   OP_S      3'b010
`define   OP_B      3'b011
`define   OP_U      3'b100
`define   OP_J      3'b101
`define   OP_IL     3'b110 // Meaning Load instructions in I-type
`define   OP_JALR   3'b111 // Meaning JALR instruction in I-type

// ALUControlOp output
`define   ConOP_ADD     3'b000
`define   ConOP_BRANCH  3'b011
`define   ConOP_R       3'b001
`define   ConOP_R_      3'b101
`define   ConOP_I       3'b010
`define   ConOP_I_      3'b110
`define   ConOP_ID      3'b111

module ALU_Control(func7,ALUOp,ALUControlOp);
  input [6:0]func7;
  input [2:0]ALUOp;
  output reg [2:0]ALUControlOp;

  always @(*) begin
    if (ALUOp == `OP_R) begin
      // check if func7 is 7'b0100000
      if (func7[5] == 1'b0) begin
        ALUControlOp = `ConOP_R;
      end
      else begin
        ALUControlOp = `ConOP_R_;
      end
    end
    else if (ALUOp == `OP_I) begin
      // check if func7 is 7'b0100000
      if (func7[5] == 1'b0) begin
        ALUControlOp = `ConOP_I;
      end
      else begin
        ALUControlOp = `ConOP_I_;
      end
    end
    else if (ALUOp == `OP_S) begin
      ALUControlOp = `ConOP_ADD;
    end
    else if (ALUOp == `OP_B) begin
      ALUControlOp = `ConOP_BRANCH;
    end
    else if (ALUOp == `OP_U) begin
      ALUControlOp = `ConOP_ID;
    end
    else if (ALUOp == `OP_J) begin
      ALUControlOp = `ConOP_ID;
    end
    else if (ALUOp == `OP_IL) begin
      ALUControlOp = `ConOP_ADD;
    end
    else if (ALUOp == `OP_JALR) begin
      ALUControlOp = `ConOP_ADD;
    end
  end
endmodule