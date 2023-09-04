module LSU (
  input [4:0] opcode,
  input [31:0] mem_read_data,
  input [2:0] funct3,
  input [31:0] rs1,
  input [31:0] rs2,
  input [31:0] imm,
  output reg has_result,
  output reg [31:0] result,
  output reg [31:0] mem_addr,
  output reg [31:0] mem_write_data,
  output reg [1:0] mem_write_width,
  output reg error
);

  always@(*) begin
    has_result = 0;
    result = 0;
    mem_addr = rs1 + imm;
    mem_write_data = rs2;
    mem_write_width = 0;
    error = 0;
    case (opcode)
      // load
      5'b00000: begin
        has_result = 1;
        case (funct3)
          // lb
          3'b000: result = { {24{mem_read_data[7]}}, mem_read_data[7:0] };
          // lh
          3'b001: result = { {16{mem_read_data[15]}}, mem_read_data[15:0] };
          // lw
          3'b010: result = mem_read_data;
          // lbu
          3'b100: result = { {24{1'b0}}, mem_read_data[7:0] };
          // lhu
          3'b101: result = { {16{1'b0}}, mem_read_data[15:0] };
          default: error = 1;
        endcase
      end
      // store
      5'b01000:
        case (funct3)
          // sb
          3'b000: mem_write_width = 1;
          // sh
          3'b001: mem_write_width = 2;
          // sw
          3'b010: mem_write_width = 3;
          default: error = 1;
        endcase
      default: error = 1;
    endcase
  end
endmodule
