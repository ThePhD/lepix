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
		"[" ^ "id " ^ ( string_of_int pos.Driver.token_number ) ^ ( token_to_string token ) ^ ":" 
		^ token_source_to_string pos ^ "] " 
		^ helper tail
	| [] -> "\n" in helper token_list
