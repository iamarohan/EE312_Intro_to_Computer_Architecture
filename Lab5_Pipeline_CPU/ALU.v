`define   ADD       5'b00000
`define   SUB       5'b00001
`define   SLL       5'b00010
`define   SLT       5'b00011
`define   SLTU      5'b00100
`define   XOR       5'b00101
`define   SRL       5'b00110
`define   SRA       5'b00111
`define   OR        5'b01000
`define   AND       5'b01001
`define   JALR      5'b01010

module ALU(A,B,ALUControlOp,Output);
  input [31:0]A;
  input [31:0]B;
  input [4:0]ALUControlOp;
  output reg [31:0]Output;
  //temporary variables
  integer i;
  reg signed [31:0] sA, sB;
  reg a, b;
  initial begin
    Output = 31'b0;
  end

  always @(*) begin
    if (ALUControlOp == `ADD) begin
      Output = A+B;
    end
    else if (ALUControlOp == `SUB) begin
      Output = A-B;
    end
    else if (ALUControlOp == `SLL) begin
      Output = A;
      for (i =0;i < B[5:0];i = i+1) begin
          Output = Output<<1;
        end
    end
    else if (ALUControlOp == `SLT) begin
      sA = A;
      sB = B;
      if (sA < sB) begin
              Output = 31'b1;
            end
            else begin
              Output = 31'b0;
            end
    end
    else if (ALUControlOp == `SLTU) begin
        if (A < B) begin
          Output = 31'b1;
        end
        else begin
          Output = 31'b0;
        end
    end
    else if (ALUControlOp == `XOR) begin
      Output = A ^ B;
    end
    else if (ALUControlOp == `SRL) begin
          Output = A;
          for (i = 0; i < B[5:0]; i=i+1) begin
            Output = Output >> 1;
          end
    end
    else if (ALUControlOp == `SRA) begin
      Output = A;
          for (i = 0; i < B[5:0]; i=i+1) begin
            b = Output[15];
            Output = Output >>> 1;
            Output[15] = b;
          end
    end
    else if (ALUControlOp == `OR) begin
      Output = A|B;
    end
    else if (ALUControlOp == `AND) begin
      Output = A&B;
    end
    else if (ALUControlOp == `JALR) begin
      Output = A+B;
      Output[0] = 1'b0;
    end
  end
endmodule