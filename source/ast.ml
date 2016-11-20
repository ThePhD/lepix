(* Abstract Syntax Tree *)

type binary_op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq 
	| And | Or

type prefix_unary_op = 
	| Neg | Not

type builtin_type = 
	| Int 
	| Bool 
	| Void 
	| Float 
	| Array of builtin_type * int

type bind = string * builtin_type

type name = string
type qualified_id = string list

type expr =
	| BoolLit of bool
	| IntLit of int
	| FloatLit of float
	| Id of qualified_id
	| Call of expr * expr list
	| Access of expr * expr list
	| MemberAccess of expr * name 
	| BinaryOp of expr * binary_op * expr
	| PrefixUnaryOp of prefix_unary_op * expr 
	| Assign of string list * expr   
	| ArrayLit of expr list
	| Noexpr

type variable_definition = 
	| VarBinding of bind * expr

type parallel_expr =
	| Invocations of expr
	| ThreadCount of expr

type stmt =
	| Expr of expr
	| Return of expr
	| If of expr * stmt list * stmt list
	| For of expr * expr * expr * stmt list
	| ForBy of expr * expr * expr * stmt list
	| While of expr * stmt list 
	| Break of int
	| Continue
	| Var of variable_definition
	| Parallel of parallel_expr list * stmt list
	| Atomic of stmt list

type function_definition = {
	func_name : string;
	func_parameters : bind list;
	func_return_type : builtin_type;
	func_body : stmt list; 
}

type definition =
	| FuncDef of function_definition
	| VarDef of variable_definition
	| NamespaceDef of string list * definition list

type prog = definition list

(* Pretty-printing functions *)

let string_of_binary_op = function
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

let string_of_unary_op = function
	| Neg -> "-"
	| Not -> "!"

let rec string_of_expr = function
	| IntLit(l) -> string_of_int l
	| BoolLit(true) -> "true"
	| BoolLit(false) -> "false"
	| FloatLit(f) -> string_of_float f
	| Id(sl) -> String.concat "." sl
	| BinaryOp(e1, o, e2) ->
		string_of_expr e1 ^ " " ^ string_of_binary_op o ^ " " ^ string_of_expr e2
	| PrefixUnaryOp(o, e) -> string_of_unary_op o ^ string_of_expr e
	| Access(e, l) -> string_of_expr e ^ "[" ^ (String.concat ", " (List.map string_of_expr l)) ^ "]"
	| MemberAccess(e, s) -> string_of_expr e ^ "." ^ s
	| Assign(sl, e) -> ( String.concat "." sl ) ^ " = " ^ string_of_expr e
	| Call(e, el) ->
		string_of_expr e ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
	| Noexpr -> "{ Noop }"
	| ArrayLit(el) -> "[ " ^ String.concat ", " (List.map string_of_expr el) ^ " ]"

let string_of_parallel_expr = function
	| Invocations(e) -> string_of_expr e
	| ThreadCount(e) -> string_of_expr e

let rec string_of_expr_list = function
	| [] -> ""
	| s::l -> string_of_expr s ^ "," ^ string_of_expr_list l

let rec string_of_typename = function
	| Int -> "int"
	| Bool -> "bool"
	| Void -> "void"
	| Float -> "float"
	| Array(t, d) -> string_of_typename t ^ ( String.make d '[' ) ^ ( String.make d ']' )

let rec string_of_bind = function
	| (n, t) -> n ^ " : " ^ string_of_typename t

let string_of_var_binding = function 
	| VarBinding(b, e) -> "var " ^ string_of_bind b ^ " = " ^ string_of_expr e ^ ";\n"

let rec string_of_stmt_list = function
	| [] -> ""
	| hd::[] -> string_of_stmt hd
	| hd::tl -> string_of_stmt hd ^ string_of_stmt_list tl
	and string_of_stmt = function
		| Expr(expr) -> string_of_expr expr ^ ";\n"; 
		| Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
		| If(e, s, []) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}"
		| If(e, s, s2) -> "if (" ^ string_of_expr e ^ ")\n" ^"{" ^  string_of_stmt_list s ^ "}\n" ^ "else\n{" ^ string_of_stmt_list s2 ^"\n}"
		| For(e1, e2, e3, sl) -> "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^ string_of_expr e3  ^ ")\n{ " ^ string_of_stmt_list sl ^ "}"
		| ForBy(e1, e2, e3, sl) -> "for (" ^ string_of_expr e1  ^ " to " ^ string_of_expr e2 ^ " by " ^ string_of_expr e3  ^ ")\n{ " ^ string_of_stmt_list sl ^ "}"
		| While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt_list s
		| Break(n) -> ( if n == 1 then "break" else "break" ^ string_of_int n ) ^ ";\n"
		| Continue -> "continue;\n"
		| Var(vdef) -> string_of_var_binding vdef
		| Parallel(pel,sl) -> "parallel(" ^ (String.concat ", " (List.map string_of_parallel_expr pel)) ^ " )\n{\n" ^ string_of_stmt_list sl ^ "\n}\n" 
		| Atomic(sl) -> "atomic {\n" ^ string_of_stmt_list sl ^ "}\n"

let string_of_function_definition fdecl =
	"fun " ^  fdecl.func_name 
    ^ "(" ^ (String.concat ", " (List.map string_of_bind fdecl.func_parameters)) ^ ") : " 
    ^ string_of_typename fdecl.func_return_type  ^ "{\n" 
    ^ string_of_stmt_list fdecl.func_body 
    ^ "}\n"

let rec string_of_definition = function
	| FuncDef(fdef) -> string_of_function_definition fdef
	| VarDef(vdef) -> string_of_var_binding vdef
	| NamespaceDef(sl, defs) -> "namespace {\n" ^ (String.concat "" (List.map string_of_definition defs) ) ^ "}\n"

let string_of_program p = 
	(String.concat "" (List.map string_of_definition p) )
