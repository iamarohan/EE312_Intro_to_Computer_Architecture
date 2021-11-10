`timescale 1ns/10ps

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
	
	reg [31:0] PC;
	wire [31:0] NXT_PC;
	wire [31:0] jalr_output;
	wire [31:0] I_MEM_DOUT;
	// ALU
	wire [2:0]  ALUControlOp;
	wire Bcond;
	wire [31:0] ALU_Output;

	// Simple_ALU
	wire [31:0] PC_Addr;

	// Immediate
	wire [31:0] Immediate_Output;

	// LW_byteset
	wire [31:0] LW_Output;

	// SW_byteset
	wire [31:0] SW_Output;

	// Multiplexer
	wire [31:0] mux_jmp_output;
	wire [31:0] mux_alusrc_output;
	wire [31:0] mux_memtoreg_output;
	wire [31:0] mux_zerofour_output;

	wire [31:0] PCALU_Output;
	wire BR_Output;
	wire JBR_Output;

	// Control signals
	wire ALUSrc;
	wire [2:0] ALUOp;
	wire Jump;
	wire Branch;
	wire JALR;
	wire [1:0] rdSel;
	wire MemRead;
	wire MemWrite;
	wire MemtoReg;
	wire RegWrite;

	initial begin
		NUM_INST <= 0;
		PC <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end

	always @(posedge CLK) begin
		I_MEM_ADDR <= NXT_PC[11:0];
	end

	Control control (
		.OPcode				(I_MEM_DI[6:0]),
		.ALUSrc 			(ALUSrc),
		.ALUOp				(ALUOp),
		.Jump 				(Jump),
		.Branch 			(Branch),
		.JALR 				(JALR),
		.rdSel				(rdSel),
		.MemRead 			(MemRead),
		.MemWrite 			(MemWrite),
		.MemtoReg			(MemtoReg),
		.RegWrite 			(RegWrite)
	);

	ALU_Control alu_control (
		.func7 				(I_MEM_DI[31:25]),
		.ALUOp 				(ALUOp),
		.ALUControlOp 		(ALUControlOp)
	);

	ALU alu (
		.A 					(RF_RD1),
		.B 					(mux_alusrc_output),
		.ALUControlOp		(ALUControlOp),
		.func3 				(I_MEM_DI[14:12]),
		.Bcond 				(Bcond),
		.Output 			(ALU_Output)
	);

	Simple_ALU simple_alu (
		.A 					(PC_Addr),
		.B 					(mux_memtoreg_output),
		.rdSel 				(rdSel),
		.Output 			(RF_WD)
	);

	Immediate immediate (
		.ALUOp 				(ALUOp),
		.Instruction 		(I_MEM_DI),
		.Immediate_Output	(Immediate_Output)
	);

	LW_byteset lw_byteset (
		.Input_data 		(D_MEM_DI),
		.func3 				(I_MEM_DI[14:12]),
		.Output_data 		(LW_Output)
	);

	SW_byteset sw_byteset (
		.Input_data 		(RF_RD2),
		.func3 				(I_MEM_DI[14:12]),
		.Output_data 		(SW_Output)
	);

	Data_BE data_be (
		.MemRead 			(MemRead),
		.MemWrite 			(MemWrite),
		.func3 				(I_MEM_DI[14:12]),
		.D_MEM_BE 			(D_MEM_BE)
	);

	Multiplexer mux_jmp (
		.input_one 			(PC+4),
		.input_two 			(PCALU_Output),
		.switch 			(JBR_Output),
		.out 				(mux_jmp_output)
	);

	
	Multiplexer mux_jalr (
		.input_one 			(mux_jmp_output),
		.input_two 			(ALU_Output),
		.switch 			(JALR),
		.out 				(jalr_output)
	);

	Multiplexer mux_alusrc (
		.input_one 			(RF_RD2),
		.input_two 			(Immediate_Output),
		.switch 			(ALUSrc),
		.out 				(mux_alusrc_output)
	);

	Multiplexer mux_memtoreg (
		.input_one 			(LW_Output),
		.input_two 			(ALU_Output),
		.switch 			(MemtoReg),
		.out 				(mux_memtoreg_output)
	);

	Multiplexer mux_zerofour (
		.input_one 			(0),
		.input_two 			(4),
		.switch 			(Jump),
		.out 				(mux_zerofour_output)
	);

	// bring data/control path done

	assign OUTPUT_PORT = RF_WD;

	assign I_MEM_CSN = (RSTn) ? 0:1;
	assign D_MEM_CSN = (RSTn) ? 0:1; 


	assign NXT_PC = (~RSTn) ? 0:jalr_output;

	assign RF_WE = RegWrite;
	assign RF_RA1 = I_MEM_DI[19:15];
	assign RF_RA2 = I_MEM_DI[24:20];
	assign RF_WA1 = I_MEM_DI[11:7];

	assign PC_Addr = PC+mux_zerofour_output;

	//next target adress logic
	assign BR_Output = Branch&&Bcond;
	assign JBR_Output = BR_Output||Jump;
	assign PCALU_Output = PC + Immediate_Output;
	//related to D_MEM
	assign D_MEM_DOUT  = SW_Output;
	assign D_MEM_ADDR = ALU_Output[11:0];
	assign D_MEM_WEN = (MemWrite)? 0 : 1;
	assign HALT = (I_MEM_DI == 32'h00008067) ? ((RF_RD1 == 32'h0000000c) ? 1: 0) : 0;
	
	always @ (posedge CLK) begin
	  //related to control
	  //related to R_MEM
	  if (!RSTn) begin
	     PC <=0;
	  end
	  PC <= NXT_PC;
	  
	end

endmodule //
