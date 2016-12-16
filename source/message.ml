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

(* Message formatters and helpers. *)


let preprocessing_error pcontext =
	let ( t, info ) = pcontext.Predriver.token in
	let ( source_line, source_indentation, columns_after_indent ) = 
		( Base.line_of_source pcontext.Predriver.source_code info ) 
	in
	let column_range = info.Base.token_column_range in
	let (column_text, is_columns_wide) = Representation.token_range_to_string column_range in
	let msg = "Preprocessing Error in " ^ pcontext.Predriver.source_name ^ ":" 
	^ "\n" ^ "\t" ^ "Unrecognizable parse pattern at token #" ^ ( string_of_int pcontext.Predriver.token_count )
		^ ": [id " ^ string_of_int info.Base.token_number ^ ":" ^ Representation.preparser_token_to_string t ^ "]"
	^ "\n" ^ "\t" ^ "Line: " ^ string_of_int info.Base.token_line_number
	^ "\n" ^ "\t" ^ ( if is_columns_wide then "Columns: " else "Column: " ) ^ column_text
	^ "\n"
	^ "\n" ^ source_line
	^ "\n" ^ source_indentation ^ ( String.make columns_after_indent ' ' ) ^ "^~~"
	in
	msg

let preprocessing_lexer_error pcontext core_msg c s e =
	let ( t, info ) = pcontext.Predriver.token in
	let ( source_line, source_indentation, columns_after_indent ) = 
		( Base.line_of_source pcontext.Predriver.source_code info ) 
	in
	let column_range = info.Base.token_column_range in
	let (column_text, is_columns_wide) = Representation.token_range_to_string column_range in
	let msg = "Preprocessing Lexing Error in " ^ pcontext.Predriver.source_name ^ ":" 
	^ "\n" ^ "\t" ^ core_msg ^ " at token#" ^ ( string_of_int pcontext.Predriver.token_count )
		^ ": [id " ^ string_of_int info.Base.token_number ^ ":" ^ Representation.preparser_token_to_string t ^ "]"
	^ "\n" ^ "\t" ^ "Line: " ^ string_of_int info.Base.token_line_number
	^ "\n" ^ "\t" ^ ( if is_columns_wide then "Columns: " else "Column: " ) ^ column_text
	^ "\n"
	^ "\n" ^ source_line
	^ "\n" ^ source_indentation ^ ( String.make columns_after_indent ' ' ) ^ "^~~"
	in
	msg

let lexer_error context core_msg c s e =
	let abspos = s.Lexing.pos_cnum in
	let endabspos = e.Lexing.pos_cnum in
	let relpos = 1 + abspos - s.Lexing.pos_bol in
	let endrelpos = 1 + endabspos - e.Lexing.pos_bol in		
	let (column_text, is_columns_wide) = Representation.token_range_to_string ( relpos, endrelpos ) in
	let msg = "Lexing Error in " ^ context.Driver.source_name ^ ":"
	^ "\n" ^ "\t" ^ core_msg ^ " at character: " ^  c
	^ "\n" ^ "\t" ^ "Line: " ^ string_of_int s.Lexing.pos_lnum
	^ "\n" ^ "\t" ^ ( if is_columns_wide then "Columns: " else "Column: " ) ^ column_text 
	in
	msg

let parser_error context core_msg =
	let ( t, info ) = context.Driver.token in
	let ( source_line, source_indentation, columns_after_indent ) = 
		( Base.line_of_source context.Driver.source_code info ) 
	in
	let column_range = info.Base.token_column_range in
	let (column_text, is_columns_wide) = Representation.token_range_to_string column_range in
	let msg = "Parsing Error in " ^ context.Driver.source_name ^ ":" 
	^ "\n" ^ "\t" ^ core_msg ^ " at token #" ^ ( string_of_int context.Driver.token_count )
		^ ": [id " ^ string_of_int info.Base.token_number ^ ":" ^ Representation.parser_token_to_string t ^ "]"
	^ "\n" ^ "\t" ^ "Line: " ^ string_of_int info.Base.token_line_number
	^ "\n" ^ "\t" ^ ( if is_columns_wide then "Columns: " else "Column: " ) ^ column_text
	^ "\n"
	^ "\n" ^ source_line
	^ "\n" ^ source_indentation ^ ( String.make columns_after_indent ' ' ) ^ "^~~"
	in
	msg