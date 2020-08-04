//NAME: Vidulash Rajaratnam
//SNUM: 8190398

package MatchingCost

import (
	"fmt"
	"math"
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

//Function to calculate euclidean distance and form resulting slice of integers
func MatchingCostEuclidean(frame1 [][]string, frame2 [][]string)(result [][]int){
	for i:= 0;i<len(frame1);i++{
		var line []int
		for n:= 0;n<len(frame2);n++{
			value:= Euclidean(frame1[i],frame2[n])
			line = append(line,value)
		}
		result= append(result,line)

	}
	fmt.Print("----------EUCLIDEAN METHOD----------\n")
	PrintMatrix(result)
	return result
}

//Function that calculates the euclidean distance between two frames
func Euclidean(frameone []string, frametwo []string) (result int){
	oneh1,_ := strconv.ParseFloat(frameone[1],64)
	oneh2,_ := strconv.ParseFloat(frameone[3],64)
	oneh := (oneh1+oneh2+oneh1)/2 //145.5

	onew1,_ := strconv.ParseFloat(frameone[2],64)
	onew2,_ := strconv.ParseFloat(frameone[4],64)
	onew := (onew1+onew2+onew1)/2 //145.5

	twoh1,_ := strconv.ParseFloat(frametwo[1],64)
	twoh2,_ := strconv.ParseFloat(frametwo[3],64)
	twoh := (twoh1+twoh2+twoh1)/2 //145.5

	twow1,_ := strconv.ParseFloat(frametwo[2],64)
	twow2,_ := strconv.ParseFloat(frametwo[4],64)
	twow := (twow1+twow2+twow1)/2 //145.5

	result = int(math.Round(math.Pow(math.Pow(float64(twoh-oneh),2) + math.Pow(float64(twow-onew),2),0.5)))
	return result
}

//Function to calculate box area and form resulting slice of integers
func MatchingCostBoxArea(frame1 [][]string, frame2 [][]string)(result [][]int){
	for i:= 0;i<len(frame1);i++{
		var line []int
		for n:= 0;n<len(frame2);n++{
			value:= Boxarea(frame1[n],frame2[i])
			line = append(line,value)
		}
		result= append(result,line)

	}
	fmt.Print("----------AREA METHOD----------\n")
	PrintMatrix(result)
	return result
}

//Function that calculates the box area of two frames and returns their difference
func Boxarea(frameone []string, frametwo []string) (result int){
	oneh,_ := strconv.ParseFloat(frameone[3],64)
	onew,_ := strconv.ParseFloat(frameone[4],64)
	twoh,_ := strconv.ParseFloat(frametwo[3],64)
	twow,_ := strconv.ParseFloat(frametwo[4],64)
	f1area := oneh * onew
	f2area := twoh * twow
	result = int(math.Round(math.Abs(f1area - f2area)))
	return result
}
