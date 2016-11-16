%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA LSQUARE RSQUARE COLON FUN CONTINUE BREAK PARALLEL TO BY
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR VAR
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

%start program
%type<string> program
%%

args_list: { [] }
| expr { [$1] }
|  args_list COMMA expr { $3::$1 }

type_name:
  INT { Int }
| FLOAT { Float }
| BOOL { Bool }
| VOID { Void }
| type_name LSQUARE RSQUARE { Array($1) }
| type_name LSQUARE LSQUARE RSQUARE RSQUARE { Array(Array($1)) }
| type_name LSQUARE LSQUARE LSQUARE RSQUARE  RSQUARE RSQUARE { Array(Array(Array($1))) }

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

binding:
VAR ID COLON type_name { ($2,$4) }

decl:
VAR ID COLON type_name SEMI { 0  }
| binding ASSIGN expr SEMI { Assign($1,$3) }

fun_decl:
FUN ID LPAREN params_list RPAREN COLON type_name block { { fname=$2;formals=$4;typ=$7;body=$8 } }

params_list: { [] }
| ID COLON type_name { [($1,$3)] }
| ID COLON type_name COMMA params_list { ($1,$3)::$5 }

statement:
| expr SEMI { Expr($1) }
| branch_statement { $1 }
| iter_statement { $1 }
| ret_statement  { $1 }
| jump_statement { $1 }
| fun_decl { $1 }
| decl { $1 }

compound_statement : { [] }
| compound_statement statement { $2::$1 }

block:
LBRACE compound_statement RBRACE { Block(List.rev $2) }

parallel_block:
block { $1 }
| PARALLEL LPAREN args_list RPAREN block { 0 }

branch_statement:
IF LPAREN expr RPAREN parallel_block %prec NOELSE { If($3,$5) }
| IF LPAREN expr RPAREN parallel_block ELSE parallel_block { If($3,5,$7)  }

iter_statement:
WHILE LPAREN expr RPAREN parallel_block { While($3,$5) }
|  FOR LPAREN expr TO expr BY expr RPAREN parallel_block { For($3,$5,$7,$9) }
|  FOR LPAREN expr SEMI expr SEMI expr RPAREN parallel_block { For($3,$5,$7,$9) }

ret_statement:
RETURN expr SEMI { Return($2) }

jump_statement:
BREAK SEMI { Break }
| CONTINUE SEMI { Continue }

program:
 compound_statement EOF { 0 }
