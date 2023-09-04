module BU (
  input [31:0] pc,
  input [4:0] opcode,
  input [2:0] funct3,
  input signed [31:0] rs1,
  input signed [31:0] rs2,
  input signed [31:0] imm,
  output reg link,
  output reg [31:0] target,
  output reg taken,
  output reg error
);

  reg [31:0] rs1_u;
  always@(*) begin
    link = 0;
    target = 0;
    taken = 0;
    error = 0;
    rs1_u = rs1;
    case (opcode)
      // jal
      5'b11011: begin
        link = 1;
        target = pc + imm;
      end
      // jalr
      5'b11001:
        if (funct3 == 3'b000) begin
          link = 1;
          target = (rs1 + imm) & ~1;
        end
        else error = 1;
      5'b11000: begin
        target = pc + imm;
        case (funct3)
          // beq
          3'b000: taken = rs1 == rs2;
          // bne
          3'b001: taken = rs1 != rs2;
          // blt
          3'b100: taken = rs1 < rs2;
          // bge
          3'b101: taken = rs1 >= rs2;
          // bltu
          3'b110: taken = rs1_u < rs2;
          // bgeu
          3'b111: taken = rs1_u >= rs2;
          default: error = 1;
        endcase
      end
      default: error = 1;
    endcase
  end
endmodule
