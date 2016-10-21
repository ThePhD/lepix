%{ open Ast %}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR
%token RETURN IF ELSE FOR WHILE INT BOOL VOID
%token <int> LITERAL
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
%type < Ast.program> program

%%

array_access:
 ID LBRACKET INT RBRACKET 	{ Access($1,$3) }
| array_access LBRACKET INT RBRACKET  { Access($1,$3) }

stmnt:
***TODO***

decls:
***TODO***

type:
  INT { Int }
| BOOL { Bool }
| FLOAT { Float }
| VOID { Void }

loops:
  FOR ID ASSIGN INT TO INT BY INT stmnt 	{ For($2,$4,$6,$8) }
| WHILE expr stmnt				{ While($2,$3) }

cond:
 IF LPAREN stmnt RPAREN LBRACE stmnt RBRACE	{ If($3,$6) }
| cond ELSE LPAREN stmnt RPAREN 		{ Else($1,$4) }

expr:
  INT		     { Int($1) }
| TRUE		     { BoolList(true) }
| FALSE	             { BoolList(false) }
| ID		     { Id($1) } 
| expr PLUS   expr   { Binop($1, Add, $3) }
| expr MINUS  expr   { Binop($1, Sub, $3) }
| expr TIMES  expr   { Binop($1, Mul, $3) }
| expr DIVIDE expr   { Binop($1, Div, $3) }
| expr EQ expr	     { Binop($1, Equal, $3)}
| expr NEQ expr      { Binop($1, Neq, $3)}
| expr LT expr       { Binop($1, Less, $3)}
| expr LEQ expr      { Binop($1, Leq, $3)}
| expr GT expr       { Binop($1, Greater, $3)}
| expr GEQ expr      { Binop($1, Geq, $3)}
| MINUS expr %prec NEG { Unop(Neg, $2) }
| ID ASSIGN expr      { Assign($1, $3) }
| NOT expr	      { Unop(Not, $2) }
| LPAREN expr RPAREN {$2}
