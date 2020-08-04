//NAME: Vidulash Rajaratnam
//SNUM: 8190398

package main

import (
	"CompAssignment1/Hungarian"
	"CompAssignment1/MatchingCost"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"time"
)

//Function that prints out [][]int slice in a clear matrix format
func printMatrix(matrix [][]int){
	fmt.Print("Current Matrix:\n")
	for i:= 0;i<len(matrix);i++{
		fmt.Print("[ ")
		for n:= 0;n<len(matrix[i]);n++{
			fmt.Print(matrix[i][n]," ")
		}
		fmt.Print("] \n")
	}
	fmt.Print("\n")
}

//Main program function
func main() {
	var file1,file2 string
	//Get user input for start and end positions
	fmt.Print("----------WELCOME TO FACE TRACKER GOLANG----------","\n")
	fmt.Print("Input frame 1 path:","\n")
	fmt.Scanln(&file1)
	fmt.Print("Input frame 2 path:","\n")
	fmt.Scanln(&file2)

	//If user does not give frame file input, gives error message and calls main fucntion again
	if (len(file2)==0 || len(file1)==0){
		fmt.Print("INVALID! Please input both file path","\n")
		main()
		os.Exit(1) //Exits after
	}

	// Opens file for both frames, shows error message if file could not be opened
	frame1, err := os.Open(file1)
	if err != nil {
		log.Fatalln("ERROR: File ",file1," could not be opened", err)
	}
	frame2, err := os.Open(file2)
	if err != nil {
		log.Fatalln("ERROR: File ",file2," could not be opened", err)
	}

	// Parse the files for both frames once opened
	f1 := csv.NewReader(frame1)
	f2 := csv.NewReader(frame2)

	var finalframe1 [][]string
	var finalframe2 [][]string

	// Iterate through the files to make slice of each line
	for {
		frame1slice, err := f1.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		finalframe1 = append(finalframe1, frame1slice)
	}
	for {
		frame2slice, err := f2.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		finalframe2 = append(finalframe2, frame2slice)
	}

	//Get user option for method
	var methodchoice int
	fmt.Println("Which method would you like to use to calculate cost?")
	fmt.Println("1. Euclidean Method")
	fmt.Println("2. Area Method")
	fmt.Print("Choice: ")
	fmt.Scanln(&methodchoice)

	//If user selects ProgramPackages method
	if (methodchoice==1) {
		step1 := MatchingCost.MatchingCostEuclidean(finalframe1, finalframe2)
		//Section for concurrent row reduction
		var rowredresult [][]int                        //result of row reduction
		rowreductchannel := make(chan bool, len(step1)) //create channel to track row reductions
		for i := 0; i < len(step1); i++ {               //iterates through rows
			time.Sleep(1 * time.Millisecond)
			go func() {
				rowredresult = append(rowredresult, Hungarian.Rowreduct(step1, i-1, rowreductchannel)) //go function to reduce row
			}()
		}
		done1 := <-rowreductchannel //Receive confirmation
		if done1 {                  //If row reduction complete, print matrix
			fmt.Print("1. AFTER ROW REDUCTION \n")
			printMatrix(rowredresult)
		} else { //If an error occurs
			fmt.Print("Error: In concurrent row reduction", done1)
		}
		close(rowreductchannel) //close row reduction channel since its completed

		//Section for concurrent column reduction
		colreductchannel := make(chan bool, len(rowredresult[0])) //create channel to track column reductions
		for i := 0; i < len(rowredresult[0]); i++ {               //iterates through columns
			time.Sleep(1 * time.Millisecond)
			go func() {
				Hungarian.Colreduct(rowredresult, i, colreductchannel) //go function to reduce column
			}()
			time.Sleep(1 * time.Millisecond)
		}
		done2 := <-colreductchannel //Receive confirmation
		if done2 {                  //If column reduction complete, print matrix
			fmt.Print("2. AFTER COLUMN REDUCTION \n")
			printMatrix(rowredresult)
		} else { //If an error occurs
			fmt.Print("Error: In concurrent column reduction", done2)
		}
		close(colreductchannel) //close column reduction channel since its completed

		//Begins hungarian algorithm

		//making a copy of matrix to keep track of changes with 0s
		var tracker [][]int
		for i:=0;i<len(rowredresult);i++{
			var line []int
			for n:=0;n<len(rowredresult[i]);n++{
				if (rowredresult[i][n]!=0){
					line = append(line,2)
				} else{
					line = append(line,0)
				}
			}
			tracker = append(tracker,line)
		}
		assignments := Hungarian.OptimalAssignment2(rowredresult,tracker)
		//fmt.Println("Total Assignments: ",assignments,"\n")

		var hold [][]int
		var entered = false //boolean to check if
		for (assignments) < len(rowredresult){
			if (entered){
				Hungarian.ShiftingZeroes(rowredresult,hold) //shift zeroes
			}else{
				Hungarian.ShiftingZeroes(rowredresult,tracker)} //shift zeroes
			entered = true
			var tracker [][]int //reset tracking matrix
			for i:=0;i<len(rowredresult);i++{
				var line []int
				for n:=0;n<len(rowredresult[i]);n++{
					if rowredresult[i][n]!=0 {
						line = append(line,2)
					} else{
						line = append(line,0)
					}
				}
				tracker = append(tracker,line)
			}
			hold = tracker
			assignments = Hungarian.OptimalAssignment2(rowredresult,tracker) //check optimal assignment again
			//fmt.Println("Total Assignments: ",assignments)
		}

		//Checks whether program had to shift values
		if (entered){
			fmt.Println("5. MAKING FINAL ASSIGNMENTS")
			fmt.Println("------------------------------------")
			total2 := Hungarian.FinalAssignments2(step1,hold)
			fmt.Println("Total cost: ",total2)
			Hungarian.CreateOptimalCSV(step1,hold,finalframe1,finalframe2)

		}else{
			fmt.Println("5. MAKING FINAL ASSIGNMENTS")
			fmt.Println("------------------------------------")
			total2 := Hungarian.FinalAssignments2(step1,tracker)
			fmt.Println("Total cost: ",total2)
			Hungarian.CreateOptimalCSV(step1,tracker,finalframe1,finalframe2)
		}


	} else if (methodchoice==2){
		step1 := MatchingCost.MatchingCostBoxArea(finalframe1, finalframe2)

		//Section for concurrent row reduction
		var rowredresult [][]int                        //result of row reduction
		rowreductchannel := make(chan bool, len(step1)) //create channel to track row reductions
		for i := 0; i < len(step1); i++ {               //iterates through rows
			time.Sleep(1 * time.Millisecond)
			go func() {
				rowredresult = append(rowredresult, Hungarian.Rowreduct(step1, i-1, rowreductchannel)) //go function to reduce row
			}()
		}
		done1 := <-rowreductchannel //Receive confirmation
		if done1 {                  //If row reduction complete, print matrix
			fmt.Print("1. AFTER ROW REDUCTION \n")
			printMatrix(rowredresult)
		} else { //If an error occurs
			fmt.Print("Error: In concurrent row reduction", done1)
		}
		close(rowreductchannel) //close row reduction channel since its completed

		//Section for concurrent column reduction
		colreductchannel := make(chan bool, len(rowredresult[0])) //create channel to track column reductions
		for i := 0; i < len(rowredresult[0]); i++ {               //iterates through columns
			time.Sleep(1 * time.Millisecond)
			go func() {
				Hungarian.Colreduct(rowredresult, i, colreductchannel) //go function to reduce column
			}()
			time.Sleep(1 * time.Millisecond)
		}
		done2 := <-colreductchannel //Receive confirmation
		if done2 {                  //If column reduction complete, print matrix
			fmt.Print("2. AFTER COLUMN REDUCTION \n")
			printMatrix(rowredresult)
		} else { //If an error occurs
			fmt.Print("Error: In concurrent column reduction", done2)
		}
		close(colreductchannel) //close column reduction channel since its completed

		//Begins hungarian algorithm
		//making a copy of matrix to keep track of changes with 0s
		var tracker [][]int
		for i:=0;i<len(rowredresult);i++{
			var line []int
			for n:=0;n<len(rowredresult[i]);n++{
				if (rowredresult[i][n]!=0){
					line = append(line,2)
				} else{
					line = append(line,0)
				}
			}
			tracker = append(tracker,line)
		}
		assignments := Hungarian.OptimalAssignment2(rowredresult,tracker)
		//fmt.Println("Total Assignments: ",assignments,"\n")

		var hold [][]int
		var entered = false //boolean to check if
		for (assignments) < len(rowredresult){
			if (entered){
				Hungarian.ShiftingZeroes(rowredresult,hold) //shift zeroes
			}else{
				Hungarian.ShiftingZeroes(rowredresult,tracker)} //shift zeroes
			entered = true
			var tracker [][]int //reset tracking matrix
			for i:=0;i<len(rowredresult);i++{
				var line []int
				for n:=0;n<len(rowredresult[i]);n++{
					if rowredresult[i][n]!=0 {
						line = append(line,2)
					} else{
						line = append(line,0)
					}
				}
				tracker = append(tracker,line)
			}
			hold = tracker
			assignments = Hungarian.OptimalAssignment2(rowredresult,tracker) //check optimal assignment again
			//fmt.Println("Total Assignments: ",assignments)
		}

		//Checks whether program had to shift values
		if (entered){
			fmt.Println("5. MAKING FINAL ASSIGNMENTS")
			fmt.Println("------------------------------------")
			total2 := Hungarian.FinalAssignments2(step1,hold)
			fmt.Println("Total cost: ",total2)
			Hungarian.CreateOptimalCSV(step1,hold,finalframe1,finalframe2)

		}else{
			fmt.Println("5. MAKING FINAL ASSIGNMENTS")
			fmt.Println("------------------------------------")
			total2 := Hungarian.FinalAssignments2(step1,tracker)
			fmt.Println("Total cost: ",total2)
			Hungarian.CreateOptimalCSV(step1,tracker,finalframe1,finalframe2)
		}

	}else{
		fmt.Print("Invalid: Not a valid choice, restart program.")
	}



}
