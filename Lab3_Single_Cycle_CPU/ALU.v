// func3 Operator
`define   func3_ADD     3'b000
`define   func3_SLL     3'b001
`define   func3_SLT     3'b010
`define   func3_SLTU    3'b011
`define   func3_XOR     3'b100
`define   func3_SRL     3'b101
`define   func3_OR      3'b110
`define   func3_AND     3'b111

// Branch func3
`define   OP_BEQ        3'b000
`define   OP_BNE        3'b001
`define   OP_BLT        3'b100
`define   OP_BGE        3'b101
`define   OP_BLTU       3'b110
`define   OP_BGEU       3'b111

// ALUControlOp output
`define   ConOP_ADD     3'b000
`define   ConOP_BRANCH  3'b011
`define   ConOP_R       3'b001
`define   ConOP_R_      3'b101
`define   ConOP_I       3'b010
`define   ConOP_I_      3'b110
`define   ConOP_ID      3'b111

module ALU(A,B,ALUControlOp,func3,Bcond,Output);
  input [31:0]A;
  input [31:0]B;
  input [2:0]ALUControlOp;
  input [2:0]func3;
  output reg Bcond;
  output reg [31:0]Output;
  reg signed [31:0] sA, sB;
  reg unsigned [31:0] uA, uB;
  reg a, b;

  integer i;

  initial begin
    Output = 31'b0;
    Bcond = 1'b0;
  end

  // addition
  always @(*) begin
    Bcond = 1'b0;
    if ((ALUControlOp == `ConOP_ADD)) begin
      Output = A + B;
    end
    else if (ALUControlOp == `ConOP_BRANCH) begin
      if (func3 == `OP_BEQ) begin
        if (A == B) begin
          Bcond = 1'b1;
          Output = 31'b1;
        end
      end
      else if (func3 == `OP_BNE) begin
        if (A != B) begin
          Bcond = 1'b1;
          Output = 31'b1;
        end
      end
      else if (func3 == `OP_BLT) begin
        a = A[31];
        b = B[31];
        if (a == 1 && b == 0) begin
          Bcond = 1'b1;
          Output = 31'b1;
        end
        else begin
          if (A < B) begin
            Bcond = 1'b1;
            Output = 31'b1;
          end
        end
      end
      else if (func3 == `OP_BGE) begin
        a = A[31];
        b = B[31];
        if (a == 0 && b == 1) begin
          Bcond = 1'b1;
          Output = 31'b1;
        end
        else begin
          if (A >= B) begin
            Bcond = 1'b1;
            Output = 31'b1;
          end
        end
      end
      else if (func3 == `OP_BLTU) begin
        a = A[31];
        b = B[31];
        if (a == 0 && b == 1) begin
          Bcond = 1'b1;
          Output = 31'b1;
        end
        else begin
          if (A < B) begin
            Bcond = 1'b1;
            Output = 31'b1;
          end
        end
      end
      else if (func3 == `OP_BGEU) begin
        a = A[31];
        b = B[31];
        if (a == 1 && b == 0) begin
          Bcond = 1'b1;
          Output = 31'b1;
        end
        else begin
          if (A > B) begin
            Bcond = 1'b1;
            Output = 31'b1;
          end
        end
      end
    end
    else if (ALUControlOp == `ConOP_ID) begin
      // out second identity Value
      Output = B;
    end
    else begin
      // R-type
      if (ALUControlOp[1] == 1'b0 && ALUControlOp[0] == 1'b1) begin
        if (func3 == `func3_ADD) begin
          // ADD
          if (ALUControlOp[2] == 1'b0) begin
            Output = A + B;
          end
          // SUB
          else begin
            Output = A - B;
          end
        end
        // SLL
        else if (func3 == `func3_SLL) begin
          Output = A;
          for (i = 0; i < B[5:0]; i=i+1) begin
            Output = Output << 1;
          end
        end
        // SLT
        else if (func3 == `func3_SLT) begin
          sA = A;
          sB = B;
          if (sA < sB) begin
            Output = 31'b1;
          end
          else begin
            Output = 31'b0;
          end
        end
        // SLTU
        else if (func3 == `func3_SLTU) begin
          uA = A;
          uB = B;
          if (uA < uB) begin
            Output = 31'b1;
          end
          else begin
            Output = 31'b0;
          end
        end
        // XOR
        else if (func3 == `func3_XOR) begin
          Output = A ^ B;
        end
        else if (func3 == `func3_SRL) begin
          // SRL
          if (ALUControlOp[2] == 1'b0) begin
            Output = A;
            for (i = 0; i < B[5:0]; i=i+1) begin
              Output = Output >> 1;
            end
          end
          // SRA
          else begin
            Output = A;
            for (i = 0; i < B[5:0]; i=i+1) begin
              b = Output[15];
              Output = Output >>> 1;
              Output[15] = b;
            end
          end
        end
        // OR
        else if (func3 == `func3_OR) begin
          Output = A | B;
        end
        // AND
        else if (func3 == `func3_AND) begin
          Output = A & B;
        end
      end
      // I-type
      if (ALUControlOp[1] == 1'b1 && ALUControlOp[0] == 1'b0) begin
        // ADDI
        if (func3 == `func3_ADD) begin
          Output = A + B;
        end
        // SLLI
        else if (func3 == `func3_SLL) begin
          Output = A;
          for (i = 0; i < B[5:0]; i=i+1) begin
            Output = Output << 1;
          end
        end
        // SLTI
        else if (func3 == `func3_SLT) begin
          sA = A;
          sB = B;
          if (sA < sB) begin
            Output = 31'b1;
          end
          else begin
            Output = 31'b0;
          end
        end
        // SLTIU
        else if (func3 == `func3_SLTU) begin
          uA = A;
          uB = B;
          if (uA < uB) begin
            Output = 31'b1;
          end
          else begin
            Output = 31'b0;
          end
        end
        // XORI
        else if (func3 == `func3_XOR) begin
          Output = A ^ B;
        end
        else if (func3 == `func3_SRL) begin
          // SRLI
          if (ALUControlOp[2] == 1'b0) begin
            Output = A;
            for (i = 0; i < B[5:0]; i=i+1) begin
              Output = Output >> 1;
            end
          end
          // SRAI
          else begin
            Output = A;
            for (i = 0; i < B[5:0]; i=i+1) begin
              b = Output[15];
              Output = Output >>> 1;
              Output[15] = b;
            end
          end
        end
        // ORI
        else if (func3 == `func3_OR) begin
          Output = A | B;
        end
        // ANDI
        else if (func3 == `func3_AND) begin
          Output = A & B;
        end
      end
    end
   end
endmodule