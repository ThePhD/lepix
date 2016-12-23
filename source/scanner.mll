(* LePiX - LePiX Language Compiler Implementation
Copyright (c) 2016- ThePhD

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
let binary_digit = '0' | '1'
let hex_digit = ['0'-'9'] | ['A'-'F'] | ['a'-'f']
let octal_digit = ['0'-'7']
let decimal_digit = ['0'-'9']
let uppercase_letter = ['A'-'Z']
let lowercase_letter = ['a'-'z']
let n_digit = decimal_digit | uppercase_letter | lowercase_letter

rule token = parse
| whitespace { token lexbuf }
| newline  { Lexing.new_line lexbuf; token lexbuf }
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
| "+="     { PLUSASSIGN }
| "-="     { MINUSASSIGN }
| "*="     { TIMESASSIGN }
| "/="     { DIVIDEASSIGN }
| "%="     { MODULOASSIGN }
| "++"     { PLUSPLUS }
| "--"     { MINUSMINUS }
| "%"      { MODULO }
| '='      { ASSIGN }
| '&'      { AMP }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
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
| "auto"   { AUTO }
| "int" ((decimal_digit+)? as s) { let bits = if s = "" then 32 else ( int_of_string s ) in INT(bits) }
| "float" ((decimal_digit+)? as s) { let bits = if s = "" then 64 else ( int_of_string s ) in FLOAT(bits) }
| "bool"   { BOOL }
| "string" { STRING }
| "void"   { VOID }
| "memory" { MEMORY }
| "true"   { TRUE }
| "false"  { FALSE }
| "var"    { VAR }
| "let"    { LET }
| "const"  { CONST }
| "fun"	    { FUN }
| "parallel" { PARALLEL }
| "break" { BREAK }
| "continue" { CONTINUE }
| "invocations" { INVOCATIONS }
| "thread_count" { THREADCOUNT }
| "atomic" { ATOMIC }
| "namespace" { NAMESPACE }
| "import" { IMPORT }
| '"'      { string_literal ( Buffer.create 128 ) lexbuf }
| decimal_digit+ as lxm { INTLITERAL(Num.num_of_string lxm) }
| "0c" | "0C" { octal_int_literal lexbuf }
| "0x" | "0X" { hex_int_literal lexbuf }
| "0b" | "0B" { binary_int_literal lexbuf }
| ( "0n" | "0N" ) ( decimal_digit+ as b ) ("n" | "N") { n_int_literal (int_of_string b) lexbuf }
| '.' ['0'-'9']+ ('e' ('+'|'-')? ['0'-'9']+)? as lxm { FLOATLITERAL(float_of_string lxm) }
| ['0'-'9']+ ( '.' ['0'-'9']* ('e' ('+'|'-')? ['0'-'9']+)? | ('e' ('+'|'-')? ['0'-'9']+)?) as lxm { FLOATLITERAL(float_of_string lxm) } 
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as c { raise (Errors.UnknownCharacter(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }


and octal_int_literal = parse
| octal_digit+ as s { INTLITERAL( Polyfill.num_of_string_base 8 s ) }
| _ as c { raise (Errors.BadNumericLiteral(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }


and hex_int_literal = parse
| hex_digit+ as s { INTLITERAL( Polyfill.num_of_string_base 16 s ) }
| _ as c { raise (Errors.BadNumericLiteral(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }


and binary_int_literal = parse
| binary_digit+ as s { INTLITERAL( Polyfill.num_of_string_base 2 s ) }
| _ as c { raise (Errors.BadNumericLiteral(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }


and n_int_literal base = parse
| n_digit+ as s    { INTLITERAL( Polyfill.num_of_string_base base s ) }
| _ as c { raise (Errors.BadNumericLiteral(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }


and string_literal string_buffer = parse
| newline as c { Lexing.new_line lexbuf; Buffer.add_char string_buffer c; string_literal string_buffer lexbuf }
| '"' { let v = STRINGLITERAL( Buffer.contents string_buffer ) in v }
| "\\\"" as s { Buffer.add_string string_buffer s; string_literal string_buffer lexbuf }
| _ as c { Buffer.add_char string_buffer c; string_literal string_buffer lexbuf }


and multi_comment level = parse
| newline { Lexing.new_line lexbuf; multi_comment level lexbuf }
| "*/" { if level = 0 then token lexbuf else multi_comment (level-1) lexbuf }
| "/*" { multi_comment (level+1) lexbuf }
| _    { multi_comment level lexbuf }


and single_comment = parse
| newline { Lexing.new_line lexbuf; token lexbuf }
| _    { single_comment lexbuf }
