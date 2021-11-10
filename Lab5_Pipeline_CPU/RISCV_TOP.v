module RISCV_TOP (
   //General Signals
   input wire CLK,
   input wire RSTn,

   //I-Memory Signals
   output wire I_MEM_CSN,
   input wire [31:0] I_MEM_DI,//input from IM
   output reg [11:0] I_MEM_ADDR,//in byte address

   //D-Memory Signals
   output wire D_MEM_CSN,
   input wire [31:0] D_MEM_DI,
   output wire [31:0] D_MEM_DOUT,
   output wire [11:0] D_MEM_ADDR,//in word address
   output wire D_MEM_WEN,
   output wire [3:0] D_MEM_BE,

   //RegFile Signals
   output wire RF_WE,
   output wire [4:0] RF_RA1,
   output wire [4:0] RF_RA2,
   output wire [4:0] RF_WA1,
   input wire [31:0] RF_RD1,
   input wire [31:0] RF_RD2,
   output wire [31:0] RF_WD,
   output wire HALT,                   // if set, terminate program
   output reg [31:0] NUM_INST,         // number of instruction completed
   output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
   );

   reg  [31:0] PC;
   wire [31:0] NXT_PC;
   reg  [2:0]  HALT_reg;
   reg         HALT_trig;
   reg 		   stall_bcond;
   // Pipeline Register
   // IF_ID
   reg [31:0] IF_ID_Instruction;
   reg [31:0] IF_ID_Immediate_Output;
   reg [31:0] IF_ID_PC;
   wire [3:0] IF_ID_D_MEM_BE;

   // ID_EX
   reg       ID_EX_RegWrite;
   reg       ID_EX_MemWrite;
   reg       ID_EX_MemtoReg;
   reg [3:0] ID_EX_D_MEM_BE;
   reg       ID_EX_Bcond;
   reg [2:0] ID_EX_ALUOp;
   reg [4:0]    ID_EX_ALUControlOp;
   reg [31:0]    ID_EX_ALU1;
   reg [31:0]    ID_EX_ALU2;
   reg       ID_EX_ALUSrcA;
   reg [1:0]    ID_EX_ALUSrcB;
   reg [4:0]    ID_EX_RegisterRs1;
   reg [4:0]    ID_EX_RegisterRs2;
   reg [4:0]    ID_EX_RegisterRd;
   reg [31:0]    ID_EX_storeVal;
   reg 	  ID_EX_increment_NUM_INST;

   // EX_MEM
   reg       EX_MEM_RegWrite;
   reg       EX_MEM_MemWrite;
   reg       EX_MEM_MemtoReg;
   reg [3:0]    EX_MEM_D_MEM_BE;
   reg       EX_MEM_Bcond;
   reg [2:0]    EX_MEM_ALUOp;
   reg [4:0]    EX_MEM_RegisterRd;
   reg [31:0]    EX_MEM_ALU_Output;
   reg [31:0]    EX_MEM_storeVal;
   reg 	  EX_MEM_increment_NUM_INST;


   // MEM_WB
   reg       MEM_WB_RegWrite;
   reg       MEM_WB_MemtoReg;
   reg       MEM_WB_Bcond;
   reg [2:0]    MEM_WB_ALUOp;
   reg [4:0]    MEM_WB_RegisterRd;
   reg [31:0]    MEM_WB_ALU_Output;
   reg [31:0]    MEM_WB_D_MEM_DI;
   reg 	  MEM_WB_increment_NUM_INST;

// Pipeline Register End

   // Control signals
   wire       RegWrite;
   wire       MemWrite;
   wire       MemtoReg;
   wire       Bcond;
   wire [2:0]    ALUOp;
   wire [4:0]    ALUControlOp;
   wire       ALUSrcA;
   wire [1:0]    ALUSrcB;
   wire 	 JALR_mul;
   wire       PCWrite;
   wire       Hazard;
   wire 	  increment_NUM_INST;

   // ALU
   wire [31:0] ALU_Output;

   // ALU_Control

   // Forwarding_unit
   wire [1:0]    ForwardA;
   wire [1:0]    ForwardB;
   wire [1:0]    Forward_bcondA;
   wire [1:0]    Forward_bcondB;
   wire [1:0]	 SWForwardB;

   // Hazard_unit

   // BTB
   wire       BTB_bcond;
   wire [31:0] branch_addr;
   wire [31:0] BTB_PC;
   wire       BTB_isBranched;
   reg       BTB_isBranched_register;

   // Immediate
   wire [31:0] Immediate_Output;

   // Multiplexer
   wire [31:0] mux_alusrcA_output;
   wire [31:0] mux_jal_pc_output;
   wire [31:0] mux_jalr_pc_output;
   wire [31:0] mux_MemtoReg_output;

   // Multiplexer3to1
   wire [31:0] mux3to1_alusrcB_output;
   wire [31:0] mux3to1_forwardA_output;
   wire [31:0] mux3to1_forwardB_output;
   wire [31:0] mux3to1_forwardA_bcond_output;
   wire [31:0] mux3to1_forwardB_bcond_output;
   wire [31:0] mux3to1_SWforwardB_output;

   // PC
   wire       jal_gate;
   wire [31:0] JALR_target_addr;

   initial begin
      NUM_INST <= 0;
      PC <= 0;
      HALT_trig <= 0;
      HALT_reg <= 3'b100;
      stall_bcond <= 0;
   end

   Control control (
      .OPcode          (IF_ID_Instruction[6:0]),
      .ALUOp             (ALUOp),
      .ALUSrcA          (ALUSrcA),
      .ALUSrcB          (ALUSrcB),
      .RegWrite          (RegWrite),
      .D_MEM_BE          (IF_ID_D_MEM_BE),
      .MemWrite          (MemWrite),
      .MemtoReg          (MemtoReg),
      .JALR_mul          (JALR_mul),
      .increment_NUM_INST(increment_NUM_INST)
   );

   ALU_Control alu_control (
      .ALUOp             (ALUOp),
      .func3             (IF_ID_Instruction[14:12]),
      .func7             (IF_ID_Instruction[31:25]),
      .ALUControlOp       (ALUControlOp)
   );

   ALU alu (
      .A                (mux3to1_forwardA_output),
      .B                (mux3to1_forwardB_output),
      .ALUControlOp       (ID_EX_ALUControlOp),
      .Output          (ALU_Output)
   );

   Forwarding_unit forwarding_unit (
      .EX_MEM_RegWrite    (EX_MEM_RegWrite),
      .MEM_WB_RegWrite    (MEM_WB_RegWrite),
      .EX_MEM_RegisterRd    (EX_MEM_RegisterRd),
      .MEM_WB_RegisterRd    (MEM_WB_RegisterRd),
      .ID_EX_RegisterRs1    (ID_EX_RegisterRs1),
      .ID_EX_RegisterRs2    (ID_EX_RegisterRs2),
      .IF_ID_RegisterRs1	(IF_ID_Instruction[19:15]),
      .IF_ID_RegisterRs2 	(IF_ID_Instruction[24:20]),
      .ID_EX_ALUSrcB      (ID_EX_ALUSrcB),
      .ForwardA          (ForwardA),
      .ForwardB          (ForwardB),
      .Forward_bcondA    (Forward_bcondA),
      .Forward_bcondB    (Forward_bcondB),
      .SWForwardB 		 (SWForwardB)
   );

   Hazard_unit hazard_unit (
   	  .CLK					(CLK),
   	  .I_MEM_DI 			(I_MEM_DI),
   	  .IF_ID_Instruction 	(IF_ID_Instruction),
   	  .RegWrite 			(RegWrite),
   	  .MemWrite 			(MemWrite),
   	  .JALR_mul 			(JALR_mul),
   	  .ID_EX_MemWrite 		(ID_EX_MemWrite),
   	  .IF_ID_RegisterRd 	(IF_ID_Instruction[11:7]),
   	  .ID_EX_RegisterRd 	(ID_EX_RegisterRd),
   	  .I_MEM_DI_RegisterRs1 (I_MEM_DI[19:15]),
   	  .I_MEM_DI_RegisterRs2 (I_MEM_DI[24:20]),
   	  .prev_mul				(BTB_isBranched_register),
   	  .bcond 				(BTB_bcond),
   	  .PCWrite 				(PCWrite),
   	  .Hazard 				(Hazard)
   );

   BTB btb (
      .CLK             (CLK),
      .RSTn            (RSTn),
      .PC              (PC),
      .bcond           (BTB_bcond),
      .prev_mul        (BTB_isBranched_register),
      .Instruction     (I_MEM_DI),
      .IF_ID_PC        (IF_ID_PC),
      .branch_addr     (branch_addr),
      .IF_ID_Instruction (IF_ID_Instruction),
      .BTB_PC          (BTB_PC),
      .mul             (BTB_isBranched)
   );

   Immediate immediate (
      .Instruction       (I_MEM_DI),
      .Immediate_Output    (Immediate_Output)
   );

   Multiplexer mux_alusrcA (
      .input_one          (IF_ID_PC),
      .input_two          (RF_RD1),
      .switch          (ALUSrcA),
      .out             (mux_alusrcA_output)
   );

   Multiplexer3to1 mux3to1_alusrcB (
      .input_one          (RF_RD2),
      .input_two           (4),
      .input_three       (IF_ID_Immediate_Output),
      .switch          (ALUSrcB),
      .out             (mux3to1_alusrcB_output)
   );

   Multiplexer3to1 mux3to1_forwardA (
      .input_one          (ID_EX_ALU1),
      .input_two           (mux_MemtoReg_output),
      .input_three       (EX_MEM_ALU_Output),
      .switch          (ForwardA),
      .out             (mux3to1_forwardA_output)
   );

   Multiplexer3to1 mux3to1_forwardB (
      .input_one          (ID_EX_ALU2),
      .input_two           (mux_MemtoReg_output),
      .input_three       (EX_MEM_ALU_Output),
      .switch          (ForwardB),
      .out             (mux3to1_forwardB_output)
   );

   Multiplexer3to1 mux3to1_SWforwardB (
      .input_one          (ID_EX_storeVal),
      .input_two          (mux_MemtoReg_output),
      .input_three        (EX_MEM_ALU_Output),
      .switch             (SWForwardB),
      .out                (mux3to1_SWforwardB_output)
   );

   Multiplexer3to1 mux3to1_forwardA_bcond (
      .input_one          (RF_RD1),
      .input_two           (EX_MEM_ALU_Output),
      .input_three       (mux_MemtoReg_output),
      .switch          (Forward_bcondA),
      .out             (mux3to1_forwardA_bcond_output)
   );

   Multiplexer3to1 mux3to1_forwardB_bcond (
      .input_one          (RF_RD2),
      .input_two           (EX_MEM_ALU_Output),
      .input_three       (mux_MemtoReg_output),
      .switch          (Forward_bcondB),
      .out             (mux3to1_forwardB_bcond_output)
   );

   Multiplexer mux_MemtoReg (
      .input_one          (MEM_WB_ALU_Output),
      .input_two          (MEM_WB_D_MEM_DI),
      .switch          (MEM_WB_MemtoReg),
      .out             (mux_MemtoReg_output)
   );

   Multiplexer mux_jal_pc (
      .input_one          (BTB_PC),
      .input_two          (branch_addr),
      .switch          (jal_gate),
      .out             (mux_jal_pc_output)
   );

   Multiplexer mux_jalr_pc (
      .input_one          (mux_jal_pc_output),
      .input_two          (JALR_target_addr),
      .switch          (JALR_mul),
      .out             (mux_jalr_pc_output)
   );

   always @(*) begin
      I_MEM_ADDR <=  PC & 32'hfff;
   end

   // Only allow for NUM_INST
   always @ (negedge CLK) begin
      if (RSTn && MEM_WB_increment_NUM_INST) NUM_INST <= NUM_INST + 1;
   end

   // OUTPUT_PORT
   assign OUTPUT_PORT = (MEM_WB_ALUOp == 3'b011) ? ((MEM_WB_Bcond) ? 1 : 0) :
                   ((MEM_WB_ALUOp == 3'b010) ? MEM_WB_ALU_Output : RF_WD);

   // TODO: implement
   assign I_MEM_CSN = (RSTn) ? 0 : 1;
   assign D_MEM_CSN = (RSTn) ? 0 : 1;

   // Register
   assign RF_WE = MEM_WB_RegWrite;
   assign RF_RA1 = IF_ID_Instruction[19:15];
   assign RF_RA2 = IF_ID_Instruction[24:20];
   assign RF_WA1 = MEM_WB_RegisterRd;
   assign RF_WD = mux_MemtoReg_output;
   // D_MEM
   assign D_MEM_DOUT = EX_MEM_storeVal;
   assign D_MEM_ADDR = EX_MEM_ALU_Output;
   assign D_MEM_WEN = EX_MEM_MemWrite;
   assign D_MEM_BE = EX_MEM_D_MEM_BE;

   assign HALT = !(HALT_reg[2] || HALT_reg[1] || HALT_reg[0]);

   // BTB
   assign BTB_bcond  = (stall_bcond) ? 0:
   					 (IF_ID_Instruction[6:0] == 7'b1100011) ? (
                     (IF_ID_Instruction[14:12] == 3'b000) ? (mux3to1_forwardA_bcond_output == mux3to1_forwardB_bcond_output) : (
                     (IF_ID_Instruction[14:12] == 3'b001) ? (mux3to1_forwardA_bcond_output != mux3to1_forwardB_bcond_output) : (
                     (IF_ID_Instruction[14:12] == 3'b100) ? ($signed(mux3to1_forwardA_bcond_output) < $signed(mux3to1_forwardB_bcond_output)) : (
                     (IF_ID_Instruction[14:12] == 3'b101) ? ($signed(mux3to1_forwardA_bcond_output) >= $signed(mux3to1_forwardB_bcond_output)) : (
                     (IF_ID_Instruction[14:12] == 3'b110) ? (mux3to1_forwardA_bcond_output < mux3to1_forwardB_bcond_output) : (
                     (IF_ID_Instruction[14:12] == 3'b111) ? (mux3to1_forwardA_bcond_output >= mux3to1_forwardB_bcond_output) : 0
                  		)))))) : 0;
   assign branch_addr = PC + Immediate_Output;

   // PC
   assign jal_gate = (I_MEM_DI[6:0] == 7'b1101111) ? (~Hazard) : 0;

   assign JALR_target_addr = RF_RD1 + Immediate_Output;
   assign JALR_target_addr = {JALR_target_addr[31:1],1'b0};

   // NXT_PC
   assign NXT_PC = (RSTn) ? (mux_jalr_pc_output) : 0;

   always @(posedge CLK) begin
      // SET PC VALUE
      stall_bcond <= 0;
      if (PCWrite) begin
         PC <= NXT_PC;      // using PCWRITE
      end
      if ((I_MEM_DI == 32'h00008067) && 
      ((IF_ID_Instruction == 32'h00c00093) || (RF_RD1 == 32'h0000000c))) HALT_trig <= 1'b1;

      if (HALT_trig) begin
         HALT_reg <= HALT_reg - 1;
      end
      // IF_ID pipeline register
      IF_ID_Instruction <= I_MEM_DI;
      IF_ID_Immediate_Output <= Immediate_Output;
      IF_ID_PC <= PC;
      //Control signals
      
      ID_EX_RegWrite <= RegWrite;
      ID_EX_MemWrite <= MemWrite;
      ID_EX_MemtoReg <= MemtoReg;
      ID_EX_D_MEM_BE <= IF_ID_D_MEM_BE;
      ID_EX_ALUOp <= ALUOp;
      ID_EX_ALUControlOp <= ALUControlOp;
      ID_EX_ALUSrcA <= ALUSrcA;
      ID_EX_ALUSrcB <= ALUSrcB;
      ID_EX_increment_NUM_INST <= increment_NUM_INST;

      if (Hazard) IF_ID_Instruction <= 32'h00000000;
      
      // ID_EX pipeline register
      ID_EX_Bcond <= BTB_bcond;
      ID_EX_ALU1 <= mux_alusrcA_output;
      ID_EX_ALU2 <= mux3to1_alusrcB_output;
      ID_EX_RegisterRs1 <= IF_ID_Instruction[19:15];
      ID_EX_RegisterRs2 <= IF_ID_Instruction[24:20];
      ID_EX_RegisterRd <= IF_ID_Instruction[11:7];
      ID_EX_storeVal <= RF_RD2;
      

      // EX_MEM pipeline register
      EX_MEM_RegWrite <= ID_EX_RegWrite;
      EX_MEM_MemWrite <= ID_EX_MemWrite;
      EX_MEM_MemtoReg <= ID_EX_MemtoReg;
      EX_MEM_D_MEM_BE <= ID_EX_D_MEM_BE;
      EX_MEM_Bcond <= ID_EX_Bcond;
      EX_MEM_ALUOp <= ID_EX_ALUOp;
      EX_MEM_RegisterRd <= ID_EX_RegisterRd;
      EX_MEM_ALU_Output <= ALU_Output;
      EX_MEM_storeVal <= mux3to1_SWforwardB_output;
      EX_MEM_increment_NUM_INST <= ID_EX_increment_NUM_INST;

      // MEM_WB pipeline register
      MEM_WB_RegWrite <= EX_MEM_RegWrite;
      MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
      MEM_WB_Bcond <= EX_MEM_Bcond;
      MEM_WB_ALUOp <= EX_MEM_ALUOp;
      MEM_WB_RegisterRd <= EX_MEM_RegisterRd;
      MEM_WB_ALU_Output <= EX_MEM_ALU_Output;
      MEM_WB_D_MEM_DI <= D_MEM_DI;
      MEM_WB_increment_NUM_INST <= EX_MEM_increment_NUM_INST;

      BTB_isBranched_register <= BTB_isBranched;
	end
endmodule 
