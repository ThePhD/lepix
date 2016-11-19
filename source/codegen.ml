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

let context = L.global_context();;
let context_builder = L.builder context;;
let m = L.create_module context "lepix";;
let f32_t   = L.float_type   context;;
let f64_t   = L.double_type  context;;
let i8_t    = L.i8_type      context;;
(* for 'char' type to printf -- even if they resolve to same type, we differentiate*)
let char_t  = L.i8_type      context;;
let i32_t   = L.i32_type     context;;
let i64_t   = L.i64_type     context;;
(* LLVM treats booleans as 1-bit integers, not distinct types with their own true / false *)
let bool_t  = L.i1_type      context;;
let void_t  = L.void_type    context;;
(* TODO: clean up this hack and implement proper scoping and finding of functions
and other scoped / namespaced / runtime libraries *)
let printf_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |];;
let printf_func = L.declare_function "printf" printf_t m;;

let generate (ast) =
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
		| A.Call(e, el) -> ignore( print_endline ( "generating function call: " ^ ( A.string_of_expr e ) ) );
			let target = gen_expression e in 
			let int_format_str = L.build_global_stringptr "%d\n" "fmt" context_builder in
			let args = ( Array.of_list ( int_format_str :: (List.map gen_expression el) ) ) in
			let v = L.build_call target args "printf" context_builder in
			v
		
		(* TODO: do code generation for these *)
		| A.Access(e, el) ->
			L.const_int i32_t 0
		| A.BinaryOp(e1, op, e2) ->
			L.const_int i32_t 0
		| A.PrefixUnaryOp(op, e1) ->
			L.const_int i32_t 0
		| A.Assign(s, e) ->
			L.const_int i32_t 0
		| A.ArrayLit(el) ->
			L.const_int i32_t 0
		| A.Noexpr ->
			L.const_int i32_t 0
	in

	let gen_statement = function
		| A.Expr(e) -> gen_expression e
		| A.Return(e) -> gen_expression e

		(* TODO: fill this out *)
		| A.If(e, true_sl, false_sl) ->
			L.const_int i32_t 0 
		| A.For(inite, compe, incre, sl) ->
			L.const_int i32_t 0 
		| A.ForBy(frome, toe, bye, sl) ->
			L.const_int i32_t 0 
		| A.While(expr, sl) ->
			L.const_int i32_t 0 
		| A.Break(n) ->
			L.const_int i32_t 0 
		| A.Continue ->
			L.const_int i32_t 0 
		| A.Var(vdecl) ->
			L.const_int i32_t 0
		| A.Parallel(el, sl) ->
			L.const_int i32_t 0
		| A.Atomic(sl) ->
			L.const_int i32_t 0 
	in

	let rec gen_statement_list = function
		(* 0 value (default integer return, specifically to get main() working right now...*)
		| [] -> L.const_int i32_t 0
		| s :: [] -> gen_statement s
		| s :: rest -> ignore(gen_statement s); gen_statement_list rest
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
		let body_block = L.entry_block ll_func in
		L.position_at_end body_block context_builder;
		let ret_val = gen_statement_list f.A.func_body in
		let _ = L.build_ret ret_val context_builder in
		ll_func
	in

	let gen_variable_definition v =
		(* TODO: placeholder, replace with actual variable definition and symbol insertion *)
		L.const_int i32_t 0xCCCCCCC
	in

	let gen_namespace_definition name definitions =
		(* TODO: placeholder, replace with actual variable definition and symbol insertion *)
		L.const_int i32_t 0xCCCCCCC
	in

	let gen_decl = function
		| A.FuncDef(fd) -> gen_function_definition fd
		| A.VarDef(vd) -> gen_variable_definition vd
		| A.NamespaceDef(ns_name, ns_definitions) -> (gen_namespace_definition ns_name ns_definitions)
	in

	let gen_program p =
		ignore( List.map gen_decl p )
	in

	gen_program ast;
	
	m
;;