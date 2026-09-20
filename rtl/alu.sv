// Code your design here
module riscv_alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [3:0] alu_control,
    output logic [7:0] result,
    output logic       zero
);

    // 1. INSTRUCTION DECODING (Enable Variables)
    logic en_add, en_sub, en_sll, en_slt, en_sltu;
    logic en_xor, en_srl, en_sra, en_or, en_and;
    
    assign en_add  = (alu_control == 4'b0000);
    assign en_sub  = (alu_control == 4'b1000);
    assign en_sll  = (alu_control == 4'b0001);
    assign en_slt  = (alu_control == 4'b0010);
    assign en_sltu = (alu_control == 4'b0011);
    assign en_xor  = (alu_control == 4'b0100);
    assign en_srl  = (alu_control == 4'b0101);
    assign en_sra  = (alu_control == 4'b1101);
    assign en_or   = (alu_control == 4'b0110);
    assign en_and  = (alu_control == 4'b0111);

    // Grouping enables for shared hardware blocks
    logic en_arith;
    assign en_arith = en_add | en_sub | en_slt | en_sltu;

   
    // 2. OPERAND ISOLATION (AND Gate Masking)
    
    logic [7:0] a_arith, b_arith;
    logic [7:0] a_sll, b_sll;
    logic [7:0] a_srl, b_srl;
    logic [7:0] a_sra, b_sra;
    logic [7:0] a_logic, b_logic;

    // Isolate inputs for the Adder/Subtractor block
    assign a_arith = a & {8{en_arith}};
    assign b_arith = b & {8{en_arith}};

    // Isolate inputs for Shifters
    assign a_sll = a & {8{en_sll}};
    assign b_sll = b & {8{en_sll}};
    
    assign a_srl = a & {8{en_srl}};
    assign b_srl = b & {8{en_srl}};
    
    assign a_sra = a & {8{en_sra}};
    assign b_sra = b & {8{en_sra}};

    // Isolate inputs for bitwise logic (can share masks)
    logic en_bitwise;
    assign en_bitwise = en_and | en_or | en_xor;
    assign a_logic = a & {8{en_bitwise}};
    assign b_logic = b & {8{en_bitwise}};

   
    // 3. EXECUTION BLOCKS (Only one toggles at a time)
   

    // --- Bitwise Logic ---
    logic [7:0] res_and, res_or, res_xor;
  assign res_and = (a_logic & b_logic) & {8{en_and}};
    assign res_or  = (a_logic | b_logic) & {8{en_or}};
    assign res_xor = (a_logic ^ b_logic) & {8{en_xor}};

    // --- Shared Adder / Subtractor (For ADD, SUB, SLT, SLTU) ---
    logic [7:0] b_mux;
    logic [7:0] arith_sum;
    logic [8:0] carry;
    logic       do_sub;
    
    // Trigger subtraction for SUB, SLT, and SLTU
    assign do_sub   = (en_sub | en_slt | en_sltu); 
    assign b_mux    = b_arith ^ {8{do_sub}};
    assign carry[0] = do_sub; 

    always_comb begin  
        integer i;
        for (i = 0; i < 8; i++) begin 
            arith_sum[i] = a_arith[i] ^ b_mux[i] ^ carry[i];
            carry[i+1]   = (a_arith[i] & b_mux[i]) | (b_mux[i] & carry[i]) | (a_arith[i] & carry[i]);
        end
    end

    // Comparator flags derived from the isolated arithmetic block
    logic overflow, slt_bit, sltu_bit;
    assign overflow = (~a_arith[7] & b_arith[7] & arith_sum[7]) | (a_arith[7] & ~b_arith[7] & ~arith_sum[7]); 
    assign slt_bit  = arith_sum[7] ^ overflow;
    assign sltu_bit = ~carry[8];

    logic [7:0] res_add, res_sub, res_slt, res_sltu;
    assign res_add  = arith_sum & {8{en_add}};
    assign res_sub  = arith_sum & {8{en_sub}};
    assign res_slt  = {7'b0, slt_bit} & {8{en_slt}};
    assign res_sltu = {7'b0, sltu_bit} & {8{en_sltu}};

    // --- Shift Left Logical (SLL) ---
    logic [7:0] sll_s1, sll_s2, res_sll;
    assign sll_s1[7] = (b_sll[0] & a_sll[6]) | (~b_sll[0] & a_sll[7]);
    assign sll_s1[6] = (b_sll[0] & a_sll[5]) | (~b_sll[0] & a_sll[6]);
    assign sll_s1[5] = (b_sll[0] & a_sll[4]) | (~b_sll[0] & a_sll[5]);
    assign sll_s1[4] = (b_sll[0] & a_sll[3]) | (~b_sll[0] & a_sll[4]);
    assign sll_s1[3] = (b_sll[0] & a_sll[2]) | (~b_sll[0] & a_sll[3]);
    assign sll_s1[2] = (b_sll[0] & a_sll[1]) | (~b_sll[0] & a_sll[2]);
    assign sll_s1[1] = (b_sll[0] & a_sll[0]) | (~b_sll[0] & a_sll[1]);
    assign sll_s1[0] = (b_sll[0] & 1'b0)     | (~b_sll[0] & a_sll[0]); 

    assign sll_s2[7] = (b_sll[1] & sll_s1[5]) | (~b_sll[1] & sll_s1[7]);
    assign sll_s2[6] = (b_sll[1] & sll_s1[4]) | (~b_sll[1] & sll_s1[6]);
    assign sll_s2[5] = (b_sll[1] & sll_s1[3]) | (~b_sll[1] & sll_s1[5]);
    assign sll_s2[4] = (b_sll[1] & sll_s1[2]) | (~b_sll[1] & sll_s1[4]);
    assign sll_s2[3] = (b_sll[1] & sll_s1[1]) | (~b_sll[1] & sll_s1[3]);
    assign sll_s2[2] = (b_sll[1] & sll_s1[0]) | (~b_sll[1] & sll_s1[2]);
    assign sll_s2[1] = (b_sll[1] & 1'b0)      | (~b_sll[1] & sll_s1[1]); 
    assign sll_s2[0] = (b_sll[1] & 1'b0)      | (~b_sll[1] & sll_s1[0]); 

    assign res_sll[7] = (b_sll[2] & sll_s2[3]) | (~b_sll[2] & sll_s2[7]);
    assign res_sll[6] = (b_sll[2] & sll_s2[2]) | (~b_sll[2] & sll_s2[6]);
    assign res_sll[5] = (b_sll[2] & sll_s2[1]) | (~b_sll[2] & sll_s2[5]);
    assign res_sll[4] = (b_sll[2] & sll_s2[0]) | (~b_sll[2] & sll_s2[4]);
    assign res_sll[3] = (b_sll[2] & 1'b0)      | (~b_sll[2] & sll_s2[3]); 
    assign res_sll[2] = (b_sll[2] & 1'b0)      | (~b_sll[2] & sll_s2[2]);
    assign res_sll[1] = (b_sll[2] & 1'b0)      | (~b_sll[2] & sll_s2[1]);
    assign res_sll[0] = (b_sll[2] & 1'b0)      | (~b_sll[2] & sll_s2[0]);

    // --- Shift Right Logical (SRL) ---
    logic [7:0] srl_s1, srl_s2, res_srl;
    assign srl_s1[0] = (b_srl[0] & a_srl[1]) | (~b_srl[0] & a_srl[0]);
    assign srl_s1[1] = (b_srl[0] & a_srl[2]) | (~b_srl[0] & a_srl[1]);
    assign srl_s1[2] = (b_srl[0] & a_srl[3]) | (~b_srl[0] & a_srl[2]);
    assign srl_s1[3] = (b_srl[0] & a_srl[4]) | (~b_srl[0] & a_srl[3]);
    assign srl_s1[4] = (b_srl[0] & a_srl[5]) | (~b_srl[0] & a_srl[4]);
    assign srl_s1[5] = (b_srl[0] & a_srl[6]) | (~b_srl[0] & a_srl[5]);
    assign srl_s1[6] = (b_srl[0] & a_srl[7]) | (~b_srl[0] & a_srl[6]);
    assign srl_s1[7] = (b_srl[0] & 1'b0)     | (~b_srl[0] & a_srl[7]); 

    assign srl_s2[0] = (b_srl[1] & srl_s1[2]) | (~b_srl[1] & srl_s1[0]);
    assign srl_s2[1] = (b_srl[1] & srl_s1[3]) | (~b_srl[1] & srl_s1[1]);
    assign srl_s2[2] = (b_srl[1] & srl_s1[4]) | (~b_srl[1] & srl_s1[2]);
    assign srl_s2[3] = (b_srl[1] & srl_s1[5]) | (~b_srl[1] & srl_s1[3]);
    assign srl_s2[4] = (b_srl[1] & srl_s1[6]) | (~b_srl[1] & srl_s1[4]);
    assign srl_s2[5] = (b_srl[1] & srl_s1[7]) | (~b_srl[1] & srl_s1[5]);
    assign srl_s2[6] = (b_srl[1] & 1'b0)      | (~b_srl[1] & srl_s1[6]); 
    assign srl_s2[7] = (b_srl[1] & 1'b0)      | (~b_srl[1] & srl_s1[7]);

    assign res_srl[0] = (b_srl[2] & srl_s2[4]) | (~b_srl[2] & srl_s2[0]);
    assign res_srl[1] = (b_srl[2] & srl_s2[5]) | (~b_srl[2] & srl_s2[1]);
    assign res_srl[2] = (b_srl[2] & srl_s2[6]) | (~b_srl[2] & srl_s2[2]);
    assign res_srl[3] = (b_srl[2] & srl_s2[7]) | (~b_srl[2] & srl_s2[3]);
    assign res_srl[4] = (b_srl[2] & 1'b0)      | (~b_srl[2] & srl_s2[4]); 
    assign res_srl[5] = (b_srl[2] & 1'b0)      | (~b_srl[2] & srl_s2[5]);
    assign res_srl[6] = (b_srl[2] & 1'b0)      | (~b_srl[2] & srl_s2[6]);
    assign res_srl[7] = (b_srl[2] & 1'b0)      | (~b_srl[2] & srl_s2[7]);

    // --- Shift Right Arithmetic (SRA) ---
    logic [7:0] sra_s1, sra_s2, res_sra;
    logic       sign_bit;
    assign sign_bit = a_sra[7];

    assign sra_s1[0] = (b_sra[0] & a_sra[1]) | (~b_sra[0] & a_sra[0]);
    assign sra_s1[1] = (b_sra[0] & a_sra[2]) | (~b_sra[0] & a_sra[1]);
    assign sra_s1[2] = (b_sra[0] & a_sra[3]) | (~b_sra[0] & a_sra[2]);
    assign sra_s1[3] = (b_sra[0] & a_sra[4]) | (~b_sra[0] & a_sra[3]);
    assign sra_s1[4] = (b_sra[0] & a_sra[5]) | (~b_sra[0] & a_sra[4]);
    assign sra_s1[5] = (b_sra[0] & a_sra[6]) | (~b_sra[0] & a_sra[5]);
    assign sra_s1[6] = (b_sra[0] & a_sra[7]) | (~b_sra[0] & a_sra[6]);
    assign sra_s1[7] = (b_sra[0] & sign_bit) | (~b_sra[0] & a_sra[7]); 

    assign sra_s2[0] = (b_sra[1] & sra_s1[2])  | (~b_sra[1] & sra_s1[0]);
    assign sra_s2[1] = (b_sra[1] & sra_s1[3])  | (~b_sra[1] & sra_s1[1]);
    assign sra_s2[2] = (b_sra[1] & sra_s1[4])  | (~b_sra[1] & sra_s1[2]);
    assign sra_s2[3] = (b_sra[1] & sra_s1[5])  | (~b_sra[1] & sra_s1[3]);
    assign sra_s2[4] = (b_sra[1] & sra_s1[6])  | (~b_sra[1] & sra_s1[4]);
    assign sra_s2[5] = (b_sra[1] & sra_s1[7])  | (~b_sra[1] & sra_s1[5]);
    assign sra_s2[6] = (b_sra[1] & sign_bit)   | (~b_sra[1] & sra_s1[6]);
    assign sra_s2[7] = (b_sra[1] & sign_bit)   | (~b_sra[1] & sra_s1[7]);

    assign res_sra[0] = (b_sra[2] & sra_s2[4])  | (~b_sra[2] & sra_s2[0]);
    assign res_sra[1] = (b_sra[2] & sra_s2[5])  | (~b_sra[2] & sra_s2[1]);
    assign res_sra[2] = (b_sra[2] & sra_s2[6])  | (~b_sra[2] & sra_s2[2]);
    assign res_sra[3] = (b_sra[2] & sra_s2[7])  | (~b_sra[2] & sra_s2[3]);
    assign res_sra[4] = (b_sra[2] & sign_bit)   | (~b_sra[2] & sra_s2[4]); 
    assign res_sra[5] = (b_sra[2] & sign_bit)   | (~b_sra[2] & sra_s2[5]);
    assign res_sra[6] = (b_sra[2] & sign_bit)   | (~b_sra[2] & sra_s2[6]);
    assign res_sra[7] = (b_sra[2] & sign_bit)   | (~b_sra[2] & sra_s2[7]);

    
    // Because unselected paths output 8'b0, we simply OR them together.
    
    assign result = res_add | res_sub | res_slt | res_sltu | 
                    res_sll | res_srl | res_sra | 
                    res_and | res_or  | res_xor;

    // Zero flag generation using NOR logic on the final result
    assign zero = ~(result[0] | result[1] | result[2] | result[3] |
                    result[4] | result[5] | result[6] | result[7]);

endmodule
