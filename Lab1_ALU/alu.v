`timescale 1ns / 100ps

// Arithmetic
`define   OP_ADD   4'b0000
`define   OP_SUB   4'b0001
// Bitwise Boolean operation
`define   OP_AND   4'b0010
`define   OP_OR    4'b0011
`define   OP_NAND  4'b0100
`define   OP_NOR   4'b0101
`define   OP_XOR   4'b0110
`define   OP_XNOR  4'b0111
// Logic
`define   OP_ID   4'b1000
`define   OP_NOT  4'b1001

// Shift
`define   OP_LRS  4'b1010
`define   OP_ARS  4'b1011
`define   OP_RR   4'b1100
`define   OP_LLS  4'b1101
`define   OP_ALS  4'b1110
`define   OP_RL   4'b1111

module ALU(A,B,OP,C,Cout);

   input [15:0]A;
   input [15:0]B;
   input [3:0]OP;
   output reg [15:0]C;
   output reg Cout;
   reg [15:0]sub;
   reg a, b, c, ssub;

   // addition
   always @(*) begin
   Cout = 1'b0;
   if (OP == `OP_ADD) begin
   C = A+B;
   a = A[15];
   b = B[15];
   c = C[15];
      if (a && b) begin
         if (c==0) begin
         Cout = 1'b1;
         end
      end
      if (~a && ~b) begin
         if (c==1) begin
         Cout = 1'b1;
         end
      end
   end

   // subtraction
   else if (OP == `OP_SUB) begin
   sub = ~B+1;

   a = A[15];
   C = A+sub;
   ssub = sub[15];
   c = C[15];
      if (a && ssub) begin
         if (c==0) begin
         Cout = 1'b1;
         end
      end
      if (~a && ~ssub) begin
         if (c==1) begin
         Cout = 1'b1;
         end
      end
   end

   // and
   else if (OP == `OP_AND) begin
   C = A&B;
   end

   //or
   else if (OP == `OP_OR) begin
   C = A|B;
   end

   //nand
   else if (OP == `OP_NAND) begin
   C = ~(A&B);
   end

   //nor
   else if (OP == `OP_NOR) begin
   C = ~(A|B);
   end

   //xor
   else if (OP == `OP_XOR) begin
   C = A^B;
   end

   //xnor
   else if (OP == `OP_XNOR) begin
   C = A~^B;
   end

   //identity
   else if (OP == `OP_ID) begin
   C = A;
   end

   //16-bit not
   else if (OP == `OP_NOT) begin
   C = ~A;
   end

   //logical right shift
   else if (OP == `OP_LRS) begin
   C = A>>1;
   end

   //arithmetric right shift
   else if (OP == `OP_ARS) begin
   a = A[15];
   C = A>>>1;
   C[15] = a;
   
   end

   //rotate right
   else if (OP == `OP_RR) begin
   C = {A[0],A[15:1]};
   end

   //logical right shift
   else if (OP == `OP_LLS) begin
   C = A<<1;
   end

   //arithmetric left shift
   else if (OP == `OP_ALS) begin
   C = A<<<1;
   end

   //rotate left
   else if (OP == `OP_RL) begin
   C = {A[14:0],A[15]};
   end
   end
endmodule