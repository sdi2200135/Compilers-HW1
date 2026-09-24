import java.util.Scanner;

public class Main{
    public static void main(String[] argv) throws Exception {
        System.out.println("Please type your arithmetic expression:");
        
        Scanner scan = new Scanner(System.in);
        String str = scan.nextLine();
    
        try{
            Parser p = new Parser(str);
            int res = p.evaluate();
            System.out.println("The result is:" + res);
        } 
        catch(Exception e){
            System.err.println("Error: " + e.getMessage() + "\n");
        }
        scan.close();
    }
}
