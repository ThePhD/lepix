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

let token_to_string = function
	| Parser.LPAREN -> "LPAREN"	
	| Parser.RPAREN -> "RPAREN"	
	| Parser.LBRACE -> "LBRACE"	
	| Parser.RBRACE -> "RBRACE"	
	| Parser.LSQUARE -> "LSQUARE"
	| Parser.RSQUARE -> "RSQUARE"
	| Parser.SEMI -> "SEMI"	
	| Parser.COMMA -> "COMMA"	
	| Parser.PLUS -> "PLUS"	
	| Parser.MINUS -> "MINUS"	
	| Parser.TIMES -> "TIMES"	
	| Parser.DIVIDE -> "DIVIDE"	
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
	| Parser.FUN -> "FUN"
	| Parser.NAMESPACE -> "NAMESPACE"
	| Parser.IF -> "IF"
	| Parser.ELSE -> "ELSE"	
	| Parser.FOR -> "FOR"
	| Parser.TO -> "TO"
	| Parser.BY -> "BY"
	| Parser.WHILE -> "WHILE"	
	| Parser.RETURN -> "RETURN"	
	| Parser.INT -> "INT"
	| Parser.FLOAT -> "FLOAT"	
	| Parser.BOOL -> "BOOL"	
	| Parser.VOID -> "VOID"
	| Parser.TRUE -> "TRUE"	
	| Parser.FALSE -> "FALSE"	
	| Parser.BREAK -> "BREAK"	
	| Parser.CONTINUE -> "CONTINUE"	
	| Parser.INTLITERAL(i) -> "INTLITERAL(" ^ string_of_int i ^ ")"
	| Parser.FLOATLITERAL(f) -> "FLOATLITERAL(" ^ string_of_float f ^ ")"
	| Parser.ID(s) -> "ID(" ^ s ^ ")"
	| Parser.MODULO -> "MODULO"
	| Parser.EOF -> "EOF"

let token_range_to_string (x, y) =
	let range_is_wide = ( y - x > 1 ) in
	if range_is_wide then
		string_of_int x ^ "-" ^ string_of_int y
	else
		string_of_int x

let token_source_to_string t =
	string_of_int t.Driver.token_line_number 
	^ ":" 
	^ token_range_to_string t.Driver.token_column_range

let token_list_to_string token_list = 
	let rec helper = function
	| (token, pos) :: tail -> 
		"[" ^ ( token_to_string token ) ^ ":" 
		^ token_source_to_string pos ^ "] " 
		^ helper tail
	| [] -> "\n" in helper token_list


(* Program types: Dump and Pretty-Printing Functions *)

let string_of_binary_op = function
	| Ast.Add -> "+"
	| Ast.Sub -> "-"
	| Ast.Mult -> "*"
	| Ast.Div -> "/"
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

let rec string_of_expr = function
	| Ast.IntLit(l) -> string_of_int l
	| Ast.BoolLit(true) -> "true"
	| Ast.BoolLit(false) -> "false"
	| Ast.FloatLit(f) -> string_of_float f
	| Ast.Id(sl) -> String.concat "." sl
	| Ast.BinaryOp(e1, o, e2) ->
		string_of_expr e1 ^ " " ^ string_of_binary_op o ^ " " ^ string_of_expr e2
	| Ast.PrefixUnaryOp(o, e) -> string_of_unary_op o ^ string_of_expr e
	| Ast.Access(e, l) -> string_of_expr e ^ "[" ^ (String.concat ", " (List.map string_of_expr l)) ^ "]"
	| Ast.MemberAccess(e, s) -> string_of_expr e ^ "." ^ s
	| Ast.Assign(sl, e) -> ( String.concat "." sl ) ^ " = " ^ string_of_expr e
	| Ast.Call(e, el) ->
		string_of_expr e ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
	| Ast.Noexpr -> "{ Noop }"
	| Ast.ArrayLit(el) -> "[ " ^ String.concat ", " (List.map string_of_expr el) ^ " ]"

let string_of_parallel_expr = function
	| Ast.Invocations(e) -> string_of_expr e
	| Ast.ThreadCount(e) -> string_of_expr e

let rec string_of_expr_list = function
	| [] -> ""
	| s::l -> string_of_expr s ^ "," ^ string_of_expr_list l

let rec string_of_typename = function
	| Ast.Int -> "int"
	| Ast.Bool -> "bool"
	| Ast.Void -> "void"
	| Ast.Float -> "float"
	| Ast.Array(t, d) -> string_of_typename t ^ ( String.make d '[' ) ^ ( String.make d ']' )

let rec string_of_bind = function
	| (n, t, r) -> n ^ " : " ^ ( if r then "&" else "" ) ^ string_of_typename t

let string_of_var_binding = function 
	| Ast.VarBinding(b, e) -> "var " ^ string_of_bind b ^ " = " ^ string_of_expr e ^ ";\n"

let rec string_of_stmt_list = function
	| [] -> ""
	| hd::[] -> string_of_stmt hd
	| hd::tl -> string_of_stmt hd ^ string_of_stmt_list tl
	and string_of_stmt = function
		| Ast.Expr(expr) -> string_of_expr expr ^ ";\n"; 
		| Ast.Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
		| Ast.If(e, s, []) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}"
		| Ast.If(e, s, s2) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}\n" ^ "else\n{" ^ string_of_stmt_list s2 ^"\n}"
		| Ast.For(e1, e2, e3, sl) -> "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^ string_of_expr e3  ^ ")\n{ " ^ string_of_stmt_list sl ^ "}"
		| Ast.ForBy(e1, e2, e3, sl) -> "for (" ^ string_of_expr e1  ^ " to " ^ string_of_expr e2 ^ " by " ^ string_of_expr e3  ^ ")\n{ " ^ string_of_stmt_list sl ^ "}"
		| Ast.While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt_list s
		| Ast.Break(n) -> ( if n == 1 then "break" else "break" ^ string_of_int n ) ^ ";\n"
		| Ast.Continue -> "continue;\n"
		| Ast.Var(vdef) -> string_of_var_binding vdef
		| Ast.Parallel(pel,sl) -> "parallel(" ^ (String.concat ", " (List.map string_of_parallel_expr pel)) ^ " )\n{\n" ^ string_of_stmt_list sl ^ "\n}\n" 
		| Ast.Atomic(sl) -> "atomic {\n" ^ string_of_stmt_list sl ^ "}\n"

let string_of_function_definition fdecl =
	"fun " ^  fdecl.Ast.func_name 
    ^ "(" ^ (String.concat ", " (List.map string_of_bind fdecl.Ast.func_parameters)) ^ ") : " 
    ^ string_of_typename fdecl.Ast.func_return_type  ^ "{\n" 
    ^ string_of_stmt_list fdecl.Ast.func_body 
    ^ "}\n"

let rec string_of_definition = function
	| Ast.FuncDef(fdef) -> string_of_function_definition fdef
	| Ast.VarDef(vdef) -> string_of_var_binding vdef
	| Ast.NamespaceDef(sl, defs) -> "namespace " ^ ( String.concat "." sl ) ^ "{\n" 
		^ (String.concat "" (List.map string_of_definition defs) ) ^ "}\n"

let string_of_program p = 
	(String.concat "" (List.map string_of_definition p) )

(* Error message helpers *)
let line_of_source src token_info =
	let ( absb, abse ) = token_info.Driver.token_character_range 
	and linestart = token_info.Driver.token_line_start
	in
	let ( lineend, _ ) =
		let f (endindex, should_skip) idx =
			let c = src.[idx] in
			if should_skip then (endindex, true) else
			(endindex + 1, c = '\n' || c = ';' || c = '}' || c = '{')
		in
		Polyfill.foldi f ( linestart, false ) linestart ( ( String.length src ) - linestart )
	in
	let srcline = String.sub src linestart (lineend - linestart) in
	let srclinelen = String.length srcline in
	let ( srcindent, _ ) = 
		let f (s, should_skip) idx = 
			let c = srcline.[idx] in
			let ws = not ( Polyfill.is_whitespace c ) in
			if should_skip || ws then (s, false) else
			(s ^ ( String.make 1 c ), true)
		in
		Polyfill.foldi f ( "", false ) 0 srclinelen
	in
	let indentlen = String.length srcindent
	and tokenlen = lineend - absb
	in
	( srcline, srcindent, (max ( srclinelen - indentlen - tokenlen ) 0 ) )
