# Recursive Descent Parser and IR Compiler (Compilers-HW1)

A compilers course project developed at NKUA. It consists of two parts:

- **Part 1** – A hand-written recursive descent parser in Java that evaluates
  arithmetic expressions (`+`, `-`, `**`, parentheses).
- **Part 2** – A small compiler that translates a tiny expression/function
  language (IR) into Java source code, using **JFlex** for lexical analysis and
  **CUP** for LALR parsing.

---

## 1. Project Structure

```
.
├── Part 1/
│   ├── Main.java        # Entry point: reads an expression, prints the result
│   ├── Parser.java      # Recursive descent parser + evaluator
│   └── README.md        # Grammar, FIRST/FOLLOW sets
│
├── Part 2/
│   ├── scanner.flex         # JFlex lexer specification
│   ├── parser.cup           # CUP grammar for IR → Java translation
│   ├── parser2.cup          # Second CUP grammar (with argument handling)
│   ├── Main.java            # Driver for Parser  (IR on stdin → Translated.ir)
│   ├── Main2.java           # Driver for Parser2 (Translated.ir → Translated.java)
│   ├── Translated.txt       # Example IR input
│   └── README.md            # Notes and known limitations
│
├── Homework 2/              # Separate assignment (not described here)
├── Makefile
└── README.md
```

---

## 2. Part 1 – Arithmetic Expression Parser

### 2.1 Description

`Main.java` prompts the user for an arithmetic expression, feeds it to
`Parser`, and prints the evaluated integer result. `Parser` is a classic
**recursive descent parser** with one method per non-terminal.

Supported operators (in increasing precedence):

| Operator | Meaning | Associativity |
|----------|---------|---------------|
| `+` `-`  | Addition / subtraction | Left |
| `**`     | Power (via `Math.pow`)  | Right |
| `()`     | Grouping | — |

### 2.2 Grammar

```
1. expr   -> term expr1
2. expr1  -> + term expr1 | - term expr1 | ε
3. term   -> factor term1
4. term1  -> ** term | ε
5. factor -> num | (expr)
6. num    -> digit num1
7. num1   -> digit num1 | ε
8. digit  -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

### 2.3 FIRST / FOLLOW sets

```
FIRST(expr)   = {0..9, ( }
FIRST(expr1)  = {+, -, ε}
FIRST(term)   = {0..9, ( }
FIRST(term1)  = {**, ε}
FIRST(factor) = {(, 0..9 }
FIRST(num)    = {0..9 }
FIRST(num1)   = {0..9, ε}
FIRST(digit)  = {0..9 }

FOLLOW(expr)   = {$, )}
FOLLOW(expr1)  = {$, )}
FOLLOW(term)   = {+, -, $, )}
FOLLOW(term1)  = {+, -, $, )}
FOLLOW(factor) = {**, +, -, $, )}
FOLLOW(num)    = {**, +, -, $, )}
FOLLOW(num1)   = {**, +, -, $, )}
FOLLOW(digit)  = {**, +, -, $, )}
```

### 2.4 How it works

- `expression()` → `term()` then `expression1()`.
- `term()` → `factor()` then `term1()`.
- `factor()` handles parentheses recursively and falls back to `num()`.
- `num()` / `num1()` / `digit()` build an integer left-to-right.
- Spaces are skipped by `space()` before checking the next character.
- On a malformed input, a `RuntimeException` is thrown with a descriptive
  message (`"A ')' is expected."`, `"A digit is expected."`, etc.), which
  `Main` catches and prints to `stderr`.

### 2.5 How to run

```bash
cd "Part 1"
javac Main.java Parser.java
java Main
```

Example:

```
Please type your arithmetic expression:
2 + 3 ** 2
The result is:11
```

> Note: since the parser is recursive descent, the grammar is required to be
> LL(1) — which it is (see FIRST/FOLLOW above).

---

## 3. Part 2 – IR → Java Translator

### 3.1 Description

Part 2 implements a two-stage compiler:

1. **Lexical analysis** – `scanner.flex` is compiled by **JFlex** into
   `Scanner.java`.
2. **Syntactic analysis + translation** – `parser.cup` / `parser2.cup` are
   compiled by **CUP** into `Parser.java` / `Parser2.java`. Each production
   returns a `String` that is a fragment of Java source.

The pipeline:

```
Translated.txt  ──[Main]──▶  Translated.ir  ──[Main2]──▶  Translated.java
   (IR input)                  (AST dump)                    (Java code)
```

- `Main`  runs the first grammar (`parser.cup`) and prints an intermediate
  representation to `Translated.ir`.
- `Main2` runs the second grammar (`parser2.cup`), which reads the IR and
  emits a complete Java file `Translated.java`.
- `javac Translated.java && java Translated` executes the generated program.

### 3.2 The input language (IR)

The scanner recognises:

| Token | Meaning |
|-------|---------|
| `prefix`, `suffix` | String prefix / suffix tests |
| `=`        | Equality |
| `reverse`  | String reversal |
| `+`        | Concatenation |
| `(`, `)`   | Grouping |
| `{`, `}`   | Function bodies |
| `,`        | Argument separator |
| `if`, `else` | Conditionals |
| `VAR`      | Identifier (`[a-zA-Z_][a-zA-Z0-9_]*`) |
| `STRING`   | String literal `"..."` |

Example input (`Translated.txt`):

```
findLangType(langName) {
  if ("Java" prefix langName)
    if(langName prefix "Java")
      "Static"
    else
      if("script" suffix langName)
        "Dynamic"
      else
        "Unknown"
      else
        if ("script" suffix langName)
          "Probably Dynamic"
        else
          "Unknown"
}

findLangType("Java")
findLangType("Javascript")
findLangType("Typescript")
```

### 3.3 The two CUP grammars

**`parser.cup` (first pass)** – builds a textual IR. Notable features:

- `expr3` handles `CONCAT`, `EQUALITY`, `PREFIX`, `SUFFIX`, `REVERSE`.
- `func` and `func_call` handle 0- or 1-argument forms.
- `if_else` handles the conditional.
- Result of each production is a `String` fragment printed by `expr_list`.

**`parser2.cup` (second pass)** – emits Java source. Notable features:

- Wraps everything in `public class Translated { ... }` with a `main`.
- `expr3` translates `PREFIX` to `startsWith`, `REVERSE` to
  `new StringBuilder(...).reverse()`, etc.
- `func` emits `public static String <name>(String <args>) { ... }`.
- `func_call` emits `<name>(<args>)`.

### 3.4 How to build & run

The Makefile automates everything:

```bash
# 1. Generate Scanner.java, Parser.java, Parser2.java, sym.java and compile
make compile

# 2. IR -> .ir  (uses parser.cup)
make execute
#    java -cp java-cup-11b-runtime.jar:. Main < Translated.txt > Translated.ir

# 3. .ir -> Translated.java  (uses parser2.cup)
make execute1
#    java -cp java-cup-11b-runtime.jar:. Main2 < Translated.ir > Translated.java

# 4. Compile and run the generated Java
make run
#    javac Translated.java && java Translated

# Cleanup
make clean      # remove .class files
make clean1     # remove generated sources and intermediate files
```

Required jars (already referenced in the Makefile):

- `java-cup-11b.jar` — the CUP generator
- `java-cup-11b-runtime.jar` — the CUP runtime

### 3.5 Known limitations

- **3+ argument functions are not fully supported.** The code path for
  handling three or more arguments is commented out in `parser2.cup`:

  ```
  /*expr4 ::= comma_manage:cm {: RESULT = "String " + cm ;:}
  ;*/
  ```

  As a result, function declarations with three arguments cannot be
  translated, even though the parser compiles. Functions with 0–2 arguments
  work correctly.

- **Example 2 fails at the first function call.** When translating the second
  example from the assignment, the compiler throws an error at the line just
  before the first function call. Investigation showed the failure is related
  to a call to a parameterless function that is either not declared earlier,
  or is used as the first argument of another call. The exact cause was not
  isolated.

- **Workaround.** To keep the generated Java runnable, a call to the
  problematic parameterless function is inserted before the other calls if
  no such call has already been made.

- **Precedence caveat.** `COMMA` is declared left-associative in
  `parser2.cup`, which is required for the argument-list grammar to reduce
  correctly.

---

## 4. Building Everything

From the repository root:

```bash
# Part 1
cd "Part 1"
javac Main.java Parser.java
java Main

# Part 2
cd "Part 2"
make compile
make execute
make execute1
make run
```

---

## 5. Repository Layout Convention

| Folder | Contents |
|--------|----------|
| `Part 1/` | Homework 1 – recursive descent parser |
| `Part 2/` | Homework 1 – JFlex + CUP translator to Java |
