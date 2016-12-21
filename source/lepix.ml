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

(* Top-level of the LePiX compiler: scan & parse the input,
check the resulting AST, generate LLVM IR, and dump the module *)

let _ = 
	let input = ref Base.Pipe in
	let output = ref Base.Pipe in
	let action = ref Base.Llvm in
	let verbose = ref false in
	let specified = ref [] in
	let context = { 
		Driver.source_name = "";
		Driver.source_code = "";
		Driver.original_source_code = "";
		Driver.token_count = 0;
		Driver.token = ( Parser.EOF, 
			{ Base.token_source_name = ""; Base.token_number = 0; 
			Base.token_line_number = 0; Base.token_line_start = 0;
			Base.token_column_range = (0, 0); Base.token_character_range = (0, 0) } 
		);
	} 
	and pcontext = {
	     Predriver.source_name = "";
		Predriver.source_code = "";
		Predriver.original_source_code = "";
		Predriver.token_count = 0;
		Predriver.token = ( Preparser.EOF, 
			{ Base.token_source_name = ""; Base.token_number = 0; 
			Base.token_line_number = 0; Base.token_line_start = 0;
			Base.token_column_range = (0, 0); Base.token_character_range = (0, 0) } 
		);
     }
	in
	let ocontext = { 
		Options.options_help = fun (s) -> ( "" ); 
	} in
	(* Call options Parser for Driver *)
	let _ =
	try
		let ( i, o, a, s, v ) = ( Options.read_options ocontext Sys.argv ) in
			input := i;
			output := o;
			action := a;
			specified := s;
			verbose := v
	with
		| err -> let _ = match err with
			| Errors.BadOption(s) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Unrecognized option: " ^ s
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| Errors.NoOption ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "No inputs or options specified"
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| Errors.MissingOption(o) ->
				let msg = "Options Error:"
				^ "\n" ^ "\t" ^ "Flag " ^ o ^ " needs an additional argument after it that is not dashed"
				^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
				prerr_endline msg
			| Errors.OptionFileNotFound(f) ->
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
		ignore( ( exit Errors.option_error_exit_code ) )
	in
	(* Perform actual lexing and parsing using the Driver here *)
	try 
		let allactions = !specified in
		let source_name = ( Base.target_to_pipe_string !input true ) in
		let pre_source_text = match !input with
			| Base.Pipe -> Io.read_text stdin
			| Base.File(f) -> ( Io.read_file_text f )
		in
		let output_to_target ( s ) = match !output with
			| Base.Pipe -> ( print_endline s )
			| Base.File(f) -> ( Io.write_file_text s f )
		in
		let print_predicate b =
			fun v -> ( v = b ) 
		in
		let print_help () =
			let msg = "Help:"
			^ "\n" ^ ( ocontext.Options.options_help "\t" ) in
			print_endline msg
		in
		if !action = Base.Help then begin
			print_help ()
		end else
		(* Since we do the actions in these functions multiple times,
		We refactor them out here to make our lives easier while we tweak 
		stuff *)
		let dump_tokens f tokenstream =
			if ( List.exists (print_predicate Base.Tokens) allactions ) then f( Representation.parser_token_list_to_string tokenstream )
		and dump_ast f program =
			if ( List.exists (print_predicate Base.Ast) allactions ) then f( Representation.string_of_program program )
		and dump_semantic f semanticprogram =
			if ( List.exists (print_predicate Base.Semantic) allactions ) then f( Representation.string_of_s_program semanticprogram )
		and dump_module f m =
			f( Llvm.string_of_llmodule m )
		in
		let source_text = Predriver.pre_process pcontext !input pre_source_text in
		context.Driver.source_name <- source_name;
		context.Driver.original_source_code <- pre_source_text;
		context.Driver.source_code <- source_text;
		let _ = match !action with
			| Base.Help -> print_help ()	
			| Base.Preprocess -> 
				output_to_target( source_text )
			| Base.Tokens -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				( dump_tokens output_to_target tokenstream )
			| Base.Ast -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				( dump_tokens print_endline tokenstream );
				let program = Driver.parse context tokenstream in 
				( dump_ast output_to_target program)
			| Base.Semantic ->
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				( dump_tokens print_endline tokenstream );
				let program = Driver.parse context tokenstream in 
				( dump_ast print_endline program );
				let semanticprogram = Driver.analyze program in 
				( dump_semantic output_to_target semanticprogram )
			| Base.Llvm -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				( dump_tokens print_endline tokenstream );
				let program = Driver.parse context tokenstream in 
				( dump_ast print_endline program );
				let semanticprogram = Driver.analyze program in 
				( dump_semantic print_endline semanticprogram );
				let m = Codegen.generate semanticprogram in
				if !verbose then ( dump_module print_endline m );
				( dump_module output_to_target m )
			| Base.Compile -> 
				let lexbuf = Lexing.from_string source_text in
				let tokenstream = Driver.lex source_name lexbuf in
				( dump_tokens print_endline tokenstream );
				let program = Driver.parse context tokenstream in 
				( dump_ast print_endline program );
				let semanticprogram = Driver.analyze program in 
				( dump_semantic print_endline semanticprogram );
				let m = Codegen.generate semanticprogram in
				Llvm_analysis.assert_valid_module m;
				( dump_module output_to_target m )
		in
		()
	with
		| err -> let _ = match err with
			(* Preprocessor-Specific Errors *)
			(* Preprocessing Parser Errors *)
			| Preparser.Error ->
				let msg = Message.preprocessing_error pcontext in
				prerr_endline msg
			| Errors.PreUnknownCharacter( c, (s, e) ) ->
				let msg = Message.preprocessing_lexer_error pcontext "Unrecognized character in program" c s e in
				prerr_endline msg
			
			(* General Compiler Errors *)
			(* Lexer Errors *)
			| Errors.UnknownCharacter( c, (s, e) ) ->
				let msg = Message.lexer_error context "Unrecognized character in program" c s e in
				prerr_endline msg
		
			| Errors.BadNumericLiteral( c, (s, e) ) ->
				let msg = Message.lexer_error context "Bad character in numeric literal" c s e in
				prerr_endline msg
		
			(* Parser Errors *)
			| Parser.Error
			| Parsing.Parse_error ->
				let msg = Message.parser_error context "Unrecognizable parse pattern" in
				prerr_endline msg
			| Errors.MissingEoF ->
				let msg = "Parsing Error in" ^ context.Driver.source_name ^ ":" 
				^ "\n" ^ "\t" ^ "Missing EoF at end of token stream (bad lexer input?)" 
				in
				prerr_endline msg

			(* Semantic Analyzer and Codegen Errors *)
			(* Semantic Errors *)
			(* TODO: positional information should be tracked through the AST as well... *)
			| Errors.BadFunctionCall(s) ->
				let msg = "Bad Function Call error: " ^ s
				in
				prerr_endline msg
			| Errors.TypeMismatch(s) ->
				let msg = "Mismatched types error: " ^ s
				in
				prerr_endline msg
			| Errors.IdentifierNotFound(s) ->
				let msg = "Identifier Not Found error: " ^ s
				in
				prerr_endline msg
			| Errors.InvalidFunctionSignature(s, n) ->
				let msg = "Invalid signature: " ^ s ^ " in " ^ n
				in
				prerr_endline msg
			| Errors.InvalidMainSignature(s) ->
				let msg = "Invalid signature: " ^ s
				in
				prerr_endline msg
			| Errors.InvalidBinaryOperation(s)
			| Errors.InvalidUnaryOperation(s) ->
				let msg = "Invalid operation: " ^ s
				in
				prerr_endline msg
			
			(* Direct Codegen Errors *)
			| Errors.UnknownVariable(s) ->
				let msg = "Codegen (LLVM IR) error: " ^ s
				in
				prerr_endline msg
			| Errors.UnknownFunction(s) ->
				let msg = "Codegen (LLVM IR) error: " ^ s
				in
				prerr_endline msg
			| Errors.VariableLookupFailure(name, _) ->
				let msg = "Codegen (LLVM IR) error: could not properly find variable with the name " ^ name
				in
				prerr_endline msg
			| Errors.FunctionLookupFailure(name, mangledname) ->
				let msg = "Codegen (LLVM IR) error: looking for the function with the name " ^ name ^ " (mangled name: " ^ mangledname ^ ")"
				in
				prerr_endline msg
			| Errors.BadPrintfArgument ->
				let msg = "Codegen (LLVM IR) error: lib.print and related functions only take either a string, an integer, or a floating point argument"
				in
				prerr_endline msg

			(* Common Errors *)
			(* Missing File/Bad File Name, Bad System Calls *)
			| Sys_error(s) ->
				let msg = "Sys_error: \n\t" ^ s
				in
				prerr_endline msg

			(* Unsupported features *)
			| Errors.Unsupported(s) ->
				let msg = "Unsupported (ran out of implementation time): \n\t" ^ s
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
		ignore( exit Errors.compiler_error_exit_code )
