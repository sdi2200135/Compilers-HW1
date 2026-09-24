import java_cup.runtime.*;

%%
/* ----------------- Options and Declarations Section----------------- */

/*
   The name of the class JFlex will create will be Scanner.
   Will write the code to the file Scanner.java.
*/
%class Scanner

/*
  The current line number can be accessed with the variable yyline
  and the current column number with the variable yycolumn.
*/
%line
%column

/*
   Will switch to a CUP compatibility mode to interface with a CUP
   generated parser.
*/
%cup
%unicode

/*
  Declarations

  Code between %{ and %}, both of which must be at the beginning of a
  line, will be copied letter to letter into the lexer class source.
  Here you declare member variables and functions that are used inside
  scanner actions.
*/

%{
    /**
        The following two methods create java_cup.runtime.Symbol objects
    **/
    private Symbol symbol(int type) {
       return new Symbol(type, yyline, yycolumn);
    }
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}

/*
  Macro Declarations

  These declarations are regular expressions that will be used latter
  in the Lexical Rules Section.
*/

/* A line terminator is a \r (carriage return), \n (line feed), or
   \r\n. */
LineTerminator = \r|\n|\r\n

/* White space is a line terminator, space, tab, or line feed. */
WhiteSpace     = {LineTerminator} | [ \t\f]

/* A literal integer is is a number beginning with a number between
   one and nine followed by zero or more numbers between zero and nine
   or just a zero.  */
char_lit = [a-zA-Z_][a-zA-Z0-9_]*

/* String literal is anything between double quotes. */
string_lit = \"(\\.|[^\"\\\\])*\" 

%%
/* ------------------------Lexical Rules Section---------------------- */

<YYINITIAL> {
/* operators */
 "prefix"      { return symbol(sym.PREFIX); }
 "suffix"      { return symbol(sym.SUFFIX); }
 "="           { return symbol(sym.EQUALITY); }
 "reverse"     { return symbol(sym.REVERSE); }
 "+"           { return symbol(sym.CONCAT); }
 "("           { return symbol(sym.LPAREN); }
 ")"           { return symbol(sym.RPAREN); }
 ";"           { return symbol(sym.SEMI); }
 "{"           { return symbol(sym.LBRACE); }
 "}"           { return symbol(sym.RBRACE); }
 ","           { return symbol(sym.COMMA); }
 "if"          { return symbol(sym.IF); }
 "else"        { return symbol(sym.ELSE); }
}


{char_lit} { return symbol(sym.VAR, yytext()); }


/* Match a string literal (e.g., "John") */
{string_lit}   { return symbol(sym.STRING, yytext().substring(1, yytext().length()-1)); }

{WhiteSpace} { }

/* No token was found for the input so through an error.  Print out an
   Illegal character message with the illegal character that was found. */
[^]                    { throw new Error("Illegal character <"+yytext()+">"); }
