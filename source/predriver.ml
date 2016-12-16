(* LePiX - LePiX Language Compiler Implementation
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

(* Routines for preprocessing source code. *)

type pre_context = {
     mutable source_name : string;
     mutable source_code : string;
     mutable original_source_code : string;
	mutable token_count : int;
     mutable token : Preparser.token * Base.token_source;
}

let pre_lex sourcename lexbuf =
	let rec acc lexbuf tokens tokennumber =
		let next_token = Prescanner.token lexbuf
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
			let t = ( token, { Base.token_source_name = sourcename; Base.token_number = tokennumber; 
				Base.token_line_number = line; Base.token_line_start = startp.Lexing.pos_bol; 
				Base.token_column_range = (relpos, endrelpos); Base.token_character_range = (abspos, endabspos) } 
			) in
			t
		in
		let rec matcher = function 
			| [] -> raise (Errors.MissingEoF)
			| Preparser.EOF :: [] -> ( create_token Preparser.EOF ) :: tokens
			| token :: [] -> ( create_token token ) :: ( acc lexbuf tokens ( 1 + tokennumber ) )
			| token :: rest -> ( create_token token ) :: ( matcher rest )
		in matcher next_token
	in acc lexbuf [] 0

let pre_parse context token_list =
	(* Keep a reference to the original token list
	And use that to dereference rather than whatever crap we get from
	the channel *)
	let tokenlist = ref(token_list) in
	let tokenizer _ = match !tokenlist with
	(* Break each token down into pieces, info and all*)
	| (token, info) :: rest -> 
		context.source_name <- info.Base.token_source_name;
		context.token_count <- 1 + context.token_count;
		context.token <- ( token, info );
		(* Shift the list down by one by referencing 
		the beginning of the rest of the list *)
		tokenlist := rest; 
		(* return token we care about *)
		token
	(* The parser stops calling the tokenizer when 
	it hits EOF: if it reaches the empty list, WE SCREWED UP *)
	| [] -> raise (Errors.MissingEoF)
	in
	(* Pass in an empty channel built off a cheap string
	and then ignore the fuck out of it in our 'tokenizer' 
	internal function *)
	let past = Preparser.source tokenizer (Lexing.from_string "") in
	past

let rec pre_process context source source_text =
	let source_name = Base.target_to_string source in
	context.source_name <- source_name;
	context.source_code <- source_text;
	let reldir = match source with
		| Base.Pipe -> ( Sys.getcwd () )
		| Base.File(f) -> Filename.dirname f
	in
	let generate v p = match p with
		| Preast.Text(s) -> v ^ s
		| Preast.ImportString(f) -> v ^ "\"" ^ Io.read_file_text (Filename.concat reldir f) ^ "\""
		| Preast.ImportSource(f) -> let realf = (Filename.concat reldir f) in
			let ftext = Io.read_file_text realf in
			let processedtext = ( pre_process context ( Base.File(f) ) ftext ) in
			v ^ processedtext
	in
	let tokenstream = pre_lex source_name ( Lexing.from_string source_text ) in
	(*TODO: debug shit tokens at a later date*)
	(*print_endline ( Representation.preparser_token_list_to_string tokenstream );*)
	let past = pre_parse context tokenstream in
	List.fold_left generate "" past
