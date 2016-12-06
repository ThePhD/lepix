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

%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA 
%token LSQUARE RSQUARE COLON
%token DOT 
%token PARALLEL INVOCATIONS ATOMIC THREADCOUNT
%token PLUSPLUS MINUSMINUS 
%token PLUS MINUS TIMES DIVIDE ASSIGN 
%token MODULO
%token PLUSASSIGN MINUSASSIGN TIMESASSIGN DIVIDEASSIGN
%token MODULOASSIGN
%token NOT AND OR EQ NEQ LT LEQ GT GEQ
%token TRUE FALSE
%token VAR LET
%token FUN TO BY 
%token RETURN CONTINUE BREAK IF ELSE FOR WHILE
%token AMP CONST
%token <int> INT 
%token <int> FLOAT 
%token BOOL VOID STRING
%token AUTO
%token NAMESPACE
%token <string> ID
%token <string> STRINGLITERAL
%token <int> INTLITERAL
%token <float> FLOATLITERAL
%token EOF

%right ASSIGN
%right PLUSASSIGN MINUSASSIGN
%right TIMESASSIGN DIVIDEASSIGN MODULOASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE MODULO
%right NOT NEG
%left DOT
%left LSQUARE
%left LPAREN
%left MINUSMINUS
%left PLUSPLUS

%start program
%type<Ast.program> program
%%

qualified_id_builder:
| ID { [$1] }
| qualified_id DOT ID { $3 :: $1 }

qualified_id:
| qualified_id_builder { List.rev $1 }

builtin_type:
| AUTO { Ast.Auto }
| VOID { Ast.Void }
| BOOL { Ast.Bool }
| INT { Ast.Int($1) }
| FLOAT { Ast.Float($1) }
| STRING { Ast.String }

array_spec:
| LSQUARE RSQUARE { 1 }
| LSQUARE array_spec RSQUARE { 1 + $2 }

type_category: { (false, false) }
| AMP { (false, true) }
| CONST AMP { (true, true) }
| CONST { (true, false) }

sub_type_name:
| type_category builtin_type             { Ast.BuiltinType($2, $1) }
| type_category qualified_id             { Ast.StructType($2, $1) }
| type_category builtin_type array_spec  { Ast.Array(Ast.BuiltinType($2, $1), $3, Ast.no_qualifiers) }
| type_category qualified_id array_spec  { Ast.Array(Ast.StructType($2, $1), $3, Ast.no_qualifiers) }

sub_type_name_list_builder: { [] }
| sub_type_name { [$1] }
| sub_type_name_list_builder COMMA sub_type_name { $3 :: $1 }

sub_type_name_list:
| sub_type_name_list_builder { List.rev $1 }

type_name:
| sub_type_name { $1 }
| type_category LPAREN sub_type_name_list RPAREN sub_type_name { Ast.Function($5, $3, $1) }

expression_comma_list:                   { [] }
| expression                             { [$1] }
| expression COMMA expression_comma_list { $1 :: $3 }

expression:
| INTLITERAL { Ast.Literal(Ast.IntLit($1)) }
| FLOATLITERAL { Ast.Literal(Ast.FloatLit($1)) }
| STRINGLITERAL { Ast.Literal(Ast.StringLit($1)) }
| TRUE { Ast.Literal(Ast.BoolLit(true)) }
| FALSE { Ast.Literal(Ast.BoolLit(false)) }
| LSQUARE expression_comma_list RSQUARE { Ast.Initializer($2) }
| ID { Ast.Id($1) }
| expression DOT ID { Ast.Member($1, [$3]) }
| expression LSQUARE expression_comma_list RSQUARE { Ast.Index($1, $3)  }
| expression LPAREN expression_comma_list RPAREN { Ast.Call($1, $3)  }
| MINUS expression %prec NEG { Ast.PrefixUnaryOp(Ast.Neg, $2) }
| NOT expression { Ast.PrefixUnaryOp(Ast.Not, $2) }
| PLUSPLUS expression { Ast.PrefixUnaryOp(Ast.PreIncrement, $2) }
| MINUSMINUS expression { Ast.PrefixUnaryOp(Ast.PreDecrement, $2) }
| expression TIMES expression { Ast.BinaryOp($1, Ast.Mult, $3) }
| expression DIVIDE expression { Ast.BinaryOp($1, Ast.Div, $3)  }
| expression PLUS expression { Ast.BinaryOp($1, Ast.Add, $3) }
| expression MINUS expression { Ast.BinaryOp($1, Ast.Sub, $3) }
| expression MODULO expression { Ast.BinaryOp($1, Ast.Modulo, $3) }
| expression TIMESASSIGN expression { Ast.BinaryOp($1, Ast.MultAssign, $3) }
| expression DIVIDEASSIGN expression { Ast.BinaryOp($1, Ast.DivAssign, $3)  }
| expression PLUSASSIGN expression { Ast.BinaryOp($1, Ast.AddAssign, $3) }
| expression MINUSASSIGN expression { Ast.BinaryOp($1, Ast.SubAssign, $3) }
| expression MODULOASSIGN expression { Ast.BinaryOp($1, Ast.ModuloAssign, $3) }
| expression LT expression { Ast.BinaryOp($1, Ast.Less, $3) }
| expression GT expression { Ast.BinaryOp($1, Ast.Greater, $3) }
| expression LEQ expression { Ast.BinaryOp($1, Ast.Leq, $3) }
| expression GEQ expression { Ast.BinaryOp($1, Ast.Geq, $3) }
| expression NEQ expression { Ast.BinaryOp($1, Ast.Neq, $3) }
| expression EQ expression { Ast.BinaryOp($1, Ast.Equal, $3) }
| expression AND expression { Ast.BinaryOp($1, Ast.And, $3) }
| expression OR expression { Ast.BinaryOp($1, Ast.Or, $3) }
| expression ASSIGN expression { Ast.Assignment($1, $3) }
| LPAREN expression RPAREN { $2 }

type_spec:
| COLON type_name { $2 }

binding:
| ID type_spec { ($1, $2) }

binding_list: { [] }
| binding { [$1] }
| binding COMMA binding_list { $1 :: $3 }

var_binding:
| ID type_spec { ($1, $2) }
| ID { ($1, Ast.BuiltinType(Ast.Auto, Ast.no_qualifiers)) }

variable_definition:
| VAR var_binding ASSIGN expression { Ast.VarBinding($2, $4) }
| LET var_binding ASSIGN expression { Ast.LetBinding($2, $4) }
| VAR var_binding { Ast.VarBinding($2, Ast.NoOp) }
| LET var_binding { Ast.LetBinding($2, Ast.NoOp) }

statement_list_builder: { [] }
| statement_list_builder statement { $2 :: $1 }

statement_list :
| statement_list_builder { List.rev $1 }

parallel_binding:
| INVOCATIONS ASSIGN expression { Ast.Invocations($3) }
| THREADCOUNT ASSIGN expression { Ast.ThreadCount($3) }

parallel_binding_list_builder: { [] }
| parallel_binding { [$1] }
| parallel_binding_list_builder COMMA parallel_binding { $3 :: $1 }

parallel_binding_list:
| parallel_binding_list_builder { List.rev $1 }

sub_general_statement:
| expression { Ast.ExpressionStatement($1) }
| variable_definition { Ast.VariableStatement($1) }

general_statement:
| sub_general_statement SEMI { Ast.General($1) }

control_initializer_builder:
| sub_general_statement { ( [$1], 1 ) }
| control_initializer_builder SEMI sub_general_statement { let (l, c) = $1 in ( $3 :: l, 1 + c ) }

control_initializer:
| control_initializer_builder { let ( il, c ) = $1 in if c < 2 then ([], List.hd il) else (List.rev ( List.tl il ), List.hd il) }

sub_general_statement_list_builder: { [] }
| sub_general_statement { [$1] }
| sub_general_statement_list_builder COMMA sub_general_statement { $3 :: $1 }

sub_general_statement_list:
| sub_general_statement_list_builder { List.rev $1 }

statement:
| general_statement { $1 }
| IF LPAREN control_initializer RPAREN LBRACE statement_list RBRACE { Ast.IfBlock($3,$6) }
| IF LPAREN control_initializer RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE { Ast.IfElseBlock($3,$6,$10)  }
| WHILE LPAREN control_initializer RPAREN LBRACE statement_list RBRACE { Ast.WhileBlock($3, $6) }
| FOR LPAREN sub_general_statement_list SEMI expression SEMI expression_comma_list RPAREN LBRACE statement_list RBRACE { Ast.ForBlock($3, $5, $7, $10) }
| FOR LPAREN expression TO expression BY expression RPAREN LBRACE statement_list RBRACE { Ast.ForByToBlock($3, $5, $7, $10) }
| RETURN expression SEMI { Ast.Return($2) }
| BREAK SEMI { Ast.Break(1) }
| BREAK INTLITERAL SEMI { Ast.Break($2) }
| CONTINUE SEMI { Ast.Continue }
| PARALLEL LPAREN parallel_binding_list RPAREN LBRACE statement_list RBRACE  { Ast.ParallelBlock($3, $6) }
| PARALLEL LBRACE statement_list RBRACE  { Ast.ParallelBlock([Ast.ThreadCount(Ast.Literal(Ast.IntLit(-1))); Ast.Invocations(Ast.Literal(Ast.IntLit(-1)))], $3) }
| ATOMIC LBRACE statement_list RBRACE { Ast.AtomicBlock($3) }

function_definition:
| FUN ID LPAREN binding_list RPAREN type_spec LBRACE statement_list RBRACE { ([$2], $4, $6, $8) }

definition_list : { [] }
| definition_list function_definition { Ast.Basic(Ast.FunctionDefinition($2)) :: $1 }
| definition_list variable_definition { Ast.Basic(Ast.VariableDefinition($2)) :: $1 }
| definition_list NAMESPACE qualified_id LBRACE definition_list RBRACE { Ast.Namespace($3, $5) :: $1 }

program:
| definition_list EOF { List.rev $1 }
