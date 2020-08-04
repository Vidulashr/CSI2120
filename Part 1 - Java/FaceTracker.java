//Name: Vidulash Rajaratnam
//SNum: 8190398

import java.io.IOException;
import java.util.List;
import java.util.Scanner;

//Class responsible for the main program
public class FaceTracker {
    //Main program for user to use
    public void Program() throws IOException {
        Scanner inp = new Scanner(System.in);
        System.out.println("----------WELCOME TO FACE TRACKER JAVA----------");
        System.out.print("Input frame 1 path: ");
        String file1 = inp.nextLine();
        System.out.print("Input frame 2 path: ");
        String file2 = inp.nextLine();

        if (file1.equals("")||file2.equals("")){
            System.out.println("INVALID! Please input both file path");
            return;
        }
        else {
            System.out.println("Which method would you like to use to calculate cost?");
            System.out.println("1. Euclidean Method");
            System.out.println("2. Area Method ");
            System.out.print("Choice: ");
            int choice = inp.nextInt();

            while (choice!=2 && choice != 1) {
                System.out.println("Invalid Choice! Select Again");
                System.out.println("1. Euclidean Method");
                System.out.println("2. Area Method ");
                System.out.print("Choice: ");
                choice = inp.nextInt();
            }

            if (choice == 1) { //If user selected euclidean method to calculate cost
                System.out.println("----------EUCLIDEAN METHOD----------");
                FaceDetection detector = new FaceDetection();
                MatchingCost cost = new MatchingCost();
                List<Face> faces = detector.getAllFaces(file1, file2);
                int[][] matrix = cost.usingEuclideanDistance(faces);
                int[][] savedmatrix = matrix;
                //Throw error if matrix is not a square
                if (matrix.length != matrix[0].length) {
                    try {
                        throw new IllegalAccessException("ERROR: Matrix is not square, needs to be n x n");
                    } catch (IllegalAccessException e) {
                        System.err.println(e);
                        System.exit(1);
                    }
                }
                HungarianAlgorithm algorithm = new HungarianAlgorithm();
                int[][] assignments = algorithm.Hungarian(matrix);
                OptimalAssignment assign = new OptimalAssignment();
                assign.createAssignFile(faces,assignments,matrix);
                int totalCalculatedCost = assign.Assigning(savedmatrix, assignments);
                System.out.println("-------------------------------------------");
                assign.displayAssignments(savedmatrix, assignments);
                System.out.println("Total cost: " + totalCalculatedCost);
                System.out.println("-------------------------------------------");
            } else { //If user selected area as the method to calculate cost
                System.out.println("----------AREA METHOD----------");
                FaceDetection detector = new FaceDetection();
                MatchingCost cost = new MatchingCost();
                List<Face> faces = detector.getAllFaces(file1, file2);
                int[][] matrix = cost.usingAreaofBox(faces);
                int[][] savedmatrix = matrix;
                //Throw error if matrix is not a square
                if (matrix.length != matrix[0].length) {
                    try {
                        throw new IllegalAccessException("ERROR: Matrix is not square, needs to be n x n");
                    } catch (IllegalAccessException e) {
                        System.err.println(e);
                        System.exit(1);
                    }
                }
                HungarianAlgorithm algorithm = new HungarianAlgorithm();
                int[][] assignments = algorithm.Hungarian(matrix);
                OptimalAssignment assign = new OptimalAssignment();
                assign.createAssignFile(faces,assignments,matrix);
                int totalCalculatedCost = assign.Assigning(savedmatrix, assignments);
                System.out.println("-------------------------------------------");
                assign.displayAssignments(savedmatrix, assignments);
                System.out.println();
                System.out.println("Total cost: " + totalCalculatedCost);
                System.out.println("-------------------------------------------");
            }
        }
    }

    //Runs program till user quits
    public static void main(String[] args) throws IOException {
        boolean running = true;
        while(running) {
            FaceTracker run = new FaceTracker();
            run.Program();
            Scanner inp = new Scanner(System.in);
            System.out.println("Try Again? (Y/N): ");
            String input = inp.nextLine();
            while (!(input.equals("Y") || input.equals("N") || input.equals("y") || input.equals("n"))) {
                input = inp.nextLine();
            }
            if (input.equals("Y") || input.equals("y")) {
            }
            else {
                System.out.println("Thanks for using FaceTracker!");
                running=false;
            }
        }
    }
}
