//Name: Vidulash Rajaratnam
//SNum: 8190398

//Class responsible for the hungarian algorithm
public class HungarianAlgorithm {

    //Main method running hungarian algorithm, identifies and returns assignments
    public int[][] Hungarian(int[][] matrix) {
        printMatrix(matrix); //Print reduced matrix
        System.out.println("");
        //Reduce the matrix by rows
        int[][] newmatrix = new int[matrix.length][matrix[0].length];
        for (int i = 0; i < matrix.length; i++) {
            newmatrix[i] = RowReduction(matrix[i]);
        }
        System.out.println("1. AFTER ROW REDUCTION");
        System.out.println("------------------------------------");
        printMatrix(newmatrix); //Print reduced matrix
        System.out.println("");

        //Reduce the matrix by columns
        for (int i = 0; i < matrix[0].length; i++) {
            ColReduction(newmatrix);
        }
        System.out.println("2. AFTER COLUMN REDUCTION");
        System.out.println("------------------------------------");
        printMatrix(newmatrix); //Print reduced matrix
        System.out.println("");

        // Make tracking matrix
        int[][] tracker = new int[newmatrix.length][newmatrix[0].length];
        for (int i = 0; i < newmatrix.length; i++) {
            for (int n = 0;n<newmatrix[i].length;n++){
                if (newmatrix[i][n]!=0){
                    tracker[i][n] = 2;
                }
                else if (newmatrix[i][n]==0){
                    tracker[i][n] = 0;
                }
            }
        }

        int assignments = OptimalAssignment2(newmatrix,tracker);
        int[][] hold = tracker;
        boolean entered = false; //boolean to check if
        while (assignments < newmatrix.length){
            if (entered){
                ShiftingZeroes(newmatrix,hold); //shift zeroes
            }else{
                ShiftingZeroes(newmatrix,tracker);} //shift zeroes
            entered = true;
            for (int i = 0; i < newmatrix.length; i++) {
                for (int n = 0;n<newmatrix[i].length;n++){
                    if (newmatrix[i][n]!=0){
                        tracker[i][n] = 2;
                    }
                    else{
                        tracker[i][n] = 0;
                    }
                }
            }
            hold = tracker;
            assignments = OptimalAssignment2(newmatrix,tracker); //check optimal assignment again
            //fmt.Println("Total Assignments: ",assignments)
        }

        //Checks whether program had to shift values
        if (entered){
            int[][] total2 = FinalAssignments2(newmatrix,hold);
            return total2;

        }else{
            int[][] total2 = FinalAssignments2(newmatrix,tracker);
            return total2;
        }
    }

    //Function that makes the optimal assignments in the matrix to cover all the zeroes with the least amount of lines
    private int OptimalAssignment2(int[][] matrix, int[][] tracker){
        //Begin step 3, optimal assignments
        System.out.println("3. AFTER OPTIMAL ASSIGNMENT");
        System.out.println("------------------------------------");
        System.out.println("1: selected zero (covered) \n-1: zero (covered) \n2: uncovered");
        System.out.println("3: covered once\n4: covered twice");
        System.out.println("------------------------------------");

        int assignments = 0;
        //For rows
        for ( int i=0;i<matrix.length;i++){
            if (CheckRowZeroes(matrix,tracker,i)==1) { //if only 1 zero in the column
                int index = GetRowZeroIndex(tracker,i);
                if (tracker[i][index]==-1){
                    //skip
                } else {
                    assignments ++;
                    tracker[i][index] = 1;//make that 1 on the tracking matrix
                    int[] zeroesincolumn = GetAllColZeroIndex(tracker, index, i);//get all zeroes in the column associated with that position
                    for (int n = 0; n < zeroesincolumn.length; n++) {
                        tracker[zeroesincolumn[n]][index] = -1;
                    }
                    //ADDED
                    for (int n=0;n<tracker[i].length;n++){
                        if(tracker[n][index]==2){
                            tracker[n][index]=3; //if it hasn't been covered it is now covered denoted by a 3
                        }
                    }
                }
            }
            System.out.println("Checking Row: "+i);
            printMatrix(tracker);
            System.out.println();
        }
        //For columns
        for (int i=0;i<matrix[0].length;i++) {
            if (CheckColZeroes(matrix,tracker,i)==1){
                int index = GetColZeroIndex(tracker,i);
                if ((tracker[index][i])==0){
                    assignments ++;
                    tracker[index][i]= 1;
                    int[] zeroesinrow = GetAllRowZeroIndex(tracker,index,i); //changed from input to track, getColZeroIndex(track,i) to index
                    for (int n = 0; n < zeroesinrow.length; n++) {
                        tracker[index][zeroesinrow[n]] = -1;
                    }
                    //ADDED
                    for (int n=0;n<tracker[index].length;n++){
                        if(tracker[index][n]==2){
                            tracker[index][n]=3; // if it hasn't been covered then its now covered once denoted by a 3
                        }else if (tracker[index][n]==3){
                            tracker[index][n]=4;//if its already been covered, its now covered twice denoted by a 4
                        }
                    }
                }
            }
            System.out.println("Checking Column: "+i);
            printMatrix(tracker);
            System.out.println();

        }

        int totalremaining = matrix.length-assignments; //calculate how many assignments left to make
        int remainder = 0; //determine how many zeroes remaining
        boolean nozero = false;
        for (int i=0;i<tracker.length;i++){
            for(int n=0;n<tracker[i].length;n++){
                if ((tracker[i][n])==0){
                    nozero = true;
                    remainder+=1;
                }
            }
        }
        if (nozero){ //if there were zeroes
            if (remainder%totalremaining==1){
                assignments += totalremaining;
            }else if (remainder%totalremaining==0){
                assignments += remainder/totalremaining;
            }}
        if (totalremaining!=0){
            if (remainder==1){
                assignments += totalremaining;
            }}

        return assignments;
    }

    //Function that shifts zeros by getting the smallest value not covered by line and subtracting it from all uncovered values
    //we also add this value to double covered lines
    private void ShiftingZeroes(int[][] input, int[][] track){
        int smallest = SmallestUncovered(input,track);
        System.out.println("Smallest uncovered: "+smallest);

        //Subtract lowest value from all uncovered values
        for (int i=0;i<input.length;i++){
            for (int n=0;n<input[i].length;n++){
                if (track[i][n]==2){ //if not a 0
                    if (!CoveredTwice(track,i,n)){ //if not covered twice
                        if (!IsCovered(track,i,n)){ //if not covered at all
                            input[i][n] = input[i][n]-smallest;
                        }
                    }
                }
            }
        }
        //If covered twice, add smallest value
        for (int i=0;i<input.length;i++){
            for (int n=0;n<input[i].length;n++){
                if (track[i][n]==4){ //if not a 0
                    if (CoveredTwice(track,i,n)){ //if covered twice
                        input[i][n] = input[i][n]+smallest;
                    }
                }
            }
        }
        System.out.println("4. AFTER SHIFTING ZEROES");
        System.out.println("------------------------------------");
        printMatrix(input);
    }

    //Function that makes final assignments and prints the new matrix and calculates the final total cost
    private int[][] FinalAssignments2(int[][] input, int[][] track){
        int[][] assignements = new int[input.length][2];
        if (AllZeroes(track)){
            for (int i= 0;i<input.length;i++){
                for (int n= 0;n<input[i].length;n++){
                    if (i==n){
                        assignements[i][0] = i;
                        assignements[i][1] = n;
                    }
                }
            }
        }else {
            for (int i = 0; i < input.length; i++) {
                for ( int n = 0; n < input[i].length; n++) {
                    if (track[i][n] == 1) { //if marked to be selected
                        assignements[i][0] = i;
                        assignements[i][1] = n;
                    } else if (track[i][n] == 0) {
                        if (NoOtherAssignment(track, n, i)) { //if no other selected in the column
                            if (AZeroIntersection(track, n, i)) {
                                if (AZeroIntersectionOpposite(track, n, i)) {
                                    int[] result = GetZeroIntersectionOpposite(track, n, i);
                                    track[result[0]][result[1]] = 1;
                                    track[i][n] = 1;      //make it now selected
                                    assignements[i][0] = i;
                                    assignements[i][1] = n;
                                }
                            } else {
                                track[i][n] = 1;      //make it now selected
                                assignements[i][0] = i;
                                assignements[i][1] = n;
                            }
                        }
                    }
                }
            }
        }
        return assignements;
    }

    //Function that checks how many zeroes are in the column
    private int CheckRowZeroes(int[][] input, int[][] track, int s){
        int total = 0;
        for (int i = 0;i<input[s].length;i++){
            if (input[s][i]==0){
                if ((track[s][i]==1)||(track[s][i]==-1)){
                    //skip
                }
                else{
                    total++;
                }
            }
        }
        return total;
    }

    //Function that checks how many zeroes are in the row
    private int CheckColZeroes(int[][] input, int[][] track, int s){
        int total = 0;
        for (int i = 0; i<input.length;i++){
            if (input[i][s]==0){
                if ((track[i][s]==1)||(track[i][s]==-1)){
                    //skip
                }else{
                    total++;}
            }
        }
        return total;
    }

    //Function gets the row index when only 1 zero is present
    private int GetRowZeroIndex(int[][] input, int s){
        for(int i =0;i<input.length;i++){
            if (input[s][i]==0){
                return i;
            }
        }
        return -1;
    }

    //Function that gets positions of all zeroes in a row and returns slice
    private int[] GetAllRowZeroIndex(int[][] input, int s, int x){
        int[] zeroes = new int[input[s].length];
        int index = 0;
        for (int i =0;i<input[s].length;i++){
            if (input[s][i]==0){
                if (i==x){
                    //skip
                }else{
                    zeroes[index] = i;
                    index++;
                }
            }
        }
        return zeroes;
    }

    //Function that gets positions of all zeroes in a column and returns slice
    private int[] GetAllColZeroIndex(int[][] input, int s, int x){
        int[] zeroes = new int[input.length];
        int index = 0;
        for (int i =0;i<input.length;i++){
            if (input[i][s]==0){
                if (i==x){
                    //skip
                }else{
                    zeroes[index] = i;
                    index++;
                }
            }
        }
        return zeroes;
    }

    //Function gets the column index when only 1 zero is present
    private int GetColZeroIndex(int[][] input, int s){
        for(int i =0;i<input.length;i++){
            if (input[i][s]==0){
                return i;
            }
        }
        return -1;
    }

    //Function that checks whether int at position in row x and column y is covered twice
    private boolean CoveredTwice(int[][] track,int row, int col){
        return track[row][col] == 4;
    }

    //Function that checks whether int at position is covered at least once
    private boolean IsCovered(int[][] track,int row, int col){
        return track[row][col] == 3;
    }

    //Function that checks for smallest uncovered value and returns it
    private int SmallestUncovered(int[][] input,int[][] track){
       int low = -1;
        for (int i=0;i<input.length ;i++){
            for (int n = 0;n<input[i].length;n++){
                if (track[i][n]==2){ //if not a 0
                    if (!CoveredTwice(track,i,n)){ //if not covered twice
                        if (!IsCovered(track,i,n)){ //if not covered at all
                            if (low==-1){ //if low hasnt been initialized properly
                                low = input[i][n];
                            } else{ //if it has, check wheter next int is lower or not
                                if (input[i][n]<low){
                                    low = input[i][n]; //if it is, make it the new low value
                                }
                            }
                        }
                    }
                }
            }
        }
        return low;
    }

    //Method that reduces the row by the lowest value in the row and returns new row
    private int[] RowReduction(int[] row){
        int low = row[0];
        for (int i =0;i<row.length;i++){
            if (row[i]<low){
                low = row[i];
            }
        }
        int[] newrow = new int[row.length];
        for (int i =0;i<row.length;i++){
            newrow[i] = row[i]-low;
        }
        return newrow;
    }

    //Method that reduces the columns by the lowest values in the columns and returns new matrix
    private int[][] ColReduction(int[][] matrix){
        for (int n = 0;n<matrix[0].length;n++) {
            int low = matrix[0][n];
            for (int i = 0; i < matrix.length; i++) {
                if ((matrix[i][n]) < low) {
                    low = matrix[i][n];
                }
            }

            for (int i = 0 ; i <matrix.length;i++){
                int newinput = matrix[i][n]-low;
                matrix[i][n] = newinput;
            }
        }
        return matrix;
    }

    //Method that prints and displays matrix in a readable and clear format
    public void printMatrix(int[][] matrix){
        System.out.println("Current Matrix:");
        for (int i = 0;i<matrix.length;i++){
            System.out.print("[ ");
            for (int x = 0; x<matrix[0].length;x++){
                System.out.print(matrix[i][x] + " ");
            }
            System.out.print("]\n");
        }
    }

    //Function that checks whether there was other assignments (selected 1) in the column
    private boolean NoOtherAssignment(int[][] track, int col, int x){
        boolean check = true;
        for (int i=0;i<track.length;i++) {
            if (track[i][col] == 1){
                if (i == x) { //original row
                    //skip
                } else {  //if any 1 in the col, return false
                    check = false;
                }
            }
        }
        for (int i=0;i<track[x].length;i++) {
            if (track[x][i] == 1){
                if (i == col) { //original row
                    //skip
                } else { //if any 1 in the row, return false
                    check = false;
                }
            }
        }
        return check;
    }

    //Function that checks whether there was other zeroes in the same column and row
    private boolean AZeroIntersection(int[][] track, int col, int x){
        boolean check = false;
        for (int i=0;i<track.length;i++) {
            if (track[i][col] == 0){
                if(i == x) { //original row
                    //skip
                } else {  //if any 0 in the col, return false
                    for (int n=0;n<track[x].length;n++) {
                        if (track[x][n] == 0){
                            if (n == col) { //original row
                                //skip
                            } else { //if any 0 in the row, return false
                                check = true;
                            }
                        }
                    }
                }
            }
        }
        return check;
    }

    //Function that checks if there is a zero at the opposite position
    private boolean AZeroIntersectionOpposite(int[][] track, int col, int x){
        int r=0;
        int c=0;
        for (int i=0;i<track.length;i++) {
            if (track[i][col] == 0){
                if(i == x) { //original row
                    //skip
                } else {  //if any 0 in the col, return false
                    r = i;

                    for (int n=0;n<track[x].length;n++) {
                        if (track[x][n] == 0){
                            if (n == col) { //original row
                                //skip
                            } else { //if any 0 in the row, return false
                                c = n;

                            }
                        }
                    }
                }
            }
        }
        if (track[r][c]==0){
            return true;
        }
        return false;
    }

    //Function that returns the opposite zero position
    private int[] GetZeroIntersectionOpposite(int[][] track, int col, int x){
        int[] result = new int[2];
        for (int i=0;i<track.length;i++) {
            if (track[i][col] == 0){
                if (i == x) { //original row
                    //skip
                } else {  //if any 0 in the col, return false
                    result[0] = i;

                    for (int n=0;n<track[x].length;n++) {
                        if (track[x][n] == 0){
                            if (n == col) { //original row
                                //skip
                            } else { //if any 0 in the row, return false
                                result[1] = n;

                            }
                        }
                    }
                }
            }
        }
        if (track[result[0]][result[1]]==0){
            return result;
        }
        return result;
    }

    //Function that looks at if all the remaining in the tracker matrix are zeroes
    private boolean AllZeroes(int[][] track){
        boolean result= true;
        for (int i=0;i<track.length;i++) {
            for(int n=0;n<track[i].length;n++) {
                if (track[i][n]!=0){
                    result = false;
                }
            }
        }
        return result;
    }


}
