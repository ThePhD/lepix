%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA DOT LSQUARE RSQUARE COLON FUN CONTINUE BREAK PARALLEL TO BY
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR TILDE AS VAR
%token RETURN IF ELSE FOR WHILE INT BOOL VOID FLOAT
%token <int> INTLITERAL
%token <float> FLOATLITERAL
%token <string> ID
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT NEG

%start compound_statement
%type<string> compound_statement
%%

args_list: { [] }
| expr { [$1] }
| expr COMMA args_list{ 0 }

type_name:
  INT { Int }
| FLOAT { Float }
| BOOL { Bool }
| VOID { Void }
| type_name LSQUARE RSQUARE { 0 }
| type_name LSQUARE LSQUARE RSQUARE RSQUARE { 0 }
| type_name LSQUARE LSQUARE LSQUARE RSQUARE  RSQUARE RSQUARE { 0 }

expr:
ID { Id($1) }
| INTLITERAL { Literal($1) }
| FLOATLITERAL { FloatLit($1) }
| TRUE { BoolLit(true) }
| FALSE { BoolLit(false) } 
| ID LSQUARE args_list RSQUARE { Access($1,$3)  }
| ID LPAREN args_list RPAREN  { Call($1,$3)  }
| MINUS expr %prec NEG { Unop( Neg, $2) }
| NOT expr { Unop( Not, $2) }
| expr TIMES expr { Binop( $1, Mult, $3) }
| expr DIVIDE expr { Binop( $1, Div, $3)  }
| expr PLUS expr { Binop( $1, Add, $3) }
| expr MINUS expr { Binop( $1, Sub, $3) }
| expr LT expr { Binop( $1, Less, $3) }
| expr GT expr { Binop( $1, Greater, $3) }
| expr LEQ expr { Binop( $1, Leq, $3) }
| expr GEQ expr { Binop( $1, Geq, $3) }
| expr NEQ expr { Binop( $1, Neq, $3) }
| expr EQ expr { Binop( $1, Eq, $3) }
| expr AND expr { Binop( $1, And, $3) }
| expr OR expr { Binop( $1, Or, $3) }
| ID ASSIGN expr { Assign($1, $3) }

decl:
VAR ID COLON type_name ASSIGN expr { 0 }  

fun_decl:
FUN ID LPAREN params_list RPAREN COLON type_name block { 0 }

params_list: { 0 }
| ID COLON type_name { 0 }
| ID COLON type_name COMMA params_list { 0 }

statement:
| expr_statement { 0 }
| branch_statement { 0 }
| iter_statement { 0 }
| ret_statement { 0 }
| jump_statement { 0 }
| fun_decl { 0 }

expr_statement:
| expr SEMI {0}

compound_statement : { 0 }
| decl { 0 }
| statement { 0 }
| compound_statement SEMI decl SEMI { 0 }
| compound_statement SEMI statement SEMI { 0 }

block:
LBRACE compound_statement RBRACE { 0 }

parallel_block:
block { 0 }
| PARALLEL LPAREN args_list RPAREN block { 0 }

branch_statement:
IF LPAREN expr RPAREN parallel_block %prec NOELSE { 0 }
| IF LPAREN expr RPAREN parallel_block ELSE parallel_block { 0 }

iter_statement:
WHILE LPAREN expr RPAREN parallel_block { 0 }
|  FOR LPAREN expr TO expr BY expr RPAREN parallel_block { 0 }
|  FOR LPAREN expr SEMI expr SEMI expr RPAREN parallel_block { 0 }

ret_statement:
RETURN expr_statement { 0 }

jump_statement:
BREAK SEMI { 0 }
| CONTINUE SEMI { 0 }

