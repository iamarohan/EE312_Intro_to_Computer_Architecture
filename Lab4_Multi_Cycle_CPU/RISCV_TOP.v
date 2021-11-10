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
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	reg [31:0]PC;
	wire [31:0]NXT_PC;
	// multiplexer output signals
	wire [31:0] MemtoReg_output;
	wire [31:0] ALUSrcA_output;
	wire [31:0] ALUSrcB_output;
	wire [31:0] PcSource_output;
	//control signals
	wire [1:0]PCSource;
	wire [2:0]ALUOp;
	wire ALUSrcA;
	wire [1:0]ALUSrcB;
	wire RegWrite;
	wire PCWritecond;
	wire PCWrite;
	wire MemWrite;
	wire MemtoReg;
	wire Inst_plus;
	wire [3:0] returnState;
	// latched signals
	reg [31:0] inst_reg;
	reg [31:0] rs1_out_reg;
	reg [31:0] rs2_out_reg;
	reg [31:0] ALU_out_reg;
	//reg [31:0] d_mem_out_reg;
	//others
	wire [31:0] ALU_out;
	wire [31:0] imm_out;
	wire [4:0] ALUControlOp;
	wire Bcond;
	wire [31:0]ALU_out_JALR;
	wire PCWritecond_out;
	wire PCWrite_out;


	initial begin 
		NUM_INST = 0;
		PC = 0;

		$dumpfile("maro_sort.vcd");
		$dumpvars(0, RISCV_TOP);
	end

	always @ (*) begin
		I_MEM_ADDR <= PC & 32'hfff;
		rs1_out_reg <= RF_RD1;
		rs2_out_reg <= RF_RD2;
	end

	always @ (negedge CLK) begin
		if (RSTn && Inst_plus) NUM_INST = NUM_INST + 1;
	end

	Control control (
		.OPcode				(I_MEM_DI[6:0]),
		.CLK				(CLK),
		.RSTn				(RSTn),
		.PCSource 			(PCSource),
		.ALUOp  			(ALUOp),
		.ALUSrcA 			(ALUSrcA),
		.ALUSrcB 			(ALUSrcB),
		.RegWrite			(RegWrite),
		.PCWritecond 		(PCWritecond),
		.PCWrite 			(PCWrite),
		.D_MEM_BE 			(D_MEM_BE),
		.MemWrite			(MemWrite),
		.MemtoReg 			(MemtoReg),
		.Inst_plus 			(Inst_plus),
		.returnState 		(returnState)
	);
	ALU_Control alu_control (
		.ALUOp 				(ALUOp),
		.func3 				(I_MEM_DI[14:12]),
		.func7 				(I_MEM_DI[31:25]),
		.ALUControlOp 		(ALUControlOp)
	);
	Immediate immediate (
		.Instruction 		(I_MEM_DI),
		.Immediate_Output	(imm_out)
	);
	ALU alu (
		.A 					(ALUSrcA_output),
		.B 					(ALUSrcB_output),
		.ALUControlOp		(ALUControlOp),
		.Bcond 				(Bcond),
		.Output 			(ALU_out)
	);
	Multiplexer MUX_MemtoReg (
		.input_one 			(ALU_out_reg),
		.input_two 			(D_MEM_DI),
		.switch 			(MemtoReg),
		.out 				(RF_WD)
	);
	Multiplexer MUX_ALUSrcA (
		.input_one 			(PC),
		.input_two 			(rs1_out_reg),
		.switch 			(ALUSrcA),
		.out 				(ALUSrcA_output)
	);
	Multiplexer3to1 MUX_ALUSrcB (
		.input_one 			(rs2_out_reg),
		.input_two 			(4),
		.input_three		(imm_out),
		.switch 			(ALUSrcB),
		.out 				(ALUSrcB_output)
	);
	Multiplexer3to1 MUX_PCSource (
		.input_one 			(ALU_out),
		.input_two 			(ALU_out_reg),
		.input_three		(ALU_out_JALR),
		.switch 			(PCSource),
		.out 				(PcSource_output)
	);
	assign OUTPUT_PORT = (PCWritecond) ? ((Bcond) ? 1:0) :
							(Inst_plus && (returnState == 4'b1011)) ? ALU_out_reg : RF_WD; 
	assign I_MEM_CSN = (RSTn) ? 0:1;
	assign D_MEM_CSN = (RSTn) ? 0:1; 
	assign NXT_PC = (RSTn) ? (((returnState == 4'b0110) && ~Bcond) ? PC+4 : PcSource_output) : 0;
	//RF block signals
	assign RF_WE = RegWrite;
	assign RF_RA1 = I_MEM_DI[19:15];
	assign RF_RA2 = I_MEM_DI[24:20];
	assign RF_WA1 = I_MEM_DI[11:7];
	// PClatch logic
	assign PCWritecond_out = PCWritecond && Bcond;
	assign PCWrite_out = PCWritecond_out || PCWrite;
	// D_MEM_Logic
	assign D_MEM_DOUT = rs2_out_reg;
	assign D_MEM_ADDR = ALU_out_reg & 32'h3fff;
	assign D_MEM_WEN = MemWrite;

	assign ALU_out_JALR = {ALU_out_reg[31:1],1'b0};
	assign HALT = (I_MEM_DI == 32'h00008067) ? 
	((RF_RD1 == 32'h0000000c) ? 1: ((inst_reg == 32'h00c00093) ? 1:0)) : 0;

	always @(posedge CLK) begin
		if (PCWrite_out) PC <= NXT_PC;
		ALU_out_reg <= ALU_out;
		//d_mem_out_reg = D_MEM_DI;
		inst_reg <= I_MEM_DI;
	end

	
endmodule //
