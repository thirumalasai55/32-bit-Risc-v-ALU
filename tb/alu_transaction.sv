class transaction;
  rand bit [7:0] a;
  rand bit [7:0] b;
  rand bit [3:0] alu_control;

  bit [7:0] result;
  bit       zero;
  
  constraint valid_opcodes {
    alu_control inside {4'b0000, 4'b1000, 4'b0001, 4'b0010,
                        4'b0011, 4'b0100, 4'b0101, 4'b0110,
                        4'b0111, 4'b1101};
  }
  
  constraint boundary_a {
    a dist {
      8'h00 := 3,   
      8'h7F := 3,   
      8'h80 := 3,   
      8'hFF := 3,   
      [8'h01 : 8'h7E] :/ 5,
      [8'h81 : 8'hFE] :/ 5
    };
  }

  constraint boundary_b {
    b dist {
      8'h00 := 3,   
      8'h7F := 3,   
      8'h80 := 3,   
      8'hFF := 3,  
      8'h07 := 3,   
      [8'h01 : 8'h06] :/ 3,   
      [8'h08 : 8'h7E] :/ 3,
      [8'h81 : 8'hFE] :/ 3
    };
  }

  function void display(string name);
    $display("[%s] Opcode: %4b | A: 0x%02h | B: 0x%02h | Result: 0x%02h | Zero: %0b",
              name, alu_control, a, b, result, zero);
  endfunction

endclass
