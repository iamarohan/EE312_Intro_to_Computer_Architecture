`define JAL             7'b1101111
`define JALR            7'b1100111
`define Branch          7'b1100011
`define LW              7'b0000011
`define SW              7'b0100011
`define I_type          7'b0010011
`define R_type          7'b0110011

module Hazard_unit(
   CLK,
   I_MEM_DI,
   IF_ID_Instruction,
   RegWrite,
   MemWrite,
   JALR_mul,
   ID_EX_MemWrite,
   IF_ID_RegisterRd,
   ID_EX_RegisterRd,
   I_MEM_DI_RegisterRs1,
   I_MEM_DI_RegisterRs2,
   prev_mul,
   bcond,
   PCWrite,
   Hazard
);

   input CLK;
   input wire [31:0] I_MEM_DI;
   input wire [31:0] IF_ID_Instruction;
   input wire RegWrite;
   input wire MemWrite;
   input wire JALR_mul;
   input wire ID_EX_MemWrite;
   input wire [4:0] IF_ID_RegisterRd;
   input wire [4:0] ID_EX_RegisterRd;
   input wire [4:0] I_MEM_DI_RegisterRs1;
   input wire [4:0] I_MEM_DI_RegisterRs2;
   input wire prev_mul;
   input wire bcond;
   output wire PCWrite;
   output wire Hazard;

   reg [1:0] PCWrite_count;
   reg [1:0] Hazard_count;
   initial begin
      PCWrite_count = 2'b00;
      Hazard_count = 2'b00;
   end


   always @(negedge CLK) begin
      if (Hazard_count > 2'b00) begin 
         Hazard_count = Hazard_count - 2'b01;
      end
      if (PCWrite_count > 2'b00) begin 
         PCWrite_count = PCWrite_count - 2'b01;
      end
      if (JALR_mul) begin
         Hazard_count = 2'b01;
      end
      if (MemWrite && ((I_MEM_DI[6:0] == `I_type) ||
         (I_MEM_DI[6:0] == `R_type)||(I_MEM_DI[6:0] == `SW)) &&
         (IF_ID_RegisterRd != 0) &&
         (IF_ID_RegisterRd == I_MEM_DI_RegisterRs1)) begin
            PCWrite_count = 2'b01;
            Hazard_count = 2'b01;
         end

      if (MemWrite && (IF_ID_RegisterRd != 0) &&
         (IF_ID_RegisterRd == I_MEM_DI_RegisterRs2) &&
         ((I_MEM_DI[6:0] == `R_type)||(I_MEM_DI[6:0] == `SW))) begin
            PCWrite_count = 2'b01;
            Hazard_count = 2'b01;
         end

      if (I_MEM_DI[6:0] == `Branch) begin
         if (RegWrite && (IF_ID_RegisterRd != 0) &&
            (IF_ID_RegisterRd == I_MEM_DI_RegisterRs1)||
            (IF_ID_RegisterRd == I_MEM_DI_RegisterRs2)) begin
               PCWrite_count = 2'b01;
               Hazard_count = 2'b01;
            end

         if (MemWrite && (IF_ID_RegisterRd != 0) &&
            ((IF_ID_RegisterRd == I_MEM_DI_RegisterRs1)||
            (IF_ID_RegisterRd == I_MEM_DI_RegisterRs2))) begin
               PCWrite_count = 2'b10;
               Hazard_count = 2'b10;
            end

         if (ID_EX_MemWrite && (ID_EX_RegisterRd != 0) &&
            ((ID_EX_RegisterRd == I_MEM_DI_RegisterRs1)||
            (ID_EX_RegisterRd == I_MEM_DI_RegisterRs2))) begin
               PCWrite_count = 2'b01;
               Hazard_count = 2'b01;
            end
      end
      if (IF_ID_Instruction[6:0] == `Branch) begin
   		if (!bcond && prev_mul) begin
   	    	Hazard_count = 2'b01;
   		end

   	 	if (bcond && !prev_mul) begin
   	    	Hazard_count = 2'b01;
   		end
      end
   end

   assign PCWrite = (PCWrite_count == 2'b00) ? 1:0;
   assign Hazard = (Hazard_count == 2'b00) ? 0:1;

endmodule
