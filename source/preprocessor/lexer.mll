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
	| '#'             { print_string "# match\n"; preprocessor_token lexbuf }
	| eol as s        { print_string "eol match\n"; incr line_num; EOL(s) }
	| eof             { print_string "eof match\n"; EOF }
	| blankspace as c { print_string "blank space\n"; CHARACTER(c) }
	| _ as c          { print_string "any_char match\n"; CHARACTER(c) }

(* The actual preprocessor tokens *)
(* Here, we see that we just capture
string expressions, dot-delimeted ident names,
macro continuation lines and more *)
and preprocessor_token = parse
	| blankspace          { print_string "blank space\n"; preprocessor_token lexbuf }
	| "import"            { print_string "import match\n"; IMPORT }
	| "strings"           { print_string "strings match\n"; STRINGS }
	| '"'                 { print_string "quote match\n"; string_token (Buffer.create 64) lexbuf  }
	| name as s           { print_string "name match\n"; NAME(s) }
	| eol blankspace* '#' { print_string "continue match\n"; incr line_num; CONTINUE }

and string_token buf = parse
	| '"' { print_string "quote match\n"; STRING_LITERAL(Buffer.contents buf); preprocessor_token lexbuf }
	| _ as c { print_string "any_char match\n"; Buffer.add_char buf c; string_token buf lexbuf }
