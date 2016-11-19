(* Abstract Syntax Tree*)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq 
    | And | Or

type uop = Neg | Not

type typ = 
	| Int 
	| Bool 
	| Void 
	| Float 
	| Array of typ * int

type bind = string * typ

type expr =
	| BoolLit of bool
	| IntLit of int
	| FloatLit of float
	| Id of string list
	| Call of expr * expr list
	| Access of expr * expr list 
	| Binop of expr * op * expr
	| Unop of uop * expr 
	| Assign of string * expr   
	| ArrayAssign of string * expr * expr 
	| Arrays of expr list 
	| InitArray of string * expr list 
	| ArrayLit of expr list
	| Noexpr

type var_decl = 
	| VarDecl of bind * expr

type stmt =
	| Expr of expr
	| Return of expr
	| If of expr * stmt list * stmt list
	| For of expr * expr * expr * stmt list
	| While of expr * stmt list 
	| Break
	| Continue
	| VarDecStmt of var_decl
	| Parallel of expr list * stmt list
	| Atomic of stmt list 

type func_decl = {
	func_name : string;
	func_parameters : bind list;
	func_return_type : typ;
	func_body : stmt list; 
}

type decl =
	| Func of func_decl
	| Var of var_decl

type prog = decl list

(* Pretty-printing functions *)

let string_of_op = function
	| Add -> "+"
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
	| [] -> ""
	| s::l -> s ^ "," ^ string_of_list l

let string_of_uop = function
	| Neg -> "-"
	| Not -> "!"

let rec string_of_expr = function
	| IntLit(l) -> string_of_int l
	| BoolLit(true) -> "true"
	| BoolLit(false) -> "false"
	| FloatLit(f) -> string_of_float f
	| Id(sl) -> String.concat "." sl
	| Binop(e1, o, e2) ->
		string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
	| Unop(o, e) -> string_of_uop o ^ string_of_expr e
	| Access(e, l) -> string_of_expr e ^ "[" ^ string_of_list (List.map string_of_expr l) ^ "]"
	| ArrayAssign (s, l, e) -> s ^"[" ^ string_of_expr l ^ "] = " ^ string_of_expr e
	| Arrays (el) -> "[" ^ String.concat ", " (List.map string_of_expr el) ^ "]"
	| Assign(v, e) -> v ^ " = " ^ string_of_expr e
	| InitArray(s, el) -> s ^ " = [" ^ String.concat ", " (List.map string_of_expr el) ^ "]"
	| Call(e, el) ->
		string_of_expr e ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
	| Noexpr -> "{ Noop }"
	| ArrayLit(el) -> "[ " ^ String.concat ", " (List.map string_of_expr el) ^ " ]"

let rec string_of_expr_list = function
	| [] -> ""
	| s::l -> string_of_expr s ^ "," ^ string_of_expr_list l

let rec string_of_typ = function
	| Int -> "int"
	| Bool -> "bool"
	| Void -> "void"
	| Float -> "float"
	| Array(t, d) -> string_of_typ t ^ ( String.make d '[' ) ^ ( String.make d ']' )

let rec string_of_bind = function
	| (str, typ) -> str ^ " : " ^ string_of_typ typ

let rec string_of_bind_list = function
	| [] -> ""
	| hd::[] -> string_of_bind hd
	| hd::tl -> string_of_bind hd ^ string_of_bind_list tl

let rec string_of_var_decl = function
	| VarDecl(binding,expr) -> "var " ^ string_of_bind binding ^ " = " ^ string_of_expr expr ^ ";\n"

let rec string_of_stmt_list = function
	| [] -> ""
	| hd::[] -> string_of_stmt hd
	| hd::tl -> string_of_stmt hd ^ ";\n" ^ string_of_stmt_list tl ^ "\n"
	and string_of_stmt = function
		| Expr(expr) -> string_of_expr expr ^ ";\n"; 
		| Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
		| If(e, s, []) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}"
		| If(e, s, s2) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}\n" ^ "else\n{" ^ string_of_stmt_list s2 ^"\n}"
		| For(e1, e2, e3, s) -> "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^ string_of_expr e3  ^ ")\n{ " ^ string_of_stmt_list s ^ "}"
		| While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt_list s
		| Break -> "break;\n"
		| Continue -> "continue;\n"
		| VarDecStmt(vdecl) -> string_of_var_decl vdecl
		| Parallel(el,sl) -> "parallel( invocations = " ^ string_of_expr_list el ^ " )\n{\n" ^ string_of_stmt_list sl ^ "\n}\n" 
		| Atomic(sl) -> "atomic {\n" ^ string_of_stmt_list sl ^ "}\n"

let string_of_func_decl fdecl =
	"fun " ^  fdecl.func_name 
    ^ "(" ^ string_of_bind_list fdecl.func_parameters ^ ") :" 
    ^ string_of_typ fdecl.func_return_type  ^ "{\n" 
    ^ string_of_stmt_list fdecl.func_body 
    ^ "}"

let string_of_decl = function
	| Func(fdecl) -> string_of_func_decl fdecl
	| Var(vdecl) -> string_of_var_decl vdecl

let rec string_of_decls_list = function
	| [] -> ""
	| hd::[] -> string_of_decl hd
	| hd::tl -> string_of_decl hd ^ string_of_decls_list tl

let string_of_program p = 
	string_of_decls_list p
