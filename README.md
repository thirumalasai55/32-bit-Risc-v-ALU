# 32-bit RISC-V ALU Functional Verification

## Architecture Overview
This project successfully executes the complete functional verification of a 32-bit RISC-V Arithmetic Logic Unit (ALU) supporting the base integer (RV32I) instruction set. The primary objective was to mathematically prove the design's reliability using an industry-standard, Object-Oriented SystemVerilog testbench. Instead of relying on basic directed tests, the environment employs **Constrained-Random Verification (CRV)** to aggressively stress-test the hardware.

The architecture mirrors a professional **Universal Verification Methodology (UVM)** setup. It features a layered environment containing a Transaction class, Generator, Driver, Monitor, and Scoreboard. A **Golden Reference Model** is integrated directly into the Scoreboard, providing automated, real-time checking of the ALU's arithmetic, logical, and shift outputs, alongside the critical zero flag.

## Strategic Test Plan
A core achievement of this project is the strategic implementation of distribution constraints. The randomized stimulus is specifically engineered to target physical hardware vulnerabilities:
* **Boundary Biasing:** Using absolute and distributed weights, the generator forces extreme boundary conditions, including absolute zero, maximum positive values, maximum negative values, and all-ones. 
* **Shifter Constraints:** The testbench intelligently slices the shift operand to exactly five bits (`b[4:0]`), guaranteeing that the barrel shifter is rigorously evaluated strictly within its physical 31-bit limitation without wasting simulation cycles on invalid data.

## Verification Results & Coverage Model
By combining heavily biased random stimulus generation with strict, automated results checking, the environment successfully triggered every defined hardware corner case across **10,000 randomized transactions**. 

**Final Metric:** The final verification suite achieved a mathematically proven Functional Coverage score of exactly **100.00%**, demonstrating that the RISC-V ALU design is fundamentally ready for integration into a complete pipelined processor architecture.

### Simulation Output Proof
<img width="1636" height="817" alt="image" src="https://github.com/user-attachments/assets/64671864-7ec0-4957-957e-7d978b54b4f9" />
