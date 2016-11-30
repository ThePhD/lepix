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

(* Options / argument parser *)

type option =
	| Dash of string
	| DoubleDash of string
	| Argument of int * string

type options_context = {
     mutable options_help : string -> string;
}

let read_options ocontext sys_argv =
	let argc = Array.length sys_argv - 1 in
	(* Skip first argument one (argv 0 is the path 
	of the exec on pretty much all systems) *)
	let argv = ( Array.sub sys_argv 1 argc )
	and action = ref Core.Help
	and input = ref Core.Pipe 
	and output = ref Core.Pipe
	and specified = ref []
	and seen_stdin = ref false 
	in
	(* Our various options *)
	let update_action a =
		specified := a :: !specified;
		if ( Core.action_to_int !action ) < ( Core.action_to_int a ) then 
			action := a;
	in 
	let options = [
		( 1, "h", "help", "print the help message", 
			fun _ _ -> ( update_action(Core.Help) ) 
		);
		( 1, "p", "preprocess", "Preprocess and display source", 
			fun _ _ -> ( update_action(Core.Preprocess) ) 
		);
		( 1, "i", "input", "Take input from standard in (default: stdin)", 
			fun _ _ -> ( input := Core.Pipe; seen_stdin := true ) 
		);
		( 2, "o", "output", "Set the output file (default: stdout)", 
			fun _ o -> ( output := Core.File(o) ) 
		);
		( 1, "t", "tokens", "Print the stream of tokens",
			fun _ _ -> ( update_action(Core.Tokens) ) 
		);
		( 1, "a", "ast", "Print the parsed Program",
			fun _ _ -> ( update_action(Core.Ast) )  
		);
		( 1, "s", "semantic", "Print the Semantic Program",
			fun _ _ -> ( update_action(Core.Semantic) ) 
		);
		( 1, "l", "llvm", "Print the generated LLVM code", 
			fun _ _ -> ( update_action(Core.Llvm) )
		);
		( 1, "c", "compile", "Compile the desired input and output the final LLVM", 
			fun _ _ -> ( update_action(Core.Compile) ) 
		);
	]
	and position_option arg_index positional_index arg =
		if Sys.file_exists arg then
			input := Core.File( arg )
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
		let (_, input_short, input_long, _, _) = List.nth options 2 in
		let msg = "Help:"
			^ "\n" ^ tabulation ^ "lepix [options] filename [filenames...]" 
			^ "\n" ^ tabulation ^ "\t" ^ "filename | filenames can have one option -" ^ input_short ^ " or --" ^ input_long
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
