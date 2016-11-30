%{
(* LePiX - LePiX Language Compiler Implementation
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

(* Parser for the LePiX preprocessor: compatible with both ocamlyacc and 
menhir, as we have developed against both for testing purposes. *)

%}

%token HASH
%token IMPORT STRING
%token <string> TEXT
%token <string> STRINGLITERAL
%token EOF

%start source
%type<Preast.pre_source> source
%%

blob:
| HASH IMPORT STRINGLITERAL { Preast.ImportSource($3) }
| HASH IMPORT STRING STRINGLITERAL { Preast.ImportString($4) }
| TEXT { Preast.Text($1) }

blob_list: { [] }
| blob_list blob { $2 :: $1 }

source:
| blob_list EOF { List.rev $1 }
