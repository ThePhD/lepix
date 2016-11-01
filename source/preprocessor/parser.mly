%{ open Ast %}

%token EOF 
%token IMPORT
%token STRINGS 
%token CONTINUE
%token <string> EOL
%token <string> TEXT
%token <char> CHARACTER
%token <string> STRING_LITERAL
%token <string> NAME

%start text
%type < Ast.text> text
%type < Ast.preprocessor> preprocessor
%%

text:
	| TEXT { Text($1) }
	| CHARACTER { Character($1) }
	| EOL { Newline($1) }
	| EOF { Eof }

preprocessor:
	| IMPORT STRING_LITERAL          { ImportSource($2) }
	| IMPORT STRINGS STRING_LITERAL  { ImportString($3) }
	| IMPORT NAME                    { Import($2) }
	| CONTINUE                       { Continue }
	