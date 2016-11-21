%{
(* LePiX - LePiX Language Compiler Implementation
Copyright (c) 2016- ThePhD, Gabrielle Taylor, Akshaan Kakar, Fatimazorha Koly, Jackie Lin

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software 
without restriction, including without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to the following 
conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. *)

(* Parser for the LePiX language: compatible with both ocamlyacc and 
menhir, as we have developed against both for testing purposes. *)

open Ast

let reverse_list l =
	let rec builder acc = function
	| [] -> acc
	| hd::tl -> builder (hd::acc) tl
	in 
	builder [] l
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA 
%token LSQUARE RSQUARE COLON
%token DOT 
%token PARALLEL INVOCATIONS ATOMIC THREADCOUNT
%token PLUS MINUS TIMES DIVIDE ASSIGN 
%token MODULO
%token NOT AND OR EQ NEQ LT LEQ GT GEQ
%token AMP
%token TRUE FALSE
%token VAR LET
%token FUN TO BY 
%token RETURN CONTINUE BREAK IF ELSE FOR WHILE
%token INT BOOL VOID FLOAT
%token NAMESPACE
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
%left DOT

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

qualified_id_builder:
| ID { [$1] }
| qualified_id DOT ID { $3::$1 }

qualified_id:
| qualified_id_builder { reverse_list $1 }

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
| expr TIMES expr { BinaryOp($1, Mult, $3) }
| expr DIVIDE expr { BinaryOp($1, Div, $3)  }
| expr PLUS expr { BinaryOp($1, Add, $3) }
| expr MINUS expr { BinaryOp($1, Sub, $3) }
| expr LT expr { BinaryOp($1, Less, $3) }
| expr GT expr { BinaryOp($1, Greater, $3) }
| expr LEQ expr { BinaryOp($1, Leq, $3) }
| expr GEQ expr { BinaryOp($1, Geq, $3) }
| expr NEQ expr { BinaryOp($1, Neq, $3) }
| expr EQ expr { BinaryOp($1, Equal, $3) }
| expr AND expr { BinaryOp($1, And, $3) }
| expr OR expr { BinaryOp($1, Or, $3) }
| qualified_id ASSIGN expr { Assign($1, $3) }
| LPAREN expr RPAREN { $2 }

binding:
| ID COLON type_name { ($1,$3, false) }

params_list: { [] }
| ID COLON type_name { [($1,$3, false)] }
| ID COLON type_name COMMA params_list { ($1,$3, false)::$5 }

variable_definition:
| VAR binding ASSIGN expr SEMI { VarBinding($2,$4) }

fun_decl:
FUN ID LPAREN params_list RPAREN COLON type_name LBRACE statement_list RBRACE { { func_name=$2; func_parameters=$4; func_return_type=$7; func_body=$9} }

statement_list_builder: { [] }
| statement_list_builder statement { $2::$1 }

statement_list :
| statement_list_builder { reverse_list $1 }

parallel_binding:
| INVOCATIONS ASSIGN expr { Invocations($3) }
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
| PARALLEL LBRACE statement_list RBRACE  { Parallel([ThreadCount(IntLit(-1)); Invocations(IntLit(-1))],$3) }
| ATOMIC LBRACE statement_list RBRACE { Atomic($3) }

decls_list : { [] }
| decls_list fun_decl { FuncDef($2)::$1 }
| decls_list variable_definition { VarDef($2)::$1 }
| decls_list NAMESPACE qualified_id LBRACE decls_list RBRACE { NamespaceDef($3, $5)::$1 }

program:
| decls_list EOF { reverse_list $1 }
