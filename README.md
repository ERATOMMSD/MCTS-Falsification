This tool is based on Breach (https://github.com/decyphir/breach).


# Requirements:
Matlab can be called from commandline. (Add Matlab path to the system PATH).
Python 2.7.



# Install and Run:
1. Install Breach following https://github.com/decyphir/breach;

2. set environment variable 'FALHOME=[path]', [path] is the tool path, e.g., /home/zhenya/FalSTAR/ (note: ending with '/' !!);

3. put Simulink model at src/model. The model is required to be a successfully compiled one;

4. write a configuration file following Configuration section below and put it (not necessarily) in src/test/config.

5. cd src/test, run 'python generate_benchmark.py [configuration file]'

6. cd src/benchmarks, run 'chmod 744 *'

7. cd ., open InitFalsification.m, modify the path of Breach

8. cd ., run 'make'


# Output:
Table in .csv, including 
filename, property, algorithm, optimization solver, control points, hyper-parameters
falsification result, time consumption, (falsified during preprocessing and time, falsified after preprocessing and time).


# Configuration:
format is like:
"
 block1
 block2
 ...
"

(note: no empty lines between blocks)

blocki's format is like:

"
 [string] [int]
 [stringlist]
"

[string] is one of the followings: 

model|algorithm|addpath|loadfile|input_name|input_range|optimization|phi|controlpoints|scalar|partitions|T_playout|N_max|parameters|timespan|T

and the number of lines of [stringlist] is equal to [int].

(Some examples are already in the folder.)
