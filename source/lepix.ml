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

type action = 
	| Tokens
	| Ast
	| Semantic
	| Llvm
	| Compile

let action_to_int = function
	| Tokens -> 0
	| Ast -> 1
	| Semantic -> 2
	| Llvm -> 3
	| Compile -> 100

let _ = 
	let action = Llvm in
	let context = { 
		Driver.parser_line_number = 0; 
		Driver.parser_token = Parser.EOF;
		Driver.parser_token_count = 0;
		Driver.parser_token_number = 0;
		Driver.parser_token_range = (0, 0);
		Driver.parser_source_name = "";
	} in
	let options = [
		( "p", "pipe", "Take input from standard in", fun ( s ) -> () );
		( "o", "output", "Set the output file", fun ( s ) -> () );
		( "t", "tokens", "Print the stream of tokens", fun ( s ) -> () );
		( "a", "ast", "Print the parsed Program", fun ( s ) -> () );
		( "s", "semantic", "Print the Semantic Program", fun ( s ) -> () );
		( "l", "llvm", "Print the generated LLVM code", fun ( s ) -> () );
		( "c", "compile", "Compile to the desired input and output the final LLVM", fun ( s ) -> () );
	] in
	try 
		let lexbuf = Lexing.from_channel stdin in
		let tokenstream = Driver.lex lexbuf ":stdin" in match action with
		| Tokens -> print_endline( Representation.token_list_to_string tokenstream )
		| Ast -> let program = Driver.parse tokenstream context in
			print_endline (Representation.string_of_program program)
		| Semantic -> let program = Driver.parse tokenstream context in
			let semanticprogram = Driver.analyze program in 
			print_endline (Representation.string_of_program semanticprogram)
		| Llvm -> let program = Driver.parse tokenstream context in
			let semanticprogram = Driver.analyze program in 
			let m = Codegen.generate semanticprogram in
			print_endline (Llvm.string_of_llmodule m)
		| Compile -> let program = Driver.parse tokenstream context in
			let semanticprogram = Driver.analyze program in 
			let m = Codegen.generate semanticprogram in
			Llvm_analysis.assert_valid_module m;
			print_endline (Llvm.string_of_llmodule m)
		;
		exit 0
	with
		(* Lexer Errors *)
		| Error.UnknownCharacter( c, (s, e) ) ->
			let relpos = 1 + s.Lexing.pos_cnum - s.Lexing.pos_bol in
			let endrelpos = 1 + e.Lexing.pos_cnum - e.Lexing.pos_bol in		
			let msg = "Lexing Error:"
			^ "\n" ^ "\t" ^ "Unrecognized character in program: " ^  c
			^ "\n" ^ "\t" ^ "Line: " ^ string_of_int s.Lexing.pos_lnum
			^ "\n" ^ "\t" ^ "Character: " ^ Representation.token_range_to_string ( relpos, endrelpos )	
			in
			print_endline msg;
		
		(* Parser Errors *)
		| Parsing.Parse_error ->
			let msg = "Parsing Error:" 
			^ "\n" ^ "\t" ^ "Unrecognizable parse pattern at token #" ^ ( string_of_int context.Driver.parser_token_count )
			^ "\n" ^ "\t" ^ "Line: " ^ string_of_int context.Driver.parser_line_number
			^ "\n" ^ "\t" ^ "Character: " ^ Representation.token_range_to_string context.Driver.parser_token_range
				^ ": [id " ^ string_of_int context.Driver.parser_token_number ^ ":" ^ Representation.token_to_string context.Driver.parser_token ^ "]"
			in
			print_endline msg;
		| Error.MissingEoF ->
			let msg = "Parsing Error:" 
			^ "\n" ^ "\t" ^ "Missing EoF at end of token stream (bad lexer input?)" 
			in
			print_endline msg;
		;
		exit 1;