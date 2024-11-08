# CDMO
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
