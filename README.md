# Compiler

## project1: Lexical Definition
  Your assignment is to write a scanner for the Kotlin− language in lex. This document gives the lexical definition of the language, while the syntactic definition and code generation will follow in subsequent
assignments.

  Your programming assignments are based around this division and later assignments will use the parts of the system you have built in the earlier assignments. That is, in the first assignment you will implement
the scanner using lex, in the second assignment you will implement the syntactic definition in yacc, and in the last assignment you will generate assembly code for the Java Virtual Machine by augmenting your yacc
parser.

  This definition is subject to modification as the semester progresses. You should take care in implementation that the programs you write are well-structured and easily changed.
  
## project2: Syntactic and Semantic Definitions

Your assignment is to write an LALR(1) parser for the Kotlin− language. You will have to write the grammar and create a parser using yacc. Furthermore, you will do some simple checking of semantic
correctness. Code generation will be performed in the third phase of the project.

You first need to write your symbol table, which should be able to perform the following tasks:
* Push a symbol table when entering a scope and pop it when exiting the scope.
* Insert entries for variables, constants, and procedure declarations.
* Lookup entries in the symbol table.

You then must create an LALR(1) grammar using yacc. You need to write the grammar following the syntactic and semantic definitions in the following sections. Once the LALR(1) grammar is defined, you can
then execute yacc to produce a C program called “y.tab.c”, which contains the parsing function yyparse(). You must supply a main function to invoke yyparse(). The parsing function yyparse() calls yylex(). You will have to revise your scanner function yylex().

## project3: Code Generation

Your assignment is to generate code (in Java assembly language) for the Kotlin− language. The generated code will then be translated to Java bytecode by a Java assembler.

```
./compiler < HelloWorld.kt
./javaa p3.jasm
java HelloWorld
```
