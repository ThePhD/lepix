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
  | Access of string * expr (*int or expr*)
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr (*will a[3] be considered string or make expr*expr and check during semantic checking*)
  | ArrayAssign of string * int * expr (*^^ or string * expr * expr*)
  | Arrays of expr list (*if array without name*)
  | InitArray of string * expr list 
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
    locals : bind list; (*getting rid of possibly*)
    body : stmt list; (*why separated from function*)
  }

type program = bind list * func_decl list (*may need to change*)

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | Floatlit(f) -> string_of_float f
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Access(s, l) -> s ^ "[" ^ string_of_int l ^ "]"
  | ArrayAssign (s, l, e) -> s ^"[" ^ string_of_int l ^ "] = " ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | InitArray(s, el) -> s ^ " = [" ^ String.concat ", " (List.map string_of_expr el) ^ "]"
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""

 let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "void"
  | Float -> "float"
  | Array(t) -> "array of " ^ string_of_typ t

  

(* 
int a, b, c
int[]=[5,4,3,2,1]
int[[]]={"
*)



