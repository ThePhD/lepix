{ 
	open Parser

	(* state variables: line number, etc. *)
	let line_num = ref 1

}

(* handle windows newlines *)
let eol = '\r'? '\n'
let blankspace = [ ' ' '\t' ]
let letter = ['A' - 'Z' 'a' - 'z' ]
let digit = ['0' - '9' ]
let ident = letter ( letter | digit )+
let name = ident ('.' ident)+

(* the basic text eater *)
(* we save all the characters that we see, 
 we encounter the preprocessor starter *)
rule token = parse
	| '#'        { preprocessor_token lexbuf }
	| eol        { incr line_num; EOL }
	| eof        { EOF }
	| _ as c     { TEXT(c) }

(* The actual preprocessor tokens *)
(* Here, we see that we just capture
string expressions, dot-delimeted ident names,
macro continuation lines and more *)
and preprocessor_token = parse
	| "import"            { IMPORT }
	| "strings"           { STRINGS }
	| '"'(_* as s)'"'     { STRING_LITERAL(s) }
	| name as s           { NAME(s) }
	| eol '#'             { incr line_num; CONTINUE }
	| eol                 { incr line_num; EOL; token lexbuf }
	| eof                 { EOF; token lexbuf }
	| blankspace          { preprocessor_token lexbuf }
	| _ as c   		  { TEXT(c) }
