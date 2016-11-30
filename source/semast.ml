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

type id = string

type qualified_id = id list

type builtin_type =
	| Unit
	| Bool
	| Int of int
	| Float of int
	| String of string

type struct_type = 
	| Name of qualified_id

type type_name =
	| BuiltinType of builtin_type
	| StructType of struct_type
	| Array of type_name * int

type constness = bool
type referenceness = bool

type type_category = constness * referenceness

type qualified_type = type_name * type_category

type binding = qualified_type * id

type binary_op = Add | Sub | Mult | Div 
	| Equal | Neq | Less | Leq | Greater | Geq 
	| And | Or

type prefix_op = 
	| Neg | Not

type postfix_op =
	| Call
	| Indexing
	| Member

type literal =
	| BoolList of bool
	| IntLit of int
	| FloatLit of float
	| StringLit of string

type expression =
	| Literal of literal
	| PostfixOp of expression * postfix_op
	| BinaryOp of expression * binary_op * expression
	| PrefixOp of expression * prefix_op
	| Assignment of qualified_id * expression
	| NoOp

type parallel_expression =
	| Invocations of expression
	| ThreadCount of expression

type variable_definition = binding * expression

type general_statement =
	| ExpressionStatement of expression
	| VariableDefinition of variable_definition 

type control_initializer = general_statement list * expression

type statement = 
	| Basic of general_statement
	| Return of expression
	| ParallelBlock of parallel_expression list * statement list
	| AtomicBlock of statement list
	| IfBlock of control_initializer * statement list
	| IfElseBlock of control_initializer * statement list
	| WhileBlock of control_initializer * statement list
	| ForBlock
	| ForByBlock

type function_definition = qualified_id
	* binding list
	* qualified_type
	* binding list
	* statement list

type basic_definition = 	
	| Variables of variable_definition
	| Functions of function_definition

type struct_definition = struct_type * basic_definition list

type definition = 
	| Structure of struct_definition
	| Variable of variable_definition
	| Function of function_definition

type namespace_definition =
	| Definitions of definition list
	| Namespaces of namespace_definition list

type semantic_program = namespace_definition
 