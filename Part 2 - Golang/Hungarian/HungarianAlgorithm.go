//NAME: Vidulash Rajaratnam
//SNUM: 8190398

package Hungarian

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

//Function that prints out [][]int slice in a clear matrix format
func PrintMatrix(matrix [][]int){
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

//Function that concurrently reduces rows of matrix line by line and returns new row
func Rowreduct(input [][]int,s int, done chan bool) (line []int) {
	for i := s; i < s+1; i++ { //for each slice in the slice till x
		low := input[i][0] //First one will be assumed as the lowest
		for n := 0; n < len(input[i]); n++ { //for each int in the slice
			if input[i][n] < low { //if it is lower than current low
				low = input[i][n] //update low
			}
		}
		//Reduce each value in row by lowest value in row
		for n:= 0;n<len(input[i]);n++{
			newval := (input[i][n]-low)
			line = append(line,newval)
		}
	}
	done<- true //send true to done channel to indicate row has been reduced
	return line //return reduced row
}

//Function that concurrently reduces columns of matrix line by line and modified existing column
func Colreduct(input [][]int,s int, done chan bool){
	low := input[0][s]//First one will be assumed as the lowest
	for i := 0; i < len(input); i++ { //for each slice in the slice
		if input[i][s] < low { //if it is lower than current low
			low = input[i][s] //update low
		}
	}
	//Reduce each value in column by lowest value in column
	for i:= 0;i<len(input);i++{
		input[i][s] = (input[i][s]-low) //updates values in slice reduced by low
	}
	done<- true //send true to done channel to indicate column has been reduced
}

//Function that checks how many zeroes are in the column
func CheckColzeroes(input [][]int, s int, track [][]int) int{
	var total = 0
	for i:=0;i<len(input);i++{
		if (input[i][s]==0){
			if (track[i][s]==1)||(track[i][s]==-1){
				//skip
			}else{
				total++}
		}
	}
	return total
}//

//Function that checks how many zeroes are in the row
func CheckRowzeroes(input [][]int, s int, track [][]int) int{
	var total int = 0
	for i:=0;i<len(input[s]);i++{
		if (input[s][i]==0){
			if (track[s][i]==1)||(track[s][i]==-1){
				//skip
			}else{
				total++}
		}
	}
	return total
} //

//Function gets the row index when only 1 zero is present
func GetRowZeroIndex(input [][]int, s int) int{
	for i:=0;i<len(input[s]);i++{
		if (input[s][i]==0){
			return i
		}
	}
	return -1
}//

//Function that gets positions of all zeroes in a row and returns slice
func GetAllRowZeroIndex(input [][]int, s int, x int) (zeroes []int){
	for i:=0;i<len(input[s]);i++{
		if (input[s][i]==0){
			if i==x{
				//skip
			}else{zeroes = append(zeroes,i)}
		}
	}
	return zeroes
}//

//Function that gets positions of all zeroes in a column and returns slice
func GetAllColZeroIndex(input [][]int, s int, x int) (zeroes []int){
	for i:=0;i<len(input);i++ {
		if (input[i][s] == 0) {
			if i == x { //original row
				//skip
			} else {
				zeroes = append(zeroes, i) //keep track of which row
			}
		}
	}
	return zeroes //returns slice of zero positions
}//

//Function gets the column index when only 1 zero is present
func GetColZeroIndex(input [][]int, s int) int{
	for i:=0;i<len(input);i++{
		if (input[i][s]==0){
			return i
		}
	}
	return -1
}//

//Function that checks whether int at position in row x and column y is covered twice
func CoveredTwice(track [][]int,row int,col int) bool{
	if track[row][col]==4{
		return true
	}
	return false
}//

//Function that checks whether int at position is covered at least once
func IsCovered(track [][]int, row int,col int) bool{
	if track[row][col] == 3{
		return true
	}
	return false
}//

//Function that checks for smallest uncovered value and returns it
func SmallestUncovered(input [][]int, track [][]int) int{
	low := -1
	for i:=0;i<len(input);i++{
		for n:=0;n<len(input[i]);n++{
			if (track[i][n]==2){ //if not a 0
				if (!CoveredTwice(track,i,n)){ //if not covered twice
					if (!IsCovered(track,i,n)){ //if not covered at all
						if (low==-1){ //if low hasnt been initialized properly
							low = input[i][n]
						} else{ //if it has, check wheter next int is lower or not
							if input[i][n]<low{
								low = input[i][n] //if it is, make it the new low value
							}
						}
					}
				}
			}
		}
	}
	return low
}//

//Function that makes the optimal assignments in the matrix to cover all the zeroes with the least amount of lines
func OptimalAssignment2(input [][]int, track [][]int)(assignments int){
	fmt.Println("3. AFTER OPTIMAL ASSIGNMENT")
	fmt.Println("------------------------------------")
	fmt.Println("1: selected zero (covered) \n-1: zero (covered) \n2: uncovered")
	fmt.Println("3: covered once\n4: covered twice")
	fmt.Println("------------------------------------")

	assignments = 0
	//For rows
	for i:=0;i<len(input);i++{
		//fmt.Println(checkRowzeroes(input,i,track))
		if CheckRowzeroes(input,i,track)==1 { //if only 1 zero in the column
			index := GetRowZeroIndex(track,i)
			if (track[i][index]==-1){
				//skip
			} else {
				assignments ++
				track[i][index] = 1//make that 1 on the tracking matrix
				zeroesincolumn := GetAllColZeroIndex(track, index, i) //get all zeroes in the column associated with that position
				for n := 0; n < len(zeroesincolumn); n++ {
					track[zeroesincolumn[n]][index] = -1
				}
				//ADDED
				for n:=0;n<len(track[i]);n++{
					if(track[n][index]==2){
						track[n][index]=3 //if it hasn't been covered it is now covered denoted by a 3
					}
				}
			}
		}
		fmt.Println("Checking Row: ",i)
		PrintMatrix(track)
	}
	//For columns
	for i:=0;i<len(input[0]);i++ {
		//fmt.Println(checkColzeroes(input,i,track))
		if (CheckColzeroes(input,i,track))==1{
			index := GetColZeroIndex(track,i)
			if (track[index][i])==0{
				assignments ++
				track[index][i]= 1
				zeroesinrow := GetAllRowZeroIndex(track,index,i) //changed from input to track, getColZeroIndex(track,i) to index
				for n := 0; n < len(zeroesinrow); n++ {
					track[index][zeroesinrow[n]] = -1
				}
				//ADDED
				for n:=0;n<len(track[index]);n++{
					if(track[index][n]==2){
						track[index][n]=3 // if it hasn't been covered then its now covered once denoted by a 3
					}else if (track[index][n]==3){
						track[index][n]=4 //if its already been covered, its now covered twice denoted by a 4
					}
				}
			}
		}
		fmt.Println("Checking Column: ",i)
		PrintMatrix(track)
	}

	totalremaining := len(input)-assignments //calculate how many assignments left to make
	remainder := 0 //determine how many zeroes remaining
	nozero := false
	for i:=0;i<len(track);i++{
		for n:=0;n<len(track[i]);n++{
			if (track[i][n])==0{
				nozero = true
				remainder+=1
			}
		}
	}
	if (nozero){ //if there were zeroes
		if (remainder%totalremaining==1){
			assignments += totalremaining
		}else if (remainder%totalremaining==0){
			assignments += remainder/totalremaining
		}}
	if totalremaining!=0{
		if (remainder==1){
			assignments += totalremaining
		}}
	return assignments
}//

//Function that shifts zeros by getting the smallest value not covered by line and subtracting it from all uncovered values
//we also add this value to double covered lines
func ShiftingZeroes(input [][]int, track [][]int){
	smallest := SmallestUncovered(input,track)
	fmt.Println("Smallest uncovered:", smallest)

	//Subtract lowest value from all uncovered values
	for i:=0;i<len(input);i++{
		for n:=0;n<len(input[i]);n++{
			if (track[i][n]==2){ //if not a 0
				if (!CoveredTwice(track,i,n)){ //if not covered twice
					if (!IsCovered(track,i,n)){ //if not covered at all
						input[i][n] = input[i][n]-smallest
					}
				}
			}
		}
	}
	//If covered twice, add smallest value
	for i:=0;i<len(input);i++{
		for n:=0;n<len(input[i]);n++{
			if (track[i][n]==4){ //if not a 0
				if (CoveredTwice(track,i,n)){ //if covered twice
					input[i][n] = input[i][n]+smallest
				}
			}
		}
	}
	fmt.Print("4. AFTER SHIFTING ZEROES \n")
	fmt.Println("------------------------------------")
	PrintMatrix(input)
}//

//Function that makes final assignments and prints the new matrix and calculates the final total cost
func FinalAssignments2(input [][]int, track [][]int) int{
	total:= 0
	fmt.Print("Final Assigned Matrix: (FILE SAVED)\n")
	if (AllZeroes(track)){
		for i:= 0;i<len(input);i++{
			fmt.Print("[ ")
			for n:= 0;n<len(input[i]);n++{
				if (i==n){
					fmt.Print("(",input[i][n],") ")
					total += input[i][n]
				}else{
					fmt.Print(input[i][n]," ")}
			}
			fmt.Print("] \n")
		}
	}else {
		for i := 0; i < len(input); i++ {
			fmt.Print("[ ")
			for n := 0; n < len(input[i]); n++ {
				if (track[i][n] == 1) { //if marked to be selected
					total += input[i][n] //add to total
					fmt.Print("(", input[i][n], ") ")
				} else if (track[i][n] == 0) {
					if (NoOtherAssignment(track, n, i)) { //if no other selected in the column
						if (AZeroIntersection(track, n, i)) {
							if (AZeroIntersectionOpposite(track, n, i)) {
								r, c := GetZeroIntersectionOpposite(track, n, i)
								track[r][c] = 1
								track[i][n] = 1      //make it now selected
								total += input[i][n] //add to total
								fmt.Print("(", input[i][n], ") ")
							} else {
								fmt.Print(input[i][n], " ")
							}
						} else {
							track[i][n] = 1      //make it now selected
							total += input[i][n] //add to total
							fmt.Print("(", input[i][n], ") ")
						}
					} else {
						fmt.Print(input[i][n], " ")
					}
				} else {
					fmt.Print(input[i][n], " ")
				}
			}
			fmt.Print("] \n")
		}
	}
	fmt.Print("\n")
	return total
}//

//Function that checks whether there was other assignments (selected 1) in the column
func NoOtherAssignment(track [][]int,col int, x int) bool{
	var check = true
	for i:=0;i<len(track);i++ {
		if (track[i][col] == 1){
			if i == x { //original row
				//skip
			} else {  //if any 1 in the col, return false
				check = false
			}
		}
	}
	for i:=0;i<len(track[x]);i++ {
		if (track[x][i] == 1){
			if i == col { //original row
				//skip
			} else { //if any 1 in the row, return false
				check = false
			}
		}
	}
	return check
}//

//Function that checks whether there was other zeroes in the same column and row
func AZeroIntersection(track [][]int,col int, x int) bool{
	var check = false
	for i:=0;i<len(track);i++ {
		if (track[i][col] == 0){
			if i == x { //original row
				//skip
			} else {  //if any 0 in the col, return false
				for n:=0;n<len(track[x]);n++ {
					if (track[x][n] == 0){
						if n == col { //original row
							//skip
						} else { //if any 0 in the row, return false
							check = true
						}
					}
				}
			}
		}
	}
	return check
}//

//Function that checks if there is a zero at the opposite position
func AZeroIntersectionOpposite(track [][]int,col int, x int) bool{
	var r int
	var c int
	for i:=0;i<len(track);i++ {
		if (track[i][col] == 0){
			if i == x { //original row
				//skip
			} else {  //if any 0 in the col, return false
				r = i

				for n:=0;n<len(track[x]);n++ {
					if (track[x][n] == 0){
						if n == col { //original row
							//skip
						} else { //if any 0 in the row, return false
							c = n

						}
					}
				}
			}
		}
	}
	if (track[r][c]==0){
		return true
	}
	return false
}//

//Function that returns the opposite zero position
func GetZeroIntersectionOpposite(track [][]int,col int, x int) (int,int){
	var r int
	var c int
	for i:=0;i<len(track);i++ {
		if (track[i][col] == 0){
			if i == x { //original row
				//skip
			} else {  //if any 0 in the col, return false
				r = i

				for n:=0;n<len(track[x]);n++ {
					if (track[x][n] == 0){
						if n == col { //original row
							//skip
						} else { //if any 0 in the row, return false
							c = n

						}
					}
				}
			}
		}
	}
	if (track[r][c]==0){
		return r,c
	}
	return -1,-1
}//

//Function that creates csv file from final data
func CreateOptimalCSV(input [][]int,track [][]int, frame1 [][]string, frame2 [][]string){
	var data [][]string
	total:= 0
	if (AllZeroes(track)) {
		for i := 0; i < len(input); i++ {
			var dataline []string
			dataline = append(dataline, frame1[i][0])
			for n := 0; n < len(input[i]); n++ {
				if (i==n){
					total += input[i][n]
					dataline = append(dataline, frame2[n][0])
				}
			}
			data = append(data, dataline)
		}
	}else {
		for i := 0; i < len(input); i++ {
			var dataline []string
			dataline = append(dataline, frame1[i][0])
			for n := 0; n < len(input[i]); n++ {
				if (track[i][n] == 1) { //if marked to be selected
					total += input[i][n] //add to total
					dataline = append(dataline, frame2[n][0])
				} else if (track[i][n] == 0) {
					if (NoOtherAssignment(track, n, i)) { //if no other selected in the column
						track[i][n] = 1      //make it now selected
						total += input[i][n] //add to total
						dataline = append(dataline, frame2[n][n])
					}
				}
			}
			data = append(data, dataline)
		}
	}
	var costline []string
	costline = append(costline,"Cost:")
	costline = append(costline,strconv.Itoa(total))
	data = append(data,costline)

	n := strconv.Itoa(len(input))
	var filename = ("tracker_go_") + n + (".csv")
	csvFile, err := os.Create(filename)

	if err != nil {
		log.Fatalf("Error: Could not create file: %s", err)
	}
	csvwriter := csv.NewWriter(csvFile)
	for _, datarow:= range data {
		_ = csvwriter.Write(datarow)
	}
	csvwriter.Flush()
	csvFile.Close()
}

//Function that looks at if all the remaining in the tracker matrix are zeroes
func AllZeroes(track [][]int)bool{
	result:= true
	for i:=0;i<len(track);i++ {
		for n:=0;n<len(track[i]);n++ {
			if (track[i][n]!=0){
				result = false
			}
		}
	}
	return result
}//


