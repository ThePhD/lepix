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
| '.'      { DOT }
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

and mcomment level = parse
  "*/" { if level = 0 then token lexbuf else mcomment (level-1) lexbuf }
|  "/*" { mcomment (level+1) lexbuf }
| _    { mcomment level  lexbuf }

and scomment = parse
  "\n" { token lexbuf }
| _    { scomment lexbuf }

