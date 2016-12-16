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

let check ast = 
	ast

let extract_binding = function
	| Ast.VarBinding(b, _) -> b

let create_s_attributes () = {
	Semast.attr_parallelism = false;
	Semast.attr_arrays = false;
}

let create_s_environment () = {
	Semast.env_structs = StringMap.empty;
	Semast.env_symbols = StringMap.empty;
	Semast.env_types = StringMap.empty;
	Semast.env_imports = [];
	Semast.env_loops = [];
}

let enter_block envl = 
	create_s_environment() :: envl

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

let import_builtin_module symbols types structs = function
	| Semast.Lib -> begin
		let c_bindings = [ 
			("lib.print", Ast.Function( Ast.void_t, [Ast.int32_t], Ast.no_qualifiers ) );
			("lib.print_string", Ast.Function( Ast.void_t, [Ast.string_t], Ast.no_qualifiers ) );
			("lib.print_float32", Ast.Function( Ast.void_t, [Ast.float32_t], Ast.no_qualifiers ) );
			("lib.print_int32", Ast.Function( Ast.void_t, [Ast.float32_t], Ast.no_qualifiers ) );
		]
		in
		let acc_bindings syms (n, qt) =
			StringMap.add n qt syms
		in
		let symbols = List.fold_left acc_bindings symbols c_bindings in
		(symbols, types, structs)
	end

let gather_ast_locals attrs envl sl =
	let acc locals = function
		| Ast.General(Ast.VariableStatement(v)) -> 
			( extract_binding v ) :: locals
		| _ -> locals
	in
	let l = List.fold_left acc [] sl in
	l
	
let type_name_of_literal attrs envl = function
	| Ast.BoolLit(_) -> Ast.BuiltinType( Ast.Bool, Ast.no_qualifiers )
	| Ast.IntLit(_) -> Ast.BuiltinType( Ast.Int(32), Ast.no_qualifiers )
	| Ast.Int64Lit(_) -> Ast.BuiltinType( Ast.Int(64), Ast.no_qualifiers )
	| Ast.FloatLit(_) -> Ast.BuiltinType( Ast.Float(32), Ast.no_qualifiers )
	| Ast.StringLit(_) -> Ast.BuiltinType( Ast.String, Ast.no_qualifiers )

let rec type_name_of_expression attrs envl astexpr = 
	let t = match astexpr with
		| Ast.Literal(lit) -> type_name_of_literal attrs envl lit 
		| Ast.QualifiedId(qid)-> let qualname = Representation.string_of_qualified_id qid in
			begin match ( env_lookup_id qualname envl ) with
				| None -> raise(Errors.IdentifierNotFound("identifier '" ^ qualname ^ "' not found"))
				| Some(tn) -> tn
			end
		| Ast.Call(e, args) -> let ft = type_name_of_expression attrs envl e in 
			begin match ft with
				| Ast.Function(rt, pl, tq) -> 
					(* TODO: check arguments to make sure it matches *)
					rt
				| _ -> raise(Errors.TypeMismatch("expected a function type, but received something else."))
			end
		| Ast.Noop -> Ast.void_t
		| Ast.Member(_, _) -> raise(Errors.Unsupported("member access is not supported"))
		| _ -> raise(Errors.Unsupported("expression conversion currently unsupported"))
	in
	(* TODO: some type checks to make sure weird things like void& aren't put in place... *)
	t

let process_ast_import prefix symbols types structs imports = function
	| Ast.LibraryImport(qid) -> 
		let qualname = Representation.string_of_qualified_id qid in
		let (v, impsymbols, imptypes, impstructs) = match List.filter ( fun (n, _) -> n = qualname ) Semast.builtin_library_names with
			| (_, bltin) :: [] -> let b = Semast.SBuiltin(bltin) in
				let ( bltinsymbols, bltintypes, bltinstructs ) = import_builtin_module symbols types structs bltin in
				( b, bltinsymbols, bltintypes, bltinstructs )
			| _ -> ( Semast.SDynamic(qualname), symbols, types, structs )
		in
		( prefix, impsymbols, imptypes, impstructs, v :: imports )
		

let generate_global_env = function
| Ast.Program(ast_definitions) ->
	let rec acc ( prefix, symbols, types, structs, imports ) def =  
		match def with 
			| Ast.Import(imp) -> process_ast_import prefix symbols types structs imports imp
			| Ast.Basic(Ast.FunctionDefinition((qid, args, rt, _))) -> 
				let argst = List.map Ast.binding_type args in
				let qualname = prefix ^ Representation.string_of_qualified_id qid in
				if StringMap.mem qualname symbols then raise (Errors.FunctionAlreadyExists(qualname)) else
				let qt = Ast.Function(rt, argst, Ast.no_qualifiers) in
				( prefix, ( StringMap.add qualname qt symbols ), types, structs, imports )
			| Ast.Basic(Ast.VariableDefinition(v)) -> 
				let (name, qt) = extract_binding v in
				let qualname = prefix ^ name in
				if StringMap.mem prefix symbols then raise (Errors.VariableAlreadyExists(qualname)) else
				( prefix, ( StringMap.add qualname qt symbols ), types, structs, imports )
			| Ast.Namespace(n, dl) -> 
				let qualname = prefix ^ Representation.string_of_qualified_id n in
				let (_, innersymbols, innertypes, innerstructs, innerimports ) = List.fold_left acc ( qualname ^ ".", symbols, types, structs, imports ) dl in
				( prefix, innersymbols, innertypes, innerstructs, innerimports )
			| Ast.Structure(_) -> 
				(* Unsupported right now: warn maybe? *) 
				( prefix, symbols, types, structs, imports )
	in
	let (_, symbols, types, structs, imports) = List.fold_left acc ("", StringMap.empty, StringMap.empty, StringMap.empty, []) ast_definitions in
	let attrs = create_s_attributes () in
	let env = {
		Semast.env_structs = structs;
		Semast.env_symbols = symbols; 
		Semast.env_types = types;
		Semast.env_imports = imports;
		Semast.env_loops = [];
	}
	in
	( attrs, env )

let check_qualified_identifier attrs envl sl t =
	(attrs, envl, Semast.SQualifiedId( sl, t ) )

let check_function_call attrs envl target args t =
	(attrs, envl, Semast.SCall(target, args, t))


let generate_s_binding attrs envl b =
	(attrs, envl, b)

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
			let t = type_name_of_expression attrs envl astexpr in
			check_qualified_identifier attrs envl sl t
		| Ast.Call(e, el) -> 
			let ( attrs, envl, target ) = ( generate_s_expression attrs envl e ) in
			let ( attrs, envl, args ) = ( List.fold_left acc_s_expression (attrs, envl, []) el ) in
			let t = type_name_of_expression attrs envl astexpr in
			check_function_call attrs envl target args t
		| _ -> raise(Errors.Unsupported("expression generation for this type is current unsupported"))
	in
	( attrs, envl, se )

let generate_s_variable_definition attrs envl = function
	| Ast.VarBinding(b, e) -> 
		let (attrs, envl, sb) = generate_s_binding attrs envl b in
		let (attrs, envl, se) = generate_s_expression attrs envl e in
		(attrs, envl, Semast.SVarBinding(sb, se))

let generate_s_general_statement attrs envl = function
	| Ast.ExpressionStatement(e) ->
		let (attrs, envl, se ) = generate_s_expression attrs envl e in
		( attrs, envl, Semast.SExpressionStatement( se ) )
	| Ast.VariableStatement(v) ->
		let (attrs, envl, sv ) = generate_s_variable_definition attrs envl v in
		( attrs, envl, Semast.SVariableStatement( sv ) )

let generate_s_statement attrs envl = function
	| Ast.General(g) -> 
		let ( attrs, envl, sgs ) = generate_s_general_statement attrs envl g in
		( attrs, envl, Semast.SGeneral( sgs ) )
	| Ast.Return(e) -> 
		let ( attrs, envl, se ) = generate_s_expression attrs envl e in
		( attrs, envl, Semast.SReturn( se ) )
	| _ -> raise(Errors.Unsupported("statement type not supported"))
	
let generate_s_function_definition attrs envl astfdef =
	let acc_ast_statement (attrs, envl, ssl) s =
		let (attrs, envl, ss ) = ( generate_s_statement attrs envl s ) in
		( attrs, envl, ss :: ssl )
	in
	let (qid, parameters, rt, body) = astfdef in
	let bl = gather_ast_locals attrs envl body in
	let (attrs, envl, ssl) = List.fold_left acc_ast_statement (attrs, envl, []) body in
	let sfuncdef = if ( List.length bl ) > 0 then
	{
		Semast.func_name = qid;
		Semast.func_parameters = Semast.SParameters(parameters);
		Semast.func_return_type = rt;
		Semast.func_body = [Semast.SBlock(Semast.SLocals(bl), ssl)];
	}
	else
	{
		Semast.func_name = qid;
		Semast.func_parameters = Semast.SParameters(parameters);
		Semast.func_return_type = rt;
		Semast.func_body = ssl;
	}
	in
	( attrs, envl, Semast.SFunctionDefinition( sfuncdef ) )
	

let generate_s_basic_definition attrs envl = function
	| Ast.FunctionDefinition(fdef) -> 
		let (attrs, envl, sfdef) = generate_s_function_definition attrs envl fdef in
		(attrs, envl, Semast.SBasic(sfdef))
	| Ast.VariableDefinition(vdef) -> 
		let (attrs, envl, svdef) = generate_s_variable_definition attrs envl vdef in
		(attrs, envl, Semast.SBasic(Semast.SVariableDefinition(svdef)))
	

let generate_semantic attrs globalenv = function 
| Ast.Program(dl) ->
	let envl = [globalenv] in
	let rec acc_ast_definitions (attrs, envl, sdl) = function
		| Ast.Import(_) -> (attrs, envl, sdl)
		| Ast.Structure(_,_) -> 
			(* TODO: currently unsupported. Emit warning? *)
			raise(Errors.Unsupported("Structs are currently unsupported"))
		| Ast.Namespace(n, dl) ->
			let (attrs, envl, sdl) = List.fold_left acc_ast_definitions (attrs, envl, []) dl in
			(attrs, envl, Semast.SNamespace( n, sdl ) :: sdl )
		| Ast.Basic(b) -> 
			let (attrs, envl, sb) = ( generate_s_basic_definition attrs envl b ) in
			(attrs, envl, sb :: sdl )
	in
	let (attrs, envl, sdefs) = List.fold_left acc_ast_definitions (attrs, envl, []) dl in
	Semast.SProgram( attrs, globalenv, sdefs )

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
