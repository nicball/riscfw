module test;

reg clk;
always #10 clk = ~clk;
reg reset;
CPU cpu(clk, reset);

initial begin
  clk = 1;
  reset = 1;
  #30 reset = 0;
  #2000 $finish();
end

endmodule
