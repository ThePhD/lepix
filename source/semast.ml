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

(* Semantic checking for the Lepix compiler that will produce a new 
SemanticProgram type with things like locals group into a single type 
and type promotions / conversions organized for operators. *)

module StringMap = Map.Make(String)

type symbol_table = ( Ast.type_name * bool ) StringMap.t

type s_expression = 
	| SExpression of Ast.type_name * Ast.expression

type s_locals =
	| SLocals of Ast.binding list

type s_block =
	| SBlock of s_locals * Ast.statement list

type s_parameters =
	| SParameters of Ast.binding list

type s_general_statement =
	| SExpressionStatement of s_expression
	| SVariableStatement of Ast.variable_definition

type s_capture =
	| ParallelCapture of Ast.binding list

type s_statement =
	| SGeneral of s_general_statement
	| SReturn of s_expression
	| SBreak of int
	| SContinue
	| SParallelBlock of Ast.parallel_expression list * s_capture * s_block
	| SAtomicBlock of s_block
	| SIfBlock of s_block * s_expression * s_block
	| SIfElseBlock of s_block * s_expression * s_block * s_block
	| SWhileBlock of s_block * s_expression * s_block
	| SForBlock of s_block * s_expression * s_block * s_statement list

type s_function_definition = Ast.qualified_id * s_parameters
	* Ast.type_name * s_block

type s_basic_definition = 	
	| SVariableDefinition of Ast.variable_definition
	| SFunctionDefinition of s_function_definition

type s_struct_definition = Ast.struct_type * s_basic_definition list

type s_definition = 
	| SBasic of s_basic_definition
	| SStructure of s_struct_definition * symbol_table
	| SNamespace of Ast.qualified_id * s_definition list

type s_program = symbol_table * s_definition list
