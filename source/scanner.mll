(* Ocamllex scanner for LePiX *)

{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { mcomment 0 lexbuf }           (* Mult-iline Comments *)
| "//"	   { scomment lexbuf }		(* Single-line Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['	   { LBRACKET }
| '['	   { RBRACKET }
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
| "||"     { OR }
| "!"      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "int"    { INT }
| "bool"   { BOOL }
| "void"   { VOID }
| "true"   { TRUE }
| "false"  { FALSE }
| "let"	   { LET }
| "var"    { VAR }
| "mutable" { MUTE }
| "const"   { CONST }
| ['0'-'9']+ as lxm { INT(int_of_string lxm) }
| '.' ['0'-'9']+ ('e' ('+'|'-')? ['0'-'9']+)? as lxm { FLOAT(float_of_string lxm) }
| ['0'-'9']+ ( '.' ['0'-'9']* ('e' ('+'|'-')? ['0'-'9']+)? | ('e' ('+'|'-')? ['0'-'9']+)?) as lxm { FLOAT(float_of_string lxm) } 
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and mcomment level = parse
  "*/" { if level = 0 then token lexbuf else comments (level-1) lexbuf }
|  "/*" { mcomment (level+1) lexbuf }
| _    { mcomment level  lexbuf }

and scomment = parse
  "\n" { token lexbuf }
| _    { scomment lexbuf }

