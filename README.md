# Low-Power 8-Bit RISC-V ALU with Operand Isolation

This project implements a power-optimized 8-bit Arithmetic Logic Unit (ALU) tailored for the RISC-V instruction set architecture. Written in SystemVerilog, the design focuses on reducing dynamic power consumption using **Operand Isolation**—a technique that masks inputs to unused combinational hardware blocks to prevent unnecessary toggling.

The project includes a robust, object-oriented SystemVerilog verification environment complete with constrained random generation, functional coverage, SystemVerilog Assertions (SVA), and a custom toggle-tracking metric to quantify power savings.

## 🚀 Key Features

* **RISC-V Compatibility:** Supports 10 core operations (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND).
* **Low-Power Architecture:** Implements AND-gate masking to isolate inputs from dormant execution units, drastically reducing dynamic switching power.
* **Hardware Sharing:** Reuses a single adder/subtractor block for `ADD`, `SUB`, `SLT`, and `SLTU` instructions to save area.
* **OOP Verification Environment:** Custom testbench utilizing Transaction, Generator, Driver, Monitor, and Scoreboard classes.
* **Power Metrics Tracker:** The testbench calculates real-time toggle reduction by comparing the isolated DUT against an unisolated baseline model.
* **Coverage & Assertions:** Includes SystemVerilog Assertions for the `zero` flag and comprehensive `covergroups` for opcodes, boundary values, and cross-coverage.

---

## 🛠️ Design Architecture

The ALU design is divided into three primary stages:

### 1. Instruction Decoding

A 4-bit `alu_control` signal is decoded into individual one-hot enable signals (`en_add`, `en_xor`, etc.). These are logically grouped by hardware block (e.g., `en_arith` for addition/subtraction/comparisons, `en_bitwise` for logic operations).

### 2. Operand Isolation (Power Optimization)

Instead of feeding inputs `a` and `b` directly into all execution units simultaneously, the inputs are gated using the enable signals:

```systemverilog
assign a_arith = a & {8{en_arith}};
assign b_arith = b & {8{en_arith}};

```

When an arithmetic operation is not selected, `a_arith` and `b_arith` are forced to `0`. This prevents the complex adder/subtractor logic from evaluating and toggling, which is the primary source of dynamic power waste in standard ALU designs.

### 3. Execution Blocks & Output Muxing

* **Adder/Subtractor:** A unified combinational block handles `ADD`, `SUB`, and derivation of the `SLT` (Set Less Than) and `SLTU` (Set Less Than Unsigned) flags.
* **Shifters:** Manual gate-level implementations of logical left/right and arithmetic right shifts.
* **Output:** Because unselected blocks output `8'b0` due to isolation, the final result is efficiently routed using a wide bitwise `OR` rather than a complex multiplexer.

---

## 🧪 Verification Strategy

The testbench is built using a SystemVerilog class-based architecture, modeling a lightweight version of UVM.

* **Constrained Randomization:** The `transaction` class forces the randomizer to heavily target edge cases (`8'h00`, `8'h7F`, `8'h80`, `8'hFF`) to ensure the arithmetic boundaries and carry/overflow logic are fully stressed.
* **Golden Reference Scoreboard:** Computes expected results using high-level SV operators (`+`, `-`, `<<`, `$signed`) and compares them against DUT outputs on every clock cycle.
* **Functional Coverage:** Ensures 100% hits across all opcodes, critical operand values (max positive, min negative, zero), and their cross-coverage combinations.
* **SystemVerilog Assertions (SVA):** Bound via an interface to continuously monitor the `zero` flag integrity:
```systemverilog
property check_true_zero;
  @(posedge clk) disable iff (!rst_n)
  (result == 8'd0) |-> (zero == 1'b1);
endproperty

```



---

## 📊 Power Measurement Metrics

A unique feature of this project is the built-in power saving calculator. The testbench continuously models an "unisolated" adder in the background:

```systemverilog
// Testbench tracks toggles on both isolated (DUT) and unisolated (baseline) sums
if (dut.arith_sum != prev_sum) true_arith_toggles++;
if (unisolated_sum != prev_unisolated_sum) unisolated_arith_toggles++;

```

At the end of the 10,000-transaction simulation, the environment calculates the exact percentage of toggles prevented by the AND-masking logic. This provides immediate, quantifiable proof of the design's power efficiency.

## 💻 How to Run

1. Compile the `riscv_alu.sv` (design) and `tb_top.sv` (testbench) files using any SystemVerilog simulator (e.g., ModelSim, Questa, VCS, Xcelium, or open-source Icarus Verilog / Verilator with SV support).
2. Run the simulation. The testbench defaults to 10,000 randomized transactions.
3. Review the terminal output for:
* Scoreboard Pass/Fail counts.
* Functional Coverage percentage.
* The calculated **Toggle Reduction (Power Saved) Percentage**.


4. A `dump.vcd` file is automatically generated for waveform analysis in tools like GTKWave.
