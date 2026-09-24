CUP_JAR=java-cup-11b.jar
CUP_RUNTIME=java-cup-11b-runtime.jar
JAVAC=javac
JAVA=java

all: compile

compile:
	jflex scanner.flex
	java -jar $(CUP_JAR) -interface -parser Parser parser.cup
	java -jar $(CUP_JAR) -interface -parser Parser2 parser2.cup
	$(JAVAC) -cp $(CUP_RUNTIME) *.java

execute:
	$(JAVA) -cp $(CUP_RUNTIME):. Main < Translated.txt > Translated.ir 

execute1:
	$(JAVA) -cp $(CUP_RUNTIME):. Main2 < Translated.ir > Translated.java 
run:
	$(JAVAC) Translated.java 
	$(JAVA) Translated

clean:
	rm -f *.class *~

clean1:
	rm -f Parser.java Scanner.java sym.java Translated.ir Parser2.java Translated.java
