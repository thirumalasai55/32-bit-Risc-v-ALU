class generator;
  mailbox gen2drv;
  int repeat_count;

  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task main();
    for (int i = 0; i < repeat_count; i++) begin
      transaction trans = new();
      if (!trans.randomize()) $fatal("Gen:: transaction randomization failed");
      gen2drv.put(trans);
    end
  endtask
endclass

