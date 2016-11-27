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
		Core.source_code = "";
		Core.source_name = "";
		Core.token_count = 0;
		Core.token = ( Parser.EOF, 
			{ Core.token_source_name = ""; Core.token_number = 0; 
			Core.token_line_number = 0; Core.token_line_start = 0;
			Core.token_column_range = (0, 0); Core.token_character_range = (0, 0) } 
		);
	} in
	let ocontext = { 
		Core.options_help = fun (s) -> ( "" ); 
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
				^ "\n" ^ ( ocontext.Core.options_help "\t" ) in
				prerr_endline msg
			| Error.NoOption ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "No inputs or options specified"
				^ "\n" ^ ( ocontext.Core.options_help "\t" ) in
				prerr_endline msg
			| Error.MissingOption(o) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Flag " ^ o ^ " needs an additional argument after it that is not dashed"
				^ "\n" ^ ( ocontext.Core.options_help "\t" ) in
				prerr_endline msg
			| Error.OptionFileNotFound(f) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "File " ^ f ^ " was not found"
				^ "\n" ^ ( ocontext.Core.options_help "\t" ) in
				prerr_endline msg
			| err -> 
				let msg = "Unknown Error:" 
				^ "\n" ^ "\t" ^ "Contact the compiler vendor for more details and possibly include source code, or try simplifying the program" 
				in
				prerr_endline msg;
				raise(err)
		in
		(* Exit if arguments are wrong *)
		ignore( ( exit Error.option_error_exit_code ) )
	in
	(* Perform actual lexing and parsing using the Driver here *)
	try 
		let allactions = !specified in
		let source_name = ( Driver.target_to_pipe_string !input true ) in
		let source_text = match !input with
			| Driver.Pipe -> Io.read_text stdin
			| Driver.File(f) -> (Io.read_file_text f )
		in
		let output_string ( s ) = match !output with
			| Driver.Pipe -> ( print_endline s )
			| Driver.File(f) -> ( Io.write_file_text f s )
		in
		let print_predicate b =
			fun v -> ( v = b ) 
		in
		context.Core.source_name <- source_name;
		context.Core.source_code <- source_text;
		let _ = match !action with
			| Driver.Help -> let msg = "Help:"
				^ "\n" ^ ( ocontext.Core.options_help "\t" ) in
				print_endline msg	
			| Driver.Preprocess -> 
				let processed_source_text = Driver.preprocess source_name source_text in
				output_string( processed_source_text )
			| Driver.Tokens -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex Scanner.token source_name lexbuf in
				output_string( Representation.token_list_to_string tokenstream )
			| Driver.Ast -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex Scanner.token source_name lexbuf in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				output_string (Representation.string_of_program program)
			| Driver.Semantic ->
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex Scanner.token source_name lexbuf in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				if ( List.exists (print_predicate Driver.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				output_string (Representation.string_of_program semanticprogram)
			| Driver.Llvm -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex Scanner.token source_name lexbuf in
				if ( List.exists (print_predicate Driver.Tokens) allactions ) then print_endline( Representation.token_list_to_string tokenstream );
				let program = Driver.parse tokenstream context in 
				if ( List.exists (print_predicate Driver.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				(* if ( List.exists (print_predicate Driver.Semantic) allactions ) then print_endline( Representation.string_of_program program ); *)
				let m = Codegen.generate semanticprogram in
				output_string (Llvm.string_of_llmodule m)
			| Driver.Compile -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex Scanner.token source_name lexbuf in
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
			| Error.UnknownCharacter( c, (s, e) ) ->
				let abspos = s.Lexing.pos_cnum in
				let endabspos = e.Lexing.pos_cnum in
				let relpos = 1 + abspos - s.Lexing.pos_bol in
				let endrelpos = 1 + endabspos - e.Lexing.pos_bol in		
				let msg = "Lexing Error in " ^ context.Core.source_name ^ ":"
				^ "\n" ^ "\t" ^ "Unrecognized character in program: " ^  c
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int s.Lexing.pos_lnum
				^ "\n" ^ "\t" ^ "Column: " ^ Representation.token_range_to_string ( relpos, endrelpos )
				in
				prerr_endline msg;
		
			(* Parser Errors *)
			| Parsing.Parse_error ->
				let ( t, info ) = context.Core.token in
				let ( source_line, source_indentation, columns_after_indent ) = 
					( Representation.line_of_source context.Core.source_code info ) 
				in
				let column_range = info.Core.token_column_range in
				let msg = "Parsing Error in " ^ context.Core.source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Unrecognizable parse pattern at token #" ^ ( string_of_int context.Core.token_count )
					^ ": [id " ^ string_of_int info.Core.token_number ^ ":" ^ Representation.token_to_string t ^ "]"
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int info.Core.token_line_number
				^ "\n" ^ "\t" ^ "Columns: " ^ Representation.token_range_to_string column_range
				^ "\n"
				^ "\n" ^ source_line
				^ "\n" ^ source_indentation ^ ( String.make columns_after_indent ' ' ) ^ "^~~"
				in
				prerr_endline msg;
			| Error.MissingEoF ->
				let msg = "Parsing Error in" ^ context.Core.source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Missing EoF at end of token stream (bad lexer input?)" 
				in
				prerr_endline msg;
			| err -> 
				let msg = "Unknown Error:" 
				^ "\n" ^ "\t" ^ "Contact the compiler vendor for more details and possibly include source code, or try simplifying the program" 
				in
				prerr_endline msg;
				raise(err)
		in
		ignore( exit Error.compiler_error_exit_code )