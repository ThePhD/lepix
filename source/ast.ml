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

type binary_op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq 
	| And | Or

type prefix_unary_op = 
	| Neg | Not

type builtin_type = 
	| Float 
	| Int 
	| Bool
	| String 
	| Void 
	| Array of builtin_type * int
	| Reference of builtin_type

type bind = string * builtin_type * bool

type name = string
type qualified_id = string list

type expr =
	| BoolLit of bool
	| IntLit of int
	| StringLit of string
	| FloatLit of float
	| Id of qualified_id
	| Call of expr * expr list
	| Access of expr * expr list
	| MemberAccess of expr * name 
	| BinaryOp of expr * binary_op * expr
	| PrefixUnaryOp of prefix_unary_op * expr 
	| Assign of string list * expr   
	| ArrayLit of expr list
	| Noexpr

type variable_definition = 
	| VarBinding of bind * expr

type parallel_expr =
	| Invocations of expr
	| ThreadCount of expr

type stmt =
	| Expr of expr
	| Return of expr
	| If of expr * stmt list * stmt list
	| For of expr * expr * expr * stmt list
	| ForBy of expr * expr * expr * stmt list
	| While of expr * stmt list 
	| Break of int
	| Continue
	| Var of variable_definition
	| Parallel of parallel_expr list * stmt list
	| Atomic of stmt list

type function_definition = {
	func_name : string;
	func_parameters : bind list;
	func_return_type : builtin_type;
	func_body : stmt list; 
}

type definition =
	| FuncDef of function_definition
	| VarDef of variable_definition
	| NamespaceDef of string list * definition list

type program = definition list
