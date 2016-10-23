%{ open Pp_ast %}

%token EOF EOL
%token <string> TEXT
%token IMPORT STRINGS CONTINUE
%token <string> STRING_LITERAL
%token <string> NAME

%start main
%type < Pp_ast.expr> main

%%

main:
	| preprocessor { $1 }
	| TEXT { Text($1) }
	| EOL { Newline }
	| EOF { Eof }

preprocessor:
	| IMPORT STRING_LITERAL          { ImportSource($2) }
	| IMPORT STRINGS STRING_LITERAL  { ImportString($3) }
	| IMPORT NAME                    { Import($2) }
	| CONTINUE                       { Continue }
	