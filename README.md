# VLSI

This repository contains the project realized for the first module con Combinatorial Decision Making and Optimization exam.

Very large-scale integration (VLSI) is the process of creating an integrated circuit by combining multiple circuits on a single chip. The goal of this project is to design the VLSI of the circuits minimizing the final lenght of the device. We have developed different solutions both in CP and SMT.

## Requirements
It is required to install MiniZinc and add the executable to the PATH variable in the enviroment. For the SMT version is required a python installation. The libraries specified with the versions used are the following:
- minizinc
- z3-solver
- matplotlib
- numpy

## Usage
All the solvers are intuitively runned in the same way by executing `python solve.py` file in the folder `utilities`. By default all the 40 instances are solved.
