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

(*open Semast*)

let check (ast) = 
	(**)
	(*let collect_declarations astprogram = 
		let acc v dec = let ( prefix, map ) = v in
			match dec with 
				| Ast.FuncDef(f) -> 
					let qualname = prefix ^ f.Ast.func_name in
					if StringMap.find
				| Ast.VarDef(v) ->
				| Ast.NamespaceDef(n) ->
		in
		List.foldl acc ("", StringMap.empty) astprogram
	in
	decls = collect_declarations ast;
	*)
	ast























































































































































