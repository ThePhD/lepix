#Uses Menhir to test the parsing of the Hello World! Program
echo "FUN ID LPAREN RPAREN COLON INT LBRACE ID LPAREN INTLITERAL RPAREN SEMI RBRACE EOF" |  menhir --interpret --interpret-show-cst parser.mly  
