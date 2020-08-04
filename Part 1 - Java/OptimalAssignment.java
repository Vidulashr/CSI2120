//Name: Vidulash Rajaratnam
//SNum: 8190398

import java.io.*;
import java.util.ArrayList;
import java.util.List;

//Class responsible for making the final assignments and creating file of those assignments
public class OptimalAssignment {
    //Method that takes the assigned values and calculates the total cost and returns it
    public int Assigning(int[][] matrix,int[][] assign){
        int total = 0;
        if (assign.length > 0) {
            for (int i = 0; i < assign.length; i++) {
                int col = assign[i][0];
                int row = assign[i][1];
                total += matrix[col][row]; }
        }
        else {
            System.out.println("There was no assignments done for this matrix. No cost was determined.");
        }
        return total;
    }

    //Method that prints the assigned matrix with brackets around the selected values
    public void displayAssignments(int[][] matrix,int[][] assign){
        System.out.println("5. MAKING FINAL ASSIGNMENTS");
        System.out.println("------------------------------------");
        System.out.println("Final Assigned Matrix: (FILE SAVED)");
        for (int i = 0;i<matrix.length;i++){
            int col = assign[i][0];
            int row = assign[i][1];
            System.out.print("[ ");
            for (int x = 0; x<matrix[i].length;x++){
                if ((i==col)&&(x==row)){
                    System.out.print("("+matrix[i][x]+")"+" ");
                }
                else{System.out.print(matrix[i][x] + " ");}
            }
            System.out.print("]\n");
        }
    }

    //Method that creates the tracker file to view optimal assignments
    public void createAssignFile(List<Face> faces, int[][] assign,int[][] matrix) throws IOException {
        List<Face> frame1 = new ArrayList<>();
        List<Face> frame2= new ArrayList<>();
        for (Face f:faces){
            if (f.getFrame() == 1){
                frame1.add(f); }
            else{
                frame2.add(f); } }

        //Get string value of n (length of matrix)
        String length_n = String.valueOf(assign.length);

        //Begin creating file
        File file = new File("tracker_java_"+length_n+".csv");
        FileWriter outputfile = new FileWriter(file);
        BufferedWriter bw = new BufferedWriter(outputfile);
        PrintWriter pw = new PrintWriter(bw);

        String line ="";
        for (int i = 0;i<assign.length;i++){
            line += frame1.get(assign[i][0]).getName();
            line += ",";
            line += frame2.get(assign[i][1]).getName();
            pw.println(line);
            line = "";
        }
        String cost = "Cost:,";
        cost += String.valueOf(Assigning(matrix,assign));

        pw.println(cost);

        pw.flush();
        pw.close();
    }
}
