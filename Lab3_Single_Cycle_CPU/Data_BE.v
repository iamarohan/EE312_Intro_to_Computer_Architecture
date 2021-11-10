module Data_BE(MemRead,MemWrite,func3,D_MEM_BE);
   input wire MemRead;
   input wire MemWrite;
   input wire [2:0] func3;
   output reg [3:0] D_MEM_BE;

   always @(*) begin
      if (MemRead) begin
         if ((func3 == 3'b000) || (func3 == 3'b100)) begin
            D_MEM_BE = 4'b0001;
         end
         if ((func3 == 3'b001)||func3==3'b101) begin
            D_MEM_BE = 4'b0011;
         end
         if (func3 == 3'b010) begin
            D_MEM_BE = 4'b1111;
         end
      end
      else if (MemWrite) begin
         if ((func3 == 3'b000)) begin
            D_MEM_BE = 4'b0001;
         end
         if ((func3 == 3'b001)) begin
            D_MEM_BE = 4'b0011;
         end
         if (func3 == 3'b010) begin
            D_MEM_BE = 4'b1111;
         end
      end
      else begin
         D_MEM_BE = 4'b0000;
      end
   end
endmodule