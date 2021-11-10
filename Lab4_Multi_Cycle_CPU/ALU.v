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

module ALU(A,B,ALUControlOp,Bcond,Output);
	input [31:0]A;
	input [31:0]B;
	input [4:0]ALUControlOp;
	output reg Bcond;
	output reg [31:0]Output;
	//temporary variables
	integer i;
	reg signed [31:0] sA, sB;
	reg a, b;
	initial begin
		Bcond =1'b0;
		Output = 31'b0;
	end

	always @(*) begin
		Bcond = 1'b0;
		if (ALUControlOp == `ADD) begin
			Output = A+B;
		end
		else if (ALUControlOp == `SUB) begin
			Output = A-B;
		end
		else if (ALUControlOp == `SLL) begin
			Output = A;
			for (i =0;i < B[5:0];i = i+1) begin
		      Output = Output<<1;
		   	end
		end
		else if (ALUControlOp == `SLT) begin
			sA = A;
			sB = B;
			if (sA < sB) begin
	            Output = 31'b1;
	          end
	          else begin
	            Output = 31'b0;
	          end
		end
		else if (ALUControlOp == `SLTU) begin
		    if (A < B) begin
		      Output = 31'b1;
		    end
		    else begin
		      Output = 31'b0;
		    end
		end
		else if (ALUControlOp == `XOR) begin
			Output = A ^ B;
		end
		else if (ALUControlOp == `SRL) begin
	        Output = A;
	        for (i = 0; i < B[5:0]; i=i+1) begin
	          Output = Output >> 1;
	        end
		end
		else if (ALUControlOp == `SRA) begin
			Output = A;
	        for (i = 0; i < B[5:0]; i=i+1) begin
	          b = Output[15];
	          Output = Output >>> 1;
	          Output[15] = b;
	        end
		end
		else if (ALUControlOp == `OR) begin
			Output = A|B;
		end
		else if (ALUControlOp == `AND) begin
			Output = A&B;
		end
		else if (ALUControlOp == `JALR) begin
			Output = A+B;
			Output[0] = 1'b0;
		end
		else if (ALUControlOp == `BEQ) begin
			if (A == B) begin
	          Bcond = 1'b1;
	          Output = 31'b1;
	        end
		end
		else if (ALUControlOp == `BNE) begin
        	if (A != B) begin
        	  Bcond = 1'b1;
       		  Output = 31'b1;
        	end
		end
		else if (ALUControlOp == `BLT) begin
        	a = A[31];
	        b = B[31];
	        sA = A;
	        sB = B;
	        if (a == 1 && b == 0) begin
	          Bcond = 1'b1;
	          Output = 31'b1;
	        end
	        else begin
	          if (sA < sB) begin
	            Bcond = 1'b1;
	            Output = 31'b1;
	          end
	        end
		end
		else if (ALUControlOp == `BGE) begin
	        a = A[31];
	        b = B[31];
	        sA = A;
	        sB = B;
	        if (a == 0 && b == 1) begin
	          Bcond = 1'b1;
	          Output = 31'b1;
	        end
	        else begin
	          if (sA >= sB) begin
	            Bcond = 1'b1;
	            Output = 31'b1;
	          end
	        end
		end
		else if (ALUControlOp == `BLTU) begin
        	a = A[31];
	        b = B[31];
	        if (a == 0 && b == 1) begin
	          Bcond = 1'b1;
	          Output = 31'b1;
	        end
	        else begin
	          if (A < B) begin
	            Bcond = 1'b1;
	            Output = 31'b1;
	          end
	        end
		end
		else if (ALUControlOp == `BGEU) begin
        	a = A[31];
	        b = B[31];
	        if (a == 1 && b == 0) begin
	          Bcond = 1'b1;
	          Output = 31'b1;
	        end
	        else begin
	          if (A > B) begin
	            Bcond = 1'b1;
	            Output = 31'b1;
	          end
	        end
		end
	end
endmodule