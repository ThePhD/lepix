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


let rec preprocess = function
	| Continue(x) -> ""
	| ImportSource(target) -> read_text target 
	| ImportString(target) -> "\"" ^ (read_text target) ^ "\""
	| Import(target) -> "{{__UNIMPLEMENTED__}}"
	| _ -> "{{ preprocess: BAD DEFAULT CASE }}"
;;

let rec process = function 
	| Text(x) -> x
	| Newline(x) -> x
	| Eof -> ""
	| Preprocessor(x) -> preprocess(x)
	| _ -> "{{ process: BAD DEFAULT CASE }}"
;;

let result =
	let lexbuf = Lexing.from_channel stdin in
	let expr = Parser.expr Lexer.token lexbuf in
	process expr
;;
