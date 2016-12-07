(* LePiX Language Compiler Implementation
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

(* Contains routines for string-ifying various parts of the
infrastructure of the compiler, to make it easy to understand what the fuck we're doing. *)

(* Lexer types: dumping and pretty printing tokens *)

let preparser_token_to_string = function
	| Preparser.HASH -> "HASH"
	| Preparser.IMPORT -> "IMPORT"
	| Preparser.STRING -> "STRING"
	| Preparser.TEXT(s) -> "TEXT(" ^ s ^ ")"
	| Preparser.STRINGLITERAL(s) -> "STRINGLITERAL(" ^ s ^ ")"
	| Preparser.EOF -> "EOF"


let parser_token_to_string = function
	| Parser.LPAREN -> "LPAREN"
	| Parser.RPAREN -> "RPAREN"
	| Parser.LBRACE -> "LBRACE"
	| Parser.RBRACE -> "RBRACE"
	| Parser.LSQUARE -> "LSQUARE"
	| Parser.RSQUARE -> "RSQUARE"
	| Parser.SEMI -> "SEMI"
	| Parser.COMMA -> "COMMA"
	| Parser.PLUSPLUS -> "PLUSPLUS"
	| Parser.MINUSMINUS -> "MINUSMINUS"
	| Parser.PLUS -> "PLUS"
	| Parser.MINUS -> "MINUS"
	| Parser.TIMES -> "TIMES"
	| Parser.DIVIDE -> "DIVIDE"
	| Parser.MODULO -> "MODULO"
	| Parser.PLUSASSIGN -> "PLUSASSIGN"
	| Parser.MINUSASSIGN -> "MINUSASSIGN"
	| Parser.TIMESASSIGN -> "TIMESASSIGN"
	| Parser.DIVIDEASSIGN -> "DIVIDEASSIGN"
	| Parser.MODULOASSIGN -> "MODULOASSIGN"
	| Parser.ASSIGN -> "ASSIGN"
	| Parser.EQ -> "EQ"
	| Parser.NEQ -> "NEQ"
	| Parser.LT -> "LT"
	| Parser.LEQ -> "LEQ"
	| Parser.GT -> "GT"
	| Parser.GEQ -> "GEQ"
	| Parser.AND -> "AND"
	| Parser.OR -> "OR"
	| Parser.NOT -> "NOT"
	| Parser.DOT -> "DOT"
	| Parser.AMP -> "AMPERSAND"
	| Parser.COLON -> "COLON"
	| Parser.PARALLEL -> "PARALLEL"
	| Parser.INVOCATIONS -> "INVOCATIONS"
	| Parser.THREADCOUNT -> "THREADCOUNT"
	| Parser.ATOMIC -> "ATOMIC"
	| Parser.VAR -> "VAR"
	| Parser.LET -> "LET"
	| Parser.CONST -> "CONST"
	| Parser.FUN -> "FUN"
	| Parser.NAMESPACE -> "NAMESPACE"
	| Parser.IF -> "IF"
	| Parser.ELSE -> "ELSE"
	| Parser.FOR -> "FOR"
	| Parser.TO -> "TO"
	| Parser.BY -> "BY"
	| Parser.WHILE -> "WHILE"
	| Parser.RETURN -> "RETURN"
	| Parser.INT(b) -> "INT" ^ string_of_int b
	| Parser.FLOAT(b) -> "FLOAT" ^ string_of_int b
	| Parser.BOOL -> "BOOL"
	| Parser.STRING -> "STRING"
	| Parser.VOID -> "VOID"
	| Parser.AUTO -> "AUTO"
	| Parser.TRUE -> "TRUE"
	| Parser.FALSE -> "FALSE"
	| Parser.BREAK -> "BREAK"
	| Parser.CONTINUE -> "CONTINUE"
	| Parser.STRINGLITERAL(s) -> "STRINGLITERAL(" ^ s ^ ")"
	| Parser.INTLITERAL(i) -> "INTLITERAL(" ^ string_of_int i ^ ")"
	| Parser.FLOATLITERAL(f) -> "FLOATLITERAL(" ^ string_of_float f ^ ")"
	| Parser.ID(s) -> "ID(" ^ s ^ ")"
	| Parser.EOF -> "EOF"

let token_range_to_string (x, y) =
	let range_is_wide = ( y - x > 1 ) in
	if range_is_wide then
		string_of_int x ^ "-" ^ string_of_int y
	else
		string_of_int x

let token_source_to_string t =
	string_of_int t.Core.token_line_number 
	^ ":" 
	^ token_range_to_string t.Core.token_column_range

let preparser_token_list_to_string token_list = 
	let rec helper = function
	| (token, pos) :: tail -> 
		"[" ^ ( preparser_token_to_string token ) ^ ":" 
		^ token_source_to_string pos ^ "] " 
		^ helper tail
	| [] -> "\n" in helper token_list

let parser_token_list_to_string token_list = 
	let rec helper = function
	| (token, pos) :: tail -> 
		"[" ^ ( parser_token_to_string token ) ^ ":" 
		^ token_source_to_string pos ^ "] " 
		^ helper tail
	| [] -> "\n" in helper token_list


(* Program types: 
dumping and Pretty-Printing *)

let string_of_id i = i

let string_of_qualified_id qid = ( String.concat "." ( List.map string_of_id qid ) )

let string_of_binary_op = function
	| Ast.Add -> "+"
	| Ast.Sub -> "-"
	| Ast.Mult -> "*"
	| Ast.Div -> "/"
	| Ast.Modulo -> "%"
	| Ast.AddAssign -> "+="
	| Ast.SubAssign -> "-="
	| Ast.MultAssign -> "*="
	| Ast.DivAssign -> "/="
	| Ast.ModuloAssign -> "%="
	| Ast.Equal -> "=="
	| Ast.Neq -> "!="
	| Ast.Less -> "<"
	| Ast.Leq -> "<="
	| Ast.Greater -> ">"
	| Ast.Geq -> ">="
	| Ast.And -> "&&"
	| Ast.Or -> "||"

let string_of_unary_op = function
	| Ast.Neg -> "-"
	| Ast.Not -> "!"
	| Ast.PreDecrement -> "--"
	| Ast.PreIncrement -> "++"

let rec string_of_expression = function
	| Ast.Literal(Ast.IntLit(l)) -> string_of_int l
	| Ast.Literal(Ast.BoolLit(true)) -> "true"
	| Ast.Literal(Ast.BoolLit(false)) -> "false"
	| Ast.Literal(Ast.StringLit(s)) -> "\"" ^ s ^ "\""
	| Ast.Literal(Ast.FloatLit(f)) -> string_of_float f
	| Ast.Id(s) -> s
	| Ast.BinaryOp(e1, o, e2) ->
		string_of_expression e1 ^ " " ^ string_of_binary_op o ^ " " ^ string_of_expression e2
	| Ast.PrefixUnaryOp(o, e) -> string_of_unary_op o ^ string_of_expression e
	| Ast.Index(e, l) -> string_of_expression e ^ "[" ^ (String.concat ", " (List.map string_of_expression l)) ^ "]"
	| Ast.Member(e, qid) -> string_of_expression e ^ "." ^ string_of_qualified_id qid
	| Ast.Assignment(e1, e2) -> string_of_expression e1 ^ " = " ^ string_of_expression e2
	| Ast.Call(e, el) ->
		string_of_expression e ^ "(" ^ String.concat ", " (List.map string_of_expression el) ^ ")"
	| Ast.NoOp -> "{ nop }"
	| Ast.Initializer(el) -> "[ " ^ String.concat ", " (List.map string_of_expression el) ^ " ]"

let string_of_parallel_expression = function
	| Ast.ThreadCount(e) -> "thread_count = " ^ string_of_expression e
	| Ast.Invocations(e) -> "invocations = " ^ string_of_expression e

let rec string_of_expression_list el =
	String.concat ", " ( List.map string_of_expression el )

let rec string_of_builtin_type = function
	| Ast.Auto -> "auto"
	| Ast.Float(b) -> "float" ^ string_of_int b
	| Ast.Int(b) -> "int" ^ string_of_int b
	| Ast.Bool -> "bool"
	| Ast.String -> "string"
	| Ast.Void -> "void"

let string_of_type_qualifier = function
	| (c, r) -> ( if c then "const" else "" ) ^ ( if r then "&" else "" )

let rec string_of_type_name = function
	| Ast.BuiltinType(t, tq) -> string_of_type_qualifier tq ^ string_of_builtin_type t
	| Ast.StructType(sl, tq) -> string_of_type_qualifier tq ^ String.concat "." sl
	| Ast.Array(t, d, tq) -> string_of_type_qualifier tq ^ string_of_type_name t ^ ( String.make d '[' ) ^ ( String.make d ']' )
	| Ast.Function(r, args, tq) -> string_of_type_qualifier tq ^ string_of_type_name r ^ " ( " ^  ( String.concat ", " ( List.map ( fun v -> string_of_type_name v ) args ) ) ^ " )"

let string_of_binding = function
	| (n, t) -> n ^ " : " ^ string_of_type_name t

let string_of_variable_definition = function 
	| Ast.VarBinding(b, Ast.NoOp) -> "var " ^ string_of_binding b
	| Ast.LetBinding(b, Ast.NoOp) -> "let " ^ string_of_binding b
	| Ast.VarBinding(b, e) -> "var " ^ string_of_binding b ^ " = " ^ string_of_expression e
	| Ast.LetBinding(b, e) -> "let " ^ string_of_binding b ^ " = " ^ string_of_expression e

let string_of_general_statement = function
	| Ast.ExpressionStatement(e) -> string_of_expression e
	| Ast.VariableStatement(v) -> string_of_variable_definition v

let string_of_condition_initializer = function
	| (il, cond) -> ( String.concat "; " ( List.map string_of_general_statement il ) ) 
	^ ( if ( List.length il ) > 0 then ";" else "" )
	^ ( string_of_general_statement cond )

let rec string_of_statement s = 
	let string_of_statement_list sl = String.concat "" (List.map string_of_statement sl) in
	match s with
		| Ast.General(b) -> string_of_general_statement b ^ ";\n"; 
		| Ast.Return(expr) -> "return " ^ string_of_expression expr ^ ";\n";
		| Ast.IfBlock(ilcond, s) -> "if (" ^ string_of_condition_initializer ilcond ^ ")" 
			^ "{\n" ^  string_of_statement_list s ^ "}\n"
		| Ast.IfElseBlock(ilcond, s, s2) -> "if (" ^ string_of_condition_initializer ilcond ^ ")" 
			^ "{\n" ^  string_of_statement_list s ^ "}\n" 
			^ "else {\n" ^ string_of_statement_list s2 ^ "}\n"
		| Ast.ForBlock(gsl, cond, incrl, sl) -> "for (" ^ (String.concat ", " (List.map string_of_general_statement gsl) ) ^ "; "
			^ string_of_expression cond ^ "; "
			^ string_of_expression_list incrl  ^ ") {\n" ^ string_of_statement_list sl ^ "}\n"
		| Ast.ForByToBlock(e1, e2, e3, sl) -> "for (" ^ string_of_expression e1  ^ " to " ^ string_of_expression e2 ^ " by " ^ string_of_expression e3  ^ ") {\n" ^ string_of_statement_list sl ^ "}\n"
		| Ast.WhileBlock(ilcond, s) -> "while (" ^ string_of_condition_initializer ilcond ^ ") {\n" 
			^ string_of_statement_list s ^ "}\n"
		| Ast.Break(n) -> ( if n == 1 then "break" else "break" ^ string_of_int n ) ^ ";\n"
		| Ast.Continue -> "continue;\n"
		| Ast.ParallelBlock(pel,sl) -> "parallel(" ^ (String.concat ", " (List.map string_of_parallel_expression pel)) ^ " ) {"
			^ "\n" ^ string_of_statement_list sl ^ "}\n"
		| Ast.AtomicBlock(sl) -> "atomic {\n" ^ string_of_statement_list sl ^ "}\n"

let string_of_statement_list sl = 
	String.concat "" (List.map string_of_statement sl)

let string_of_function_definition = function
	| ( name, parameters, return_type, body) ->
		"fun " ^ string_of_qualified_id name 
	    ^ "(" ^ (String.concat ", " (List.map string_of_binding parameters)) ^ ") : " 
	    ^ string_of_type_name return_type  ^ " {\n" 
	    ^ string_of_statement_list body 
	    ^ "}\n"

let rec string_of_basic_definition = function
	| Ast.FunctionDefinition(fdef) -> string_of_function_definition fdef
	| Ast.VariableDefinition(vdef) -> string_of_variable_definition vdef ^ ";\n"

let string_of_struct_definition = function
	| (_,_) -> "{ UNSUPPORTED }\n"

let rec string_of_definition = function
	| Ast.Basic(bdef) -> string_of_basic_definition bdef
	| Ast.Structure(sdef) -> string_of_struct_definition sdef
	| Ast.Namespace(qid, defs) -> "namespace " ^ string_of_qualified_id qid ^ "{\n" 
		^ (String.concat "" (List.map string_of_definition defs) ) ^ "}\n"

let string_of_program p = 
	let s = (String.concat "" (List.map string_of_definition p) ) in
	Core.brace_tabulate s 0

(* Semantic Program types: 
dumping and pretty printing *)

let string_of_s_locals = function
	| Semast.SLocals(bl) -> String.concat ";\n" ( List.map string_of_binding bl )

let string_of_s_expression = function 
	| Semast.SExpression(t, e) -> "[[" ^ string_of_type_name t ^ "]] " ^ string_of_expression e

let string_of_s_capture = function
	| Semast.SParallelCapture(bl) -> let capturecount = List.length bl in
		if capturecount == 0 then "[[no captures]]\n" else
		"[[captures]]" ^ ( String.concat ", " ( List.map string_of_binding bl ) )
		^ ";\n"

let string_of_s_general_statement = function
	| Semast.SExpressionStatement(sexpr) -> string_of_s_expression sexpr
	| Semast.SVariableStatement(v) -> string_of_variable_definition v

let string_of_s_general_statement_list gsl =
	String.concat ";\n" (List.map string_of_s_general_statement gsl)

let rec string_of_s_statement s =
	let s_stmt_list sl =
		String.concat "\n" ( List.map string_of_s_statement sl )
	in 
	let initializer_begin (locals, gsl) =
		"{ " 
		^ string_of_s_locals locals
		^ "\n" ^ string_of_s_general_statement_list gsl
		^ "\n"	
	in 
	let initializer_end(locals, gsl) =
		"}\n"
	in match s with
	| Semast.SGeneral(g) ->  ( string_of_s_general_statement g ) ^ ";"
	| Semast.SReturn(sexpr) -> string_of_s_expression sexpr
	| Semast.SBreak(n) -> if n < 2 then "break;" else "break " ^ string_of_int n ^ ";" 
	| Semast.SContinue -> "continue;"
	| Semast.SAtomicBlock(locals, sl) -> "atomic {" 
		^ string_of_s_locals locals
		^ s_stmt_list sl
		^ "}\n"
	| Semast.SParallelBlock( pel, captures, (locals, sl)) -> 
		"parallel(" ^ (String.concat ", " (List.map string_of_parallel_expression pel)) ^ " ) {"
		^ "\n" ^ string_of_s_capture captures
		^ s_stmt_list sl 
		^ "}\n"
	| Semast.SIfBlock(Semast.SControlInitializer((initlocals, initsl), cond), (locals, sl)) -> 
		let precount = List.length initsl in
		if precount > 1 then initializer_begin (initlocals, initsl) 
		else ""
		^ "if (" ^ string_of_s_expression cond ^ ") {"
		^ "\n" ^ string_of_s_locals locals
		^ "\n" ^ s_stmt_list sl
		^ "}\n"
		^ initializer_end (initlocals, initsl)
	| Semast.SIfElseBlock(Semast.SControlInitializer((initlocals, initsl), cond), (ilocals, isl), (elocals, esl)) -> 
		let precount = List.length initsl in
		if precount > 1 then initializer_begin (initlocals, initsl) 
		else ""
		^ "if (" ^ string_of_s_expression cond ^ ") {"
		^ "\n" ^ string_of_s_locals ilocals
		^ "\n" ^ s_stmt_list isl
		^ "}\n"
		^ "else {"
		^ "\n" ^ string_of_s_locals elocals
		^ "\n" ^ s_stmt_list esl
		^ "}\n"
		^ initializer_end (initlocals, initsl)
	| Semast.SWhileBlock(Semast.SControlInitializer((initlocals, initsl), cond), (locals, sl)) -> 
		let precount = List.length initsl in
		if precount > 1 then initializer_begin (initlocals, initsl) 
		else ""
		^ "while (" ^ string_of_s_expression cond ^ ") {"
		^ "\n" ^ string_of_s_locals locals
		^ "\n" ^ s_stmt_list sl
		^ "}\n"
		^ initializer_end (initlocals, initsl)
	| Semast.SForBlock(Semast.SControlInitializer((initlocals, initsl), cond), increxprl, (locals, sl)) -> 
		let precount = List.length initsl in
		let incrl =  String.concat ", " ( List.map string_of_s_expression increxprl ) in
		if precount > 1 then initializer_begin (initlocals, initsl) 
		else ""
		^ "for (;" ^ string_of_s_expression cond ^ "; " ^ incrl ^ ") {"
		^ "\n" ^ string_of_s_locals locals
		^ "\n" ^ s_stmt_list sl
		^ "}\n"
		^ initializer_end (initlocals, initsl)

let string_of_s_statement_list sl =
	String.concat "\n" ( List.map string_of_s_statement sl )

let string_of_s_block = function
	| (locals, sl) -> "{\n" ^ string_of_s_locals locals
		^ "\n" ^ string_of_s_statement_list sl 
		^ "\n}\n"

let string_of_s_parameters = function
	| Semast.SParameters(parameters) -> String.concat ", " (List.map string_of_binding parameters)

let string_of_s_function_definition = function
	| ( qid, parameters, return_type, bodyblock ) -> 
		"fun " ^ string_of_qualified_id qid
		^ "(" ^ string_of_s_parameters parameters ^ ") : " 
		^ string_of_type_name return_type  ^ " {\n" 
		^ string_of_s_block bodyblock
		^ "}\n"

let string_of_s_basic_definition = function
	| Semast.SVariableDefinition(v) -> string_of_variable_definition v
	| Semast.SFunctionDefinition(f) -> string_of_s_function_definition f

let rec string_of_s_definition = function
	| Semast.SBasic(b) -> string_of_s_basic_definition b
	| Semast.SStructure(_,_) -> "{ Unsupported }\n"
	| Semast.SNamespace(qid, sdl) -> "namespace " ^ string_of_qualified_id qid ^ " {\n" ^ ( String.concat "" ( List.map string_of_s_definition sdl ) ) ^ "}\n"

let string_of_semantic_program = function
	| ( symboltable, sdl ) -> let s = String.concat "" (List.map string_of_s_definition sdl) in
		Core.brace_tabulate s 0
