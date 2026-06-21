
class alu_coverage;
  transaction trans;

  covergroup alu_cg;
    option.per_instance = 1;
    option.name = "RV32I_ALU_Coverage";

    // 1. OPCODE COVERAGE
    cp_opcode: coverpoint trans.alu_control {
      bins op_add  = {4'b0000};
      bins op_sll  = {4'b0001}; 
      bins op_slt  = {4'b0010}; 
      bins op_sltu = {4'b0011}; 
      bins op_xor  = {4'b0100};
      bins op_srl  = {4'b0101}; 
      bins op_or   = {4'b0110};
      bins op_and  = {4'b0111};
      bins op_sub  = {4'b1000};
      bins op_sra  = {4'b1101}; 
    }

    // 2. OPERAND A COVERAGE (cover cases)
    cp_operand_a: coverpoint trans.a {
      bins zero_val = {32'h0000_0000};
      bins max_pos  = {32'h7FFF_FFFF}; 
      bins max_neg  = {32'h8000_0000}; 
      bins all_ones = {32'hFFFF_FFFF}; 
      bins others   = {[32'h0000_0001 : 32'h7FFF_FFFE], 
                       [32'h8000_0001 : 32'hFFFF_FFFE]};         
    }

    // 3. OPERAND B COVERAGE 
    cp_operand_b: coverpoint trans.b {
      bins zero_val  = {32'h0000_0000};
      bins max_pos   = {32'h7FFF_FFFF};
      bins max_neg   = {32'h8000_0000};
      bins all_ones  = {32'hFFFF_FFFF};
      bins shift_max = {32'h0000_001F}; 
      
      bins others    = {[32'h0000_0001 : 32'h0000_001E], 
                        [32'h0000_0020 : 32'h7FFF_FFFE], 
                        [32'h8000_0001 : 32'hFFFF_FFFE]};
    }

    //  CROSS COVERAGE
    cross_opcode_x_a: cross cp_opcode, cp_operand_a;
    cross_opcode_x_b: cross cp_opcode, cp_operand_b;

  endgroup

  function new();
    alu_cg = new();
  endfunction

  function void sample_data(transaction t);
    this.trans = t;
    alu_cg.sample();
  endfunction
endclass

