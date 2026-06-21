`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "coverage.sv"   
`include "scoreboard.sv"
`include "environment.sv"

module tb_top;
  bit clk;
  always #5 clk = ~clk;

  riscv_alu_if vif(clk);

  // DUT
  riscv_alu dut (
    .a(vif.a),
    .b(vif.b),
    .alu_control(vif.alu_control),
    .result(vif.result),
    .zero(vif.zero)
  );

  environment env;

  initial begin
    env = new(vif);
    env.gen.repeat_count = 10000; // Set number of transactions to test
    env.test();
    
    #100; // Allow final transactions to clear
    $display("Final Functional Coverage = %0.2f %%", env.scb.cov_tracker.alu_cg.get_inst_coverage());
    $display("Simulation Complete.");
    $finish;
  end

  // EPWave form
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule
