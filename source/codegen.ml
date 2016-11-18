(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast

module StringMap = Map.Make(String)

type scope = {
	scope_name : string;
	scope_variables : L.llvalue StringMap.t;
	scope_functions : L.llvalue StringMap.t;
}

let generate (ast) =
	print_string (A.string_of_program ast);
	let context = L.global_context() in
	let context_builder = L.builder context in
	let m = L.create_module context "lepix" in
	let f32_t   = L.float_type   context in
	let f64_t   = L.double_type  context in
	let i8_t    = L.i8_type      context in
	(* for 'char' type to printf -- even if they resolve to same type, we differentiate*)
	let char_t  = L.i8_type      context in
	let i32_t   = L.i32_type     context in
	let i64_t   = L.i64_type     context in
	(* LLVM treats booleans as 1-bit integers, not distinct types with their own true / false *)
	let bool_t  = L.i1_type      context in
	let void_t  = L.void_type    context in
	(* TODO: clean up this hack and implement proper scoping and finding of functions
	and other scoped / namespaced / runtime libraries *)
	let printf_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in 
	let printf_func = L.declare_function "printf" printf_t m in
	let int_format_str = L.build_global_stringptr "%d\n" "fmt" context_builder in
	
	(* Function to convert Ast types to LLVM Types
	Applies itself recursively, using the above 
	created types on the context *)
	let rec ast_to_llvm_type = function
		| A.Bool -> bool_t
		| A.Int -> i32_t
		| A.Float -> f32_t
		| A.Void -> void_t
		| A.Array(t, d) -> L.array_type (ast_to_llvm_type t) d
	in

	let gen_function_declaration f =
		(* Generate the function with its signature *)
		let args_t = Array.of_list (List.map (fun (_, t) -> ast_to_llvm_type t) f.A.func_parameters) in
		let sig_t = L.function_type (ast_to_llvm_type f.A.func_return_type) args_t in
		L.declare_function f.A.func_name sig_t m;
	in

	let rec gen_expression = function
		| A.Id(sl) -> let composite_id = (String.concat "." sl) in
		(* TODO: fix this and the entire if condition by implementing search for the scope's functions *)
		if composite_id = "lib.print" then 
			printf_func
		else
			printf_func
		| A.BoolLit(value) -> L.const_int bool_t (if value then 1 else 0) (* bool_t is still an integer, must convert *)
		| A.IntLit(value) -> L.const_int i32_t value
		| A.FloatLit(value) -> L.const_float f32_t value
		| A.Call(e, el) -> let target = gen_expression e in 
			let args = ( Array.of_list ( int_format_str :: (List.map gen_expression el) ) ) in
			L.build_call target args "printf" context_builder
	in

	let gen_statement = function
		| A.Expr(e) -> gen_expression e
	in

	let rec gen_statement_list = function
		(* 0 value (default integer return, specifically to get main() working right now...*)
		| [] -> L.const_int i32_t 0
		| s :: [] -> gen_statement s
		| s :: rest -> gen_statement s; gen_statement_list rest
	in

	(* TODO: this will come in handy later when we need to declare lots of functions
	but not define them (e.g., for stuff we link in from the C Library or other modules... *)
	(* let gen_function_declaration f = 
		(* Generate the function with its signature *)
		let args_t = Array.of_list (List.map (fun (_, t) -> ast_to_llvm_type t) f.A.func_parameters) in
		let sig_t = L.function_type (ast_to_llvm_type f.A.func_return_type) args_t in
		L.define_function f.A.func_name sig_t m;
	in *)

	let gen_function_definition f = 
		(* Generate the function with its signature *)
		let args_t = Array.of_list (List.map (fun (_, t) -> ast_to_llvm_type t) f.A.func_parameters) in
		let sig_t = L.function_type (ast_to_llvm_type f.A.func_return_type) args_t in
		let ll_func = L.define_function f.A.func_name sig_t m in
		(* generate the body *)
		let body_block = L.append_block context "entry_point:" ll_func in
		L.position_at_end body_block context_builder;
		let ret_val = gen_statement_list f.A.func_body in
		let _ = L.build_ret ret_val context_builder in
		ll_func
	in

    let gen_variable_definition v =
        (* TODO: placeholder, replace with actual variable definition and symbol insertion *)
	   L.const_int i32_t 3435973836
    in

	let gen_decl = function
		| A.Func(f) -> gen_function_definition f
		| A.Var(v) -> gen_variable_definition v
	in

	let gen_decl_list = function
		| [] -> ignore()
		| d :: rest -> ignore(gen_decl d)
	in

	let gen_module p = function
		| A.Prog(dl) -> List.map gen_decl dl
	in
	(* TODO: The code that imports a module or a built-in namespace *)
	let add_import = function
		| "lib" -> ignore()
	in
	gen_module ast;
	m
;;