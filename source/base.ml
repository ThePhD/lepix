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

(* Base types and routines. *)

type token_source = {
     token_source_name : string;
	token_number : int;
     token_line_number : int;
     token_line_start : int;
	token_column_range : int * int;
	token_character_range : int * int;
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
	| Preprocess
	| Tokens
	| Ast
	| Semantic
	| Llvm
	| Compile

let action_to_int = function
	| Help -> -1
	| Preprocess -> 0
	| Tokens -> 1
	| Ast -> 10
	| Semantic -> 100
	| Llvm -> 1000
	| Compile -> 10000

let entry_point_name = "main"

(* Core options *)

let default_integral_bit_width = 32
let default_floating_bit_width = 64

(* Error message helpers *)

let line_of_source src token_info =
	let ( absb, abse ) = token_info.token_character_range 
	and linestart = token_info.token_line_start
	in
	let ( lineend, _ ) =
		let f (endindex, should_skip) idx =
			let c = src.[idx] in
			let skip_this = c = '\n' in
			if should_skip || skip_this then 
				(endindex, true) 
			else
				(endindex + 1, false)
		in
		Polyfill.foldi f ( linestart, false ) linestart ( ( String.length src ) - linestart )
	in
	let srcline = String.sub src linestart (max 0 (lineend - linestart - 1)) in
	let srclinelen = String.length srcline in
	let ( srcindent, _ ) = 
		let f (s, should_skip) idx = 
			let c = srcline.[idx] in
			let nws = not ( Polyfill.is_whitespace c ) in
			if should_skip || nws then 
				(s, false) 
			else
				(s ^ ( String.make 1 c ), true)
		in
		Polyfill.foldi f ( "", false ) 0 srclinelen
	in
	let indentlen = String.length srcindent
	and tokenlen = lineend - absb
	in
	( srcline, srcindent, (max ( srclinelen - indentlen - tokenlen ) 0 ) )


let brace_tabulate str tabs =
	let len = ( String.length str ) in
	let lines = Polyfill.string_split_with "\n" str Polyfill.KeepDelimeter in
	let lineslen = ( List.length lines ) in
	let buf = Buffer.create ( len + ( lineslen * 4 ) ) in
	let acc ( buf, t ) line = 
		let tmod = 0 - ( Polyfill.int_of_bool ( String.contains line '}' ) ) in
		let t = t + tmod in
		Buffer.add_string buf (String.make t '\t'); Buffer.add_string buf line;
		let t = t + ( Polyfill.int_of_bool ( String.contains line '{' ) ) in
		(buf, t)
	in
	let (buf, _) = List.fold_left acc ( buf, tabs ) lines in
	Buffer.contents buf
