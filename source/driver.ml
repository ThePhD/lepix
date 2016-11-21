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

(* Drives the typical lexing and parsing algorithm
while adding pertinent source, line and character information. *)

open Parser

type token_source = {
     token_source_name : string;
	token_number : int;
     token_line_number : int;
	token_column_range : int * int;
	token_character_range : int * int;
}

type driver_context = {
     mutable parser_source_name : string;
     mutable parser_line_number : int;
	mutable parser_token : Parser.token;
	mutable parser_token_count : int;
	mutable parser_token_number : int;
	mutable parser_token_range : int * int;
}

type options_context = {
     mutable options_help : string -> string;
}

type target =
	| Pipe
	| File of string

let target_to_string = function
	| Pipe -> "pipe"
	| File(s) -> "file: " ^ s

let target_to_pipe_string i b = match i with
	| Pipe -> if b then "stdin" else "stdout"
	| File(s) -> "file: " ^ s

type action = 
	| Help
	| Tokens
	| Ast
	| Semantic
	| Llvm
	| Compile

let action_to_int = function
	| Help -> -1
	| Tokens -> 0
	| Ast -> 1
	| Semantic -> 2
	| Llvm -> 3
	| Compile -> 100

let read_options ocontext =
	let argc = Array.length Sys.argv - 1 in
	(* Skip first argument one (argv 0 is the path 
	of the exec on pretty much all systems) *)
	let argv = ( Array.sub Sys.argv 1 argc ) in
	let action = ref Help in
	let input = ref Pipe in 
	let output = ref Pipe in 
	let specified = ref [] in
	let seen_stdin = ref false in
	(* Our various options *)
	let update_action a =
		specified := a :: !specified;
		if ( action_to_int !action ) < ( action_to_int a ) then 
			action := a;
	in 
	let options = [
		( 1, "h", "help", "print the help message", 
			fun _ _ -> ( action := Help ) 
		);
		( 1, "p", "pipe", "Take input from standard in (default: stdin)", 
			fun _ _ -> ( input := Pipe; seen_stdin := true ) 
		);
		( 2, "o", "output", "Set the output file (default: stdout)", 
			fun _ o -> ( output := File(o); () ) 
		);
		( 1, "t", "tokens", "Print the stream of tokens",
			fun _ _ -> ( update_action(Tokens) ) 
		);
		( 1, "a", "ast", "Print the parsed Program",
			fun _ _ -> ( update_action(Ast) )  
		);
		( 1, "s", "semantic", "Print the Semantic Program",
			fun _ _ -> ( update_action(Semantic) ) 
		);
		( 1, "l", "llvm", "Print the generated LLVM code", 
			fun _ _ -> ( update_action(Llvm) )
		);
		( 1, "c", "compile", "Compile the desired input and output the final LLVM", 
			fun _ _ -> ( update_action(Compile) ) 
		);
	] in
	let help tabulation =
		let value_text = "<value>" in
		let value_text_len = String.length value_text in
		let longest_option = 
			let acc len o = match o with 
				| (sz, _, long, _, _ ) -> 
					let newlen = (String.length long)
						+ if sz = 2 then 1 + value_text_len else 0
					in 
					if newlen > len then newlen else len
			in
			let l = 1 + ( List.fold_left acc 1 options ) in
			if l < value_text_len then value_text_len else l
		in
		let concat_options t =
			let builder s o = match o with
				| ( sz, short, long, desc, _ ) -> 
					let long_len = String.length long in
					let spacing_size = longest_option - long_len - ( if sz = 2 then 1 + value_text_len else 0 ) in
					let spacing_string = (String.make spacing_size ' ') in
					s  
					^ "\n" ^ t ^ "-" ^ short 
					^ "\t--" ^ long ^ (if sz = 1 then "" else " " ^ value_text)
					^ spacing_string
					^ desc
			in
			(List.fold_left builder "" options)
		in
		let msg = "Help:"
			^ "\n" ^ tabulation ^ "lepix [options] filename [filenames...]" 
			^ "\n" ^ tabulation ^ "\t" ^ "filename | filenames can have one option -p or --pipe"
			^ "\n" ^ tabulation ^ "options:"
			^ ( concat_options (tabulation ^ "\t") )
		in
		msg
	in
	ocontext.options_help <- help;
	(* Exit early if possible *)
	if argc < 1 then
		(!input, !output, !action, !specified)
	else
	(* For stopping us from processing a second-option arg if we have it *)
	let block = ref false in
	(* Function for each argument *)
	let f idx arg = 
		if !block then block := false else
		let arglen = String.length arg in
		if arglen < 2 then raise(Error.BadOption(arg));
		let is_dashed s = 
			let isdash = s.[0] = '-' in
			let isdoubledash = isdash && s.[1] = '-' in
			let acc i b = 
				i + (Polyfill.int_of_bool b)
			in
			( isdash, isdoubledash, ( List.fold_left acc 0 [ isdash; isdoubledash ] ) )
		in
		let ( d, dd, dashcount ) = is_dashed arg in
		let nodasharg = String.sub arg dashcount ( arglen - dashcount ) in
		let make_arg_pairs l =
			List.map (fun s -> ( s, false )) l
		in
		let execute_on_match_option (opt_failure, problems) opt_string use_short =
			if problems then (opt_failure, problems) else
			let pred = function 
				| (_, short, long, _, f ) -> 
					if use_short then
						short = opt_string
					else 
						long = opt_string
			in
			try
				match List.find pred options with
					| ( 1, _, _, _, f ) -> 
						(f opt_string ""); 
						( opt_failure, false )
					| ( 2, _, _, _, f ) -> 
						if ( idx + 1 ) >= argc  then 
							raise(Error.MissingOption(opt_string));
						let nextarg = ( argv.(1 + idx) ) in
						(f opt_string nextarg);
						block := true;
						( opt_failure, false )
					| _ -> ( opt_string, true )
			with
				| _ -> ( opt_string, true )
		in
		match (d, dd) with
			(* if it has a dash only *)
			| ( true, false ) -> 
				(* each letter can be its own thing *)
				let perletter (opt_failure, problems) ( c, _ ) = 
					let opt_string = ( String.make 1 c ) in
					execute_on_match_option (opt_failure, problems) opt_string true
				in
				(* look at every character. If there's 1 match among them, go crazy *)
				let arglist = make_arg_pairs (Polyfill.string_to_list nodasharg) in
				let (opt_failure, problems) = ( List.fold_left perletter ( "", false ) arglist ) in
				if problems then 
					let msg = "-" ^ opt_failure 
						^ if ( List.length arglist ) > 1 then " ( in " ^ arg ^ " )" else "" 
					in
				raise(Error.BadOption(msg))
			(* if it has a double dash... *)
			| ( _, true ) -> 
				(* each comma-delimeted word can be its own option *)
				let perword (opt_failure, problems) ( opt_string, _ ) = 
					execute_on_match_option (opt_failure, problems) opt_string false
				in
				(* look at word character. If there's 1 match among them, go crazy *)
				let arglist = make_arg_pairs (Polyfill.string_split "," nodasharg) in
				let (opt_failure, problems) = ( List.fold_left perword ( "", false ) arglist ) in
				if problems then 
					let msg = "--" ^ opt_failure 
						^ if ( List.length arglist ) > 1 then " ( in " ^ arg ^ " )" else "" 
					in
				raise(Error.BadOption(msg))
			| ( false, false ) ->
				(* otherwise, it's just a plain file *)
				if Sys.file_exists arg then
					input := File( arg )
				else
					raise(Error.OptionFileNotFound(arg))
		;
	in
	(* Iterate over the arguments *)
	Array.iteri f argv;
	(* Return tuple of input, output, action *)
	( !input, !output, !action, !specified )

let lex lexbuf sourcename =
	Scanner.sourcename := sourcename;
	let tokennumber = ref 0 in
	let rec acc lexbuf tokens =
		let next_token = Scanner.token lexbuf in
		let startp = Lexing.lexeme_start_p lexbuf in
		let endp = Lexing.lexeme_end_p lexbuf in
		let line = startp.Lexing.pos_lnum in
		let relpos = 1 + startp.Lexing.pos_cnum - startp.Lexing.pos_bol in
		let endrelpos = 1 + endp.Lexing.pos_cnum - endp.Lexing.pos_bol in
		let abspos = startp.Lexing.pos_cnum in
		let endabspos = endp.Lexing.pos_cnum in
		let create_token token =
			let t = ( token, { token_source_name = sourcename; token_number = !tokennumber; token_line_number = line; 
			token_column_range = (relpos, endrelpos); token_character_range = (abspos, endabspos) } ) in
			tokennumber := 1 + !tokennumber; 
			t
		in
		match next_token with
		| EOF as token -> ( create_token token ) :: tokens
		| token -> ( create_token token ) :: ( acc lexbuf tokens )
	in acc lexbuf []
;;

let parse token_list context =
	(* Keep a reference to the original token list
	And use that to dereference rather than whatever crap we get from
	the channel *)
	let tokenlist = ref(token_list) in
	let tokenizer _ = match !tokenlist with
	(* Break each token down into pieces, info and all*)
	| (token, info) :: rest -> 
		context.parser_token_count <- 1 + context.parser_token_count;
		context.parser_token_number <- info.token_number;
		context.parser_line_number <- info.token_line_number;
		context.parser_token <- token;
		context.parser_token_range <- info.token_character_range;
		context.parser_source_name <- info.token_source_name;
		(* Shift the list down by one by referencing 
		the beginning of the rest of the list *)
		tokenlist := rest;
		(* return token we care about *)
		token
	(* The parser stops calling the tokenizer when 
	it hits EOF: if it reaches the empty list, WE SCREWED UP *)
	| [] -> raise (Error.MissingEoF)
	in
	(* Pass in an empty channel built off a cheap string
	and then ignore the fuck out of it in our 'tokenizer' 
	internal function *)
	let program = Parser.program tokenizer (Lexing.from_string "") in
	program
;;

let analyze program =
	(* TODO: other important checks and semantic analysis here 
	that will create a proper checked program type*)
	let sem = Semant.check program in
	sem
;;
