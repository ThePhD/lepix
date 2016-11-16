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
  | FloatLit of float
  | Access of string * expr list 
  | Binop of expr * op * expr
  | Unop of uop * expr 
  | Assign of string * expr   
  | ArrayAssign of string * expr * expr 
  | Arrays of expr list 
  | InitArray of string * expr list 
  | Call of string * expr list
  | Noexpr

type decl = 
  Decl of bind * expr

type stmt =
  Expr of expr
  | Return of expr
  | If of expr * stmt list * stmt list
  | For of expr * expr * expr * stmt list
  | While of expr * stmt list 
  | Break
  | Continue
  | DecStmt of decl 

type func_decl = {
    fname : string;
    formals : bind list;
    typ : typ;
    body : stmt list; 
  }

type prog = 
Prog of decl list * func_decl list 

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

let rec string_of_list = function
[] -> ""
| s::l -> s^","^ string_of_list l

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | FloatLit(f) -> string_of_float f
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Access(s, l) -> s ^ "[" ^ string_of_list (List.map string_of_expr l) ^ "]"
  | ArrayAssign (s, l, e) -> s ^"[" ^ string_of_expr l ^ "] = " ^ string_of_expr e
  | Arrays (el) -> "[" ^ String.concat ", " (List.map string_of_expr el) ^ "]"
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | InitArray(s, el) -> s ^ " = [" ^ String.concat ", " (List.map string_of_expr el) ^ "]"
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""

let rec string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "void"
  | Float -> "float"
  | Array(t) -> "array of " ^ string_of_typ t

let rec string_of_bind = function
| (str, typ) -> str ^ " : " ^ string_of_typ typ

let rec string_of_bind_list = function
  [] -> ""
| hd::[] -> string_of_bind hd
| hd::tl -> string_of_bind hd ^ string_of_bind_list tl

let rec string_of_decl = function
  | Decl(binding,expr) -> "var " ^ string_of_bind binding ^ " = " ^ string_of_expr expr ^ ";\n"

let rec string_of_decls_list = function
   [] -> ""
  | hd::[] -> string_of_decl hd
  | hd::tl -> string_of_decl hd ^ string_of_decls_list tl

 let rec string_of_stmt_list = function
 | [] -> ""
 | hd::[] -> string_of_stmt hd
 | hd::tl -> string_of_stmt hd ^ ";\n" ^ string_of_stmt_list tl
 and  string_of_stmt = function
  | Expr(expr) -> string_of_expr expr ^ ";\n"; 
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, []) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}"
  | If(e, s, s2) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}\n" ^ "else\n{" ^ string_of_stmt_list s2 ^"\n}"
  | For(e1, e2, e3, s) -> "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^ string_of_expr e3  ^ ")\n{ " ^ string_of_stmt_list s ^ "}"
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt_list s
  | Break -> "break;\n"
  | Continue -> "continue;\n"
  | DecStmt(decl) -> string_of_decl decl

let rec string_of_fdecl = function
  | fdecl -> "fun " ^  fdecl.fname ^ "( " ^ string_of_bind_list fdecl.formals ^ " ) :" ^ string_of_typ fdecl.typ  ^ "\n{" ^ string_of_stmt_list fdecl.body ^ "}\n"

let rec string_of_fdecls_list = function
   [] -> ""
  | hd::[] -> string_of_fdecl hd
  | hd::tl -> string_of_fdecl hd ^ string_of_fdecls_list tl

let string_of_program = function
  | Prog(d,f) -> string_of_decls_list d ^ "\n" ^ string_of_fdecls_list f ^ "\n"

