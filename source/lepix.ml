(* Top-level of the LePiX compiler: scan & parse the input,
   check the resulting AST, generate LLVM IR, and dump the module *)


let lexbuf = Lexing.from_channel stdin in
let ast = Parser.program Scanner.token lexbuf in
print_string (Ast.string_of_program ast)
