`include "alu_interface.sv"
`include "alu_transaction.sv"
`include "alu_coverage.sv"
`include "alu_generator.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_scoreboard.sv"

class environment;
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard scb;

  mailbox gen2drv;
  mailbox mon2scb;

  virtual riscv_alu_if vif;

  function new(virtual riscv_alu_if vif);
    this.vif = vif;
    gen2drv  = new();
    mon2scb  = new();

    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);
  endfunction

  task test();
    fork
      drv.main();
      mon.main();
      scb.main();
    join_none

    gen.main(); 
    wait(scb.count == gen.repeat_count);
  endtask

endclass

module tb_top;

  bit clk;
  always #5 clk = ~clk;

  bit rst_n;
  initial begin
    rst_n = 0;
    #15;
    rst_n = 1;
  end
  
  riscv_alu_if vif(clk, rst_n);

  riscv_alu dut (
    .a          (vif.a),
    .b          (vif.b),
    .alu_control(vif.alu_control),
    .result     (vif.result),
    .zero       (vif.zero)
  );

  // ==========================================
  // POWER METRICS: TOGGLE TRACKING LOGIC
  // ==========================================
  logic [7:0] prev_sum;
  int true_arith_toggles = 0;

  logic       unisolated_do_sub;
  logic [7:0] unisolated_b_mux;
  logic [7:0] unisolated_sum;
  logic [7:0] prev_unisolated_sum;
  int         unisolated_arith_toggles = 0;

  assign unisolated_do_sub = (vif.alu_control == 4'b1000) | (vif.alu_control == 4'b0010) | (vif.alu_control == 4'b0011);
  assign unisolated_b_mux = vif.b ^ {8{unisolated_do_sub}};
  assign unisolated_sum   = vif.a + unisolated_b_mux + unisolated_do_sub;

  always @(posedge vif.clk) begin
    if (rst_n) begin
      if (dut.arith_sum != prev_sum) begin
        true_arith_toggles++;
      end
      prev_sum = dut.arith_sum;

      if (unisolated_sum != prev_unisolated_sum) begin
        unisolated_arith_toggles++;
      end
      prev_unisolated_sum = unisolated_sum;
    end
  end
  // ==========================================

  environment env;
  real power_saved_percent;

  initial begin
    env = new(vif);
    env.gen.repeat_count = 10000;
    env.test();

    #100;

    if (unisolated_arith_toggles > 0) begin
      power_saved_percent = (real'(unisolated_arith_toggles - true_arith_toggles) / unisolated_arith_toggles) * 100.0;
    end else begin
      power_saved_percent = 0.0;
    end

    $display("");
    $display("  SIMULATION RESULTS");
    $display("  Total     : %0d", env.scb.count);
    $display("  Passed    : %0d", env.scb.pass_count);
    $display("  Failed    : %0d", env.scb.fail_count);
    $display("  Coverage  : %0.2f %%",
              env.scb.cov_tracker.alu_cg.get_inst_coverage());
    $display("=======================================");
    $display(" POWER METRICS (TOGGLE COUNT)");
    $display(" Baseline Toggles (No Isolation) : %0d", unisolated_arith_toggles);
    $display(" Actual Toggles (With Isolation) : %0d", true_arith_toggles);
    $display(" Toggle Reduction (Power Saved)  : %0.2f %%", power_saved_percent);
    $display("=======================================");
    $display("");
    $display("Simulation Complete.");
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule
