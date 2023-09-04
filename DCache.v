module DCache (
  input clk,
  input reset,
  input [31:0] addr,
  input [31:0] write_data,
  input [1:0]  write_width,
  output [31:0] read_data
);

  reg [31:0] mem[1048575:0];
  
  assign read_data = mem[addr];
  
  reg [31:0] i;
  always@(posedge clk) begin
    if (reset)
      for (i = 0; i < 1048576; ++i)
        mem[i] <= 0;
    else
      case (write_width)
        1: mem[addr] <= {read_data[31:8], write_data[7:0]};
        2: mem[addr] <= {read_data[31:16], write_data[15:0]};
        3: mem[addr] <= write_data;
      endcase
  end
endmodule
