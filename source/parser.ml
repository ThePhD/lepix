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

open Parsing;;
let _ = parse_error;;
let yytransl_const = [|
  257 (* SEMI *);
  258 (* LPAREN *);
  259 (* RPAREN *);
  260 (* LBRACE *);
  261 (* RBRACE *);
  262 (* COMMA *);
  263 (* DOT *);
  264 (* LSQUARE *);
  265 (* RSQUARE *);
  266 (* COLON *);
  267 (* FUN *);
  268 (* CONTINUE *);
  269 (* BREAK *);
  270 (* PARALLEL *);
  271 (* TO *);
  272 (* BY *);
  273 (* PLUS *);
  274 (* MINUS *);
  275 (* TIMES *);
  276 (* DIVIDE *);
  277 (* ASSIGN *);
  278 (* NOT *);
  279 (* EQ *);
  280 (* NEQ *);
  281 (* LT *);
  282 (* LEQ *);
  283 (* GT *);
  284 (* GEQ *);
  285 (* TRUE *);
  286 (* FALSE *);
  287 (* AND *);
  288 (* OR *);
  289 (* TILDE *);
  290 (* AS *);
  291 (* VAR *);
  292 (* RETURN *);
  293 (* IF *);
  294 (* ELSE *);
  295 (* FOR *);
  296 (* WHILE *);
  297 (* INT *);
  298 (* BOOL *);
  299 (* VOID *);
  300 (* FLOAT *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  301 (* INTLITERAL *);
  302 (* FLOATLITERAL *);
  303 (* ID *);
    0|]

let yylhs = "\255\255\
\002\000\002\000\002\000\003\000\003\000\003\000\004\000\004\000\
\004\000\005\000\005\000\005\000\005\000\006\000\007\000\008\000\
\008\000\008\000\008\000\009\000\009\000\009\000\010\000\010\000\
\010\000\011\000\011\000\011\000\011\000\011\000\012\000\012\000\
\012\000\013\000\013\000\014\000\014\000\015\000\015\000\016\000\
\017\000\018\000\018\000\018\000\001\000\001\000\001\000\001\000\
\001\000\001\000\019\000\025\000\025\000\025\000\025\000\026\000\
\026\000\027\000\020\000\020\000\021\000\021\000\021\000\022\000\
\023\000\023\000\024\000\000\000"

let yylen = "\002\000\
\001\000\001\000\001\000\001\000\004\000\004\000\000\000\001\000\
\003\000\001\000\001\000\001\000\001\000\002\000\003\000\001\000\
\001\000\001\000\001\000\001\000\003\000\003\000\001\000\003\000\
\003\000\001\000\003\000\003\000\003\000\003\000\001\000\003\000\
\003\000\001\000\003\000\001\000\003\000\001\000\003\000\006\000\
\007\000\000\000\003\000\005\000\001\000\001\000\001\000\001\000\
\001\000\001\000\002\000\000\000\001\000\004\000\004\000\003\000\
\003\000\005\000\005\000\007\000\005\000\009\000\009\000\002\000\
\002\000\002\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\012\000\013\000\011\000\
\010\000\000\000\000\000\000\000\000\000\068\000\000\000\000\000\
\020\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\045\000\046\000\047\000\048\000\049\000\050\000\000\000\
\066\000\065\000\064\000\000\000\000\000\000\000\002\000\003\000\
\001\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\051\000\000\000\000\000\067\000\000\000\000\000\000\000\000\000\
\000\000\000\000\016\000\018\000\019\000\017\000\015\000\021\000\
\022\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\039\000\000\000\053\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\056\000\057\000\000\000\000\000\000\000\
\000\000\000\000\000\000\061\000\006\000\000\000\005\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\055\000\054\000\000\000\041\000\000\000\060\000\
\000\000\000\000\000\000\044\000\000\000\000\000\000\000\000\000\
\058\000\063\000\062\000"

let yydgoto = "\002\000\
\014\000\042\000\095\000\096\000\015\000\016\000\017\000\071\000\
\018\000\019\000\020\000\021\000\022\000\023\000\024\000\086\000\
\025\000\090\000\026\000\027\000\028\000\029\000\030\000\031\000\
\087\000\060\000\105\000"

let yysindex = "\010\000\
\179\000\000\000\227\254\031\255\052\255\000\000\000\000\000\000\
\000\000\107\255\067\255\104\255\113\255\000\000\037\255\242\254\
\000\000\080\255\120\255\131\255\124\255\091\255\122\255\013\255\
\148\255\000\000\000\000\000\000\000\000\000\000\000\000\129\255\
\000\000\000\000\000\000\107\255\107\255\107\255\000\000\000\000\
\000\000\000\000\047\255\019\255\107\255\107\255\107\255\107\255\
\107\255\107\255\107\255\107\255\107\255\107\255\107\255\107\255\
\000\000\107\255\005\255\000\000\123\255\018\255\012\255\021\255\
\037\255\037\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\080\255\080\255\120\255\120\255\120\255\120\255\131\255\
\131\255\124\255\091\255\000\000\137\255\000\000\093\255\163\255\
\178\255\191\255\181\255\107\255\107\255\181\255\047\255\065\255\
\099\255\186\255\149\000\000\000\000\000\019\255\189\255\198\255\
\164\255\015\255\035\255\000\000\000\000\037\255\000\000\019\255\
\200\255\203\255\205\255\019\255\037\255\181\255\107\255\107\255\
\047\255\195\255\000\000\000\000\123\255\000\000\161\255\000\000\
\022\255\023\255\107\255\000\000\148\255\181\255\181\255\197\255\
\000\000\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\049\255\150\255\014\255\102\000\134\000\178\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\007\255\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\115\255\000\000\209\255\000\000\000\000\000\000\
\166\255\180\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\086\255\118\255\182\255\214\255\246\255\022\000\054\000\
\078\000\110\000\142\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\087\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\217\255\000\000\166\255\000\000\000\000\000\000\
\121\255\000\000\000\000\000\000\209\255\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\127\255\
\000\000\000\000\000\000"

let yygindex = "\000\000\
\122\000\000\000\241\255\196\255\000\000\164\000\145\000\232\255\
\132\000\111\000\139\000\168\000\169\000\000\000\222\255\125\000\
\000\000\101\000\217\000\000\000\000\000\000\000\000\000\000\000\
\000\000\202\255\169\255"

let yytablesize = 475
let yytable = "\043\000\
\059\000\062\000\063\000\064\000\088\000\097\000\108\000\014\000\
\059\000\014\000\001\000\014\000\092\000\057\000\031\000\119\000\
\031\000\032\000\031\000\044\000\091\000\014\000\014\000\094\000\
\134\000\135\000\093\000\014\000\031\000\031\000\128\000\033\000\
\058\000\058\000\031\000\058\000\031\000\031\000\058\000\085\000\
\014\000\058\000\058\000\058\000\031\000\031\000\138\000\139\000\
\065\000\023\000\120\000\023\000\034\000\023\000\066\000\058\000\
\127\000\106\000\107\000\067\000\068\000\069\000\070\000\023\000\
\023\000\023\000\023\000\109\000\036\000\023\000\110\000\023\000\
\023\000\023\000\023\000\023\000\023\000\115\000\137\000\023\000\
\023\000\039\000\040\000\041\000\129\000\130\000\024\000\122\000\
\024\000\008\000\024\000\126\000\008\000\099\000\121\000\008\000\
\136\000\100\000\045\000\046\000\024\000\024\000\024\000\024\000\
\110\000\037\000\024\000\111\000\024\000\024\000\024\000\024\000\
\024\000\024\000\038\000\052\000\024\000\024\000\025\000\052\000\
\025\000\055\000\025\000\009\000\006\000\007\000\009\000\040\000\
\008\000\009\000\061\000\040\000\025\000\025\000\025\000\025\000\
\047\000\048\000\025\000\009\000\025\000\025\000\025\000\025\000\
\025\000\025\000\053\000\054\000\025\000\025\000\026\000\059\000\
\026\000\056\000\026\000\049\000\050\000\051\000\052\000\076\000\
\077\000\078\000\079\000\133\000\026\000\026\000\110\000\101\000\
\007\000\089\000\026\000\007\000\026\000\026\000\026\000\026\000\
\026\000\026\000\074\000\075\000\026\000\026\000\027\000\098\000\
\027\000\007\000\027\000\102\000\007\000\072\000\073\000\080\000\
\081\000\103\000\104\000\112\000\027\000\027\000\116\000\117\000\
\123\000\118\000\027\000\124\000\027\000\027\000\027\000\027\000\
\027\000\027\000\125\000\042\000\027\000\027\000\029\000\131\000\
\029\000\058\000\029\000\043\000\113\000\084\000\082\000\114\000\
\083\000\132\000\035\000\000\000\029\000\029\000\000\000\000\000\
\000\000\000\000\029\000\000\000\029\000\029\000\029\000\029\000\
\029\000\029\000\000\000\000\000\029\000\029\000\028\000\000\000\
\028\000\000\000\028\000\000\000\000\000\000\000\000\000\000\000\
\000\000\059\000\000\000\000\000\028\000\028\000\000\000\000\000\
\000\000\000\000\028\000\000\000\028\000\028\000\028\000\028\000\
\028\000\028\000\000\000\000\000\028\000\028\000\030\000\000\000\
\030\000\000\000\030\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\030\000\030\000\000\000\000\000\
\000\000\000\000\030\000\000\000\030\000\030\000\030\000\030\000\
\030\000\030\000\000\000\000\000\030\000\030\000\033\000\000\000\
\033\000\000\000\033\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\033\000\033\000\000\000\000\000\
\000\000\000\000\033\000\000\000\033\000\033\000\032\000\000\000\
\032\000\000\000\032\000\000\000\033\000\033\000\000\000\000\000\
\000\000\000\000\000\000\000\000\032\000\032\000\000\000\000\000\
\000\000\000\000\032\000\000\000\032\000\032\000\034\000\000\000\
\034\000\000\000\034\000\000\000\032\000\032\000\035\000\000\000\
\035\000\000\000\035\000\000\000\034\000\034\000\000\000\000\000\
\000\000\000\000\034\000\000\000\035\000\035\000\000\000\000\000\
\000\000\000\000\035\000\000\000\034\000\034\000\036\000\000\000\
\036\000\000\000\036\000\000\000\035\000\035\000\037\000\000\000\
\037\000\000\000\037\000\000\000\036\000\036\000\000\000\000\000\
\000\000\000\000\036\000\000\000\037\000\037\000\000\000\003\000\
\004\000\005\000\037\000\000\000\000\000\036\000\006\000\007\000\
\000\000\000\000\008\000\000\000\000\000\037\000\000\000\000\000\
\000\000\000\000\038\000\000\000\038\000\009\000\038\000\085\000\
\010\000\011\000\000\000\012\000\013\000\003\000\004\000\005\000\
\038\000\038\000\000\000\000\000\006\000\007\000\038\000\000\000\
\008\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\009\000\000\000\000\000\010\000\011\000\
\000\000\012\000\013\000"

let yycheck = "\015\000\
\000\000\036\000\037\000\038\000\059\000\066\000\094\000\001\001\
\004\001\003\001\001\000\005\001\001\001\001\001\001\001\001\001\
\003\001\047\001\005\001\034\001\003\001\015\001\016\001\003\001\
\003\001\003\001\015\001\021\001\015\001\016\001\118\000\001\001\
\021\001\021\001\021\001\021\001\023\001\024\001\021\001\035\001\
\034\001\021\001\021\001\021\001\031\001\032\001\134\000\135\000\
\002\001\001\001\016\001\003\001\001\001\005\001\008\001\021\001\
\117\000\092\000\093\000\041\001\042\001\043\001\044\001\015\001\
\016\001\017\001\018\001\003\001\002\001\021\001\006\001\023\001\
\024\001\025\001\026\001\027\001\028\001\102\000\133\000\031\001\
\032\001\045\001\046\001\047\001\119\000\120\000\001\001\112\000\
\003\001\003\001\005\001\116\000\006\001\001\001\110\000\009\001\
\131\000\005\001\019\001\020\001\015\001\016\001\017\001\018\001\
\006\001\002\001\021\001\009\001\023\001\024\001\025\001\026\001\
\027\001\028\001\002\001\001\001\031\001\032\001\001\001\005\001\
\003\001\031\001\005\001\003\001\018\001\019\001\006\001\001\001\
\022\001\009\001\002\001\005\001\015\001\016\001\017\001\018\001\
\017\001\018\001\021\001\033\001\023\001\024\001\025\001\026\001\
\027\001\028\001\023\001\024\001\031\001\032\001\001\001\004\001\
\003\001\032\001\005\001\025\001\026\001\027\001\028\001\049\000\
\050\000\051\000\052\000\003\001\015\001\016\001\006\001\005\001\
\003\001\047\001\021\001\006\001\023\001\024\001\025\001\026\001\
\027\001\028\001\047\000\048\000\031\001\032\001\001\001\047\001\
\003\001\006\001\005\001\010\001\009\001\045\000\046\000\053\000\
\054\000\003\001\014\001\010\001\015\001\016\001\010\001\002\001\
\001\001\038\001\021\001\001\001\023\001\024\001\025\001\026\001\
\027\001\028\001\006\001\003\001\031\001\032\001\001\001\021\001\
\003\001\021\001\005\001\003\001\099\000\058\000\055\000\099\000\
\056\000\125\000\010\000\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\023\001\024\001\025\001\026\001\
\027\001\028\001\255\255\255\255\031\001\032\001\001\001\255\255\
\003\001\255\255\005\001\255\255\255\255\255\255\255\255\255\255\
\255\255\001\001\255\255\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\023\001\024\001\025\001\026\001\
\027\001\028\001\255\255\255\255\031\001\032\001\001\001\255\255\
\003\001\255\255\005\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\023\001\024\001\025\001\026\001\
\027\001\028\001\255\255\255\255\031\001\032\001\001\001\255\255\
\003\001\255\255\005\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\023\001\024\001\001\001\255\255\
\003\001\255\255\005\001\255\255\031\001\032\001\255\255\255\255\
\255\255\255\255\255\255\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\023\001\024\001\001\001\255\255\
\003\001\255\255\005\001\255\255\031\001\032\001\001\001\255\255\
\003\001\255\255\005\001\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\031\001\032\001\001\001\255\255\
\003\001\255\255\005\001\255\255\031\001\032\001\001\001\255\255\
\003\001\255\255\005\001\255\255\015\001\016\001\255\255\255\255\
\255\255\255\255\021\001\255\255\015\001\016\001\255\255\011\001\
\012\001\013\001\021\001\255\255\255\255\032\001\018\001\019\001\
\255\255\255\255\022\001\255\255\255\255\032\001\255\255\255\255\
\255\255\255\255\001\001\255\255\003\001\033\001\005\001\035\001\
\036\001\037\001\255\255\039\001\040\001\011\001\012\001\013\001\
\015\001\016\001\255\255\255\255\018\001\019\001\021\001\255\255\
\022\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\033\001\255\255\255\255\036\001\037\001\
\255\255\039\001\040\001"

let yynames_const = "\
  SEMI\000\
  LPAREN\000\
  RPAREN\000\
  LBRACE\000\
  RBRACE\000\
  COMMA\000\
  DOT\000\
  LSQUARE\000\
  RSQUARE\000\
  COLON\000\
  FUN\000\
  CONTINUE\000\
  BREAK\000\
  PARALLEL\000\
  TO\000\
  BY\000\
  PLUS\000\
  MINUS\000\
  TIMES\000\
  DIVIDE\000\
  ASSIGN\000\
  NOT\000\
  EQ\000\
  NEQ\000\
  LT\000\
  LEQ\000\
  GT\000\
  GEQ\000\
  TRUE\000\
  FALSE\000\
  AND\000\
  OR\000\
  TILDE\000\
  AS\000\
  VAR\000\
  RETURN\000\
  IF\000\
  ELSE\000\
  FOR\000\
  WHILE\000\
  INT\000\
  BOOL\000\
  VOID\000\
  FLOAT\000\
  EOF\000\
  "

let yynames_block = "\
  INTLITERAL\000\
  FLOATLITERAL\000\
  ID\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 25 "parser.mly"
    ( 0 )
# 388 "parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 26 "parser.mly"
             ( 0 )
# 395 "parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : float) in
    Obj.repr(
# 27 "parser.mly"
               ( 0 )
# 402 "parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'primary_expr) in
    Obj.repr(
# 30 "parser.mly"
               ( 0 )
# 409 "parser.ml"
               : 'postfix_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'postfix_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'args_list) in
    Obj.repr(
# 31 "parser.mly"
                                         ( 0 )
# 417 "parser.ml"
               : 'postfix_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'postfix_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'args_list) in
    Obj.repr(
# 32 "parser.mly"
                                        ( 0 )
# 425 "parser.ml"
               : 'postfix_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 34 "parser.mly"
           ( 0 )
# 431 "parser.ml"
               : 'args_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'postfix_expr) in
    Obj.repr(
# 35 "parser.mly"
               ( 0 )
# 438 "parser.ml"
               : 'args_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'args_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'postfix_expr) in
    Obj.repr(
# 36 "parser.mly"
                               ( 0 )
# 446 "parser.ml"
               : 'args_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 39 "parser.mly"
        ( 0 )
# 452 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 40 "parser.mly"
      ( 0 )
# 458 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 41 "parser.mly"
        ( 0 )
# 464 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 42 "parser.mly"
        ( 0 )
# 470 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'unary_operator) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'postfix_expr) in
    Obj.repr(
# 45 "parser.mly"
                              ( 0 )
# 478 "parser.ml"
               : 'unary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'unary_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'type_name) in
    Obj.repr(
# 48 "parser.mly"
                          ( 0 )
# 486 "parser.ml"
               : 'cast_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 51 "parser.mly"
      ( 0 )
# 492 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 52 "parser.mly"
        ( 0 )
# 498 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 53 "parser.mly"
       ( 0 )
# 504 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 54 "parser.mly"
       ( 0 )
# 510 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'cast_expr) in
    Obj.repr(
# 57 "parser.mly"
           ( 0 )
# 517 "parser.ml"
               : 'mult_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mult_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'cast_expr) in
    Obj.repr(
# 58 "parser.mly"
                            ( 0 )
# 525 "parser.ml"
               : 'mult_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mult_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'cast_expr) in
    Obj.repr(
# 59 "parser.mly"
                             ( 0 )
# 533 "parser.ml"
               : 'mult_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mult_expr) in
    Obj.repr(
# 62 "parser.mly"
          ( 0 )
# 540 "parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'add_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mult_expr) in
    Obj.repr(
# 63 "parser.mly"
                          ( 0 )
# 548 "parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'add_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mult_expr) in
    Obj.repr(
# 64 "parser.mly"
                           ( 0 )
# 556 "parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 67 "parser.mly"
         ( 0 )
# 563 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 68 "parser.mly"
                       ( 0 )
# 571 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 69 "parser.mly"
                       ( 0 )
# 579 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 70 "parser.mly"
                        ( 0 )
# 587 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 71 "parser.mly"
                        ( 0 )
# 595 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 75 "parser.mly"
         ( 0 )
# 602 "parser.ml"
               : 'eq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'eq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 76 "parser.mly"
                       ( 0 )
# 610 "parser.ml"
               : 'eq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'eq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 77 "parser.mly"
                      ( 0 )
# 618 "parser.ml"
               : 'eq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'eq_expr) in
    Obj.repr(
# 81 "parser.mly"
        ( 0 )
# 625 "parser.ml"
               : 'and_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'and_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'eq_expr) in
    Obj.repr(
# 82 "parser.mly"
                       ( 0 )
# 633 "parser.ml"
               : 'and_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'and_expr) in
    Obj.repr(
# 85 "parser.mly"
         ( 0 )
# 640 "parser.ml"
               : 'or_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'or_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'and_expr) in
    Obj.repr(
# 86 "parser.mly"
                      ( 0 )
# 648 "parser.ml"
               : 'or_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'or_expr) in
    Obj.repr(
# 89 "parser.mly"
        ( 0 )
# 655 "parser.ml"
               : 'assign_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'assign_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 90 "parser.mly"
                                ( 0 )
# 663 "parser.ml"
               : 'assign_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'type_name) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'assign_expr) in
    Obj.repr(
# 93 "parser.mly"
                                          ( 0 )
# 672 "parser.ml"
               : 'decl))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'params_list) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'type_name) in
    Obj.repr(
# 97 "parser.mly"
                                                 ( 0 )
# 681 "parser.ml"
               : 'fun_decl))
; (fun __caml_parser_env ->
    Obj.repr(
# 99 "parser.mly"
             ( 0 )
# 687 "parser.ml"
               : 'params_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'type_name) in
    Obj.repr(
# 100 "parser.mly"
                     ( 0 )
# 695 "parser.ml"
               : 'params_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'type_name) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'params_list) in
    Obj.repr(
# 101 "parser.mly"
                                       ( 0 )
# 704 "parser.ml"
               : 'params_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_statement) in
    Obj.repr(
# 104 "parser.mly"
                 ( 0 )
# 711 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'branch_statement) in
    Obj.repr(
# 105 "parser.mly"
                   ( 0 )
# 718 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'iter_statement) in
    Obj.repr(
# 106 "parser.mly"
                 ( 0 )
# 725 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'ret_statement) in
    Obj.repr(
# 107 "parser.mly"
                ( 0 )
# 732 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'jump_statement) in
    Obj.repr(
# 108 "parser.mly"
                 ( 0 )
# 739 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'fun_statement) in
    Obj.repr(
# 109 "parser.mly"
                ( 0 )
# 746 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'assign_expr) in
    Obj.repr(
# 112 "parser.mly"
                   (0)
# 753 "parser.ml"
               : 'expr_statement))
; (fun __caml_parser_env ->
    Obj.repr(
# 114 "parser.mly"
                     ( 0 )
# 759 "parser.ml"
               : 'compound_statement))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'decl) in
    Obj.repr(
# 115 "parser.mly"
       ( 0 )
# 766 "parser.ml"
               : 'compound_statement))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'compound_statement) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'decl) in
    Obj.repr(
# 116 "parser.mly"
                                    ( 0 )
# 774 "parser.ml"
               : 'compound_statement))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'compound_statement) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 117 "parser.mly"
                                         ( 0 )
# 782 "parser.ml"
               : 'compound_statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'compound_statement) in
    Obj.repr(
# 120 "parser.mly"
                                 ( 0 )
# 789 "parser.ml"
               : 'block))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'block) in
    Obj.repr(
# 121 "parser.mly"
                      ( 0 )
# 796 "parser.ml"
               : 'block))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'args_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'block) in
    Obj.repr(
# 124 "parser.mly"
                                       ( 0 )
# 804 "parser.ml"
               : 'parallel_block))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'assign_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'parallel_block) in
    Obj.repr(
# 127 "parser.mly"
                                                         ( 0 )
# 812 "parser.ml"
               : 'branch_statement))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'assign_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'parallel_block) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'parallel_block) in
    Obj.repr(
# 128 "parser.mly"
                                                                  ( 0 )
# 821 "parser.ml"
               : 'branch_statement))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'assign_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'parallel_block) in
    Obj.repr(
# 131 "parser.mly"
                                               ( 0 )
# 829 "parser.ml"
               : 'iter_statement))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 6 : 'assign_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : 'assign_expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : 'assign_expr) in
    let _9 = (Parsing.peek_val __caml_parser_env 0 : 'parallel_block) in
    Obj.repr(
# 132 "parser.mly"
                                                                              ( 0 )
# 839 "parser.ml"
               : 'iter_statement))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 6 : 'assign_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : 'assign_expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : 'assign_expr) in
    let _9 = (Parsing.peek_val __caml_parser_env 0 : 'parallel_block) in
    Obj.repr(
# 133 "parser.mly"
                                                                                  ( 0 )
# 849 "parser.ml"
               : 'iter_statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr_statement) in
    Obj.repr(
# 136 "parser.mly"
                      ( 0 )
# 856 "parser.ml"
               : 'ret_statement))
; (fun __caml_parser_env ->
    Obj.repr(
# 139 "parser.mly"
           ( 0 )
# 862 "parser.ml"
               : 'jump_statement))
; (fun __caml_parser_env ->
    Obj.repr(
# 140 "parser.mly"
                ( 0 )
# 868 "parser.ml"
               : 'jump_statement))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'fun_decl) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'block) in
    Obj.repr(
# 143 "parser.mly"
               ( 0 )
# 876 "parser.ml"
               : 'fun_statement))
(* Entry statement *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let statement (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : string)
