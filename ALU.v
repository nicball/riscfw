module ALU (
  input [4:0] opcode,
  input [2:0] funct3,
  input [6:0] funct7,
  input signed [31:0] rs1,
  input signed [31:0] rs2,
  input signed [31:0] imm,
  input [31:0] pc,
  output reg [31:0] result,
  output reg error
);

  reg unsigned [31:0] rs1_u;
  always@(*) begin
    rs1_u = rs1;
    error = 0;
    result = 0;
    case (opcode)
      // lui 
      5'b01101: result = imm;
      // auipc
      5'b00101: result = imm + pc;
      5'b00100:
        case (funct3)
          // addi
          3'b000: result = rs1 + imm;
          // slti
          3'b010: result = rs1 < imm;
          // sltiu
          3'b011: result = rs1_u < imm;
          // xori
          3'b100: result = rs1 ^ imm;
          // ori
          3'b110: result = rs1 | imm;
          // andi
          3'b111: result = rs1 & imm;
          default:
            case ({funct7, imm[5], funct3})
              // slli
              11'b00000000001: result = rs1 << imm[4:0];
              // srli
              11'b00000000101: result = rs1 >> imm[4:0];
              // srai
              11'b01000000101: result = rs1 >>> imm[4:0];
              default: error = 1;
            endcase
        endcase
      5'b01100:
        case ({funct7, funct3})
          // add
          10'b0000000000: result = rs1 + rs2;
          // sub
          10'b0100000000: result = rs1 - rs2;
          // sll
          10'b0000000001: result = rs1 << rs2;
          // slt
          10'b0000000010: result = rs1 < rs2;
          // sltu
          10'b0000000011: result = rs1_u < rs2;
          // xor
          10'b0000000100: result = rs1 ^ rs2;
          // srl
          10'b0000000101: result = rs1 >> rs2;
          // sra
          10'b0100000101: result = rs1 >>> rs2;
          // or
          10'b0000000110: result = rs1 | rs2;
          // and
          10'b0000000111: result = rs1 & rs2;
          default: error = 1;
        endcase
      default: error = 1;
    endcase
  end
endmodule
