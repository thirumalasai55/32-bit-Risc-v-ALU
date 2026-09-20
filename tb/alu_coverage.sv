class alu_coverage;
  transaction trans;

  covergroup alu_cg;
    option.per_instance = 1;
    option.name = "RV_ALU_8bit_Coverage";
    
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
  
    cp_operand_a: coverpoint trans.a {
      bins zero_val = {8'h00};
      bins max_pos  = {8'h7F};   
      bins min_neg  = {8'h80};   
      bins all_ones = {8'hFF};
      bins others   = {[8'h01 : 8'h7E], [8'h81 : 8'hFE]};
    }
    
    cp_operand_b: coverpoint trans.b {
      bins zero_val  = {8'h00};
      bins max_pos   = {8'h7F};
      bins min_neg   = {8'h80};
      bins all_ones  = {8'hFF};
      bins shift_max = {8'h07};  
      bins shift_mid = {[8'h01 : 8'h06]};
      bins others    = {[8'h08 : 8'h7E], [8'h81 : 8'hFE]};
    }
   
    cp_result: coverpoint trans.result {
      bins zero_out = {8'h00};
      bins max_pos  = {8'h7F};
      bins min_neg  = {8'h80};
      bins all_ones = {8'hFF};
      bins others   = {[8'h01 : 8'h7E], [8'h81 : 8'hFE]};
    }

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
