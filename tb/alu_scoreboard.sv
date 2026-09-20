class scoreboard;
  mailbox    mon2scb;
  alu_coverage cov_tracker;

  int count      = 0;
  int pass_count = 0;
  int fail_count = 0;

  function new(mailbox mon2scb);
    this.mon2scb  = mon2scb;
    cov_tracker   = new();
  endfunction

  task main();
    transaction trans;
    bit [7:0] expected_result;
    bit       expected_zero;

    forever begin
      mon2scb.get(trans);
      cov_tracker.sample_data(trans);

      case (trans.alu_control)
        4'b0000: expected_result = trans.a + trans.b;
        4'b1000: expected_result = trans.a - trans.b;
        4'b0001: expected_result = trans.a << trans.b[2:0];
        4'b0010: expected_result = ($signed(trans.a) < $signed(trans.b)) ? 8'd1 : 8'd0;
        4'b0011: expected_result = (trans.a < trans.b)                   ? 8'd1 : 8'd0;
        4'b0100: expected_result = trans.a ^ trans.b;
        4'b0101: expected_result = trans.a >> trans.b[2:0];
        4'b0110: expected_result = trans.a | trans.b;
        4'b0111: expected_result = trans.a & trans.b;
        4'b1101: expected_result = $signed(trans.a) >>> trans.b[2:0];
        default: expected_result = 8'd0;
      endcase

      expected_zero = (expected_result == 8'd0);
      count++;
      
      if (expected_result === trans.result && expected_zero === trans.zero) begin
        pass_count++;
        
        if (count % 1000 == 0) begin
          $display("[PASS #%0d] Opcode: %4b | A: 0x%0d | B: 0x%0d | Expected: 0x%0d | Got: 0x%0d | Zero: %0b",
                    count, trans.alu_control, trans.a, trans.b,
                    expected_result, trans.result, trans.zero);
        end
      end else begin
        fail_count++;
        
        $display("[FAIL #%0d] Opcode: %4b | A: 0x%0d | B: 0x%0d | Expected: 0x%0d | Got: 0x%0d | ExpZero: %0b | GotZero: %0b",
                  count, trans.alu_control, trans.a, trans.b,
                  expected_result, trans.result, expected_zero, trans.zero);
        trans.display("FAILED TRANSACTION");
      end
    end
  endtask

endclass
