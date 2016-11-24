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
     token_line_start : int;
	token_column_range : int * int;
	token_character_range : int * int;
}

type driver_context = {
     mutable driver_source_code : string;
	mutable driver_token_count : int;
     mutable driver_source_name : string;
     mutable driver_token : Parser.token * token_source;
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

type option =
	| Dash of string
	| DoubleDash of string
	| Argument of int * string

let read_options ocontext =
	let argc = Array.length Sys.argv - 1 in
	(* Skip first argument one (argv 0 is the path 
	of the exec on pretty much all systems) *)
	let argv = ( Array.sub Sys.argv 1 argc )
	and action = ref Help
	and input = ref Pipe 
	and output = ref Pipe
	and specified = ref []
	and seen_stdin = ref false 
	in
	(* Our various options *)
	let update_action a =
		specified := a :: !specified;
		if ( action_to_int !action ) < ( action_to_int a ) then 
			action := a;
	in 
	let options = [
		( 1, "h", "help", "print the help message", 
			fun _ _ -> ( update_action(Help) ) 
		);
		( 1, "p", "pipe", "Take input from standard in (default: stdin)", 
			fun _ _ -> ( input := Pipe; seen_stdin := true ) 
		);
		( 2, "o", "output", "Set the output file (default: stdout)", 
			fun _ o -> ( output := File(o) ) 
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
	]
	and position_option arg_index positional_index arg =
		if Sys.file_exists arg then
			input := File( arg )
		else
			raise(Error.OptionFileNotFound(arg))
	in
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
	
	let to_option idx arg = 
		let arglen = String.length arg in
		match arg with
			| _ when Polyfill.string_starts_with arg "--" -> DoubleDash((String.sub arg 2 (arglen - 2)))
			| _ when Polyfill.string_starts_with arg "-" -> Dash((String.sub arg 1 (arglen - 1)))
			| _ -> Argument(idx, arg)
	in
	(* Convert all arguments to the Option type first *)
	let options_argv = Array.mapi to_option argv in
	
	(* Function for each argument *)
	let f (index, positional_index, skip_next) option_arg =
		if skip_next then (1 + index, positional_index, false) else 
		let execute_on_match_sub_option ( opt_failure, should_block ) opt_string pred = match opt_failure with
			(* There is some failure, so just propogate it through *)
			| Some(x) -> ( opt_failure, should_block )
			(* There is no failure, so now work with the list *)
			| None -> begin match List.filter pred options with
				(* We use filter instead of find because find is dumb and throws an
				exception instead of just returning an optional because
				whoever designed the OCaml standard library is an absolute
				bell end. *)
				| ( 1, _, _, _, f ) :: tail -> (* Only needs 1 argument *)
					(f opt_string ""); 
					( opt_failure, should_block )
				| ( 2, _, _, _, f ) :: tail -> (* Needs 2 arguments, look ahead by 1 *)
					if ( index + 1 ) >= argc  then 
						raise(Error.MissingOption(opt_string));
					let nextarg = ( options_argv.(1 + index) ) in 
					let _ = match nextarg with
						| Argument(idx, s) -> (f opt_string s)
						| _ -> raise(Error.BadOption(opt_string))
					in
					( opt_failure, true )				
				| _ -> (* Unhandled case: return new failure string *)
					( Some opt_string, should_block )
				end
		and on_failure dashes opt arglist arg =
			let msg = dashes ^ opt 
				^ if ( List.length arglist ) > 1 then " ( in " ^ dashes ^ arg ^ " )" else "" 
			in
			raise(Error.BadOption(msg))
		in
		let ( should_skip_next, was_positional ) = match option_arg with
			| Dash(arg) ->
				(* if it has a dash only *)
				(* each letter can be its own thing *)
				let perletter (opt_failure, should_break) c = 
					let opt_string = ( String.make 1 c ) in
					let short_pred (_, short, _, _, _ ) = 
						short = opt_string
					in
					execute_on_match_sub_option (opt_failure, should_break) opt_string short_pred
				in
				(* look at every character. If there's 1 match among them, go crazy *)
				let arglist = (Polyfill.string_to_list arg) in
				let (opt_failure, causes_skip) = ( List.fold_left perletter ( None, false ) arglist ) in
				begin match opt_failure with
					| None -> 
						( causes_skip, 0 )
					| Some(opt) -> let _ = (on_failure "--" opt arglist arg) in 
						( causes_skip, 0 )
				end
			| DoubleDash(arg) ->
				(* if it has a double dash... *)
				(* each comma-delimeted word can be its own option *)
				let perword (opt_failure, problems) opt_string = 
					let long_pred (_, _, long, _, _ ) =
						long = opt_string
					in
					execute_on_match_sub_option (opt_failure, problems) opt_string long_pred
				in
				(* look at word character. If there's 1 match among them, go crazy *)
				let arglist = Polyfill.string_split "," arg in
				let (opt_failure, causes_skip) = ( List.fold_left perword ( None, false ) arglist ) in
				begin match opt_failure with
					| None -> 
						( causes_skip, 0 )
					| Some(opt) -> let _ = (on_failure "--" opt arglist arg) in 
						( causes_skip, 0 )
				end
			(* otherwise, it's just a positional argument *)
			| Argument(idx, arg) ->
				(position_option index positional_index arg);
				( skip_next, 1 )
		in
		(1 + index, positional_index + was_positional, should_skip_next)
	in
	(* Iterate over the arguments *)
	let _ = Array.fold_left f (0, 0, false) options_argv in
	(* Return tuple of input, output, action *)
	( !input, !output, !action, !specified )

let lex lexbuf sourcename =
	Scanner.sourcename := sourcename;
	let tokennumber = ref 0 in
	let rec acc lexbuf tokens =
		let next_token = Scanner.token lexbuf
		and startp = Lexing.lexeme_start_p lexbuf
		and endp = Lexing.lexeme_end_p lexbuf
		in
		let line = startp.Lexing.pos_lnum
		and relpos = (1 + startp.Lexing.pos_cnum - startp.Lexing.pos_bol)
		and endrelpos = (1 + endp.Lexing.pos_cnum - endp.Lexing.pos_bol) 
		and abspos = startp.Lexing.pos_cnum
		and endabspos = endp.Lexing.pos_cnum
		in
		let create_token token =
			let t = ( token, { token_source_name = sourcename; token_number = !tokennumber; 
				token_line_number = line; token_line_start = startp.Lexing.pos_bol; 
				token_column_range = (relpos, endrelpos); token_character_range = (abspos, endabspos) } 
			) in
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
		context.driver_source_name <- info.token_source_name;
		context.driver_token_count <- 1 + context.driver_token_count;
		context.driver_token <- ( token, info );
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
