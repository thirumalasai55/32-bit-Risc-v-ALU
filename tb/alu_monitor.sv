class monitor;
  mailbox mon2scb;
  virtual riscv_alu_if vif;

  function new(virtual riscv_alu_if vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main();
    forever begin
      transaction trans = new();
      @(posedge vif.clk);
      #1; // Slight delay to ensure the sample stable values after the clock edge
      
      trans.a = vif.a;
      trans.b = vif.b;
      trans.alu_control = vif.alu_control;
      trans.result = vif.result;
      trans.zero = vif.zero;
      
      mon2scb.put(trans);
    end
  endtask
endclass
