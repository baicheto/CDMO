# Multiple Couriers Planning (MCP) Problem

This repository contains the project work for the **Combinatorial Decision Making and Optimization** course (academic year 2023/2024). The project focuses on modeling and solving the **Multiple Couriers Planning (MCP)** problem using various optimization approaches, including:

1. **Constraint Programming (CP)**
2. **Propositional Satisfiability (SAT) and/or Satisfiability Modulo Theories (SMT)**
3. **Mixed-Integer Linear Programming (MIP)**

## Problem Description

The MCP problem arises in the context of efficiently scheduling couriers to deliver items to customers, minimizing transportation costs. The problem is formally defined as follows:

- **Inputs:**
  - `m`: Number of couriers.
  - `n`: Number of items (`n >= m`).
  - `l1, l2, ..., lm`: Maximum load size for each courier.
  - `s1, s2, ..., sn`: Size of each item.
  - Distance matrix `D`:
    - `Di,j`: Distance between distribution points `i` and `j`.
    - `Dn+1`: Origin point (courier's start and end location).

- **Constraints:**
  - Each courier must start and end their route at the origin point.
  - Each courier's assigned items must not exceed their maximum load.
  - Routes must be planned for all couriers to deliver assigned items.

- **Objective:**
  - Minimize the maximum distance traveled by any courier.

### Input Format
Instances of MCP are provided as text files with the following structure:
```
m n l1 l2 ... lm
s1 s2 ... sn
D1,1 D1,2 ... D1,n+1
D2,1 D2,2 ... D2,n+1
...
Dn+1,1 Dn+1,2 ... Dn+1,n+1
```
Example:
```
3 7 15 10 7
3 2 6 8 5 4 4
0 3 3 6 5 6 6 2
3 0 4 3 4 7 7 3
3 4 0 7 6 3 3 4
6 3 7 0 3 4 7 3
5 4 6 3 0 6 3 4
6 7 3 4 6 0 2 4
6 7 3 7 3 2 0 4
2 3 4 3 4 4 4 0
```


### Modeling Approaches

1. **Constraint Programming (CP):**
   - Model implemented in **MiniZinc**.
   - Use of **Chuffed** and **Gecode** solver.

2. **Propositional SAT/SMT:**
   - SMT model implemented.

3. **Mixed-Integer Linear Programming (MIP):**
   - Use of MIP solver (Gurobi)


# To Run:
Combinatorial Decision Making and Optimisation Project 
to run the docker file for SMT:
0) need to be in the SMT folder
1) docker build . -t image -f DockerFile
2) docker run -it -v "$(pwd)/instances:/src/instances" image

to run solution checker for SMT files run through docker:
0) need to be in the SMT folder
1) 

to run the docker file for CP:
0) need to be in the CP folder
1) docker build . -t image -f DockerFile
2) docker run -it -v "$(pwd)/instances:/src/instances" image

to run solution checker for CP files run through docker:
0) need to be in the CP folder
1) 

to run the docker file for MIP:

to run the solution checker for the instances run in our local machines: 
0) You need to be in the Checker folder -> then copy the name of the solution checker: sol_checker.py
1) You then need to go to the Test_data folder -> copy as the input the full path of the instance folder, 
containing all .dat files
2) The last path that needs to be copied is the one for the results folder:
3) If you want to run the results of the CP, you need to copy the full path of the results_cp folder
4) Respectively, for SMT is results_smt folder and for MIP results_mip folder
5) The full command should look like this:
6) python sol_checker.py /Users/user/Desktop/Strawberries_Project/Checker/Test_data/instances /Users/user/Desktop/Strawberries_Project/Checker/Test_data/results_cp/
