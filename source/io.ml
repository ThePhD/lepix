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

(* These subroutines are for the specific purpose of 
working with the file system, since we are not using Batteries Included of Jane Street's
Core.Std and the like in our implementation so far... *)

let lines_in_file f filename =
	let chan = open_in filename in
	try while true do f(input_line chan) done
	with End_of_file -> close_in chan
;;

let read_text filename =
	(* Read all the lines into a reference and return
	the value itself *)
	let result = ref "" in
	lines_in_file ( fun line -> result := !result ^ line ) filename;
	!result
;;

let write_text text filename =
	let chan = open_out filename in (* create or truncate file, return channel *)
		Printf.fprintf chan "%s\n" text; (* write something *)
	(* flush and close the channel *)
	close_out chan
;; 