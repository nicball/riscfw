module Decoder (
  input [31:0] instr,
  output reg [4:0] opcode,
  output reg [4:0] rd,
  output reg rd_valid,
  output reg [4:0] rs1,
  output reg [4:0] rs2,
  output reg [31:0] imm,
  output reg [2:0] funct3,
  output reg [6:0] funct7,
  output reg error
);

  initial $monitor("time=%0t, opcode=%0b", $time, opcode);

  always@(*) begin
    opcode = instr[6:2];
    funct3 = instr[14:12];
    funct7 = instr[31:25];
    rd = instr[11:7];
    rd_valid = 0;
    rs1 = instr[19:15];
    rs2 = instr[24:20];
    imm = 0;
    error = 0;
    casez (opcode)
      // B type
      5'b11000:
        imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8] };
        
      // J type
      5'b11011: begin
        imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
        rd_valid = 1;
      end
      
      // R type
      5'b01100: begin
        imm = 0;
        rd_valid = 1;
      end
      
      // S type
      5'b01000:
        imm = { {21{instr[31]}}, instr[30:25], instr[11:7] };
        
      // I type
      5'b00000, 5'b00011, 5'b00100, 5'b11001, 5'b11100: begin
        imm = { {21{instr[31]}}, instr[30:20] };
        rd_valid = 1;
      end
      
      // U type
      5'b00101, 5'b01101: begin
        imm = { instr[31:12], 12'b0 };
        rd_valid = 1;
      end
        
      default: error = 1;
    endcase
  end
  
endmodule
