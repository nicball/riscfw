module RegFile (
  input clk,
  input reset,
  input [4:0] read_addr_1,
  input [4:0] read_addr_2,
  input write_enable,
  input [4:0] write_addr,
  input [31:0] write_data,
  output [31:0] read_data_1,
  output [31:0] read_data_2
);

  reg [31:0] regfile[31:0];
  
  // initial $monitor("time=%t, t2=%d", $time, regfile[7]);
  
  assign read_data_1 = read_addr_1 ? regfile[read_addr_1] : 0;
  assign read_data_2 = read_addr_2 ? regfile[read_addr_2] : 0;
  
  reg [31:0] i;
  always@(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 32; ++i) begin
        regfile[i] <= 0;
      end
    end
    else begin
      if (write_enable) begin
        regfile[write_addr] <= write_data;
      end
    end
  end
  
endmodule
