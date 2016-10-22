(* Abstract Syntax Tree and functions for printing it *)

type preprocessor = 
	Import of string 
	| ImportSource of string 
	| ImportString of string

type text = 
	| Text of string
	| Newline of string

