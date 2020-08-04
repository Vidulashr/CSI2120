//Name: Vidulash Rajaratnam
//SNum: 8190398

import java.io.*;
import java.util.ArrayList;
import java.util.List;

//Class responsible to calculate the matching cost through 2 methods
public class MatchingCost {
    //Method that creates csv file and returns cost matrix for two lists of faces using euclidean distance algorithm
    public int[][] usingEuclideanDistance(List<Face> faces) throws IOException {
        List<Face> frame1 = new ArrayList<>();
        List<Face> frame2= new ArrayList<>();
        for (Face f:faces){
            if (f.getFrame() == 1){
                frame1.add(f); }
            else{
                frame2.add(f); } }

        File file = new File("matching_costs_euclidean.csv");
        FileWriter outputfile = new FileWriter(file);
        BufferedWriter bw = new BufferedWriter(outputfile);
        PrintWriter pw = new PrintWriter(bw);

        String[] header = new String[frame2.size()+1];
        header[0] = ",";
        for (int i = 1;i<=frame1.size();i++){
            if (i==frame1.size()){
                header[i] = frame1.get(i-1).getName();}
            else{
                header[i] = frame1.get(i-1).getName()+",";
            }
        }
        pw.println(getStringOutput(header));

        for (int i = 0;i<frame1.size();i++){
            //Initialize size
            String[] line = new String[frame2.size()+1];
            //Add frame name first with comma
            line[0] = frame2.get(i).getName()+",";
            //For loop that adds names from first frame along with matching distances
            for (int x =0;x<frame2.size();x++){
                if (x==frame2.size()-1){
                    line[x+1] = Integer.toString(Euclidean(frame1.get(i),frame2.get(x)));}
                else{
                    line[x+1] = Integer.toString(Euclidean(frame1.get(i),frame2.get(x)))+","; }
            }
            //Writes to file
            pw.println(getStringOutput(line));
        }
        pw.flush();
        pw.close();

        //For loop to create matrix of distances
        int[][] matrix = new int[frame1.size()][frame2.size()];
        for (int i = 0;i<frame1.size();i++){
            int[] line = new int[frame1.size()];
            for (int x = 0;x<frame2.size();x++){
                line[x] = Euclidean(frame1.get(i),frame2.get(x));
            }
            matrix[i] = line;
        }

        //Returns matching matrix in array of array of integers
        return matrix;
    }

    //Function that calculates euclidean distance from two faces
    private int Euclidean(Face faceone, Face facetwo){
        //Getting center coordinates for both faces
        double[] c_faceone = new double[]{(faceone.getUpX()+(faceone.getUpX()+faceone.getWidthX()))/2,(faceone.getUpY()+(faceone.getUpY()+faceone.getHeightY()))/2};
        double[] c_facetwo = new double[]{(facetwo.getUpX()+(facetwo.getUpX()+facetwo.getWidthX()))/2,(facetwo.getUpY()+(facetwo.getUpY()+facetwo.getHeightY()))/2};
        double x = Math.pow((c_facetwo[0]-c_faceone[0]),2);
        double y = Math.pow((c_facetwo[1]-c_faceone[1]),2);
        //Actually calculate distance
        int distance = (int) Math.round(Math.sqrt(x+y));
        return distance;
    }

    //Method that creates csv file and returns cost matrix for two lists of faces using area of box
    public int[][] usingAreaofBox(List<Face> faces) throws IOException {
        List<Face> frame1 = new ArrayList<>();
        List<Face> frame2= new ArrayList<>();
        for (Face f:faces){
            if (f.getFrame() == 1){
                frame1.add(f); }
            else{
                frame2.add(f); } }

        File file = new File("matching_costs_area.csv");
        FileWriter outputfile = new FileWriter(file);
        BufferedWriter bw = new BufferedWriter(outputfile);
        PrintWriter pw = new PrintWriter(bw);

        String[] header = new String[frame2.size()+1];
        header[0] = ",";
        for (int i = 1;i<=frame1.size();i++){
            if (i==frame1.size()){
                header[i] = frame1.get(i-1).getName();}
            else{
                header[i] = frame1.get(i-1).getName()+",";
            }
        }
        pw.println(getStringOutput(header));

        //
        for (int i = 0;i<frame1.size();i++){
            //Initialize size
            String[] line = new String[frame2.size()+1];
            //Add frame name first with comma
            line[0] = frame2.get(i).getName()+",";
            //For loop that adds names from first frame along with matching areas
            for (int x =0;x<frame2.size();x++){
                if (x==frame2.size()-1){
                    line[x+1] = Integer.toString(Math.abs(getFrameArea(frame1.get(x))-getFrameArea(frame2.get(i))));}
                else{
                    line[x+1] = Integer.toString(Math.abs(getFrameArea(frame1.get(x))-getFrameArea(frame2.get(i))))+","; }
            }
            //Writes to file
            pw.println(getStringOutput(line));
        }
        pw.flush();
        pw.close();

        //For loop to create matrix of distances
        int[][] matrix = new int[frame1.size()][frame2.size()];
        for (int i = 0;i<frame1.size();i++){
            int[] line = new int[frame1.size()];
            for (int x = 0;x<frame2.size();x++){
                line[x] = (Math.abs(getFrameArea(frame1.get(x))-getFrameArea(frame2.get(i))));
            }
            matrix[i] = line;
        }

        //Returns matching matrix in array of array of integers
        return matrix;
    }

    //Method that returns area of a frame
    private int getFrameArea(Face frame){
        int area = frame.getWidthX()*frame.getHeightY();
        return area;
    }

    //Function that outputs string representation of string array, for proper format to add to csv file
    private String getStringOutput(String[] result){
        String output = "";
        for (int i =0;i<result.length;i++){
            output += result[i];
        }
        return output;
    }
}

