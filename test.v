module test;

reg clk;
always #10 clk = ~clk;
reg reset;
CPU cpu(clk, reset);

initial begin
  #0 clk = 1;
  #0 reset = 1;
  #30 reset = 0;
end

endmodule
