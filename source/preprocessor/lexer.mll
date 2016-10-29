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
	| '#'        { print_string "# match\n"; preprocessor_token lexbuf }
	| eol as s   { print_string "eol match\n"; incr line_num; EOL(s) }
	| eof        { EOF }
	| _ as c     { CHARACTER(c) }

(* The actual preprocessor tokens *)
(* Here, we see that we just capture
string expressions, dot-delimeted ident names,
macro continuation lines and more *)
and preprocessor_token = parse
	| "import"            { print_string "import match\n"; IMPORT }
	| "strings"           { print_string "strings match\n"; STRINGS }
	| '"'                 { print_string "string match\n"; string_token (Buffer.create 64) lexbuf  }
	| name as s           { print_string "name match\n"; NAME(s) }
	| eol '#'             { print_string "continue match\n"; incr line_num; CONTINUE }
	| eol                 { print_string "eol match\n"; incr line_num; print_string "blank space\n"; token lexbuf }
	| eof                 { print_string "eof match\n"; token lexbuf }
	| blankspace          { print_string "blank space\n"; preprocessor_token lexbuf }
	| _ as c   		  { print_string "any_char match\n"; CHARACTER(c) }

and string_token buf = parse
	| '"' { STRING_LITERAL(Buffer.contents buf); preprocessor_token lexbuf }
	| _ as c { Buffer.add_char buf c; string_token buf lexbuf }
