module CPU (
  input clk,
  input reset
);

  reg [31:0] pc;
  
  reg [31:0] next_pc;
  reg [31:0] instr_result;
  reg instr_has_result;
  
  wire [31:0] instr;
  ICache icache( .clk(clk), .reset(reset), .addr(pc), .instr(instr) );
  
  wire [4:0] opcode;
  wire [4:0] rs1_index;
  wire [4:0] rs2_index;
  wire [4:0] rd_index;
  wire [31:0] imm;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire invalid_instr;
  wire not_used;
  Decoder decoder(
    .instr(instr),
    .opcode(opcode),
    .rd(rd_index),
    .rd_valid(not_used),
    .rs1(rs1_index),
    .rs2(rs2_index),
    .imm(imm),
    .funct3(funct3),
    .funct7(funct7),
    .error(invalid_instr)
  );
  
  wire [31:0] rs1;
  wire [31:0] rs2;
  RegFile regfile(
    .clk(clk),
    .reset(reset), 
    .read_addr_1(rs1_index),
    .read_addr_2(rs2_index),
    .write_enable(instr_has_result),
    .write_addr(rd_index),
    .write_data(instr_result),
    .read_data_1(rs1),
    .read_data_2(rs2)
  );
  
  wire alu_error;
  wire [31:0] alu_result;
  ALU alu(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .rs1(rs1),
    .rs2(rs2),
    .imm(imm),
    .pc(pc),
    .result(alu_result),
    .error(alu_error)
  );
  
  wire lsu_error;
  wire lsu_has_result;
  wire [31:0] lsu_result;
  wire [31:0] mem_addr;
  wire [31:0] mem_read_data;
  wire [31:0] mem_write_data;
  wire [1:0] mem_write_width;
  LSU lsu(
    .opcode(opcode),
    .mem_read_data(mem_read_data),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .imm(imm),
    .has_result(lsu_has_result),
    .result(lsu_result),
    .mem_addr(mem_addr),
    .mem_write_data(mem_write_data),
    .mem_write_width(mem_write_width),
    .error(lsu_error)
  );
  DCache dcache(
    .clk(clk),
    .reset(reset),
    .addr(mem_addr),
    .write_data(mem_write_data),
    .write_width(mem_write_width),
    .read_data(mem_read_data)
  );
  
  wire bu_error;
  wire bu_has_result;
  wire branch_taken;
  wire [31:0] branch_target;
  BU bu(
    .pc(pc),
    .opcode(opcode),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .imm(imm),
    .link(bu_has_result),
    .target(branch_target),
    .taken(branch_taken),
    .error(bu_error)
  );
  
  reg bad_instr;
  always@(*) begin
    instr_has_result = 0;
    instr_result = 0;
    next_pc = pc + 4;
    bad_instr = invalid_instr;
    if (~alu_error) begin
      instr_has_result = 1;
      instr_result = alu_result;
    end
    else if (~lsu_error) begin
      if (lsu_has_result) begin
        instr_has_result = 1;
        instr_result = lsu_result;
      end
    end
    else if (~bu_error) begin
      if (bu_has_result) begin
        instr_has_result = 1;
        instr_result = pc + 4;
      end
      if (branch_taken) next_pc = branch_target;
    end
    else bad_instr = 1;
  end
  
  always@(posedge clk) begin
    if (reset) begin
      pc <= 0;
    end
    else if (~bad_instr) begin
      pc <= next_pc;
    end
  end
  
  initial $monitor("time=%t, clk=%d, opcode=%d, imm=%d, pc=%d, target=%d, badinstr=%d", $time, clk, opcode, imm, pc, branch_target, bad_instr);
endmodule
