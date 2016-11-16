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
%type<Ast.prog> program
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
| expr EQ expr { Binop( $1, Equal, $3) }
| expr AND expr { Binop( $1, And, $3) }
| expr OR expr { Binop( $1, Or, $3) }
| ID ASSIGN expr { Assign($1, $3) }

binding:
ID COLON type_name { ($1,$3) }

decl:
| VAR binding ASSIGN expr SEMI { Decl($2,$4) }

params_list: { [] }
| ID COLON type_name { [($1,$3)] }
| ID COLON type_name COMMA params_list { ($1,$3)::$5 }

fun_decl:
FUN ID LPAREN params_list RPAREN COLON type_name LBRACE statement_list RBRACE { { fname=$2;formals=$4;typ=$7;body=$9} }

statement_list: { [] }
| statement_list statement { $2::$1 }

statement:
 expr SEMI { Expr($1) }
| IF LPAREN expr RPAREN LBRACE statement_list RBRACE %prec NOELSE { If($3,$6,[]) }
| IF LPAREN expr RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE { If($3,$6,$10)  }
| WHILE LPAREN expr RPAREN LBRACE statement_list RBRACE { While($3,$6) }
|  FOR LPAREN expr TO expr BY expr RPAREN LBRACE statement_list RBRACE { For($3,$5,$7,$10) }
|  FOR LPAREN expr SEMI expr SEMI expr RPAREN LBRACE statement_list RBRACE { For($3,$5,$7,$10) }
| RETURN expr SEMI  { Return($2) }
| BREAK SEMI { Break }
| CONTINUE SEMI { Continue }
| decl { DecStmt($1) } 

/* 
| decl { $1 }
*/

decls_list: { [] }
| decls_list decl { $2::$1 }

fdecls_list : { [] }
| fdecls_list fun_decl { $2::$1 }

program:
decls_list fdecls_list EOF { Prog($1,$2) }
