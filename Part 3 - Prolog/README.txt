NAME: Vidulash Rajaratnam
SNUM: 8190398
COURSE: CSI2120

For Comprehensive Assignment Part 2 - Prolog:
I have included 1 pl file named as the following:

1. PrologSolution.pl

Program will create 1 csv files in WORKING directory:

2. tracking_prolog_n.csv

*NOTE*
*Provided frame csv files are also included for testing. 
*MAKE sure to place the COST_MATRIX_N csv file in prolog working directory.
*Program will SAVE result file in that prolog working directory.
*Please test the following as shown from the assignment PDF:

readCostMatrixCSV( "cost_matrix_3.csv", CostMatrix),hungarianMatch(CostMatrix, OptimalAssign,OptimalCost),saveOptimalAssignment( OptimalAssign, "tracker_prolog_3.csv").

*Cost matrix must be inputted as: [['','I','II'],['A',10,10],['B',10,10]] 
format if want to test DIRECTLY into hungarianMatch, for the program
to get assignments with column and row names.
       




