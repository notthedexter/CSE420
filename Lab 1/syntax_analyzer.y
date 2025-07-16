%{
#include "symbol_info.h"
#include <iostream>
#include <fstream>

#define YYSTYPE symbol_info*

int yyparse(void);
int yylex(void);

extern FILE *yyin;
extern int lines;
ofstream outlog;

int lines = 1;
void yyerror(const char *s) {
    std::cerr << "Error at line " << lines << ": " << s << std::endl;
}
%}

%token IF WHILE FOR ELSE BREAK DO INT FLOAT VOID SWITCH DEFAULT GOTO CHAR DOUBLE RETURN CASE CONTINUE PRINTF CONST_INT CONST_FLOAT ID ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COLON COMMA
%nonassoc IF
%nonassoc ELSE


%%

start : program
    {
        outlog << "At line no: " << lines << " start : program " << endl << endl;
    }
    ;

program : program unit
    {
        outlog << "At line no: " << lines << " program : program unit " << endl << endl;
        $$ = new symbol_info($1->getname() + "\n" + $2->getname(), "program");
    }
    | unit
    {
        $$ = $1;
    }
    ;

unit : var_declaration
    { 
        outlog << "At line no: " << lines << " unit : var_declaration " << endl << endl;
        $$ = $1;
    }
    | func_definition
    {
        outlog << "At line no: " << lines << " unit : func_definition " << endl << endl;
        $$ = $1;
    }
    ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
    {
        outlog << "At line no: " << lines << " func_definition with parameters" << endl << endl;
        $$ = new symbol_info($1->getname() + " " + $2->getname() + "(" + $4->getname() + ")\n" + $6->getname(), "func_def");
    }
    | type_specifier ID LPAREN RPAREN compound_statement
    {
        outlog << "At line no: " << lines << " func_definition without parameters" << endl << endl;
        $$ = new symbol_info($1->getname() + " " + $2->getname() + "()\n" + $5->getname(), "func_def");
    }
    ;

parameter_list : parameter_list COMMA type_specifier ID
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname() + " " + $4->getname(), "parameter_list");
    }
    | parameter_list COMMA type_specifier
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname(), "parameter_list");
    }
    | type_specifier ID
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname(), "parameter_list");
    }
    | type_specifier
    {
        $$ = $1;
    }
    ;

compound_statement : LCURL statements RCURL
    {
        outlog << "At line no: " << lines << " compound_statement with statements" << endl << endl;
        $$ = new symbol_info("{\n" + $2->getname() + "}", "compound_statement");
    }
    | LCURL RCURL
    {
        outlog << "At line no: " << lines << " empty compound_statement" << endl << endl;
        $$ = new symbol_info("{}", "compound_statement");
    }
    ;

var_declaration : type_specifier declaration_list SEMICOLON
    {
        outlog << "At line no: " << lines << " var_declaration" << endl << endl;
        $$ = new symbol_info($1->getname() + " " + $2->getname() + ";", "var_declaration");
    }
    ;

type_specifier : INT
    {
        $$ = new symbol_info("int", "type_specifier");
    }
    | FLOAT
    {
        $$ = new symbol_info("float", "type_specifier");
    }
    | VOID
    {
        $$ = new symbol_info("void", "type_specifier");
    }
    ;

declaration_list : declaration_list COMMA ID
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname(), "declaration_list");
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname() + "[" + $5->getname() + "]", "declaration_list");
    }
    | ID
    {
        $$ = new symbol_info($1->getname(), "declaration_list");
    }
    | ID LTHIRD CONST_INT RTHIRD
    {
        $$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "declaration_list");
    }
    ;

statements : statement
    {
        $$ = $1;
    }
    | statements statement
    {
        $$ = new symbol_info($1->getname() + "\n" + $2->getname(), "statements");
    }
    ;

statement : var_declaration
    {
        outlog << "At line no: " << lines << " var_declaration statement" << endl << endl;
        $$ = $1;
    }
    | expression_statement
    {
        outlog << "At line no: " << lines << " expression_statement" << endl << endl;
        $$ = $1;
    }
    | compound_statement
    {
        outlog << "At line no: " << lines << " compound_statement" << endl << endl;
        $$ = $1;
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement
    {
        outlog << "At line no: " << lines << " for statement" << endl << endl;
        $$ = new symbol_info("for(" + $3->getname() + $4->getname() + $5->getname() + ")" + $7->getname(), "statement");
    }
    | IF LPAREN expression RPAREN statement %prec IF
    {
        outlog << "At line no: " << lines << " if statement" << endl << endl;
        $$ = new symbol_info("if(" + $3->getname() + ")" + $5->getname(), "statement");
    }
    | IF LPAREN expression RPAREN statement ELSE statement %prec ELSE
    {
        outlog << "At line no: " << lines << " if-else statement" << endl << endl;
        $$ = new symbol_info("if(" + $3->getname() + ")" + $5->getname() + " else " + $7->getname(), "statement");
    }
    | WHILE LPAREN expression RPAREN statement
    {
        outlog << "At line no: " << lines << " while statement" << endl << endl;
        $$ = new symbol_info("while(" + $3->getname() + ")" + $5->getname(), "statement");
    }
    | PRINTF LPAREN ID RPAREN SEMICOLON
    {
        outlog << "At line no: " << lines << " printf statement" << endl << endl;
        $$ = new symbol_info("printf(" + $3->getname() + ");", "statement");
    }
    | RETURN expression SEMICOLON
    {
        outlog << "At line no: " << lines << " return statement" << endl << endl;
        $$ = new symbol_info("return " + $2->getname() + ";", "statement");
    }
    ;

expression_statement : SEMICOLON
    {
        $$ = new symbol_info(";", "expression_statement");
    }
    | expression SEMICOLON
    {
        $$ = new symbol_info($1->getname() + ";", "expression_statement");
    }
    ;

expression : logic_expression
    {
        $$ = $1;
    }
    | variable ASSIGNOP logic_expression
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname() + " " + $3->getname(), "expression");
    }
    ;

logic_expression : rel_expression
    {
        $$ = $1;
    }
    | rel_expression LOGICOP rel_expression
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname() + " " + $3->getname(), "logic_expression");
    }
    ;

rel_expression : simple_expression
    {
        $$ = $1;
    }
    | simple_expression RELOP simple_expression
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname() + " " + $3->getname(), "rel_expression");
    }
    ;

simple_expression : term
    {
        $$ = $1;
    }
    | simple_expression ADDOP term
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname() + " " + $3->getname(), "simple_expression");
    }
    ;

term : unary_expression
    {
        $$ = $1;
    }
    | term MULOP unary_expression
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname() + " " + $3->getname(), "term");
    }
    ;

unary_expression : ADDOP unary_expression
    {
        $$ = new symbol_info($1->getname() + $2->getname(), "unary_expression");
    }
    | NOT unary_expression
    {
        $$ = new symbol_info($1->getname() + $2->getname(), "unary_expression");
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor : variable
    {
        $$ = $1;
    }
    | ID LPAREN argument_list RPAREN
    {
        $$ = new symbol_info($1->getname() + "(" + $3->getname() + ")", "factor");
    }
    | LPAREN expression RPAREN
    {
        $$ = new symbol_info("(" + $2->getname() + ")", "factor");
    }
    | CONST_INT
    {
        $$ = $1;
    }
    | CONST_FLOAT
    {
        $$ = $1;
    }
    | variable INCOP
    {
        $$ = new symbol_info($1->getname() + $2->getname(), "factor");
    }
    ;

variable : ID
    {
        $$ = new symbol_info($1->getname(), "variable");
    }
    | ID LTHIRD expression RTHIRD
    {
        $$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "variable");
    }
    ;

argument_list : arguments
    {
        $$ = $1;
    }
    | /* empty */
    {
        $$ = new symbol_info("", "argument_list");
    }
    ;

arguments : arguments COMMA logic_expression
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname(), "arguments");
    }
    | logic_expression
    {
        $$ = $1;
    }
    ;

%%

int main(int argc, char *argv[]) {
    if(argc != 2) {
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }
    
    yyin = fopen(argv[1], "r");
    outlog.open("my_log.txt", ios::trunc);
    
    if(yyin == NULL) {
        cerr << "Couldn't open file: " << argv[1] << endl;
        return 1;
    }
    
    yyparse();
    
    outlog << "Total lines processed: " << lines << endl;
    outlog.close();
    fclose(yyin);
    
    return 0;
}