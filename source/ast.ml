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

(* Types and routines for the abstract syntax tree and 
representation of a LePiX program. *)

type id = string

type qualified_id = id list

type struct_type = 
	qualified_id (* Name *)

type builtin_type =
	| Void
	| Bool
	| Int of int
	| Float of int
	| String

type constness = bool
type referenceness = bool

type type_qualifier = constness * referenceness

let no_qualifiers = (false, false)

type type_name =
	| BuiltinType of builtin_type * type_qualifier
	| StructType of struct_type * type_qualifier
	| Array of type_name * int * type_qualifier
	| Function of type_name * type_name list * type_qualifier

type binding = id * type_name

type binary_op = Add | Sub | Mult | Div 
	| Equal | Neq | Less | Leq | Greater | Geq 
	| And | Or | Modulo

type prefix_op = 
	| Neg | Not

type literal =
	| BoolLit of bool
	| IntLit of int
	| FloatLit of float
	| StringLit of string

type expression =
	| Literal of literal
	| Id of id
	| Member of expression * qualified_id
	| Call of expression * expression list
	| Index of expression * expression list
	| Initializer of expression list
	| BinaryOp of expression * binary_op * expression
	| PrefixUnaryOp of prefix_op * expression
	| Assignment of expression * expression
	| NoOp

type parallel_expression =
	| Invocations of expression
	| ThreadCount of expression

type variable_definition = 
	| VarBinding of binding * expression
	| LetBinding of binding * expression

type general_statement =
	| ExpressionStatement of expression
	| VariableStatement of variable_definition

type control_initializer = general_statement list * general_statement

type statement = 
	| General of general_statement
	| Return of expression
	| Break of int
	| Continue
	| ParallelBlock of parallel_expression list * statement list
	| AtomicBlock of statement list
	| IfBlock of control_initializer * statement list
	| IfElseBlock of control_initializer * statement list * statement list
	| WhileBlock of control_initializer * statement list
	| ForBlock of general_statement list * expression * expression list * statement list
	| ForByToBlock of expression * expression * expression * statement list

type function_definition = 
	qualified_id (* Name *)
	* binding list (* Parameters *)
	* type_name (* Return Type *)
	* statement list (* Body *)

type basic_definition = 	
	| VariableDefinition of variable_definition
	| FunctionDefinition of function_definition

type struct_definition = struct_type * basic_definition list

type definition = 
	| Basic of basic_definition
	| Structure of struct_definition
	| Namespace of qualified_id * definition list

type program = definition list

(* Useful destructuring and common operations *)
let binding_type = function
	| (_, qt) -> qt

let binding_name = function
	| (n, _) -> n
