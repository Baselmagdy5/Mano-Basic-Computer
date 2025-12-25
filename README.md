# Mano-Basic-Computer
# Mano Basic Computer in VHDL

This project implements the **Mano Basic Computer** architecture (from M. Morris Mano’s *Computer System Architecture*) using **VHDL**.  
It models the core datapath and control logic of the educational 16-bit accumulator-based processor, making it useful for learning computer architecture and digital design concepts.

## Features
- 16-bit accumulator architecture
- Common registers (AC, DR, IR, PC, AR, TR)
- ALU operations and micro-operations
- Instruction cycle and control sequencing
- Memory read/write operations
- Simulation-ready testbench support

## Project Structure
- `src/` – VHDL source files
- `tb/` – testbenches
- `docs/` – diagrams and notes (optional)
- `project/` – tool-specific project files (optional)

## Tools
You can simulate or synthesize using:
- ModelSim / Questa
- Vivado
- GHDL + GTKWave

## How to Run
1. Add all VHDL files to your project.
2. Compile sources.
3. Run the provided testbench or create your own.
4. View waveforms to observe instruction execution.

## Educational Use
This project is intended **for learning and experimentation**, not production use.

## License
MIT (or your preferred license)

