module ICache (
  input clk,
  input reset,
  input [31:0] addr,
  output reg [31:0] instr
);

  always@(*) begin
    case (addr)
      // loop:
      // li t1, 42
      32'h0: instr = 32'h02a00313;
      // add t2, t2, t1
      32'h4: instr = 32'h006383b3;
      // li t3, 1000
      32'h8: instr = 32'h3e800e13;
      // blt t2, t3, loop
      32'hc: instr = 32'hffc3cae3;
      
      default: instr = 32'b0;
    endcase
  end
endmodule
