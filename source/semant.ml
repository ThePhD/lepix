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

(* Semantic checking for the Lepix compiler that will produce a new 
SemanticProgram type with things like locals group into a single type 
and type promotions / conversions organized for operators. *)

module StringMap = Map.Make(String)

let check (ast) = 
	(**)
	let build_global_symbol_table astprogram = 
		let rec acc v def = let ( prefix, map ) = v in
			match def with 
				| Ast.Basic(Ast.FunctionDefinition((qid, args, rt, _, _))) -> 
					let argst = List.map Ast.binding_type args in
					let qualname = prefix ^ "." ^ Representation.string_of_qualified_id qid in
					if StringMap.mem qualname map then raise (Error.FunctionAlreadyExists(qualname)) else
					let qt = Ast.Function(rt, argst, Ast.no_qualifiers) in
					( prefix, ( StringMap.add qualname qt map ) )
				| Ast.Basic(Ast.VariableDefinition(v)) -> 
					let (name, qt) = match v with
						| Ast.VarBinding((name, qt), _) -> (name, qt)
						| Ast.LetBinding((name, qt), _) -> (name, qt)
					in
					let qualname = prefix ^ "." ^ name in
					if StringMap.mem prefix map then raise (Error.VariableAlreadyExists(qualname)) else
					( prefix, ( StringMap.add qualname qt map ) )
				| Ast.Namespace(n, dl) -> 
					let qualname = prefix ^ "." ^ Representation.string_of_qualified_id n in
					List.fold_left acc ( qualname, map ) dl
				| Ast.Structure(_) -> 
					(* Unsupported right now: warn maybe? *) 
					( prefix, map )
		in
		let (_, defns) = List.fold_left acc ("", StringMap.empty) astprogram in
	in
	let generate_semantic symbolsl =
		
	in
	let defns = build_global_symbol_table ast in
	( defns, ( generate_semantic [defns] )
	
	ast
