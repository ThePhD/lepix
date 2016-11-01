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
  268 (* PLUS *);
  269 (* MINUS *);
  270 (* TIMES *);
  271 (* DIVIDE *);
  272 (* ASSIGN *);
  273 (* NOT *);
  274 (* EQ *);
  275 (* NEQ *);
  276 (* LT *);
  277 (* LEQ *);
  278 (* GT *);
  279 (* GEQ *);
  280 (* TRUE *);
  281 (* FALSE *);
  282 (* AND *);
  283 (* OR *);
  284 (* TILDE *);
  285 (* AS *);
  286 (* VAR *);
  287 (* RETURN *);
  288 (* IF *);
  289 (* ELSE *);
  290 (* FOR *);
  291 (* WHILE *);
  292 (* INT *);
  293 (* BOOL *);
  294 (* VOID *);
  295 (* FLOAT *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  296 (* INTLITERAL *);
  297 (* FLOATLITERAL *);
  298 (* ID *);
    0|]

let yylhs = "\255\255\
\002\000\002\000\002\000\003\000\003\000\003\000\004\000\004\000\
\004\000\005\000\005\000\005\000\005\000\006\000\007\000\008\000\
\008\000\008\000\008\000\009\000\009\000\009\000\010\000\010\000\
\010\000\011\000\011\000\011\000\011\000\011\000\012\000\012\000\
\012\000\013\000\013\000\014\000\014\000\015\000\015\000\001\000\
\016\000\017\000\017\000\017\000\000\000"

let yylen = "\002\000\
\001\000\001\000\001\000\001\000\004\000\004\000\000\000\001\000\
\003\000\001\000\001\000\001\000\001\000\002\000\003\000\001\000\
\001\000\001\000\001\000\001\000\003\000\003\000\001\000\003\000\
\003\000\001\000\003\000\003\000\003\000\003\000\001\000\003\000\
\003\000\001\000\003\000\001\000\003\000\001\000\003\000\006\000\
\007\000\000\000\003\000\005\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\045\000\000\000\000\000\016\000\018\000\
\019\000\017\000\000\000\000\000\012\000\013\000\011\000\010\000\
\000\000\000\000\020\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\002\000\003\000\001\000\004\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\015\000\
\021\000\022\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\039\000\000\000\000\000\000\000\
\006\000\000\000\005\000\000\000"

let yydgoto = "\002\000\
\004\000\030\000\062\000\063\000\017\000\018\000\019\000\011\000\
\020\000\021\000\022\000\023\000\024\000\025\000\026\000\000\000\
\000\000"

let yysindex = "\014\000\
\243\254\000\000\239\254\000\000\020\255\241\254\000\000\000\000\
\000\000\000\000\021\255\248\254\000\000\000\000\000\000\000\000\
\016\255\015\255\000\000\032\255\038\255\006\255\041\255\022\255\
\039\255\049\255\000\000\000\000\000\000\000\000\010\255\241\254\
\248\254\248\254\248\254\248\254\248\254\248\254\248\254\248\254\
\248\254\248\254\248\254\248\254\248\254\016\255\016\255\000\000\
\000\000\000\000\032\255\032\255\038\255\038\255\038\255\038\255\
\006\255\006\255\041\255\022\255\000\000\010\255\033\255\007\255\
\000\000\016\255\000\000\010\255"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\002\000\043\000\103\000\115\000\040\000\
\003\000\068\000\000\000\000\000\000\000\000\000\001\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\035\255\036\255\000\000\
\000\000\000\000\019\000\031\000\055\000\067\000\079\000\091\000\
\107\000\119\000\123\000\052\000\000\000\001\255\000\000\000\000\
\000\000\000\000\000\000\005\255"

let yygindex = "\000\000\
\000\000\000\000\239\255\023\000\000\000\024\000\020\000\039\000\
\026\000\251\255\022\000\029\000\030\000\000\000\000\000\000\000\
\000\000"

let yytablesize = 406
let yytable = "\031\000\
\014\000\023\000\038\000\008\000\013\000\014\000\008\000\009\000\
\015\000\008\000\009\000\046\000\066\000\009\000\001\000\067\000\
\003\000\047\000\024\000\016\000\007\000\008\000\009\000\010\000\
\005\000\037\000\038\000\039\000\040\000\006\000\025\000\053\000\
\054\000\055\000\056\000\065\000\012\000\007\000\066\000\036\000\
\007\000\007\000\026\000\032\000\007\000\033\000\034\000\043\000\
\068\000\035\000\036\000\037\000\049\000\050\000\027\000\027\000\
\028\000\029\000\041\000\042\000\051\000\052\000\057\000\058\000\
\045\000\044\000\029\000\040\000\061\000\064\000\048\000\059\000\
\000\000\060\000\000\000\000\000\000\000\000\000\028\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\030\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\031\000\000\000\
\000\000\000\000\033\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\034\000\000\000\000\000\000\000\032\000\000\000\
\000\000\000\000\035\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\023\000\023\000\000\000\
\014\000\023\000\038\000\023\000\023\000\023\000\023\000\023\000\
\023\000\000\000\000\000\023\000\023\000\014\000\024\000\024\000\
\000\000\000\000\024\000\000\000\024\000\024\000\024\000\024\000\
\024\000\024\000\025\000\025\000\024\000\024\000\025\000\000\000\
\025\000\025\000\025\000\025\000\025\000\025\000\000\000\036\000\
\025\000\025\000\026\000\000\000\026\000\026\000\026\000\026\000\
\026\000\026\000\036\000\037\000\026\000\026\000\027\000\000\000\
\027\000\027\000\027\000\027\000\027\000\027\000\037\000\000\000\
\027\000\027\000\029\000\000\000\029\000\029\000\029\000\029\000\
\029\000\029\000\000\000\000\000\029\000\029\000\028\000\000\000\
\028\000\028\000\028\000\028\000\028\000\028\000\000\000\000\000\
\028\000\028\000\030\000\000\000\030\000\030\000\030\000\030\000\
\030\000\030\000\000\000\000\000\030\000\030\000\031\000\000\000\
\031\000\031\000\033\000\000\000\033\000\033\000\000\000\000\000\
\031\000\031\000\034\000\000\000\033\000\033\000\032\000\000\000\
\032\000\032\000\035\000\000\000\034\000\034\000\000\000\000\000\
\032\000\032\000\000\000\000\000\035\000\035\000"

let yycheck = "\017\000\
\000\000\000\000\000\000\003\001\013\001\014\001\006\001\003\001\
\017\001\009\001\006\001\002\001\006\001\009\001\001\000\009\001\
\030\001\008\001\000\000\028\001\036\001\037\001\038\001\039\001\
\042\001\020\001\021\001\022\001\023\001\010\001\000\000\037\000\
\038\000\039\000\040\000\003\001\016\001\003\001\006\001\000\000\
\006\001\006\001\000\000\029\001\009\001\014\001\015\001\026\001\
\066\000\012\001\013\001\000\000\033\000\034\000\000\000\040\001\
\041\001\042\001\018\001\019\001\035\000\036\000\041\000\042\000\
\016\001\027\001\000\000\000\000\045\000\047\000\032\000\043\000\
\255\255\044\000\255\255\255\255\255\255\255\255\000\000\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\000\000\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
\255\255\255\255\000\000\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\000\000\255\255\255\255\255\255\000\000\255\255\
\255\255\255\255\000\000\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\012\001\013\001\255\255\
\016\001\016\001\016\001\018\001\019\001\020\001\021\001\022\001\
\023\001\255\255\255\255\026\001\027\001\029\001\012\001\013\001\
\255\255\255\255\016\001\255\255\018\001\019\001\020\001\021\001\
\022\001\023\001\012\001\013\001\026\001\027\001\016\001\255\255\
\018\001\019\001\020\001\021\001\022\001\023\001\255\255\016\001\
\026\001\027\001\016\001\255\255\018\001\019\001\020\001\021\001\
\022\001\023\001\027\001\016\001\026\001\027\001\016\001\255\255\
\018\001\019\001\020\001\021\001\022\001\023\001\027\001\255\255\
\026\001\027\001\016\001\255\255\018\001\019\001\020\001\021\001\
\022\001\023\001\255\255\255\255\026\001\027\001\016\001\255\255\
\018\001\019\001\020\001\021\001\022\001\023\001\255\255\255\255\
\026\001\027\001\016\001\255\255\018\001\019\001\020\001\021\001\
\022\001\023\001\255\255\255\255\026\001\027\001\016\001\255\255\
\018\001\019\001\016\001\255\255\018\001\019\001\255\255\255\255\
\026\001\027\001\016\001\255\255\026\001\027\001\016\001\255\255\
\018\001\019\001\016\001\255\255\026\001\027\001\255\255\255\255\
\026\001\027\001\255\255\255\255\026\001\027\001"

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
# 320 "parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 26 "parser.mly"
             ( 0 )
# 327 "parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : float) in
    Obj.repr(
# 27 "parser.mly"
               ( 0 )
# 334 "parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'primary_expr) in
    Obj.repr(
# 30 "parser.mly"
               ( 0 )
# 341 "parser.ml"
               : 'postfix_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'postfix_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'args_list) in
    Obj.repr(
# 31 "parser.mly"
                                         ( 0 )
# 349 "parser.ml"
               : 'postfix_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'postfix_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'args_list) in
    Obj.repr(
# 32 "parser.mly"
                                        ( 0 )
# 357 "parser.ml"
               : 'postfix_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 34 "parser.mly"
           ( 0 )
# 363 "parser.ml"
               : 'args_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'postfix_expr) in
    Obj.repr(
# 35 "parser.mly"
               ( 0 )
# 370 "parser.ml"
               : 'args_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'args_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'postfix_expr) in
    Obj.repr(
# 36 "parser.mly"
                               ( 0 )
# 378 "parser.ml"
               : 'args_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 39 "parser.mly"
        ( 0 )
# 384 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 40 "parser.mly"
      ( 0 )
# 390 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 41 "parser.mly"
        ( 0 )
# 396 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 42 "parser.mly"
        ( 0 )
# 402 "parser.ml"
               : 'unary_operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'unary_operator) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'postfix_expr) in
    Obj.repr(
# 45 "parser.mly"
                              ( 0 )
# 410 "parser.ml"
               : 'unary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'unary_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'type_name) in
    Obj.repr(
# 48 "parser.mly"
                          ( 0 )
# 418 "parser.ml"
               : 'cast_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 51 "parser.mly"
      ( 0 )
# 424 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 52 "parser.mly"
        ( 0 )
# 430 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 53 "parser.mly"
       ( 0 )
# 436 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 54 "parser.mly"
       ( 0 )
# 442 "parser.ml"
               : 'type_name))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'cast_expr) in
    Obj.repr(
# 57 "parser.mly"
           ( 0 )
# 449 "parser.ml"
               : 'mult_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mult_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'cast_expr) in
    Obj.repr(
# 58 "parser.mly"
                            ( 0 )
# 457 "parser.ml"
               : 'mult_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mult_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'cast_expr) in
    Obj.repr(
# 59 "parser.mly"
                             ( 0 )
# 465 "parser.ml"
               : 'mult_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mult_expr) in
    Obj.repr(
# 62 "parser.mly"
          ( 0 )
# 472 "parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'add_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mult_expr) in
    Obj.repr(
# 63 "parser.mly"
                          ( 0 )
# 480 "parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'add_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mult_expr) in
    Obj.repr(
# 64 "parser.mly"
                           ( 0 )
# 488 "parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 67 "parser.mly"
         ( 0 )
# 495 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 68 "parser.mly"
                       ( 0 )
# 503 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 69 "parser.mly"
                       ( 0 )
# 511 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 70 "parser.mly"
                        ( 0 )
# 519 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 71 "parser.mly"
                        ( 0 )
# 527 "parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 75 "parser.mly"
         ( 0 )
# 534 "parser.ml"
               : 'eq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'eq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 76 "parser.mly"
                       ( 0 )
# 542 "parser.ml"
               : 'eq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'eq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 77 "parser.mly"
                      ( 0 )
# 550 "parser.ml"
               : 'eq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'eq_expr) in
    Obj.repr(
# 81 "parser.mly"
        ( 0 )
# 557 "parser.ml"
               : 'and_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'and_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'eq_expr) in
    Obj.repr(
# 82 "parser.mly"
                       ( 0 )
# 565 "parser.ml"
               : 'and_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'and_expr) in
    Obj.repr(
# 85 "parser.mly"
         ( 0 )
# 572 "parser.ml"
               : 'or_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'or_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'and_expr) in
    Obj.repr(
# 86 "parser.mly"
                      ( 0 )
# 580 "parser.ml"
               : 'or_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'or_expr) in
    Obj.repr(
# 89 "parser.mly"
        ( 0 )
# 587 "parser.ml"
               : 'assign_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'assign_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 90 "parser.mly"
                                ( 0 )
# 595 "parser.ml"
               : 'assign_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'type_name) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'assign_expr) in
    Obj.repr(
# 93 "parser.mly"
                                          ( 0 )
# 604 "parser.ml"
               : string))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'params_list) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'type_name) in
    Obj.repr(
# 97 "parser.mly"
                                                 ( 0 )
# 613 "parser.ml"
               : 'fun_decl))
; (fun __caml_parser_env ->
    Obj.repr(
# 99 "parser.mly"
             ( 0 )
# 619 "parser.ml"
               : 'params_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'type_name) in
    Obj.repr(
# 100 "parser.mly"
                     ( 0 )
# 627 "parser.ml"
               : 'params_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'type_name) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'params_list) in
    Obj.repr(
# 101 "parser.mly"
                                       ( 0 )
# 636 "parser.ml"
               : 'params_list))
(* Entry decl *)
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
let decl (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : string)
