(* LePiX Language Compiler Implementation
Copyright (c) 2016- ThePhD, Gabrielle Taylor, Akshaan Kakar, Fatimazorha Koly, Jackie Lin

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software 
without restriction, including without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to the following 
conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. *)

(* Code generation: translate takes a semantically checked AST and produces 
LLVM IR:
http://llvm.org/docs/tutorial/index.html
http://llvm.moe/ocaml/ *)

module L = Llvm
module A = Ast
module R = Representation

module StringMap = Map.Make(String)

type function_value = L.llvalue
type function_map = function_value StringMap.t
type variable_value = L.llvalue
type variable_map = variable_value StringMap.t


(* TODO: clean up this hack and implement proper scoping and finding of functions
and other scoped / namespaced / runtime libraries *)

let generate (ast) =
	let context = L.global_context() in
	let context_builder = L.builder context in
	let m = Llvm.create_module context "lepix"
	and f32_t   = Llvm.float_type   context
	(*and f64_t   = Llvm.double_type  context*)
	and i8_t    = Llvm.i8_type      context
	(* for 'char' type to printf -- even if they resolve to same type, we differentiate*)
	and char_t  = Llvm.i8_type      context
	and i32_t   = Llvm.i32_type     context
	(*and i64_t   = L.i64_type     context*)
	(* LLVM treats booleans as 1-bit integers, not distinct types with their own true / false *)
	and bool_t  = Llvm.i1_type      context
	and void_t  = Llvm.void_type    context
	in
	let p_i8_t  = Llvm.pointer_type i8_t
	and p_char_t  = Llvm.pointer_type char_t
	in

	let printf_t = Llvm.var_arg_function_type i32_t [| p_char_t |] in
	let printf_func = Llvm.declare_function "printf" printf_t m in
	let set_up_external_handler context lmod = 
		(* Assume *Nix handling with `dl` library *)
		let dlopen = Llvm.declare_function "dlopen" ( Llvm.function_type p_i8_t [| p_i8_t; i32_t |] ) lmod in
		let dlsym = Llvm.declare_function "dlsym" ( Llvm.function_type p_i8_t [| p_i8_t; p_char_t |] ) lmod in
		let dlclose = Llvm.declare_function "dlclose" ( Llvm.function_type i32_t [| p_i8_t |] ) lmod in
		dlsym
	in

	(* Function to convert Ast types to LLVM Types
	Applies itself recursively, using the above 
	created types on the context *)
	let rec ast_to_llvm_type = function
		| A.Bool -> bool_t
		| A.Int -> i32_t
		| A.Float -> f32_t
		| A.String -> p_char_t
		| A.Void -> void_t
		| A.Array(t, d) -> Llvm.array_type (ast_to_llvm_type t) d
		| A.Reference(t) -> Llvm.pointer_type (ast_to_llvm_type t)
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
		| A.StringLit(value) -> 
			let str = L.build_global_string value "data.1" context_builder in
			str
		| A.FloatLit(value) -> L.const_float f32_t value
		| A.Call(e, el) -> 
			let target = gen_expression e in 
			let int_format_str = L.build_global_stringptr "%d\n" "fmt" context_builder in
			let args = ( Array.of_list ( int_format_str :: (List.map gen_expression el) ) ) in
			let v = L.build_call target args "printf" context_builder in
			v
		
		(* TODO: do code generation for these *)
		| A.Access(e, el) ->
			L.const_int i32_t 0
		| A.MemberAccess(e, el) ->
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
		let args_t = Array.of_list (List.map (fun (_, t, _) -> ast_to_llvm_type t) f.A.func_parameters) in
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