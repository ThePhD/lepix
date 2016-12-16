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

let whitespace = [' ' '\t' '\r']
let newline = ['\n']

rule token = parse
| newline as c { Lexing.new_line lexbuf; let b = Buffer.create 1024 in Buffer.add_char b c; sub_token b lexbuf }
| '#'          { let t = Preparser.HASH in t :: hash_token lexbuf  }
| _ as c       { let b = Buffer.create 1024 in Buffer.add_char b c; sub_token b lexbuf }
| eof          { [Preparser.EOF] }

and sub_token text_buf = parse
| newline as c  { Lexing.new_line lexbuf; Buffer.add_char text_buf c; sub_token text_buf lexbuf }
| '#'           { let s = Buffer.contents text_buf in let t = Preparser.TEXT(s) in let l = Preparser.HASH :: ( hash_token lexbuf ) in t :: l  }
| _ as c        { Buffer.add_char text_buf c; sub_token text_buf lexbuf }
| eof           { let s = Buffer.contents text_buf in let t = Preparser.TEXT(s) in [t; Preparser.EOF] }

and hash_token = parse
| newline    { Lexing.new_line lexbuf; token lexbuf }
| whitespace { hash_token lexbuf }
| '"'        { let b = ( Buffer.create 128 ) in string_literal b lexbuf }
| "import"   { Preparser.IMPORT :: hash_token lexbuf }
| "string"   { Preparser.STRING :: hash_token lexbuf }
| eof        { [Preparser.EOF] }
| _ as c     { raise (Errors.UnknownCharacter(String.make 1 c, ( Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf ) )) }

and string_literal string_buf = parse
| newline as c { Lexing.new_line lexbuf; Buffer.add_char string_buf c; string_literal string_buf lexbuf }
| '"'          { let sl = Preparser.STRINGLITERAL( Buffer.contents string_buf ) in [sl] }
| "\\\"" as s  { Buffer.add_string string_buf s; string_literal string_buf lexbuf }
| _ as c       { Buffer.add_char string_buf c; string_literal string_buf lexbuf }
