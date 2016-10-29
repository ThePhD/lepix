open Ast
open Printf

let lines_in_file f filename =
	let chan = open_in filename in
	try while true do f(input_line chan) done
	with End_of_file -> close_in chan
;;

let read_text filename =
	(* well shit *)
	let result = ref "" in
	lines_in_file (fun line -> result := !result ^ line );
	!result
;;

let write_text text filename =
	let chan = open_out filename in (* create or truncate file, return channel *)
		fprintf chan "%s\n" text; (* write something *)
	(* flush and close the channel *)
	close_out chan
;; 

let string_of_chars chars = 
	let buf = Buffer.create 16 in
	List.iter (Buffer.add_char buf) chars;
	Buffer.contents buf
;;

let rec preprocess = function
	| Continue -> ""
	| ImportSource(target) -> read_text target 
	| ImportString(target) -> "\"" ^ (read_text target) ^ "\""
	| Import(target) -> "{{__UNIMPLEMENTED__}}"
;;

let rec process = function 
	| Text(x) -> x
	| Character(x) -> string_of_chars [x] 
	| Newline(x) -> x
	| Eof -> ""
	| Preprocessor(x) -> preprocess(x)
;;

let result =
	let lexbuf = Lexing.from_channel stdin in
	let ppmain = Parser.text Lexer.token lexbuf in
	process ppmain
;;
