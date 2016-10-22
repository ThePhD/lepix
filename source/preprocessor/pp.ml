open Ast
open Core.Std

let lines_in_file f filename =
	let chan = open_in filename in
	try while true do f(input_line chan) done
	with End_of_file -> close_in chan;;

let read_text filename =
	(* well shit *)
	let result = ref "" in
	lines_in_file (fun line -> result := !result ^ line );
	!result;

let write_text text filename =
	let chan = open_out filename in (* create or truncate file, return channel *)
		fprintf chan "%s\n" text; (* write something *)
	close_out chan; (* flush and close the channel *)


let rec preprocess = function 
	| Text(x) -> x
	| Newline(x) -> x

	| ImportSource(target) -> read_text target 
	| ImportString(target) -> '"' ^ (read_text target) ^ '"'
	| Import(target) -> "{{__UNIMPLEMENTED__}}"
	;

let _ =
	let lexbuf = Lexing.from_channel stdin in
	let expr = Parser.expr Scanner.token lexbuf in
	let result = preprocess expr in
		write_text result "out.lepix"	
