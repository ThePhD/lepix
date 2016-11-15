type token =
  | SEMI
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | COMMA
  | DOT
  | LSQUARE
  | RSQUARE
  | COLON
  | FUN
  | CONTINUE
  | BREAK
  | PARALLEL
  | TO
  | BY
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | ASSIGN
  | NOT
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | TRUE
  | FALSE
  | AND
  | OR
  | TILDE
  | AS
  | VAR
  | RETURN
  | IF
  | ELSE
  | FOR
  | WHILE
  | INT
  | BOOL
  | VOID
  | FLOAT
  | INTLITERAL of (int)
  | FLOATLITERAL of (float)
  | ID of (string)
  | EOF

val compound_statement :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string
