// ALUOp signal types
`define   OP_R      3'b000
`define   OP_I      3'b001
`define   OP_S      3'b010
`define   OP_B      3'b011
`define   OP_ADD    3'b100 // 무조건 add
`define   OP_J      3'b101
`define   OP_IL     3'b110 // Meaning Load instructions in I-type
`define   OP_JALR   3'b111 // Meaning JALR instruction in I-type

`define   ADD       5'b00000
`define   SUB       5'b00001
`define   SLL       5'b00010
`define   SLT       5'b00011
`define   SLTU      5'b00100
`define   XOR       5'b00101
`define   SRL       5'b00110
`define   SRA       5'b00111
`define   OR        5'b01000
`define   AND       5'b01001
`define   JALR      5'b01010
`define   BEQ       5'b01011
`define   BNE       5'b01100
`define   BLT       5'b01101
`define   BGE       5'b01110
`define   BLTU      5'b01111
`define   BGEU      5'b10000

module ALU_Control(ALUOp,func3,func7,ALUControlOp);
	input [2:0] ALUOp;
	input [2:0] func3;
	input [6:0] func7;
	output reg [4:0]ALUControlOp;

	always @(*) begin
		//R-type computation
		if (ALUOp == `OP_R) begin
			if ((func3 == 3'b000) && (func7 == 7'b0000000)) begin
				ALUControlOp = `ADD;
			end
			else if ((func3 == 3'b000) && (func7 == 7'b0100000)) begin
				ALUControlOp = `SUB;
			end
			else if ((func3 == 3'b001) && (func7 == 7'b0000000)) begin
				ALUControlOp = `SLL;
			end
			else if ((func3 == 3'b010) && (func7 == 7'b0000000)) begin
				ALUControlOp = `SLT;
			end
			else if ((func3 == 3'b011) && (func7 == 7'b0000000)) begin
				ALUControlOp = `SLTU;
			end
			else if ((func3 == 3'b100) && (func7 == 7'b0000000)) begin
				ALUControlOp = `XOR;
			end
			else if ((func3 == 3'b101) && (func7 == 7'b0000000)) begin
				ALUControlOp = `SRL;
			end
			else if ((func3 == 3'b101) && (func7 == 7'b0100000)) begin
				ALUControlOp = `SRA;
			end
			else if ((func3 == 3'b110) && (func7 == 7'b0000000)) begin
				ALUControlOp = `OR;
			end
			else if ((func3 == 3'b111) && (func7 == 7'b0000000)) begin
				ALUControlOp = `AND;
			end
		end
		// I type computation
		else if (ALUOp == `OP_I) begin
			if (func3 == 3'b000) begin
				ALUControlOp = `ADD;
			end
			else if (func3 == 3'b010) begin
				ALUControlOp = `SLT;
			end
			else if (func3 == 3'b011) begin
				ALUControlOp = `SLTU;
			end
			else if (func3 == 3'b100) begin
				ALUControlOp = `XOR;
			end
			else if (func3 == 3'b110) begin
				ALUControlOp = `OR;
			end
			else if (func3 == 3'b111) begin
				ALUControlOp = `AND;
			end
			else if ((func3 == 3'b001) && (func7 == 7'b0000000)) begin
				ALUControlOp = `SLL;
			end
			else if ((func3 == 3'b101) && (func7 == 7'b0000000)) begin
				ALUControlOp = `SRL;
			end
			else if ((func3 == 3'b101) && (func7 == 7'b0100000)) begin
				ALUControlOp = `SLT;
			end
		end
		// S type
		else if (ALUOp == `OP_S) begin
			ALUControlOp = `ADD;
		end
		// B type
		else if (ALUOp == `OP_B) begin
			if (func3 == 3'b000) begin
				ALUControlOp = `BEQ;
			end
			else if (func3 == 3'b001) begin
				ALUControlOp = `BNE;
			end
			else if (func3 == 3'b100) begin
				ALUControlOp = `BLT;
			end
			else if (func3 == 3'b101) begin
				ALUControlOp = `BGE;
			end
			else if (func3 == 3'b110) begin
				ALUControlOp = `BLTU;
			end
			else if (func3 == 3'b111) begin
				ALUControlOp = `BGEU;
			end
		end
		// add
		else if (ALUOp == `OP_ADD) begin
			ALUControlOp = `ADD;
		end
		// J-type
		else if (ALUOp == `OP_J) begin
			ALUControlOp = `ADD;
		end
		// Load
		else if (ALUOp == `OP_IL) begin
			ALUControlOp = `ADD;
		end
		// JALR
		else if (ALUOp == `OP_JALR) begin
			ALUControlOp = `JALR;
		end
	end
endmodule