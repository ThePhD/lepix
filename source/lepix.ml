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

let _ = 
	let input = ref Driver.Pipe in
	let output = ref Driver.Pipe in
	let action = ref Driver.Llvm in
	let specified = ref [] in
	let context = { 
		Driver.parser_line_number = 0; 
		Driver.parser_token = Parser.EOF;
		Driver.parser_token_count = 0;
		Driver.parser_token_number = 0;
		Driver.parser_token_range = (0, 0);
		Driver.parser_source_name = "";
	} in
	let ocontext = { 
		Driver.options_help = fun (s) -> ( "" ); 
	} in
	(* Call options Parser for Driver *)
	let _ =
	try
		let ( i, o, a, s ) = ( Driver.read_options ocontext ) in
			input := i;
			output := o;
			action := a;
			specified := s
	with
		| err -> let _ = match err with
			| Error.BadOption(s) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Unrecognized option: " ^ s
				^ "\n" ^ ( ocontext.Driver.options_help "\t" ) in
				prerr_endline msg
			| Error.NoOption ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "No inputs or options specified"
				^ "\n" ^ ( ocontext.Driver.options_help "\t" ) in
				prerr_endline msg
			| Error.MissingOption(o) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Flag " ^ o ^ " needs an additional argument after it that is not dashed"
				^ "\n" ^ ( ocontext.Driver.options_help "\t" ) in
				prerr_endline msg
			| Error.OptionFileNotFound(f) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "File " ^ f ^ " was not found"
				^ "\n" ^ ( ocontext.Driver.options_help "\t" ) in
				prerr_endline msg
			| _ -> 
				let msg = "Unknown Error:" 
				^ "\n" ^ "\t" ^ "Contact the compiler vendor for more details and possibly include source code, or try simplifying the program" 
				in
				prerr_endline msg;
		in
		(* Exit if arguments are wrong *)
		ignore( ( exit Error.option_error_exit_code ) )
	in
	(* Perform actual lexing and parsing using the Driver here *)
	try 
		let allactions = !specified in
		let source_name = ( Driver.target_to_pipe_string !input true ) in
		let source_channel = match !input with
			| Driver.Pipe -> stdin
			| Driver.File(s) -> ( open_in s )
		in 
		let output_string ( s ) = match !output with
			| Driver.Pipe -> ( print_endline s )
			| Driver.File(f) -> ( Io.write_text s f )
		in 
		let print_predicate b =
			fun v -> ( v = b ) 
		in
		let _ = match !action with
			| Driver.Help -> let msg = "Help:"
				^ "\n" ^ ( ocontext.Driver.options_help "\t" ) in
				print_endline msg	
			| Driver.Tokens -> 
				let lexbuf = Lexing.from_channel source_channel in
				let tokenstream = Driver.lex lexbuf source_name in
				output_string( Representation.token_list_to_string tokenstream )
			| Driver.Ast -> 
				let lexbuf = Lexing.from_channel source_channel in
				let tokenstream = Driver.lex lexbuf source_name in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				output_string (Representation.string_of_program program)
			| Driver.Semantic ->
				let lexbuf = Lexing.from_channel source_channel in
				let tokenstream = Driver.lex lexbuf source_name in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				if ( List.exists (print_predicate Driver.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				output_string (Representation.string_of_program semanticprogram)
			| Driver.Llvm -> 
				let lexbuf = Lexing.from_channel source_channel in
				let tokenstream = Driver.lex lexbuf source_name in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				if ( List.exists (print_predicate Driver.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				(* if ( List.exists (print_predicate Driver.Semantic) allactions ) then print_endline( Representation.string_of_program program ); *)
				let m = Codegen.generate semanticprogram in
				output_string (Llvm.string_of_llmodule m)
			| Driver.Compile -> 
				let lexbuf = Lexing.from_channel source_channel in
				let tokenstream = Driver.lex lexbuf source_name in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				if ( List.exists (print_predicate Driver.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				(* if ( List.exists (print_predicate Driver.Semantic) allactions ) then print_endline( Representation.string_of_program program ); *)
				let m = Codegen.generate semanticprogram in
				Llvm_analysis.assert_valid_module m;
				output_string (Llvm.string_of_llmodule m)
		in
		()
	with
		| err -> let _ = match err with
			(* Lexer Errors *)
			| Error.UnknownCharacter( src, c, (s, e) ) ->
				let relpos = 1 + s.Lexing.pos_cnum - s.Lexing.pos_bol in
				let endrelpos = 1 + e.Lexing.pos_cnum - e.Lexing.pos_bol in		
				let msg = "Lexing Error in " ^ src ^ ":"
				^ "\n" ^ "\t" ^ "Unrecognized character in program: " ^  c
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int s.Lexing.pos_lnum
				^ "\n" ^ "\t" ^ "Character: " ^ Representation.token_range_to_string ( relpos, endrelpos )	
				in
				prerr_endline msg;
		
			(* Parser Errors *)
			| Parsing.Parse_error ->
				let msg = "Parsing Error in " ^ context.Driver.parser_source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Unrecognizable parse pattern at token #" ^ ( string_of_int context.Driver.parser_token_count )
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int context.Driver.parser_line_number
				^ "\n" ^ "\t" ^ "Character: " ^ Representation.token_range_to_string context.Driver.parser_token_range
					^ ": [id " ^ string_of_int context.Driver.parser_token_number ^ ":" ^ Representation.token_to_string context.Driver.parser_token ^ "]"
				in
				prerr_endline msg;
			| Error.MissingEoF ->
				let msg = "Parsing Error:" 
				^ "\n" ^ "\t" ^ "Missing EoF at end of token stream (bad lexer input?)" 
				in
				prerr_endline msg;
			| _ -> 
				let msg = "Unknown Error:" 
				^ "\n" ^ "\t" ^ "Contact the compiler vendor for more details and possibly include source code, or try simplifying the program" 
				in
				prerr_endline msg;
		in
		ignore( exit Error.compiler_error_exit_code )