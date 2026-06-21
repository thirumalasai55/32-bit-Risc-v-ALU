class transaction;
  rand bit [31:0] a;
  rand bit [31:0] b;
  rand bit [3:0]  alu_control;
  
  bit [31:0] result;
  bit        zero;

  // Constrain random generation for only required opcodes
  constraint valid_opcodes {
    alu_control inside {4'b0000, 4'b1000, 4'b0001, 4'b0010, 4'b0011, 
                        4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1101};
  }
  constraint boundary_a {
    a dist {
      32'h0000_0000 := 10, 
      32'h7FFF_FFFF := 10,
      32'h8000_0000 := 10,
      32'hFFFF_FFFF := 10,
      [32'h0000_0001 : 32'h7FFF_FFFE] :/ 30,
      [32'h8000_0001 : 32'hFFFF_FFFE] :/ 30
    };
  }

  constraint boundary_b {
    b dist {
      32'h0000_0000 := 10,
      32'h7FFF_FFFF := 10,
      32'h8000_0000 := 10,
      32'hFFFF_FFFF := 10,
      32'h0000_001F := 10, // 31 in decimal (max shift amount for 32-bit)
      [32'h0000_0001 : 32'h7FFF_FFFE] :/ 25,
      [32'h8000_0001 : 32'hFFFF_FFFE] :/ 25
    };
  }

  function void display(string name);
    $display("[%s] Opcode: %4b | A: 0x%08h | B: 0x%08h | Result: 0x%08h | Zero: %0b", 
              name, alu_control, a, b, result, zero);
  endfunction
endclass
