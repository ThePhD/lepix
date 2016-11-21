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
	(* TODO: throw a failure better than this *)
	(* TODO: A better handling for failures in the compiler in general would be nice? *)
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
