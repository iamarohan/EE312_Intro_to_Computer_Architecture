module Immediate(ALUOp,Instruction,Immediate_Output);
   input [2:0]ALUOp;
   input [31:0]Instruction;
   output reg [31:0]Immediate_Output;

   integer i;

   always @(*) begin
      //I-immediate
      if (ALUOp == 3'b001||ALUOp == 3'b110) begin
         for (i = 11; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[10:0] = {Instruction[30:25],Instruction[24:21],Instruction[20]};
      end
      //S-immediate
      else if (ALUOp == 3'b010) begin
         for (i = 11; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[10:0] = {Instruction[30:25],Instruction[11:8],Instruction[7]};
      end
      //B-immediate
      else if (ALUOp == 3'b011) begin
         for (i = 12; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[11:0] = {Instruction[7],Instruction[30:25],Instruction[11:8],1'b0};
      end
      //U-immediate
      else if (ALUOp == 3'b100) begin
         Immediate_Output[31:0] = {Instruction[31],Instruction[30:20],Instruction[19:12],12'b000000000000};
      end
      //J-immediate
      else if (ALUOp == 3'b101) begin
         for (i = 20; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[19:0] = {Instruction[19:12],Instruction[20],Instruction[30:25],Instruction[24:21],1'b0};
      end
   end
endmodule