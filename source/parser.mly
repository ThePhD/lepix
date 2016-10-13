%{ open Ast %}

%token PLUS MINUS TIMES DIVIDE EOF 
%token EQ NEQ LT LEQ GT GEQ LPAREN RPAREN
%token <int> LITERAL 


%left EQUALS NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS    
%left TIMES DIVIDE


%start program
%type < Ast.program> program

%%

expr:
  expr PLUS   expr { Binop($1, Add, $3) }
| expr MINUS  expr { Binop($1, Sub, $3) }
| expr TIMES  expr { Binop($1, Mul, $3) }
| expr DIVIDE expr { Binop($1, Div, $3) }
| LITERAL          { Lit($1) }
| expr EQ expr	{ Binop($1, Equal, $3)}
| expr NEQ expr    {Binop($1, Neq, $3)}
| expr LT expr    {Binop($1, Less, $3)}
| expr LEQ expr    {Binop($1, Leq, $3)}
| expr GT expr    {Binop($1, Greater, $3)}
| expr GEQ expr    {Binop($1, Geq, $3)}
| LPAREN expr RPAREN {$2}
