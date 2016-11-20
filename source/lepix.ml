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

(* Top-level of the LePiX compiler: scan & parse the input,
   check the resulting AST, generate LLVM IR, and dump the module *)

type action = Token | Ast | Ir | Compile

let _ = let action = if Array.length Sys.argv > 1 then
	List.assoc Sys.argv.(1) [ 
		("-t", Token);	(* Print the tokens *)
		("-a", Ast);	(* Print the AST *)
		("-l", Ir);  (* Generate LLVM, don't check *)
		("-c", Compile) (* Generate LLVM and check it, check LLVM IR *)
	]
	else Ir in
	try 
		let lexbuf = Lexing.from_channel stdin in
		let tokenstream = Driver.lex lexbuf ":stdin" in match action with
		| Token -> print_endline( Representation.token_list_to_string tokenstream )
		| Ast -> let program = Driver.parse tokenstream in
			Driver.analyze program; print_endline (Ast.string_of_program program)
		| Ir -> let program = Driver.parse tokenstream in
			Driver.analyze program; let m = Codegen.generate program in
			print_endline (Llvm.string_of_llmodule m)
		| Compile -> let program = Driver.parse tokenstream in
			Driver.analyze program; let m = Codegen.generate program in
			Llvm_analysis.assert_valid_module m;
			print_endline (Llvm.string_of_llmodule m)
	with
		| Parsing.Parse_error ->
			let msg = "Parsing Error:" 
			^ "\n" ^ "\t" ^ "Line: " ^ string_of_int !Driver.parser_line_number
			^ "\n" ^ "\t" ^ "Character: " ^ Representation.token_range_to_string !Driver.parser_token_range
			^ "\n" ^ "\t" ^ "Syntax Error at token #" ^ ( string_of_int !Driver.parser_token_count ) 
				^ ": [id " ^ string_of_int !Driver.parser_token_number ^ ":" ^ Representation.token_to_string !Driver.parser_token ^ "]"
			in
			print_endline msg