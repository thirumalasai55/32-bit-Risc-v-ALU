interface riscv_alu_if(input logic clk, input logic rst_n);
  logic [7:0] a;
  logic [7:0] b;
  logic [3:0] alu_control;
  logic [7:0] result;
  logic       zero;

  property check_true_zero;
    @(posedge clk) disable iff (!rst_n)
    (result == 8'd0) |-> (zero == 1'b1);
  endproperty

  property check_false_zero;
    @(posedge clk) disable iff (!rst_n)
    (result != 8'd0) |-> (zero == 1'b0);
  endproperty

  assert_true_zero:  assert property(check_true_zero);
  assert_false_zero: assert property(check_false_zero);

endinterface
