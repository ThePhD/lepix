%{
open Ast

let reverse_list l =
	let rec builder acc = function
	| [] -> acc
	| hd::tl -> builder (hd::acc) tl
	in 
	builder [] l
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA LSQUARE RSQUARE COLON FUN TO BY 
%token PARALLEL INVOCATIONS ATOMIC THREADCOUNT
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR VAR
%token RETURN CONTINUE BREAK IF ELSE FOR WHILE
%token INT BOOL VOID FLOAT
%token DOT NAMESPACE
%token <string> ID
%token <int> INTLITERAL
%token <float> FLOATLITERAL
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
| args_list COMMA expr { $3::$1 }

array_spec: 
| LSQUARE RSQUARE { 1 }
| LSQUARE array_spec RSQUARE { 1 + $2 }

type_name:
| INT { Int }
| FLOAT { Float }
| BOOL { Bool }
| VOID { Void }
| type_name array_spec { Array($1, $2); }

qualified_id:
| ID { [$1] }
| qualified_id DOT ID { $3::$1 }

expr:
| qualified_id { Id($1) }
| INTLITERAL { IntLit($1) }
| FLOATLITERAL { FloatLit($1) }
| TRUE { BoolLit(true) }
| FALSE { BoolLit(false) }
| LSQUARE args_list RSQUARE { ArrayLit($2) }
| qualified_id LSQUARE args_list RSQUARE { Access(Id($1),$3)  }
| qualified_id LPAREN args_list RPAREN  { Call(Id($1),$3)  }
| MINUS expr %prec NEG { PrefixUnaryOp(Neg, $2) }
| NOT expr { PrefixUnaryOp(Not, $2) }
| expr TIMES expr { BinaryOp( $1, Mult, $3) }
| expr DIVIDE expr { BinaryOp( $1, Div, $3)  }
| expr PLUS expr { BinaryOp( $1, Add, $3) }
| expr MINUS expr { BinaryOp( $1, Sub, $3) }
| expr LT expr { BinaryOp( $1, Less, $3) }
| expr GT expr { BinaryOp( $1, Greater, $3) }
| expr LEQ expr { BinaryOp( $1, Leq, $3) }
| expr GEQ expr { BinaryOp( $1, Geq, $3) }
| expr NEQ expr { BinaryOp( $1, Neq, $3) }
| expr EQ expr { BinaryOp( $1, Equal, $3) }
| expr AND expr { BinaryOp( $1, And, $3) }
| expr OR expr { BinaryOp( $1, Or, $3) }
| qualified_id ASSIGN expr { Assign($1, $3) }

binding:
| ID COLON type_name { ($1,$3) }

params_list: { [] }
| ID COLON type_name { [($1,$3)] }
| ID COLON type_name COMMA params_list { ($1,$3)::$5 }

variable_definition:
| VAR binding ASSIGN expr SEMI { VarBinding($2,$4) }

fun_decl:
FUN ID LPAREN params_list RPAREN COLON type_name LBRACE statement_list RBRACE { { func_name=$2; func_parameters=$4; func_return_type=$7; func_body=$9} }

statement_list_builder: { [] }
| statement_list_builder statement { $2::$1 }

statement_list :
| statement_list_builder { reverse_list $1 }

parallel_binding:
| INVOCATIONS ASSIGN expr { Invocation($3) }
| THREADCOUNT ASSIGN expr { ThreadCount($3) }

parallel_binding_list_builder: { [] }
| parallel_binding { [$1] }
| parallel_binding_list_builder COMMA parallel_binding { $3::$1 }

parallel_binding_list:
| parallel_binding_list_builder { reverse_list $1 }

statement:
| expr SEMI { Expr($1) }
| IF LPAREN expr RPAREN LBRACE statement_list RBRACE %prec NOELSE { If($3,$6,[]) }
| IF LPAREN expr RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE { If($3,$6,$10)  }
| WHILE LPAREN expr RPAREN LBRACE statement_list RBRACE { While($3,$6) }
| FOR LPAREN expr TO expr BY expr RPAREN LBRACE statement_list RBRACE { For($3,$5,$7,$10) }
| FOR LPAREN expr SEMI expr SEMI expr RPAREN LBRACE statement_list RBRACE { ForBy($3,$5,$7,$10) }
| RETURN expr SEMI  { Return($2) }
| BREAK SEMI { Break(1) }
| BREAK INTLITERAL SEMI { Break($2) }
| CONTINUE SEMI { Continue }
| variable_definition { Var($1) }
| PARALLEL LPAREN parallel_binding_list RPAREN LBRACE statement_list RBRACE  { Parallel($3,$6) }
| ATOMIC LBRACE statement_list RBRACE { Atomic($3) }

decls_list : { [] }
| decls_list fun_decl { FuncDef($2)::$1 }
| decls_list variable_definition { VarDef($2)::$1 }
| decls_list NAMESPACE qualified_id LBRACE decls_list RBRACE { NamespaceDef($3, $5)::$1 }

program:
| decls_list EOF { reverse_list $1 }
