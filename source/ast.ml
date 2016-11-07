
(* Abstract Syntax Tree*)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or

type uop = Neg | Not

type typ = Int | Bool | Void | Float | Array of typ 

type bind = string * typ

type expr =
    Literal of int
  | BoolLit of bool
  | Id of string
  | Floatlit of float
  | Arrays of expr list (*list of values for array*) 
  | Access of expr * int 
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr (*will a[3] be considered string*)
  | Call of string * expr list
  | Noexpr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt

(*check*)
type func_decl = {
    fname : string;
    formals : bind list;
    typ : typ;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list 
