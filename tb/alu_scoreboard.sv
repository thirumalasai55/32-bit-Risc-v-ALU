class scoreboard;
  mailbox mon2scb;
  alu_coverage cov_tracker;
  int count=0;
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
    cov_tracker = new();
  endfunction

  task main();
    transaction trans;
    bit [31:0] expected_result;
    bit        expected_zero;

    forever begin
      mon2scb.get(trans);
      cov_tracker.sample_data(trans);
      
      
      case(trans.alu_control)
        4'b0000: expected_result = trans.a + trans.b;
        4'b1000: expected_result = trans.a - trans.b;
        4'b0001: expected_result = trans.a << trans.b[4:0];
        4'b0010: expected_result = $signed(trans.a) < $signed(trans.b) ? 32'd1 : 32'd0;
        4'b0011: expected_result = trans.a < trans.b ? 32'd1 : 32'd0;
        4'b0100: expected_result = trans.a ^ trans.b;
        4'b0101: expected_result = trans.a >> trans.b[4:0];
        4'b0110: expected_result = trans.a | trans.b;
        4'b0111: expected_result = trans.a & trans.b;
        4'b1101: expected_result = $signed(trans.a) >>> trans.b[4:0];
        default: expected_result = 32'd0;
      endcase
      expected_zero = (expected_result == 32'd0);
  
      count++;    
      //To optimize simulation performance and reduce I/O overhead, I suppressed individual transaction logs and implemented a Heartbeat Monitor that reports status every 1,000 cycles."
      if ((expected_result == trans.result && expected_zero == trans.zero) && count % 1000 == 0) begin
       $display("[SCOREBOARD] PASS -> Expected: 0x%08h | Got: 0x%08h", expected_result, trans.result);
       trans.display("correct TRANSACTION");
      end 
      
      else if (count % 1000 == 0) begin
        $display("[SCOREBOARD] fail -> Expected: 0x%08h | Got: 0x%08h", expected_result, trans.result);
      end
        
       
    end
  endtask
endclass
