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
	let input = ref Core.Pipe in
	let output = ref Core.Pipe in
	let action = ref Core.Llvm in
	let specified = ref [] in
	let context = { 
		Driver.source_name = "";
		Driver.source_code = "";
		Driver.original_source_code = "";
		Driver.token_count = 0;
		Driver.token = ( Parser.EOF, 
			{ Core.token_source_name = ""; Core.token_number = 0; 
			Core.token_line_number = 0; Core.token_line_start = 0;
			Core.token_column_range = (0, 0); Core.token_character_range = (0, 0) } 
		);
	} 
	and pcontext = {
	     Predriver.source_name = "";
		Predriver.source_code = "";
		Predriver.original_source_code = "";
		Predriver.token_count = 0;
		Predriver.token = ( Preparser.EOF, 
			{ Core.token_source_name = ""; Core.token_number = 0; 
			Core.token_line_number = 0; Core.token_line_start = 0;
			Core.token_column_range = (0, 0); Core.token_character_range = (0, 0) } 
		);
     }
	in
	let ocontext = { 
		Options.options_help = fun (s) -> ( "" ); 
	} in
	(* Call options Parser for Driver *)
	let _ =
	try
		let ( i, o, a, s ) = ( Options.read_options ocontext Sys.argv ) in
			input := i;
			output := o;
			action := a;
			specified := s
	with
		| err -> let _ = match err with
			| Error.BadOption(s) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Unrecognized option: " ^ s
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| Error.NoOption ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "No inputs or options specified"
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| Error.MissingOption(o) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Flag " ^ o ^ " needs an additional argument after it that is not dashed"
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| Error.OptionFileNotFound(f) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "File " ^ f ^ " was not found"
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| err -> 
				let msg = "Unknown Error during Option parsing:" 
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
		let source_name = ( Core.target_to_pipe_string !input true ) in
		let pre_source_text = match !input with
			| Core.Pipe -> Io.read_text stdin
			| Core.File(f) -> ( Io.read_file_text f )
		in
		let output_to_target ( s ) = match !output with
			| Core.Pipe -> ( print_endline s )
			| Core.File(f) -> ( Io.write_file_text s f )
		in
		let print_predicate b =
			fun v -> ( v = b ) 
		in
		let print_help () =
			let msg = "Help:"
			^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
			print_endline msg
		in
		if !action = Core.Help then begin
			print_help ();
			()	
		end else
		let source_text = Predriver.pre_process pcontext !input pre_source_text in
		context.Driver.source_name <- source_name;
		context.Driver.original_source_code <- pre_source_text;
		context.Driver.source_code <- source_text;
		let _ = match !action with
			| Core.Help -> print_help ()	
			| Core.Preprocess -> 
				output_to_target( source_text )
			| Core.Tokens -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				output_to_target( Representation.parser_token_list_to_string tokenstream )
			| Core.Ast -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				if ( List.exists (print_predicate Core.Tokens) allactions ) then print_endline( Representation.parser_token_list_to_string tokenstream );
				let program = Driver.parse context tokenstream in 
				output_to_target (Representation.string_of_program program)
			| Core.Semantic ->
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				if ( List.exists (print_predicate Core.Tokens) allactions ) then print_endline( Representation.parser_token_list_to_string tokenstream );
				let program = Driver.parse context tokenstream in 
				if ( List.exists (print_predicate Core.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				output_to_target (Representation.string_of_semantic_program semanticprogram)
			| Core.Llvm -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				if ( List.exists (print_predicate Core.Tokens) allactions ) then print_endline( Representation.parser_token_list_to_string tokenstream );
				let program = Driver.parse context tokenstream in 
				if ( List.exists (print_predicate Core.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				(* if ( List.exists (print_predicate Core.Semantic) allactions ) then print_endline( Representation.string_of_semantic_program program ); *)
				let m = Codegen.generate semanticprogram in
				output_to_target (Llvm.string_of_llmodule m)
			| Core.Compile -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				if ( List.exists (print_predicate Core.Tokens) allactions ) then print_endline( Representation.parser_token_list_to_string tokenstream );
				let program = Driver.parse context tokenstream in 
				if ( List.exists (print_predicate Core.Ast) allactions ) then print_endline( Representation.string_of_program program );
				let semanticprogram = Driver.analyze program in 
				(* if ( List.exists (print_predicate Core.Semantic) allactions ) then print_endline( Representation.string_of_semantic_program program ); *)
				let m = Codegen.generate semanticprogram in
				Llvm_analysis.assert_valid_module m;
				output_to_target (Llvm.string_of_llmodule m)
		in
		()
	with
		| err -> let _ = match err with
			(* Preprocessor-Specific Errors *)
			(* Preprocessing Parser Errors *)
			| Preparser.Error ->
				let ( t, info ) = pcontext.Predriver.token in
				let ( source_line, source_indentation, columns_after_indent ) = 
					( Core.line_of_source pcontext.Predriver.source_code info ) 
				in
				let column_range = info.Core.token_column_range in
				let msg = "Preprocessing Error in " ^ pcontext.Predriver.source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Unrecognizable parse pattern at token #" ^ ( string_of_int pcontext.Predriver.token_count )
					^ ": [id " ^ string_of_int info.Core.token_number ^ ":" ^ Representation.preparser_token_to_string t ^ "]"
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int info.Core.token_line_number
				^ "\n" ^ "\t" ^ "Columns: " ^ Representation.token_range_to_string column_range
				^ "\n"
				^ "\n" ^ source_line
				^ "\n" ^ source_indentation ^ ( String.make columns_after_indent ' ' ) ^ "^~~"
				in
				prerr_endline msg

			(* General Compiler Errors *)
			(* Lexer Errors *)
			| Error.UnknownCharacter( c, (s, e) ) ->
				let abspos = s.Lexing.pos_cnum in
				let endabspos = e.Lexing.pos_cnum in
				let relpos = 1 + abspos - s.Lexing.pos_bol in
				let endrelpos = 1 + endabspos - e.Lexing.pos_bol in		
				let msg = "Lexing Error in " ^ context.Driver.source_name ^ ":"
				^ "\n" ^ "\t" ^ "Unrecognized character in program: " ^  c
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int s.Lexing.pos_lnum
				^ "\n" ^ "\t" ^ "Column: " ^ Representation.token_range_to_string ( relpos, endrelpos )
				in
				prerr_endline msg
		
			| Error.BadNumericLiteral( c, (s, e) ) ->
				let abspos = s.Lexing.pos_cnum in
				let endabspos = e.Lexing.pos_cnum in
				let relpos = 1 + abspos - s.Lexing.pos_bol in
				let endrelpos = 1 + endabspos - e.Lexing.pos_bol in		
				let msg = "Lexing Error in " ^ context.Driver.source_name ^ ":"
				^ "\n" ^ "\t" ^ "Bad character in integer literal: " ^  c
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int s.Lexing.pos_lnum
				^ "\n" ^ "\t" ^ "Column: " ^ Representation.token_range_to_string ( relpos, endrelpos )
				in
				prerr_endline msg
		
			(* Parser Errors *)
			| Parser.Error
			| Parsing.Parse_error ->
				let ( t, info ) = context.Driver.token in
				let ( source_line, source_indentation, columns_after_indent ) = 
					( Core.line_of_source context.Driver.source_code info ) 
				in
				let column_range = info.Core.token_column_range in
				let msg = "Parsing Error in " ^ context.Driver.source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Unrecognizable parse pattern at token #" ^ ( string_of_int context.Driver.token_count )
					^ ": [id " ^ string_of_int info.Core.token_number ^ ":" ^ Representation.parser_token_to_string t ^ "]"
				^ "\n" ^ "\t" ^ "Line: " ^ string_of_int info.Core.token_line_number
				^ "\n" ^ "\t" ^ "Columns: " ^ Representation.token_range_to_string column_range
				^ "\n"
				^ "\n" ^ source_line
				^ "\n" ^ source_indentation ^ ( String.make columns_after_indent ' ' ) ^ "^~~"
				in
				prerr_endline msg
			| Error.MissingEoF ->
				let msg = "Parsing Error in" ^ context.Driver.source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Missing EoF at end of token stream (bad lexer input?)" 
				in
				prerr_endline msg

			(* Common Errors *)
			(* Missing File/Bad File Name, Bad System Calls *)
			| Sys_error(s) ->
				let msg = "Sys_error: " ^ s
				in
				prerr_endline msg

			(* Unknown Errors *)
			| err -> 
				let msg = "Unknown Error during Compilation:" 
				^ "\n" ^ "\t" ^ "Contact the compiler vendor for more details and possibly include source code, or try simplifying the program" 
				in
				prerr_endline msg;
				raise(err)
		in
		ignore( exit Error.compiler_error_exit_code )