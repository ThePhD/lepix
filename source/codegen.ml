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

(* Linked code after the c bindings from the makefile
compiled the ll for the c bindings *)

module StringMap = Map.Make(String)

type li_universe = {
	lu_attrs : Semast.s_attributes;
	lu_env : Semast.s_environment;
	lu_module : Llvm.llmodule;
	lu_context : Llvm.llcontext;
	lu_builder : Llvm.llbuilder;
	lu_variables : Llvm.llvalue StringMap.t;
	lu_functions : Llvm.llvalue StringMap.t;
	lu_named_values : Llvm.llvalue StringMap.t;
	lu_named_params : Llvm.llvalue StringMap.t;
	lu_handlers : ( li_universe -> ( Semast.s_expression list ) -> ( li_universe * Llvm.llvalue list ) ) StringMap.t;
}

let create_li_universe = function | Semast.SProgram(attrs, env, _) ->
	let context = Llvm.global_context() in
	let builder = Llvm.builder context in
	let m = Llvm.create_module context "lepix" in
	{
		lu_attrs = attrs;
		lu_env = env;
		lu_module = m;
		lu_context = context;
		lu_builder = builder;
		lu_variables = StringMap.empty;
		lu_functions = StringMap.empty;
		lu_named_values = StringMap.empty;
		lu_named_params = StringMap.empty;
		lu_handlers = StringMap.empty;
	}

let rec llvm_type_of_s_type_name lu st =
	let f32_t   = Llvm.float_type   lu.lu_context
	and f64_t   = Llvm.double_type  lu.lu_context
	(* for 'char' type to printf -- even if they resolve to same type, we differentiate*)
	and char_t  = Llvm.i8_type      lu.lu_context
	and i16_t   = Llvm.i16_type     lu.lu_context
	and i32_t   = Llvm.i32_type     lu.lu_context
	and i64_t   = Llvm.i64_type        lu.lu_context
	(* LLVM treats booleans as 1-bit integers, not distinct types with their own true / false *)
	and bool_t  = Llvm.i1_type      lu.lu_context
	and void_t  = Llvm.void_type    lu.lu_context
	in
	let p_char_t  = Llvm.pointer_type    char_t
	in
	match st with
	(* TODO: handle reference-ness (e.g., make it behave like a pointer here) *)
	| Semast.SBuiltinType( Ast.Bool, tq ) -> bool_t
	| Semast.SBuiltinType( Ast.Int(n), tq ) -> begin match n with
		| 64 -> i64_t
		| 32 -> i32_t
		| 16 -> i16_t
		| _ -> Llvm.integer_type lu.lu_context n
	end
	| Semast.SBuiltinType( Ast.Float(n), tq ) -> begin match n with
		| 64 -> f64_t
		| 32 -> f32_t
		| 16 -> (* LLVM actually has support for this, but shitty OCaml bindings *)
			(* TODO: Proper Error *)
			raise( Failure "Cannot have a Half Float because OCaml binding for LLVM is garbage" )
		| _ -> (* TODO: Proper Error *)
			raise( Failure "Unallowed Float Width" )
	end
	| Semast.SBuiltinType( Ast.String, tq ) -> p_char_t
	| Semast.SBuiltinType( Ast.Void, tq ) -> void_t
	| Semast.SArray(t, d, tq) -> Llvm.array_type (llvm_type_of_s_type_name lu t) d
	| Semast.SSizedArray(t, d, szs, tq) -> Llvm.array_type (llvm_type_of_s_type_name lu t) d
	| Semast.SFunction(rt, argst, tq) -> 
		let lrt = llvm_type_of_s_type_name lu rt
		and largst = Array.map ( llvm_type_of_s_type_name lu ) ( Array.of_list argst )
		in
		Llvm.function_type lrt largst
	| _ -> (* TODO: Proper Error *)
		raise(Errors.Unsupported("This type is not convertible to an LLVM type"))

let should_reference_pointer = function
	| Semast.SBuiltinType(Ast.String, _) -> true
	| Semast.SArray(_, _, _) -> true
	| Semast.SSizedArray(_, _, _, _) -> true
	| Semast.SFunction(_, _, _) -> true
	| _ -> false

let find_argument_handler lu target =
	let hn = Llvm.value_name target in
	try Some( StringMap.find hn lu.lu_handlers )
	with _ -> None

let llvm_lookup_function lu name t = 
	let mname = Semast.mangle_name [name] t in
	match Llvm.lookup_function mname lu.lu_module with
		| Some(v) -> v
		| None -> raise( Errors.FunctionLookupFailure( name, mname ) )

let llvm_lookup_variable lu name t = 
	match Llvm.lookup_global name lu.lu_module with
		| Some(v) -> v
		| None -> raise( Errors.VariableLookupFailure( name, name ) )

let dump_s_qualified_id lu qid t =
	let fqn = Semast.string_of_qualified_id qid in
	let lookup n =
		try 
			let v = StringMap.find n lu.lu_named_values in
			Some(v)
		with | Not_found ->
			try 
				let v = StringMap.find n lu.lu_named_params in
				Some(v)
		with | Not_found -> try 
				let v = StringMap.find n lu.lu_variables in
				Some(v)
		with | Not_found -> None
	in
	let lookup_func n =
		try 
			let v = StringMap.find n lu.lu_named_values in
			Some(v)
		with | Not_found ->
			try 
				let v = StringMap.find n lu.lu_named_params in
				Some(v)
		with | Not_found -> try 
				let v = StringMap.find n lu.lu_functions in
				Some(v)
		with | Not_found -> None
	in
	let overload_lookup qid ft = 
		let mangled = Semast.mangle_name qid ft in
		begin match lookup_func mangled with 
			| Some(v) as s -> s
			| None -> begin match lookup_func fqn with 
				| Some(v) as s -> s
				| None -> None
				end
		end
	in
	let overload_acc op ft = 
		match op with
			| Some(v) as s -> s
			| None -> overload_lookup qid ft
	in
	let idval = match t with 
		| Semast.SFunction(rt, tnl, tq) as ft ->
			begin match overload_lookup qid ft with 
				| Some(v) -> v
				| None -> raise (Errors.UnknownFunction(fqn))
			end
		| Semast.SOverloads(fl)-> 
			begin match List.fold_left overload_acc None fl with
				| Some(v) -> v
				| None -> raise(Errors.UnknownFunction(fqn))
			end
		| _ -> match lookup fqn with
				| Some(v) -> v
				| None -> raise (Errors.UnknownVariable fqn)
	in
	(lu, idval)

let dump_s_literal lu lit = 
	let f64_t   = Llvm.double_type   lu.lu_context
	and i32_t   = Llvm.i32_type     lu.lu_context
	and i64_t   = Llvm.i64_type     lu.lu_context
	and bool_t  = Llvm.i1_type      lu.lu_context
	in
	let v = match lit with
		| Semast.SBoolLit(value) -> Llvm.const_int bool_t (if value then 1 else 0) (* bool_t is still an integer, must convert *)
		| Semast.SIntLit(value) -> Llvm.const_int i32_t value
		| Semast.SInt64Lit(value) -> Llvm.const_of_int64 i64_t value true (* boolean is for signedness or not: it is signed *)
		| Semast.SStringLit(value) -> 
			let str = Llvm.build_global_stringptr value "str_lit" lu.lu_builder in
			str
		| Semast.SFloatLit(value) -> Llvm.const_float f64_t value
	in
	(lu, v)

let dump_temporary_value lu ev v =
	let v = match ( Llvm.classify_type ( Llvm.type_of v ) ) with
		| Llvm.TypeKind.Pointer -> 
			if ( should_reference_pointer ev ) then
				v
			else
				Llvm.build_load v "tmp" lu.lu_builder
		| _ -> v
	in
	v

let dump_s_expression_temporary_gen f lu e =
	let (lu, v) = ( f lu e ) in
	let v = dump_temporary_value lu ( Semast.type_name_of_s_expression e ) v in
	(lu, v)

let dump_arguments_gen f lu el =
	let acc_expr (lu, vl) e =
		let (lu, v) = dump_s_expression_temporary_gen f lu e in
		( lu, v :: vl )
	in
	let (lu, args) = List.fold_left acc_expr (lu, []) el in
	(lu, args)

let rec dump_s_expression lu e = 
	match e with
	| Semast.SLiteral(lit) -> dump_s_literal lu lit
	| Semast.SQualifiedId(qid, t) -> 
		let (lu, v) = dump_s_qualified_id lu qid t in
		(lu, v)
	| Semast.SCall(e, el, t) -> 
		let (lu, target) = dump_s_expression lu e in
		let oparghandler = find_argument_handler lu target in
		let ( lu, args ) = match oparghandler with
			| None -> 
				let ( lu, args ) = ( dump_arguments_gen ( dump_s_expression ) lu el ) in
				(lu, List.rev args)
			| Some(h) -> 
				let (lu, args) = ( h lu el ) in
				( lu, args )
		in
		let arr_args = Array.of_list args in 
		let v = match t with
			| Semast.SBuiltinType(Ast.Void, _) -> Llvm.build_call target arr_args "" lu.lu_builder
			| _ -> Llvm.build_call target arr_args "tmp.call" lu.lu_builder
		in
		(lu, v)
	| Semast.SBinaryOp(l, bop, r, t) -> 
		let (lu, lv) = dump_s_expression lu l in
		let (lu, rv) = dump_s_expression lu r in
		let opf = match bop with
			| Ast.Add -> Llvm.build_add
			| _ -> raise(Errors.Unsupported("This binary operation type is not supported for code generation"))
		in
		let v = opf lv rv "tmp.bop" lu.lu_builder in
		(lu, v)
	| _ -> raise(Errors.Unsupported("This expression is not supported for code generation"))

let dump_s_expression_temporary lu e =
	let (lu, v) = ( dump_s_expression lu e ) in
	let v = dump_temporary_value lu ( Semast.type_name_of_s_expression e ) v in
	(lu, v)

let dump_s_locals lu locals =
	let acc lu (n, tn) =
		let lty = llvm_type_of_s_type_name lu tn in
		let v = Llvm.build_alloca lty n lu.lu_builder in
		{ lu with lu_named_values = StringMap.add (n) v lu.lu_named_values }
	in
	let Semast.SLocals(bl) = locals in
	let lu = List.fold_left acc lu bl in
	lu

let dump_s_parameters lu llfunc parameters =
	let paramarr = Llvm.params llfunc in
	let paraml = Array.to_list paramarr in
	let Semast.SParameters(bl) = parameters in
	let nameparam i p = 
		let (n, _) = ( List.nth bl i ) in 
		( Llvm.set_value_name n p )
	in 
	let _ = Array.iteri nameparam paramarr in
	let acc lu (n, tn) =
		let v = List.find ( fun p -> ( ( Llvm.value_name p ) = n ) ) paraml in
		{ lu with lu_named_params = StringMap.add n v lu.lu_named_params }
	in
	let lu = List.fold_left acc lu bl in
	lu

let dump_store lu lhs lhst rhs rhst =
	let _ = Llvm.build_store rhs lhs lu.lu_builder in
	lhs

let dump_assignment lu lhse rhse lhst  =
	let rhst = Semast.type_name_of_s_expression rhse in
	let (lu, rhs) = dump_s_expression_temporary lu rhse in
	let (lu, lhs) = dump_s_expression lu lhse in
	let v = dump_store lu lhs lhst rhs rhst in
	( lu, v )

let dump_s_variable_definition lu = function
	| Semast.SVarBinding((n, tn), rhse) -> let lhse = Semast.SQualifiedId([n], tn) in
		let lhst = tn in
		let rhst = Semast.type_name_of_s_expression rhse in
		let (lu, rhs) = dump_s_expression_temporary lu rhse in
		let (lu, lhs) = dump_s_expression lu lhse in
		let v = dump_store lu lhs lhst rhs rhst in
		( lu, v )

let rec dump_s_general_statement lu gs =
	let acc lu bgs = 
		dump_s_general_statement lu bgs
	in
	match gs with
	| Semast.SGeneralBlock( locals, gsl ) -> 
		let lu = dump_s_locals lu locals in
		let lu = List.fold_left acc lu gsl in
		lu
	| Semast.SExpressionStatement(e) -> 
		let (lu, _) = dump_s_expression lu e in
		lu
	| Semast.SVariableStatement(vdef) -> 
		let (lu, _) = dump_s_variable_definition lu vdef in
		lu

let rec dump_s_statement lu s = 
	let acc lu s = 
		dump_s_statement lu s
	in
	match s with
	| Semast.SBlock( locals, sl ) ->
		let lu = dump_s_locals lu locals in
		let lu = List.fold_left acc lu sl in
		lu
	| Semast.SGeneral(gs) -> 
		dump_s_general_statement lu gs
	| Semast.SReturn(e) -> 
		let lu = match e with
			| Semast.SNoop -> 
				let _ = Llvm.build_ret_void lu.lu_builder in
				lu
			| e -> let (lu, v) = dump_s_expression_temporary lu e in
				let _ = Llvm.build_ret v lu.lu_builder in
				lu
		in
		lu
	| _ -> raise(Errors.Unsupported("This statement type is unsupported"))

let dump_s_variable_definition_global lu = function
	| Semast.SVarBinding((n, tn), e) -> 
		let (lu, rhs) = dump_s_expression lu e in
		let v = Llvm.define_global n rhs lu.lu_module in
		let lu = { lu with 
			lu_variables = StringMap.add n v lu.lu_variables 
		} in
		(*		
		let lty = llvm_type_of_s_type_name lu v in
		let v = Llvm.declare_global lty k lu.lu_module in
		{ lu with lu_variables = StringMap.add k v lu.lu_variables }
		let v = llvm_lookup_variable lu n tn in
		let _ = Llvm.set_initializer v rhs in
		let lu = { lu with lu_variables = StringMap.add n v lu.lu_variables } in
		*)
		( lu, v )

let dump_s_function_definition lu f =
	let acc lu s = 
		dump_s_statement lu s
	in
	(* Generate the function with its signature *)
	(* Which means we just look it up in the llvm module *)
	let ft = Semast.type_name_of_s_function_definition f in
	let n = Semast.string_of_qualified_id f.Semast.func_name in
	let llfunc = llvm_lookup_function lu n ft in
	(* generate the body *)
	let entryblock = Llvm.append_block lu.lu_context "entry" llfunc in
     Llvm.position_at_end entryblock lu.lu_builder;
	let lu = dump_s_parameters lu llfunc f.Semast.func_parameters in
	let lu = List.fold_left acc lu f.Semast.func_body in
	let lu = { lu with 
		lu_named_params = StringMap.empty;
	} in
	lu

let dump_s_basic_definition lu = function
	| Semast.SVariableDefinition(v) -> let (lu, _) = dump_s_variable_definition_global lu v in 
		lu
	| Semast.SFunctionDefinition(f) -> dump_s_function_definition lu f

let dump_s_definition lu = function
	| Semast.SBasic(b) -> dump_s_basic_definition lu b

let dump_array_prelude lu =
	(* Unfortunately, unsupported... *)
	lu

let dump_parallelism_prelude lu = 
	(* Unfortunately, unsupported... *)
	lu

let dump_global_string lu n v =
	let rhs = Llvm.const_stringz lu.lu_context v in
	let v = Llvm.define_global n rhs lu.lu_module in
	(lu, v)

let dump_builtin_lib lu =
	let char_t  = Llvm.i8_type      lu.lu_context
	and i32_t   = Llvm.i32_type     lu.lu_context
	(* LLVM treats booleans as 1-bit integers, not distinct types with their own true / false *)
	in
	let p_char_t  = Llvm.pointer_type    char_t
	and llzero = Llvm.const_int i32_t 0
	in
	let f_acc lu (n, lv) =
		{ lu with lu_functions = StringMap.add n lv lu.lu_functions }
	in
	let print_lib lu = 
		let printf_t = Llvm.var_arg_function_type i32_t [| p_char_t |] in
		let printf_func = Llvm.declare_function "printf" printf_t lu.lu_module in
		let (_, int_format_str) = dump_global_string lu "__ifmt" "%d"
		and (_, str_format_str) = dump_global_string lu "__sfmt" "%s"
		and (_, float_format_str) = dump_global_string lu "__ffmt" "%f"
		in
		let handler_name = "printf" in
		let handler lu el =
			let ( lu, exprl ) = ( dump_arguments_gen ( dump_s_expression ) lu el ) in
			if (List.length el) < 1 then ( lu, exprl ) else
			let hdt = Semast.type_name_of_s_expression ( List.hd el ) in
			let insertion = match hdt with
				| Semast.SBuiltinType(Ast.String, _) -> str_format_str
				| Semast.SBuiltinType(Ast.Float(n), _) -> float_format_str
				| Semast.SBuiltinType(Ast.Int(n), _) -> int_format_str
				| _ -> raise(Errors.BadPrintfArgument)
			in
			let fptr = Llvm.build_gep insertion [| llzero; llzero |] "tmp.fmt" lu.lu_builder in
			( lu, fptr :: exprl )
		in
		let libprintfuncs = [
			(( Semast.mangle_name ["lib"; "print"] ( Semast.SFunction(Semast.void_t, [Semast.string_t], Semast.no_qualifiers)) ), printf_func);
			(( Semast.mangle_name ["lib"; "print"] ( Semast.SFunction(Semast.void_t, [Semast.float64_t], Semast.no_qualifiers)) ), printf_func);
			(( Semast.mangle_name ["lib"; "print"] ( Semast.SFunction(Semast.void_t, [Semast.int32_t], Semast.no_qualifiers)) ), printf_func);
		] in
		let lu = List.fold_left f_acc lu libprintfuncs in
		let lu = { lu with 
			lu_handlers = ( StringMap.add handler_name ( handler ) lu.lu_handlers )
		} in
		lu
	in
	let math_lib lu =
		lu
	in
	let lu = print_lib lu in
	let lu = math_lib lu in
	lu
	
let dump_builtin_module lu = function
	| Semast.Lib -> dump_builtin_lib lu

let dump_module_import lu = function
	| Semast.SBuiltin(lib) -> dump_builtin_module lu lib
	| Semast.SCode(_) -> lu
	| Semast.SDynamic(_) -> lu

let dump_declarations lu =
	let rec declare k lu t = match t with
		| Semast.SOverloads(fl) -> 
			( List.fold_left (declare k) lu fl )
		| Semast.SFunction(rt,args,tq) as ft -> let lty = llvm_type_of_s_type_name lu t in
			let mk = Semast.mangle_name [k] ft in
			let v = Llvm.declare_function mk lty lu.lu_module in
			{ lu with lu_functions = StringMap.add mk v lu.lu_functions }
		| _ -> lu	
	in
	let acc_def k t lu =
		declare k lu t
	in
	let toplevel = lu.lu_env.Semast.env_definitions in
	let lu = StringMap.fold acc_def toplevel lu in
	lu

let dump_prelude lu sprog = 
	let lu = dump_array_prelude lu in
	let lu = dump_parallelism_prelude lu in
	let lu = List.fold_left dump_module_import lu lu.lu_env.Semast.env_imports in
	let lu = dump_declarations lu in
	lu
	
let generate sprog =
	let acc_def lu d =
		let lu = dump_s_definition lu d in
		lu
	in
	let lu = create_li_universe sprog in
	let lu = dump_prelude lu sprog in
	let lu = match sprog with 
		| Semast.SProgram(_, _, defs) -> ( List.fold_left acc_def lu defs )
	in
	lu.lu_module
