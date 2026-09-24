public class Parser{
    private String str;
    private int pos;

    public Parser(String str){
        this.str = str;
        this.pos = 0;
    }

    private char peek(){
        if(pos < str.length())
            return str.charAt(pos);
        else    
            return '\n';
    }

    private char next(){
        return str.charAt(pos++);
    }

    private void space(){
        if(peek() == ' ')
            next();
    }

    private int expression(){
        int res = term();
        return expression1(res);
    }

    private int expression1(int l){
        space();
        while(peek() == '+' || peek() == '-'){
            char op = next();
            int r = term();
            if(op == '+') 
                l = l + r;
            else 
                l = l - r;
        }
        return l; 
    }

    private int term(){
        int res = factor();
        return term1(res);
    }

    private int term1(int l){
        space();
        if(peek() == '*'){
            next(); 
            next(); 
            int r = term();
            l = (int) Math.pow(l, r);
            return term1(l);
        }
        return l; 
    }

    private int factor(){
        space();
        if(peek() == '('){
            next();
            int res = expression();
            if(peek() == ')') 
                next();
            else 
                throw new RuntimeException("A ')' is expexted.");
            return res;
        }
        else
            return num();
    }

    private int num(){
        int res = digit();
        return num1(res);
    }

    private int num1(int l){
        while(Character.isDigit(peek()))
            l = l*10 + digit();
        return  l;
    }

    private int digit(){
        space();
        String num = "";
        if(Character.isDigit(peek())){
            num = num + next();  
            return Integer.parseInt(num);  
        } 
        else 
            throw new RuntimeException("A digit is expected.");
    }

    public int evaluate(){
        int res = expression();
        if(pos < str.length()){
            System.err.println("Error evaluating.");
        }
        return res;
    }
}
