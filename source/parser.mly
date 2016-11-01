%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA DOT LSQUARE RSQUARE COLON FUN
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

%start decl
%type<string> decl
%%

primary_expr:
 ID { 0 }
| INTLITERAL { 0 }
| FLOATLITERAL { 0 }

postfix_expr:
  primary_expr { 0 }
| postfix_expr LSQUARE args_list RSQUARE { 0 }
| postfix_expr LPAREN args_list RPAREN  { 0 }

args_list: { 0 }
| postfix_expr { 0 }
| args_list COMMA postfix_expr { 0 }

unary_operator:
  TILDE { 0 }
| NOT { 0 }
| MINUS { 0 }
| TIMES { 0 }

unary_expr:
  unary_operator postfix_expr { 0 }

cast_expr:
  unary_expr AS type_name { 0 }

type_name:
  INT { 0 }
| FLOAT { 0 }
| BOOL { 0 }
| VOID { 0 }

mult_expr:
 cast_expr { 0 }
| mult_expr TIMES cast_expr { 0 }
| mult_expr DIVIDE cast_expr { 0 }

add_expr:
mult_expr { 0 }
| add_expr PLUS mult_expr { 0 }
| add_expr MINUS mult_expr { 0 }

rel_expr:
add_expr { 0 }
| rel_expr LT add_expr { 0 }
| rel_expr GT add_expr { 0 }
| rel_expr LEQ add_expr { 0 }
| rel_expr GEQ add_expr { 0 }


eq_expr:
rel_expr { 0 }
| eq_expr NEQ rel_expr { 0 }
| eq_expr EQ rel_expr { 0 }


and_expr:
eq_expr { 0 }
| and_expr AND eq_expr { 0 }

or_expr:
and_expr { 0 }
| or_expr OR and_expr { 0 }

assign_expr:
or_expr { 0 }
| assign_expr ASSIGN unary_expr { 0 }

decl:
VAR ID COLON type_name ASSIGN assign_expr { 0 }  


fun_decl:
FUN ID LPAREN params_list RPAREN COLON type_name { 0 }

params_list: { 0 }
| ID COLON type_name { 0 }
| ID COLON type_name COMMA params_list { 0 }

