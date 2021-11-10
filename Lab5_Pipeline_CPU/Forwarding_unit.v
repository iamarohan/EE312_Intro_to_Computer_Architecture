module Forwarding_unit(
   EX_MEM_RegWrite,
   MEM_WB_RegWrite,
   EX_MEM_RegisterRd,
   MEM_WB_RegisterRd,
   ID_EX_RegisterRs1,
   ID_EX_RegisterRs2,
   IF_ID_RegisterRs1,
   IF_ID_RegisterRs2,
   ID_EX_ALUSrcB,
   ForwardA,
   ForwardB,
   Forward_bcondA,
   Forward_bcondB,
   SWForwardB
   );
   
   input wire EX_MEM_RegWrite;
   input wire MEM_WB_RegWrite;
   input wire [4:0] EX_MEM_RegisterRd;
   input wire [4:0] MEM_WB_RegisterRd;
   input wire [4:0] ID_EX_RegisterRs1;
   input wire [4:0] ID_EX_RegisterRs2;
   input wire [4:0] IF_ID_RegisterRs1;
   input wire [4:0] IF_ID_RegisterRs2;
   input wire [1:0] ID_EX_ALUSrcB;
   output reg [1:0] ForwardA;
   output reg [1:0] ForwardB;
   output reg [1:0] Forward_bcondA;
   output reg [1:0] Forward_bcondB;
   output reg [1:0] SWForwardB;

   initial begin
      ForwardA = 2'b00;
      ForwardB = 2'b00;
      Forward_bcondA = 2'b00;
      Forward_bcondB = 2'b00;
      SWForwardB = 2'b00;
   end

   always @(*) begin
      if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) begin
         ForwardA = 2'b10;
      end

      if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs1)) begin
         Forward_bcondA = 2'b01;
      end

      if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) begin
         ForwardB = 2'b10;
         SWForwardB = 2'b10;
      end

      if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs2)) begin
         Forward_bcondB = 2'b01;
      end

      // Mem hazard
      if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
      &&  !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) 
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs1))
      && (MEM_WB_RegisterRd == ID_EX_RegisterRs1)) begin
         ForwardA = 2'b01;
      end

      if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
      &&  !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) 
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs1))
      && (MEM_WB_RegisterRd == IF_ID_RegisterRs1)) begin
         Forward_bcondA = 2'b10;
      end

      if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
      && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs2))
      && (MEM_WB_RegisterRd == ID_EX_RegisterRs2)) begin 
         ForwardB = 2'b01;
         SWForwardB = 2'b01;
      end

      if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
      && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs2))
      && (MEM_WB_RegisterRd == IF_ID_RegisterRs2)) begin 
         Forward_bcondB = 2'b10;
      end

      if ((!(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs1))) &&

         (!(MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
         && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) 
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs1))
         && (MEM_WB_RegisterRd == ID_EX_RegisterRs1)))) begin
         ForwardA = 2'b00;
      end

      if ((!(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs1))) &&

         (!(MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
         &&  !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) 
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs1))
         && (MEM_WB_RegisterRd == IF_ID_RegisterRs1)))) begin
            Forward_bcondA = 2'b00;
         end

      if ((!(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs2))) &&

         (!(MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
         && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == ID_EX_RegisterRs2))
         && (MEM_WB_RegisterRd == ID_EX_RegisterRs2)))) begin
         ForwardB = 2'b00;
         SWForwardB = 2'b00;
      end

      if ((!(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs2))) &&

         (!(MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)
         &&  !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) 
         && (EX_MEM_RegisterRd == IF_ID_RegisterRs2))
         && (MEM_WB_RegisterRd == IF_ID_RegisterRs2)))) begin
            Forward_bcondB = 2'b00;
         end

      if (ID_EX_ALUSrcB == 2'b10) ForwardB = 2'b00;
   end 
endmodule