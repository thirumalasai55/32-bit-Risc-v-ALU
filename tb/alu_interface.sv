interface riscv_alu_if(input logic clk);
  logic [31:0] a;
  logic [31:0] b;
  logic [3:0]  alu_control;
  logic [31:0] result;
  logic        zero;

  property check_true_zero;
    @(posedge clk) 
    (result == 32'd0) |-> (zero == 1'b1);
  endproperty

  property check_false_zero;
    @(posedge clk) 
    (result != 32'd0) |-> (zero == 1'b0);
  endproperty
  assert_true_zero:  assert property(check_true_zero);
  assert_false_zero: assert property(check_false_zero);
    
endinterface
