(* LePiX Language Compiler Implementation
Copyright (c) 2016- ThePhD

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

module R = Representation

let generate (ast) =
	let context = Llvm.global_context() in
	let m = Llvm.create_module context "lepix" in
	(*
	let context_builder = Llvm.builder context in
	let f32_t   = Llvm.float_type   context
	and f64_t   = Llvm.double_type  context
	and i8_t    = Llvm.i8_type      context
	(* for 'char' type to printf -- even if they resolve to same type, we differentiate*)
	and char_t  = Llvm.i8_type      context
	and i16_t   = Llvm.i16_type     context
	and i32_t   = Llvm.i32_type     context
	and i64_t   = L.i64_type        context
	(* LLVM treats booleans as 1-bit integers, not distinct types with their own true / false *)
	and bool_t  = Llvm.i1_type      context
	and void_t  = Llvm.void_type    context
	in
	let p_i8_t    = Llvm.pointer_type    i8_t
	and p_char_t  = Llvm.pointer_type    char_t
	and p_void_t  = Llvm.i8_type         context
	in

	let printf_t = Llvm.var_arg_function_type i32_t [| p_char_t |] in
	let printf_func = Llvm.declare_function "printf" printf_t m in
	let set_up_external_handler context lmod = 
		(* Assume *Nix handling with `dl` library *)
		let dlopen = Llvm.declare_function "dlopen" ( Llvm.function_type p_i8_t [| p_i8_t; i32_t |] ) lmod in
		let dlsym = Llvm.declare_function "dlsym" ( Llvm.function_type p_i8_t [| p_i8_t; p_char_t |] ) lmod in
		let dlclose = Llvm.declare_function "dlclose" ( Llvm.function_type i32_t [| p_i8_t |] ) lmod in
		( dlopen, dlsym, dlclose )
	in

	(* Function to convert Ast types to LLVM Types
	Applies itself recursively, using the above 
	created types on the context *)
	let rec ast_to_llvm_type = function
		| Ast.BuiltinType( Ast.Bool, tq ) -> bool_t
		| Ast.BuiltinType( Ast.Int(n), tq ) -> begin match n with
			| 64 -> i64_t
			| 32 -> i32_t
			| 16 -> i16_t
			| _ -> Llvm.integer_type context n
		end
		| Ast.BuiltinType( Ast.Float(n), tq ) -> begin match n with
			| 64 -> f64_t
			| 32 -> f32_t
			| 16 -> (* LLVM actually has support for this, but shitty OCaml bindings *)
				raise( Failure "Cannot have a Half Float because OCaml is Garbage" )
			| _ -> raise( Failure "Unallowed Float Width" )
		end
		| Ast.BuiltinType( Ast.String, tq ) -> p_char_t
		| Ast.BuiltinType( Ast.Void, tq ) -> void_t
		| Ast.StructType(_, _) -> Llvm.struct_type context [| f64_t |]
		| Ast.Array(t, d, tq) -> Llvm.array_type (ast_to_llvm_type t) d
		| Ast.Function(rt, argst, tq) -> 
			let lrt = ast_to_llvm_type rt
			and largst = Array.map ast_to_llvm_type ( Array.of_list argst )
			in
			Llvm.function_type lrt largst
	in

	let rec gen_expression = function 
		| Ast.Id(s) -> let composite_id = s in
			(* TODO: fix this and the entire if condition by implementing search for the scope's functions *)
			if composite_id = "lib.print" then 
				printf_func
			else
				printf_func
		| Ast.Literal(Ast.BoolLit(value)) -> L.const_int bool_t (if value then 1 else 0) (* bool_t is still an integer, must convert *)
		| Ast.Literal(Ast.IntLit(value)) -> L.const_int i32_t value
		| Ast.Literal(Ast.StringLit(value)) -> 
			let str = L.build_global_string value "data.1" context_builder in
			str
		| Ast.Literal(Ast.FloatLit(value)) -> L.const_float f32_t value
		| Ast.Call(e, el) -> 
			let target = gen_expression e in 
			let int_format_str = L.build_global_stringptr "%d\n" "fmt" context_builder in
			let args = ( Array.of_list ( int_format_str :: (List.map gen_expression el) ) ) in
			let v = L.build_call target args "printf" context_builder in
			v
		
		(* TODO: do code generation for these *)
		| Ast.Index(e, el) ->
			L.const_int i32_t 0
		| Ast.Member(e, el) ->
			L.const_int i32_t 0
		| Ast.BinaryOp(e1, op, e2) ->
			L.const_int i32_t 0
		| Ast.PrefixOp(op, e1) ->
			L.const_int i32_t 0
		| Ast.Assignment(s, e) ->
			L.const_int i32_t 0
		| Ast.Initializer(el) ->
			L.const_int i32_t 0
		| Ast.NoOp ->
			L.const_int i32_t 0
	in

	let gen_statement = function
		| Ast.General(Ast.ExpressionStatement(e)) -> gen_expression e
		
		| Ast.Return(e) -> gen_expression e

		(* TODO: fill this out *)
		| Ast.General(Ast.VariableDefinition(vdecl)) ->
			L.const_int i32_t 0
		
		| Ast.IfBlock(e, true_sl, false_sl) ->
			L.const_int i32_t 0 
		| Ast.ForBlock(ilcond, increl, sl) ->
			L.const_int i32_t 0 
		| Ast.ForByToBlock(frome, toe, bye, sl) ->
			L.const_int i32_t 0 
		| Ast.WhileBlock(ilcond, sl) ->
			L.const_int i32_t 0 
		| Ast.Break(n) ->
			L.const_int i32_t 0 
		| Ast.Continue ->
			L.const_int i32_t 0 
		| Ast.ParallelBlock(el, sl) ->
			L.const_int i32_t 0
		| Ast.AtomicBlock(sl) ->
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
		let args_t = Array.of_list (List.map (fun (_, t) -> ast_to_llvm_type t) f.Ast.func_parameters) in
		let sig_t = L.function_type (ast_to_llvm_type f.Ast.func_return_type) args_t in
		L.define_function f.Ast.func_name sig_t m;
	in *)

	let gen_function_definition f = 
		let ( n, paramsl, rt, locals, sl ) = f in
		(* Generate the function with its signature *)
		let args_t = Array.of_list (List.map (fun (_, t) -> ast_to_llvm_type t) paramsl) in
		let sig_t = L.function_type (ast_to_llvm_type rt) args_t in
		let ll_func = L.define_function n sig_t m in
		(* generate the body *)
		let body_block = L.entry_block ll_func in
		L.position_at_end body_block context_builder;
		let ret_val = gen_statement_list sl in
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

	let gen_struct_definition s =
		(* TODO: placeholder, replace with actual variable definition and symbol insertion *)
		L.const_int i32_t 0xCCCCCCC
	in

	let gen_decl = function
		| Ast.Basic(Ast.FunctionDefintion(fd)) -> gen_function_definition fd
		| Ast.Basic(Ast.VariableDefinition(vd)) -> gen_variable_definition vd
		| Ast.Structure(s) -> gen_struct_definition s
		| Ast.Namespace(ns_name, ns_definitions) -> (gen_namespace_definition ns_name ns_definitions)
	in

	let gen_program p =
		ignore( List.map gen_decl p )
	in

	gen_program ast;
	*)
	m
