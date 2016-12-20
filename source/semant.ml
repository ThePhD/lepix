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

(* Semantic checking for the Lepix compiler that will produce a new 
SemanticProgram type with things like locals group into a single type 
and type promotions / conversions organized for operators. *)

module StringMap = Map.Make(String)

let extract_binding = function
	| Ast.VarBinding(b, _) -> b

let extract_s_binding_name = function
	| (n, _) -> n

let extract_s_binding_type = function
	| (_, tn) -> tn

let create_s_attributes () = {
	Semast.attr_parallelism = false;
	Semast.attr_arrays = 0;
	Semast.attr_strings = false;
}

let create_s_environment () = {
	Semast.env_usings = [];
	Semast.env_symbols = StringMap.empty;
	Semast.env_definitions = StringMap.empty;
	Semast.env_imports = [];
	Semast.env_loops = [];
}

let enter_block envl locals = 
	let acc_symbols m l =
		let ( n, tn ) = (extract_s_binding_name l, extract_s_binding_type l) in
		StringMap.add n tn m
	in
	let symbols = List.fold_left acc_symbols StringMap.empty locals in
	let env = {
		Semast.env_usings = [];
		Semast.env_symbols = symbols;
		Semast.env_definitions = StringMap.empty;
		Semast.env_imports = [];
		Semast.env_loops = [];
     } in
	env :: envl

let lookup_id name mapl =
	let rec find = function
		| [] -> None
		| h :: tl -> try Some ( StringMap.find name h )
			with | _ -> find tl
	in
	find mapl

let env_lookup_id name envl =
	let mapl = ( List.map ( fun env -> env.Semast.env_symbols ) envl ) in
	lookup_id name mapl

let accumulate_string_type_bindings syms (n, qt) =
	try
		let v = StringMap.find n syms in 
		let vt = match v with
			| Semast.SOverloads(tl) -> Semast.SOverloads( qt :: tl )
			| Semast.SFunction(_,_,_) as t -> Semast.SOverloads( qt :: [t] )
			| _ -> raise(Not_found)
		in
		StringMap.add n vt syms
	with _ ->
		StringMap.add n qt syms

let import_builtin_module symbols = function
	| Semast.Lib -> begin
		let c_bindings = [ 
			("lib.print", Semast.SFunction( Semast.void_t, [Semast.int32_t], Semast.no_qualifiers ) );
			("lib.print", Semast.SFunction( Semast.void_t, [Semast.string_t], Semast.no_qualifiers ) );
			("lib.print", Semast.SFunction( Semast.void_t, [Semast.float32_t], Semast.no_qualifiers ) );
			("lib.print_n", Semast.SFunction( Semast.void_t, [Semast.int32_t], Semast.no_qualifiers ) );
			("lib.print_n", Semast.SFunction( Semast.void_t, [Semast.string_t], Semast.no_qualifiers ) );
			("lib.print_n", Semast.SFunction( Semast.void_t, [Semast.float32_t], Semast.no_qualifiers ) );
		]
		in
		let symbols = List.fold_left accumulate_string_type_bindings symbols c_bindings in
		(symbols)
	end

let rec type_name_of_ast_type_name = function
	| Ast.BuiltinType(bt, tq) -> Semast.SBuiltinType( bt, tq )
	| Ast.Array(tn, d, tq) -> Semast.SArray( ( type_name_of_ast_type_name tn ), d, tq )
	| Ast.SizedArray(tn, d, dims, tq) -> Semast.SSizedArray( ( type_name_of_ast_type_name tn ), d, dims, tq )
	| Ast.Function( tn, pl, tq) -> Semast.SFunction( ( type_name_of_ast_type_name tn ), ( List.map type_name_of_ast_type_name pl ), tq )

let type_name_of_ast_literal attrs envl astlit = 
	let t = match astlit with
		| Ast.BoolLit(_) -> Ast.BuiltinType( Ast.Bool, Ast.no_qualifiers )
		| Ast.IntLit(_) -> Ast.BuiltinType( Ast.Int(32), Ast.no_qualifiers )
		| Ast.Int64Lit(_) -> Ast.BuiltinType( Ast.Int(64), Ast.no_qualifiers )
		| Ast.FloatLit(_) -> Ast.BuiltinType( Ast.Float(32), Ast.no_qualifiers )
		| Ast.StringLit(_) -> Ast.BuiltinType( Ast.String, Ast.no_qualifiers )
	in
	type_name_of_ast_type_name t

let check_binary_op_common_type lt bop rt = match (lt, rt) with 
	| (Semast.SBuiltinType(Ast.Int(n), ltq), Semast.SBuiltinType(Ast.Int(m), rtq)) -> Semast.SBuiltinType(Ast.Int(max n m), Semast.no_qualifiers)
	| (Semast.SBuiltinType(Ast.Float(n), ltq), Semast.SBuiltinType(Ast.Int(m), rtq)) -> Semast.SBuiltinType(Ast.Float(max n m), Semast.no_qualifiers)
	| (Semast.SBuiltinType(Ast.Int(n), ltq), Semast.SBuiltinType(Ast.Float(m), rtq)) -> Semast.SBuiltinType(Ast.Float(max n m), Semast.no_qualifiers)
	| (Semast.SBuiltinType(Ast.Float(n), ltq), Semast.SBuiltinType(Ast.Float(m), rtq)) -> Semast.SBuiltinType(Ast.Float(max n m), Semast.no_qualifiers)
	| (Semast.SBuiltinType(Ast.Bool, ltq), Semast.SBuiltinType(Ast.Bool, rtq)) -> Semast.SBuiltinType(Ast.Bool, Semast.no_qualifiers)
	| _ -> raise(Errors.InvalidBinaryOperation("cannot perform a binary operation on two non-numeric types"))
	
let check_unary_op uop sr = match sr with
	| Semast.SBuiltinType(Ast.Int(n), ltq) -> Semast.SBuiltinType(Ast.Int(n), Semast.no_qualifiers)
	| Semast.SBuiltinType(Ast.Float(n), ltq) -> Semast.SBuiltinType(Ast.Float(n), Semast.no_qualifiers)
	| _ -> raise(Errors.InvalidUnaryOperation("cannot perform a unary operation on this type"))

let overload_resolution args = function
	| Semast.SFunction(__, tnl, _) ->
		List.exists ( fun a -> List.mem a tnl ) args
	| _ -> raise(Errors.TypeMismatch("cannot resolve an overload that includes a non-function in its type listing"))

let check_function_overloads args overloadlist =
	begin try 
		List.find ( overload_resolution args ) overloadlist
	with _ -> raise(Errors.BadFunctionCall("could not resolve the specific overload for this function call"))
	end

let rec type_name_of_ast_expression attrs envl astexpr = 
	let t = match astexpr with
		| Ast.Literal(lit) -> type_name_of_ast_literal attrs envl lit
		| Ast.QualifiedId(qid)-> let qualname = Semast.string_of_qualified_id qid in
			begin match ( env_lookup_id qualname envl ) with
				| None -> raise(Errors.IdentifierNotFound("identifier '" ^ qualname ^ "' not found"))
				| Some(stn) -> stn
			end
		| Ast.Call(e, args) -> let ft = type_name_of_ast_expression attrs envl e in 
			(* TODO: check arguments to make sure it matches *)
			begin match ft with
				| Semast.SFunction(rt, pl, tq) -> 
					rt
				| Semast.SOverloads(fl) ->
					let sargs = List.map ( type_name_of_ast_expression attrs envl ) args in
					let r = check_function_overloads sargs fl in
					print_endline ( Representation.string_of_s_type_name r );
					r
				| _ -> raise(Errors.TypeMismatch("expected a function type, but received something else."))
			end
		| Ast.Noop -> Semast.void_t
		| Ast.BinaryOp(l, bop, r) -> 
			let sl = type_name_of_ast_expression attrs envl l 
			and sr = type_name_of_ast_expression attrs envl r
			in
			check_binary_op_common_type sl bop sr
		| Ast.PrefixUnaryOp(uop, r) ->
			let sr = type_name_of_ast_expression attrs envl r in
			check_unary_op uop sr
		| Ast.Assignment(lhs, rhs) -> let lhst = type_name_of_ast_expression attrs envl lhs in
			lhst
		| Ast.Member(_, _) -> raise(Errors.Unsupported("member access is not supported"))
		| _ -> raise(Errors.Unsupported("expression conversion currently unsupported"))
	in
	(* TODO: some type checks to make sure weird things like void& aren't put in place... *)
	t

let process_ast_import prefix symbols defs imports = function
	| Ast.LibraryImport(qid) -> 
		let qualname = Semast.string_of_qualified_id qid in
		let (v, impsymbols) = match List.filter ( fun (n, _) -> n = qualname ) Semast.builtin_library_names with
			| (_, bltin) :: [] -> let b = Semast.SBuiltin(bltin) in
				let ( bltinsymbols ) = import_builtin_module symbols bltin in
				( b, bltinsymbols )
			| _ -> ( Semast.SDynamic(qualname), symbols )
		in
		( prefix, impsymbols, defs, v :: imports )
		

let generate_global_env = function
| Ast.Program(ast_definitions) ->
	let rec acc ( prefix, symbols, defs, imports ) def =  
		match def with 
			| Ast.Import(imp) -> process_ast_import prefix symbols defs imports imp
			| Ast.Basic(Ast.FunctionDefinition((qid, args, rt, _))) -> 
				let argst = List.map Ast.binding_type args in
				let qualname = prefix ^ Semast.string_of_qualified_id qid in
				if StringMap.mem qualname symbols then raise (Errors.FunctionAlreadyExists(qualname)) else
				let qt = Ast.Function(rt, argst, Ast.no_qualifiers) in
				let nsymbols = ( StringMap.add qualname ( type_name_of_ast_type_name qt ) symbols )
				and ndefs = ( StringMap.add qualname ( type_name_of_ast_type_name qt ) defs )
				in
				( prefix, nsymbols, ndefs, imports )
			| Ast.Basic(Ast.VariableDefinition(v)) -> 
				let (name, qt) = extract_binding v in
				let qualname = prefix ^ name in
				if StringMap.mem prefix symbols then raise (Errors.VariableAlreadyExists(qualname)) else
				let nsymbols = ( StringMap.add qualname ( type_name_of_ast_type_name qt ) symbols )
				and ndefs = ( StringMap.add qualname ( type_name_of_ast_type_name qt ) defs )
				in
				( prefix, nsymbols, ndefs, imports )
			| Ast.Namespace(n, dl) -> 
				let qualname = prefix ^ Semast.string_of_qualified_id n in
				let (_, innersymbols, innerdefs, innerimports ) = List.fold_left acc ( qualname ^ ".", symbols, defs, imports ) dl in
				( prefix, innersymbols, innerdefs, innerimports )
	in
	let (_, symbols, defs, imports) = List.fold_left acc ("", StringMap.empty, StringMap.empty, []) ast_definitions in
	let attrs = create_s_attributes () in
	let env = {
		Semast.env_usings = [];
		Semast.env_symbols = symbols; 
		Semast.env_definitions = defs; 
		Semast.env_imports = imports;
		Semast.env_loops = [];
	}
	in
	( attrs, env )

let check_qualified_identifier attrs envl sl t =
	(attrs, envl, Semast.SQualifiedId(sl, t))

let check_function_call attrs envl target args t =
	let t = match t with 
		| Semast.SFunction(tn, tnl, tq) as f -> f
		| Semast.SOverloads(fl) ->
			let args_t = ( List.map Semast.type_name_of_s_expression args ) in 
			check_function_overloads args_t fl
		| _ -> raise(Errors.BadFunctionCall("cannot invoke an expression which does not result in a function type of some sort"))
	in
	(attrs, envl, Semast.SCall(( Semast.coerce_type_name_of_s_expression t target ), args, ( Semast.return_type_name t ) ))

let generate_s_binding prefix attrs envl = function
	| (name, tn) -> (attrs, envl, (Semast.string_of_qualified_id ( prefix @ [name] ), type_name_of_ast_type_name tn))

let gather_ast_locals attrs envl sl =
	let acc locals = function
		| Ast.General(Ast.VariableStatement(v)) -> 
			let (_, _, sb) = generate_s_binding [] attrs envl ( extract_binding v ) in
			sb :: locals
		| _ -> locals
	in
	let l = List.fold_left acc [] sl in
	if ( List.length l ) > 0 then begin
		let envl = ( enter_block envl l ) in
		(true, attrs, envl, l)
	end else
		(false, attrs, envl, l)

let generate_s_literal attrs envl = function
	| Ast.BoolLit(b) -> (attrs, envl, Semast.SBoolLit(b))
	| Ast.IntLit(i) -> (attrs, envl, Semast.SIntLit(i))
	| Ast.Int64Lit(i) -> (attrs, envl, Semast.SInt64Lit(i))
	| Ast.FloatLit(f) -> (attrs, envl, Semast.SFloatLit(f))
	| Ast.StringLit(s) -> (attrs, envl, Semast.SStringLit(s))

let rec generate_s_expression attrs envl astexpr = 
	let acc_s_expression (attrs, envl, sel) e =
		let (attrs, envl, se) = generate_s_expression attrs envl e in
		(attrs, envl, se :: sel)
	in
	let ( attrs, envl, se ) = match astexpr with
		| Ast.Literal(lit) ->
			let ( attrs, envl, slit ) = generate_s_literal attrs envl lit in 
			( attrs, envl, Semast.SLiteral( slit ) )
		| Ast.QualifiedId(sl) -> 
			let t = type_name_of_ast_expression attrs envl astexpr in
			check_qualified_identifier attrs envl sl t
		| Ast.Call(e, el) -> 
			let ( attrs, envl, target ) = ( generate_s_expression attrs envl e ) in
			let ( attrs, envl, args ) = ( List.fold_left acc_s_expression (attrs, envl, []) el ) in
			let args = List.rev args in
			let t = type_name_of_ast_expression attrs envl astexpr in
			check_function_call attrs envl target args t
		| Ast.BinaryOp(lhs, bop, rhs) -> 
			let ( attrs, envl, slhs ) = ( generate_s_expression attrs envl lhs ) in
			let ( attrs, envl, srhs ) = ( generate_s_expression attrs envl rhs ) in
			let rhst = ( Semast.type_name_of_s_expression srhs ) in
			let lhst = ( Semast.type_name_of_s_expression slhs ) in
			( attrs, envl, Semast.SBinaryOp( slhs, bop, srhs, ( check_binary_op_common_type lhst bop rhst ) ) )
		| Ast.PrefixUnaryOp(uop, rhs) -> 
			let ( attrs, envl, srhs ) = ( generate_s_expression attrs envl rhs ) in
			let rhst = ( Semast.type_name_of_s_expression srhs ) in
			( attrs, envl, Semast.SPrefixUnaryOp( uop, srhs, ( check_unary_op uop rhst ) ) )
		| Ast.Assignment(lhs, rhs) -> 
			let ( attrs, envl, slhs ) = ( generate_s_expression attrs envl lhs ) in
			let ( attrs, envl, srhs ) = ( generate_s_expression attrs envl rhs ) in
			let lhst = ( Semast.type_name_of_s_expression slhs ) in
			( attrs, envl, Semast.SAssignment( slhs, srhs, lhst ) )
		| Ast.Noop -> ( attrs, envl, Semast.SNoop )
		| _ -> raise(Errors.Unsupported("expression generation for this type is current unsupported"))
	in
	let t = Semast.type_name_of_s_expression se in
	let attrs = match t with
		| Semast.SArray(_,d,_) 
		| Semast.SSizedArray(_,d,_,_) -> { 
				Semast.attr_strings = attrs.Semast.attr_strings; 
				Semast.attr_arrays = max d attrs.Semast.attr_arrays; 
				Semast.attr_parallelism = attrs.Semast.attr_parallelism; 
			}
		| Semast.SBuiltinType( Ast.String, _ ) -> { 
				Semast.attr_strings = true; 
				Semast.attr_arrays = attrs.Semast.attr_arrays; 
				Semast.attr_parallelism = attrs.Semast.attr_parallelism; 
			}
		| _ -> attrs
	in
	( attrs, envl, se )

let generate_s_variable_definition prefix attrs envl = function
	| Ast.VarBinding(b, e) -> 
		let (attrs, envl, sb) = generate_s_binding prefix attrs envl b in
		let (attrs, envl, se) = generate_s_expression attrs envl e in
		(attrs, envl, Semast.SVarBinding(sb, se))

let generate_s_general_statement attrs envl = function
	| Ast.ExpressionStatement(e) ->
		let (attrs, envl, se ) = generate_s_expression attrs envl e in
		( attrs, envl, Semast.SExpressionStatement( se ) )
	| Ast.VariableStatement(v) ->
		let (attrs, envl, sv ) = generate_s_variable_definition [] attrs envl v in
		( attrs, envl, Semast.SVariableStatement( sv ) )

let generate_s_statement attrs envl = function
	| Ast.General(g) -> 
		let ( attrs, envl, sgs ) = generate_s_general_statement attrs envl g in
		( attrs, envl, Semast.SGeneral( sgs ) )
	| Ast.Return(e) -> 
		let ( attrs, envl, se ) = generate_s_expression attrs envl e in
		( attrs, envl, Semast.SReturn( se ) )
	| _ -> raise(Errors.Unsupported("statement type not supported"))
	
let check_returns name ssl rt =
	(* Todo: recursively inspect all inner blocks for return types as well *)
	let acc rl = function 
		| Semast.SReturn(se) -> ( Semast.type_name_of_s_expression se ) :: rl
		| _ -> rl
	in
	let returns = List.fold_left acc [] ssl in
	let returnlength = List.length returns in
	if name = "main" then
		let mainpred = function
			| Semast.SBuiltinType(Ast.Int(32), (_, r)) -> 
				if r then raise(Errors.InvalidMainSignature("Cannot return a reference from main"));
				()
			| _ -> 
				raise(Errors.InvalidMainSignature("You can only return an int (int32) from main"))
		in
		let ssl = match rt with
			| Semast.SBuiltinType(Ast.Int(32), (_, r)) -> 
				if r then raise(Errors.InvalidMainSignature("Cannot return a reference to and integer"));
				if returnlength < 1 then
					ssl @ [Semast.SReturn(Semast.SLiteral(Semast.SIntLit(0)))]
				else
					let _ = List.iter mainpred returns in
					ssl
			| _ -> let _ = List.iter mainpred returns in
				ssl
		in
		(ssl, Semast.int32_t)
	else
		let generalpred rt r = match rt with 
			| Semast.SBuiltinType(Ast.Auto, _) -> r
			| _ -> let r = Semast.unqualify r in
				let urt = Semast.unqualify rt in
				if r <> urt then raise(Errors.InvalidFunctionSignature("return types do not match across all returns", name))
				else rt
		in
		let rt = List.fold_left generalpred rt returns in 
		let (ssl, rt) = match rt with
			| Semast.SBuiltinType(Ast.Auto, _) -> 
				if returnlength < 1 then 
					( ssl @ [Semast.SReturn(Semast.SNoop)], Semast.void_t )
				else
					(ssl, rt)
			| Semast.SBuiltinType(Ast.Void, _) ->
				if returnlength < 1 then 
					( ssl @ [Semast.SReturn(Semast.SNoop)], Semast.void_t )					
				else
					(ssl, rt)
			| _ -> 
				if returnlength < 1 then 
					raise(Errors.InvalidFunctionSignature("function was expected to return a value: returned no value", name))
				else 
					(ssl, rt)
		in
		(ssl, rt)

let generate_s_function_definition prefix attrs envl astfdef =
	let acc_ast_statements (attrs, envl, ssl) s =
		let ( attrs, envl, ss ) = ( generate_s_statement attrs envl s ) in
		( attrs, envl, ss :: ssl )
	in
	let acc_ast_parameters (attrs, envl, pl) p =
		let (attrs, envl, sp) = generate_s_binding [] attrs envl p in
		(attrs, envl, sp :: pl)
	in
	let (qid, astparameters, astrt, body) = astfdef in
	let fqid = prefix @ qid in
	let fqn = Semast.string_of_qualified_id fqid in
	let (attrs, envl, parameters) = List.fold_left acc_ast_parameters (attrs, envl, []) astparameters in
	let rt = type_name_of_ast_type_name astrt in
	let (has_locals, attrs, envl, bl) = gather_ast_locals attrs envl body in
	let (attrs, envl, ssl) = List.fold_left acc_ast_statements (attrs, envl, []) body in
	let ssl = List.rev ssl in
	let (ssl, rt) = check_returns fqn ssl rt in
	let sfuncdef = if has_locals then
	{
		Semast.func_name = fqid;
		Semast.func_parameters = Semast.SParameters(parameters);
		Semast.func_return_type = rt;
		Semast.func_body = [Semast.SBlock(Semast.SLocals(bl), ssl)];
	}
	else
	{
		Semast.func_name = fqid;
		Semast.func_parameters = Semast.SParameters(parameters);
		Semast.func_return_type = rt;
		Semast.func_body = ssl;
	}
	in
	( attrs, envl, Semast.SFunctionDefinition( sfuncdef ) )
	

let generate_s_basic_definition prefix attrs envl = function
	| Ast.FunctionDefinition(fdef) ->
		let (attrs, envl, sfdef) = generate_s_function_definition prefix attrs envl fdef in
		(attrs, envl, Semast.SBasic(sfdef))
	| Ast.VariableDefinition(vdef) -> 
		let (attrs, envl, svdef) = generate_s_variable_definition prefix attrs envl vdef in
		(attrs, envl, Semast.SBasic(Semast.SVariableDefinition(svdef)))
	

let define_libraries attrs env =
	let fi = Semast.SFunction(Semast.void_t, [Semast.int32_t], Semast.no_qualifiers) in
	let ff = Semast.SFunction(Semast.void_t, [Semast.float32_t], Semast.no_qualifiers) in
	let fs = Semast.SFunction(Semast.void_t, [Semast.string_t], Semast.no_qualifiers) in
	let fo = Semast.SOverloads([fi;ff;fs]) in
	let lib_printn_defint = {
	     Semast.func_name = ["lib"; "print_n"];
		Semast.func_parameters = Semast.SParameters([("i", Semast.int32_t)]);
		Semast.func_return_type = Semast.void_t;
		Semast.func_body = [
			Semast.SGeneral(Semast.SExpressionStatement(
				Semast.SCall(Semast.SQualifiedId(["lib"; "print"], fo), [Semast.SQualifiedId(["i"], Semast.int32_t)], Semast.void_t)
			));
			Semast.SReturn(Semast.SNoop);
		];
     }
	and lib_printn_deffloat = {
	     Semast.func_name = ["lib"; "print_n"];
		Semast.func_parameters = Semast.SParameters([("i", Semast.float32_t)]);
		Semast.func_return_type = Semast.void_t;
		Semast.func_body = [
			Semast.SGeneral(Semast.SExpressionStatement(
				Semast.SCall(Semast.SQualifiedId(["lib"; "print"], fo), [Semast.SQualifiedId(["i"], Semast.float32_t)], Semast.void_t)
			));
			Semast.SReturn(Semast.SNoop);
		];
     }
	and lib_printn_defstr = {
	     Semast.func_name = ["lib"; "print_n"];
		Semast.func_parameters = Semast.SParameters([("i", Semast.string_t)]);
		Semast.func_return_type = Semast.void_t;
		Semast.func_body = [
			Semast.SGeneral(Semast.SExpressionStatement(
				Semast.SCall(Semast.SQualifiedId(["lib"; "print"], fo), [Semast.SQualifiedId(["i"], Semast.string_t)], Semast.void_t)
			));
			Semast.SReturn(Semast.SNoop);
          ];
     }
	in
	let libdefs = [
		Semast.SBasic(Semast.SFunctionDefinition(lib_printn_defstr));
		Semast.SBasic(Semast.SFunctionDefinition(lib_printn_defint)); 
		Semast.SBasic(Semast.SFunctionDefinition(lib_printn_deffloat));
	] in
	let acc defs = function
		| Semast.SBasic(Semast.SFunctionDefinition(fdef)) ->
			let n = (Semast.string_of_qualified_id fdef.Semast.func_name )
			and qt = ( Semast.type_name_of_s_function_definition fdef )
			in
			accumulate_string_type_bindings defs (n, qt)
		| Semast.SBasic(Semast.SVariableDefinition(Semast.SVarBinding((n, tn), _))) ->
			( StringMap.add n tn defs )
	in
	let ndefs = List.fold_left acc env.Semast.env_definitions libdefs in
	( { env with Semast.env_definitions = ndefs; }, libdefs)

let direct_code_inject attrs globalenv imp sdl = 
	let s = match imp with
		| Ast.LibraryImport(qid) -> Semast.string_of_qualified_id qid
	in
	match s with
		| "lib" -> let (globalenv, library_defs) = define_libraries attrs globalenv in
			(globalenv, library_defs @ sdl)
		| _ -> (globalenv, sdl)

let generate_semantic attrs globalenv = function 
| Ast.Program(dl) ->
	let envl = [globalenv] in
	let rec acc_ast_definitions (prefix, attrs, envl, sdl) = function
		| Ast.Import(imp) ->  
			let globalenv = List.hd ( List.rev envl ) in
			let (globalenv, sdl) = direct_code_inject attrs globalenv imp sdl in
			let tail = List.tl ( List.rev envl ) in
			(prefix, attrs, ( globalenv :: tail ), sdl)
		| Ast.Namespace(n, dl) -> let qualname = prefix @ n in
			let (_, attrs, envl, nssdl) = List.fold_left acc_ast_definitions (qualname, attrs, envl, sdl) dl in
			( prefix, attrs, envl, nssdl )
		| Ast.Basic(b) -> 
			let (attrs, envl, sb) = ( generate_s_basic_definition prefix attrs envl b ) in
			( prefix, attrs, envl, sb :: sdl )
	in
	let (_, attrs, envl, sdefs) = List.fold_left acc_ast_definitions ([], attrs, envl, []) dl in
	let globalenv = List.hd ( List.rev envl ) in
	Semast.SProgram( attrs, globalenv, List.rev sdefs )

let check astprogram = 
	(* Pass 1: Gather globals inside of all the namespaces
	so they can be referenced even before they're defined (just so long as 
	they're in the same lateral global scope, not necessarily
	in vertical order) *)
	let ( attrs, env ) = generate_global_env astprogram in
	(* Pass 2: Generate the actual Semantic Tree based on what
	is inside the AST program... *)
	let sprog = generate_semantic attrs env astprogram in
	sprog
	