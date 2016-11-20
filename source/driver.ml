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

(* We use Global State here to communicate
into the parser file, which does not include token information
nor pass the current token to the error handling file.
See the header of the parser for how this stuff is used... *)
let parser_line_number = ref 1
let parser_token = ref Parser.EOF
let parser_token_count = ref 0
let parser_token_number = ref 0
let parser_token_range = ref (0, 0)
let parser_source_name = ref ""

let reset_driver_parser_data () =
	parser_line_number := 1;
	parser_token := Parser.EOF;
	parser_token_count :=  0;
	parser_token_number := 0;
	parser_token_range := (0, 0);
	parser_source_name := "";
	()

let lex lexbuf sourcename =
	Scanner.sourcename := sourcename;
	let tokennumber = ref 0 in
	let rec acc lexbuf tokens =
		let next_token = Scanner.token lexbuf in
		let startp = Lexing.lexeme_start_p lexbuf in
		let endp = Lexing.lexeme_end_p lexbuf in
		let line = startp.Lexing.pos_lnum in
		let relpos = startp.Lexing.pos_cnum - startp.Lexing.pos_bol in
		let endrelpos = endp.Lexing.pos_cnum - endp.Lexing.pos_bol in
		let abspos = startp.Lexing.pos_cnum in
		let endabspos = endp.Lexing.pos_cnum in
		let create_token token =
			tokennumber := 1 + !tokennumber;  
			( token, { token_source_name = sourcename; token_number = !tokennumber; token_line_number = line; 
			token_column_range = (relpos, endrelpos); token_character_range = (abspos, endabspos) } )
		in
		match next_token with
		| EOF as token -> ( create_token token ) :: tokens
		| token -> ( create_token token ) :: ( acc lexbuf tokens )
	in acc lexbuf []
;;

let parse token_list =
	(* Keep a reference to the original token list
	And use that to dereference rather than whatever crap we get from
	the channel *)
	reset_driver_parser_data ();
	let tokenlist = ref(token_list) in
	let tokenizer _ = match !tokenlist with
	(* Break each token down into pieces, info and all*)
	| (token, info) :: rest -> 
		parser_token_count := 1 + !parser_token_count;
		parser_token_number := info.token_number;
		parser_line_number := info.token_line_number;
		parser_token := token;
		parser_token_range := info.token_character_range;
		parser_source_name := info.token_source_name;
		(* Shift the list down by one by referencing 
		the beginning of the rest of the list *)
		tokenlist := rest;
		(* return token we care about *)
		token
	(* The parser stops calling the tokenizer when 
	it hits EOF: if it reaches the empty list, WE SCREWED UP *)
	(* TODO: throw a failure better than this *)
	(* TODO: A better handling for failures in the compiler in general would be nice? *)
	| [] -> raise (Failure "Missing EOF")
	in
	(* Pass in an empty channel built off a cheap string
	and then ignore the fuck out of it in our 'tokenizer' 
	internal function *)
	let program = Parser.program tokenizer (Lexing.from_string "") in
	program
;;

let analyze program =
	(* TODO: other important checks and semantic analysis here *)
	let sem = Semant.check program in match sem with
	| Semant.Error -> raise (Failure "Something went wrong")
	| Semant.Okay -> ()
;;
