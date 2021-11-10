`define state_00 		2'b00
`define state_01 		2'b01
`define state_10 		2'b10
`define state_11 		2'b11

`define Branch   		7'b1100011

module BTB(CLK,RSTn,PC,bcond,prev_mul,Instruction,IF_ID_Instruction,IF_ID_PC,branch_addr,BTB_PC,mul);
	input wire CLK;
	input wire RSTn;
	input wire [31:0] PC;
	input wire bcond;
	input wire prev_mul;
	input wire [31:0] Instruction;
	input wire [31:0] IF_ID_Instruction;
	input wire [31:0] IF_ID_PC;
	input wire [31:0] branch_addr;
	output wire [31:0] BTB_PC;
	output reg mul;

	reg [9:0] 	idx;
	reg [9:0] 	IF_ID_idx;
	reg [19:0]  tag[0:1023];
	reg [1:0]   BHT[0:1023];
	reg [31:0]  BTB[0:1023];
	reg [31:0]  flush_inst_addr;
	wire [31:0] new_addr; 
	reg addr_mul, isTaken;
	integer i;

	initial begin
		mul = 1'b0;
		addr_mul = 1'b0;
		isTaken = 1'b0;
		flush_inst_addr = 32'h00000000;
		idx = PC[11:2];
		IF_ID_idx = IF_ID_PC[11:2];
		for (i = 0; i < 1024; i = i+1) begin
			tag[i] = 0;
			BHT[i] = 2'b10;
			BTB[i] = 0;
		end
	end

	always @(*) begin
		if (!RSTn) begin
			for (i = 0; i < 1024; i = i+1) begin
				tag[i] = 0;
				BHT[i] = 2'b10;
				BTB[i] = 0;
			end
		end
	end

	always @(negedge CLK) begin
		mul = 1'b0;
		addr_mul = 1'b0;
		isTaken = 1'b0;
		flush_inst_addr = 32'h00000000;
		
		
		if (Instruction[6:0] == `Branch) begin
			idx = PC[11:2];
			if (tag[idx] == 0) begin
				tag[idx] = PC[31:12];
				BTB[idx] = branch_addr;
			end
			
			if (BHT[idx] == `state_00 || BHT[idx] == `state_01) begin
				isTaken = 1'b0;
			end
			else if (BHT[idx] == `state_10 || BHT[idx] == `state_11) begin
				isTaken = 1'b1;
			end

			mul = ((tag[idx] == PC[31:12]) && isTaken);

			if (mul) begin
				if (BHT[idx] != `state_11) begin
					BHT[idx] = BHT[idx] + 1;
				end
			end
			else begin
				if (BHT[idx] != `state_00) begin
					BHT[idx] = BHT[idx] - 1;
				end
			end
		end

		if (IF_ID_Instruction[6:0] == `Branch) begin
			IF_ID_idx = IF_ID_PC[11:2];
			if (!bcond && prev_mul) begin
				addr_mul = 1'b1;
				mul = 1'b1;
				flush_inst_addr = IF_ID_PC+4;
				if (BHT[IF_ID_idx] != `state_00) BHT[IF_ID_idx] = BHT[IF_ID_idx]-1;
			end
			else if (bcond && !prev_mul) begin
				addr_mul = 1'b1;
				mul = 1'b1;
				flush_inst_addr = BTB[IF_ID_idx];
				if (BHT[IF_ID_idx] != `state_11) BHT[IF_ID_idx] = BHT[IF_ID_idx]+1;
			end
		end	
	end

	assign new_addr = (addr_mul) ? flush_inst_addr:branch_addr;
	assign BTB_PC = (mul) ? new_addr:PC+4;
endmodule