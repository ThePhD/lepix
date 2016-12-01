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

(* Core types and routines. *)

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
