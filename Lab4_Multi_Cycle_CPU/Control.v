`define control_zero 	3'b000
`define control_WB1 	3'b001
`define control_WB2 	3'b010
`define control_ID 		3'b011
`define control_itr 	3'b100

`define state_IF 		4'b0000
`define state_ID 		4'b0001
`define state_JAL 		4'b0010
`define state_JALR 		4'b0101
`define state_Branch 	4'b0110
`define state_LW 		4'b0111
`define state_SW 		4'b1010
`define state_I_comp 	4'b1100
`define state_R_comp 	4'b1101
`define state_MEM1 		4'b1000
`define state_MEM2 		4'b1011
`define state_WB1 		4'b0011
`define state_WB2 		4'b0100
`define state_WB3 		4'b1001

module Control(OPcode,CLK,RSTn,PCSource,ALUOp,ALUSrcA,ALUSrcB,RegWrite,PCWritecond,PCWrite,D_MEM_BE,MemWrite,MemtoReg,Inst_plus,returnState);

	input wire [6:0] OPcode;
	input wire CLK;
	input wire RSTn;
	//combinational section of control
	output reg [1:0] PCSource;
	output reg [2:0] ALUOp;
	output reg ALUSrcA;
	output reg [1:0] ALUSrcB;
	output reg RegWrite;
	output reg PCWritecond;
	output reg PCWrite;
	output reg [3:0]D_MEM_BE;
	output reg MemWrite;
	output reg MemtoReg;
	output reg Inst_plus;
	output reg [3:0] returnState;
	//output reg IRWrite;
	// squential section of control
	reg [2:0] Microcontrol;
	reg [3:0] increment_out;
	reg [3:0] ID_table_out;
	reg [3:0] NXT_state;
	reg [3:0] state;

	//initial
	initial begin
		NXT_state <= `state_IF;
	end
	// combinational logic
	always @(*) begin
		if (state == `state_IF) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'bxxx;
			ALUSrcA <= 1'bx;
			ALUSrcB <= 2'bxx;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_itr;
		end
		else if (state == `state_ID) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'b100;
			if (OPcode == 7'b1100111) begin
				ALUSrcA <= 1'b1;
			end
			else begin
				ALUSrcA <= 1'b0;
			end
			ALUSrcB <= 2'b10;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_ID;
		end
		else if (state == `state_JAL) begin
			PCSource <= 2'b01;
			ALUOp <= 3'b100;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 2'b01;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b1;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_WB1;
		end
		else if (state == `state_JALR) begin
			PCSource <= 2'b10;
			ALUOp <= 3'b100;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 2'b01;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b1;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_WB1;
		end
		else if (state == `state_Branch) begin
			PCSource <= 2'b01;
			ALUOp <= 3'b011;
			ALUSrcA <= 1'b1;
			ALUSrcB <= 2'b00;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b1;
			PCWrite <= 1'b1;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_zero;
		end
		else if (state == `state_LW) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'b110;
			ALUSrcA <= 1'b1;
			ALUSrcB <= 2'b10;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_itr;
		end
		else if (state == `state_SW) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'b010;
			ALUSrcA <= 1'b1;
			ALUSrcB <= 2'b10;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_itr;
		end
		else if (state == `state_I_comp) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'b001;
			ALUSrcA <= 1'b1;
			ALUSrcB <= 2'b10;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_WB2;
		end
		else if (state == `state_R_comp) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'b000;
			ALUSrcA <= 1'b1;
			ALUSrcB <= 2'b00;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_WB2;
		end
		else if (state == `state_MEM1) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'b100;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 2'b01;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b1111;
			MemWrite <= 1'b1;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_itr;
		end
		else if (state == `state_MEM2) begin
			PCSource <= 2'b00;
			ALUOp <= 3'b100;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 2'b01;
			RegWrite <= 1'b0;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b1;
			D_MEM_BE <= 4'b1111;
			MemWrite <= 1'b0;
			MemtoReg <= 1'bx;
			Microcontrol <= `control_zero;
		end
		else if (state == `state_WB1) begin
			PCSource <= 2'bxx;
			ALUOp <= 3'bxxx;
			ALUSrcA <= 1'bx;
			ALUSrcB <= 2'bxx;
			RegWrite <= 1'b1;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b0;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'b0;
			Microcontrol <= `control_zero;
		end
		else if (state == `state_WB2) begin
			PCSource <= 2'b00;
			ALUOp <= 3'b100;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 2'b01;
			RegWrite <= 1'b1;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b1;
			D_MEM_BE <= 4'b0000;
			MemWrite <= 1'b0;
			MemtoReg <= 1'b0;
			Microcontrol <= `control_zero;
		end
		else if (state == `state_WB3) begin
			PCSource <= 2'b01;
			ALUOp <= 3'bxxx;
			ALUSrcA <= 1'bx;
			ALUSrcB <= 2'bxx;
			RegWrite <= 1'b1;
			PCWritecond <= 1'b0;
			PCWrite <= 1'b1;
			D_MEM_BE <= 4'b1111;
			MemWrite <= 1'b1;
			MemtoReg <= 1'b1;
			Microcontrol <= `control_zero;
		end
	end
	// ID table
	always @(*) begin
		if (OPcode == 7'b1100111) begin
			ID_table_out <= `state_JALR;
		end
		else if (OPcode == 7'b1100011) begin
			ID_table_out <= `state_Branch;
		end
		else if (OPcode == 7'b0000011) begin
			ID_table_out <= `state_LW;
		end
		else if (OPcode == 7'b0100011) begin
			ID_table_out <= `state_SW;
		end
		else if (OPcode == 7'b0010011) begin
			ID_table_out <= `state_I_comp;
		end
		else if (OPcode == 7'b0110011) begin
			ID_table_out <= `state_R_comp;
		end
		else if (OPcode == 7'b1101111) begin
			ID_table_out <= `state_JAL;
		end
	end

	//multiplexer
	always @(*) begin
		returnState <= state;
		if (Microcontrol == `control_zero) begin
			NXT_state <= `state_IF;
			Inst_plus <= 1;
		end
		else if (Microcontrol == `control_WB1) begin
			NXT_state <= `state_WB1;
			Inst_plus <= 0;
		end
		else if (Microcontrol == `control_WB2) begin
			NXT_state <= `state_WB2;
			Inst_plus <= 0;
		end
		else if (Microcontrol == `control_ID) begin
			NXT_state <= ID_table_out;
			Inst_plus <= 0;
		end
		else if (Microcontrol == `control_itr) begin
			NXT_state <= state + 1;
			Inst_plus <= 0;
		end
	end
	// sychrounous write
	always @(posedge CLK) begin
		if (RSTn) state <= NXT_state;
	end
endmodule