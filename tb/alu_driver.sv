class driver;
  mailbox gen2drv;
  virtual riscv_alu_if vif;

  function new(virtual riscv_alu_if vif, mailbox gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction

  task main();
    forever begin
      transaction trans;
      gen2drv.get(trans);
      
      @(posedge vif.clk); 
      vif.a <= trans.a;
      vif.b <= trans.b;
      vif.alu_control <= trans.alu_control;
    end
  endtask
endclass
