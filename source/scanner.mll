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

(* Ocamllex Scanner for LePiX *)

{ 
	open Parser

	let current_line = ref 1
    let sourcename = ref ""
}

let whitespace = [' ' '\t' '\r']
let newline = ['\n']

rule token = parse
| whitespace { token lexbuf }
| newline  { incr current_line; Lexing.new_line lexbuf; token lexbuf }
| "/*"     { multi_comment 0 lexbuf }
| "//"	   { single_comment lexbuf }
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['	   { LSQUARE }
| ']'	   { RSQUARE }
| ';'      { SEMI }
| ':'	   { COLON }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '='      { ASSIGN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "%"      { MODULO }
| '.'      { DOT }
| '&'      { AMP }
| "||"     { OR }
| "!"      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "by"     { BY }
| "to"     { TO }
| "return" { RETURN }
| "int"    { INT }
| "float"  { FLOAT }
| "bool"   { BOOL }
| "void"   { VOID }
| "true"   { TRUE }
| "false"  { FALSE }
| "var"    { VAR }
| "fun"	    { FUN }
| "parallel" { PARALLEL }
| "break" { BREAK }
| "continue" { CONTINUE }
| "invocations" { INVOCATIONS }
| "thread_count" { THREADCOUNT }
| "atomic" { ATOMIC }
| "namespace" { NAMESPACE }
| ['0'-'9']+ as lxm { INTLITERAL(int_of_string lxm) }
| '.' ['0'-'9']+ ('e' ('+'|'-')? ['0'-'9']+)? as lxm { FLOATLITERAL(float_of_string lxm) }
| ['0'-'9']+ ( '.' ['0'-'9']* ('e' ('+'|'-')? ['0'-'9']+)? | ('e' ('+'|'-')? ['0'-'9']+)?) as lxm { FLOATLITERAL(float_of_string lxm) } 
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and multi_comment level = parse
| newline { incr current_line; Lexing.new_line lexbuf; multi_comment level lexbuf }
|  "*/" { if level = 0 then token lexbuf else multi_comment (level-1) lexbuf }
|  "/*" { multi_comment (level+1) lexbuf }
| _    { multi_comment level  lexbuf }

and single_comment = parse
| newline { incr current_line; Lexing.new_line lexbuf; token lexbuf }
| _    { single_comment lexbuf }

