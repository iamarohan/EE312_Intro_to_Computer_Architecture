module Immediate(Instruction,Immediate_Output);
	input [31:0] Instruction;
	output reg [31:0]Immediate_Output;
	wire [6:0]Opcode;
	integer i;
	assign Opcode = Instruction[6:0];

	  always @(*) begin
      //I-immediate
      if (Opcode == 7'b1100111||Opcode == 7'b0000011||Opcode==7'b0010011) begin
         for (i = 11; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[10:0] = {Instruction[30:25],Instruction[24:21],Instruction[20]};
      end
      //S-immediate
      else if (Opcode == 7'b0100011) begin
         for (i = 11; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[10:0] = {Instruction[30:25],Instruction[11:8],Instruction[7]};
      end
      //B-immediate
      else if (Opcode == 7'b1100011) begin
         for (i = 12; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[11:0] = {Instruction[7],Instruction[30:25],Instruction[11:8],1'b0};
      end
      //J-immediate
      else if (Opcode == 7'b1101111) begin
         for (i = 20; i < 32; i=i+1) begin
            Immediate_Output[i] = Instruction[31];
         end
         Immediate_Output[19:0] = {Instruction[19:12],Instruction[20],Instruction[30:25],Instruction[24:21],1'b0};
      end
   end
endmodule