module Simple_ALU(A,B,rdSel,Output);
  input [31:0]A;
  input [31:0]B;
  input [1:0]rdSel;
  output reg [31:0]Output;

  // addition
  always @(*) begin
    if (rdSel == 2'b10) begin
      Output = A;
    end
    else if (rdSel == 2'b01) begin
      Output = B;
    end
    else if (rdSel == 2'b11) begin
      Output = A + B;
    end
    else begin
      Output = A;
    end
  end
endmodule