`define JAL             7'b1101111
`define JALR            7'b1100111
`define Branch          7'b1100011
`define LW              7'b0000011
`define SW              7'b0100011
`define I_type          7'b0010011
`define R_type          7'b0110011

`define ALUOp_JAL       3'b101
`define ALUOp_JALR      3'b111
`define ALUOp_Branch    3'b011
`define ALUOp_LW        3'b110
`define ALUOp_SW        3'b010
`define ALUOp_I         3'b001
`define ALUOp_R         3'b000

module Control(OPcode,ALUOp,ALUSrcA,ALUSrcB,RegWrite,D_MEM_BE,MemWrite,MemtoReg,JALR_mul,increment_NUM_INST);
   // input signals
   input [6:0] OPcode;
   // output control signals
   output reg [2:0] ALUOp;
   output reg ALUSrcA;
   output reg [1:0] ALUSrcB;
   output reg RegWrite;
   output reg [3:0] D_MEM_BE;
   output reg MemWrite;
   output reg MemtoReg;
   output reg JALR_mul;
   output reg increment_NUM_INST;

   always @(*) begin
      //JAL
      if (OPcode == `JAL) begin
         ALUOp = `ALUOp_JAL;
         ALUSrcA = 1'b0;
         ALUSrcB = 2'b01;
         RegWrite = 1'b1;
         D_MEM_BE = 4'b0000;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b1;
      end
      //JALR
      else if (OPcode == `JALR) begin
         ALUOp = `ALUOp_JALR;
         ALUSrcA = 1'b0;
         ALUSrcB = 2'b01;
         RegWrite = 1'b1;
         D_MEM_BE = 4'b0000;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b1;
         increment_NUM_INST = 1'b1;
      end
      //BEQ,BNE,BLT,BGE,BLTU,BGEU
      else if (OPcode == `Branch) begin
         ALUOp = `ALUOp_Branch;
         ALUSrcA = 1'b1;
         ALUSrcB = 2'b10;
         RegWrite = 1'b0;
         D_MEM_BE = 4'b0000;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b1;
      end
      //LW
      else if (OPcode == `LW) begin
         ALUOp = `ALUOp_LW;
         ALUSrcA = 1'b1;
         ALUSrcB = 2'b10;
         RegWrite = 1'b1;
         D_MEM_BE = 4'b1111;
         MemWrite = 1'b1;
         MemtoReg = 1'b1;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b1;
      end
      //SW
      else if (OPcode == `SW) begin
         ALUOp = `ALUOp_SW;
         ALUSrcA = 1'b1;
         ALUSrcB = 2'b10;
         RegWrite = 1'b0;
         D_MEM_BE = 4'b1111;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b1;
      end
      //ADDI,SLTI,SLTIU,XORI,ORI,ANDI,SLLI,SRLI,SRAI
      else if (OPcode == `I_type) begin
         ALUOp = `ALUOp_I;
         ALUSrcA = 1'b1;
         ALUSrcB = 2'b10;
         RegWrite = 1'b1;
         D_MEM_BE = 4'b0000;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b1;
      end
      //ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA,OR,AND
      else if (OPcode == `R_type) begin
         ALUOp = `ALUOp_R;
         ALUSrcA = 1'b1;
         ALUSrcB = 2'b00;
         RegWrite = 1'b1;
         D_MEM_BE = 4'b0000;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b1;
      end
      else if (OPcode == 7'b0000000) begin
         ALUOp = 3'b000;
         ALUSrcA = 1'b0;
         ALUSrcB = 2'b00;
         RegWrite = 1'b0;
         D_MEM_BE = 4'b0000;
         MemWrite = 1'b0;
         MemtoReg = 1'b0;
         JALR_mul = 1'b0;
         increment_NUM_INST = 1'b0;
      end
   end

endmodule