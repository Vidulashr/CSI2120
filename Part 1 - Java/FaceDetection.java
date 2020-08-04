//Name: Vidulash Rajaratnam
//SNum: 8190398

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

//Class responsible for reading csv files and converting them to faces
public class FaceDetection {
    public static void main(String[] args) {
        FaceDetection detect = new FaceDetection();
        List<Face> faces = detect.getAllFaces("src/frame1_3.csv","src/frame2_3.csv");
        for (Face f: faces){
            System.out.println(f);}
    }

    //Method that lists all faces and their information from both frames
    public List<Face> getAllFaces(String frame1, String frame2){
        List<Face> faces = readFromCSV(frame1,1);
        List<Face> faces2 = readFromCSV(frame2,2);
        faces.addAll(faces2);
        return faces;
    }

    //Method that reads a csv file and converts it into a list of faces
    private List<Face> readFromCSV(String filename, int frame){
        List<Face> faces = new ArrayList<>();
        Path pathtofile = Paths.get(filename);
        try (BufferedReader br = Files.newBufferedReader(pathtofile, StandardCharsets.US_ASCII)) {
            String line = br.readLine();
            while (line != null) {
                String[] attributes = line.split(",");
                Face face = createFace(attributes,frame);
                faces.add(face);
                line = br.readLine(); }
        } catch (IOException ioe) { ioe.printStackTrace(); } return faces; }

    //Method that creates faces
    private Face createFace(String[] metadata, int f) {
        String name = metadata[0];
        int upX = Integer.parseInt(metadata[1]);
        int upY = Integer.parseInt(metadata[2]);
        int widthX = Integer.parseInt(metadata[3]);
        int heightY = Integer.parseInt(metadata[4]);
        int frame = f;
        return new Face(name, upX,upY,widthX,heightY,frame); }
}

//Face class that records each box of the frame along with the dimensions and location information
class Face{
    private String name;
    private int upX,upY,widthX,heightY,frame;
    public Face(String name,int upX,int upY,int widthX, int heightY, int frame){
        this.name=name;
        this.upX=upX;
        this.upY=upY;
        this.widthX=widthX;
        this.heightY=heightY;
        this.frame =frame;
    }

    public String getName() {
        return name;
    }

    public int getHeightY() {
        return heightY;
    }

    public int getUpX() {
        return upX;
    }

    public int getUpY() {
        return upY;
    }

    public int getWidthX() {
        return widthX;
    }

    public int getFrame() {
        return frame;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String toString(){
        return "Face [name= "+name+", Upper-Corner(X,Y)= ("+upX+","+upY+"), Width in X= "+widthX+", Height in Y= "+heightY+", frame ="+frame+"]";
    }
}




