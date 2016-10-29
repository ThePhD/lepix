(* Abstract Syntax Tree and functions for printing it *)

type preprocessor = 
	| Import of string 
	| ImportSource of string
	| ImportString of string
	| Continue

type text = 
	| Preprocessor of preprocessor
	| Text of string
	| Character of char
	| Newline of string
	| Eof 
