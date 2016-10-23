(* Abstract Syntax Tree and functions for printing it *)

type cont
type eof

type preprocessor = 
	| Import of string 
	| ImportSource of string
	| ImportString of string
	| Continue of cont

type text = 
	| Preprocessor of preprocessor
	| Text of string
	| Newline of string
	| Eof 

