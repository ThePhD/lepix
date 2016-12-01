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

(* Ocamllex Scanner for LePiX Preprocessor *)

{ 
	open Parser
}

let whitespace = [' ' '\t' '\r']
let newline = ['\n']

rule token = parse
| whitespace { token lexbuf }
| newline  { Lexing.new_line lexbuf; token lexbuf }
| "/*"     { multi_comment 0 lexbuf }
| "//"	   { single_comment lexbuf }
| '"'      { string_literal ( Buffer.create 128 ) lexbuf }
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
| "int"    { INT(32) }
| "float"  { FLOAT(32) }
| "bool"   { BOOL }
| "string"   { STRING }
| "void"   { VOID }
| "true"   { TRUE }
| "false"  { FALSE }
| "var"    { VAR }
| "let"    { LET }
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
| _ as c { raise (Error.UnknownCharacter(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }

and string_literal string_buffer = parse
| newline as c { Lexing.new_line lexbuf; Buffer.add_char string_buffer c; string_literal string_buffer lexbuf }
| '"' { let v = STRINGLITERAL( Buffer.contents string_buffer ) in v }
| "\\\"" as s { Buffer.add_string string_buffer s; string_literal string_buffer lexbuf }
| _ as c { Buffer.add_char string_buffer c; string_literal string_buffer lexbuf }

and multi_comment level = parse
| newline { Lexing.new_line lexbuf; multi_comment level lexbuf }
|  "*/" { if level = 0 then token lexbuf else multi_comment (level-1) lexbuf }
|  "/*" { multi_comment (level+1) lexbuf }
| _    { multi_comment level lexbuf }

and single_comment = parse
| newline { Lexing.new_line lexbuf; token lexbuf }
| _    { single_comment lexbuf }

