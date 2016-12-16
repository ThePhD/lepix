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

(* Semantic checking for the Lepix compiler that will produce a new 
SemanticProgram type with things like locals group into a single type 
and type promotions / conversions organized for operators. *)

module StringMap = Map.Make(String)

type s_literal = 
	| SBoolLit of bool
	| SIntLit of int
	| SInt64Lit of int64
	| SFloatLit of float
	| SStringLit of string

type s_expression = 
	| SObjectInitializer of s_expression list * Ast.type_name
	| SArrayInitializer of s_expression list * Ast.type_name
	| SLiteral of s_literal
	| SQualifiedId of Ast.qualified_id * Ast.type_name
	| SMember of s_expression * Ast.qualified_id * Ast.type_name
	| SCall of s_expression * s_expression list * Ast.type_name
	| SIndex of s_expression * s_expression list * Ast.type_name
	| SBinaryOp of s_expression * Ast.binary_op * s_expression * Ast.type_name
	| SPrefixUnaryOp of Ast.prefix_op * s_expression * Ast.type_name
	| SAssignment of s_expression * s_expression * Ast.type_name
	| SNoop

type s_binding = (Ast.id * Ast.type_name)

type s_locals =
	| SLocals of s_binding list

type s_parameters =
	| SParameters of Ast.binding list

type s_variable_definition =
	| SVarBinding of s_binding * s_expression

type s_general_statement =
	| SGeneralBlock of s_locals * s_general_statement list
	| SExpressionStatement of s_expression
	| SVariableStatement of s_variable_definition

type s_capture =
	| SParallelCapture of s_binding list

type s_control_initializer =
	| SControlInitializer of s_general_statement * s_expression

type s_parallel_expression =
	| SInvocations of s_expression
	| SThreadCount of s_expression

type s_statement =
	| SBlock of s_locals * s_statement list
	| SGeneral of s_general_statement
	| SReturn of s_expression
	| SBreak of int
	| SContinue

	| SParallelBlock of s_parallel_expression list (* Invocation parameters passed to kickoff function *)
		* s_capture (* Capture list: references to outside variables *)
		* s_statement (* Locals and their statements *)

	| SAtomicBlock of s_statement (* code in the atomic block *)

	| SIfBlock of s_control_initializer (* Init statements for an if block *)
		* s_statement (* If code *)

	| SIfElseBlock of s_control_initializer (* Init statements for an if-else block *)
		* s_statement (* If code *)
		* s_statement (* Else code *)

	| SWhileBlock of s_control_initializer (* Init statements plus ending conditional for a while loop *)
		* s_statement (* code inside the while block, locals and statements *)

	| SForBlock of s_control_initializer  (* Init statements plus ending conditional for a for loop *)
		* s_expression list (* Post-loop expressions (increment/decrement) *) 
		* s_statement (* Code inside *)

type s_function_definition = {
	func_name : Ast.qualified_id;
	func_parameters : s_parameters;
     func_return_type : Ast.type_name;
	func_body : s_statement list;
}

type s_basic_definition = 	
	| SVariableDefinition of s_variable_definition
	| SFunctionDefinition of s_function_definition

type s_struct_definition = {
	struct_name : Ast.struct_type;
	struct_variables : Ast.variable_definition list;
	struct_constructors : s_function_definition list;
	struct_destructors : s_function_definition list;
	struct_functions : s_function_definition list;
	struct_definitions : s_basic_definition list;
}

type s_builtin_library =
	| Lib

let builtin_library_names = [
	( "lib", Lib ) 
]

type s_loop =
	| SFor
	| SWhile

type s_module =
	| SCode of string
	| SDynamic of string
	| SBuiltin of s_builtin_library

type s_definition = 
	| SBasic of s_basic_definition
	| SStructure of s_struct_definition
	| SNamespace of Ast.qualified_id * s_definition list

type s_attributes = {
     attr_parallelism : bool;
	attr_arrays : bool;
}

type s_environment = {
	env_structs : ( s_struct_definition ) StringMap.t;
     env_symbols : Ast.type_name StringMap.t;
	env_types : Ast.qualified_id StringMap.t;
	env_imports : s_module list;
	env_loops : s_loop list;
}

type s_program = 
	| SProgram of s_attributes * s_environment * s_definition list
