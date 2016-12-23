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

type s_prefix_op = Ast.prefix_op
type s_binary_op = Ast.binary_op
type s_qualified_id = Ast.qualified_id
type s_id = Ast.id
type s_type_qualifier = Ast.type_qualifier
type s_builtin_type = Ast.builtin_type

type s_type_name =
	| SBuiltinType of s_builtin_type * s_type_qualifier
	| SArray of s_type_name * int * s_type_qualifier
	| SSizedArray of s_type_name * int * int list * s_type_qualifier
	| SFunction of s_type_name * s_type_name list * s_type_qualifier
	| SOverloads of s_type_name list
	| SAlias of s_qualified_id * s_qualified_id

let no_qualifiers = Ast.no_qualifiers

let void_t = SBuiltinType(Ast.Void, Ast.no_qualifiers)
let auto_t = SBuiltinType(Ast.Auto, Ast.no_qualifiers)
let string_t = SBuiltinType(Ast.String, Ast.no_qualifiers)
let bool_t = SBuiltinType(Ast.Bool, Ast.no_qualifiers)
let int32_t = SBuiltinType(Ast.Int(32), Ast.no_qualifiers)
let int64_t = SBuiltinType(Ast.Int(64), Ast.no_qualifiers)
let float64_t = SBuiltinType(Ast.Float(64), Ast.no_qualifiers)

type s_binding = s_id * s_type_name

type s_literal = 
	| SBoolLit of bool
	| SIntLit of int
	| SInt64Lit of int64
	| SFloatLit of float
	| SStringLit of string

type s_expression = 
	| SObjectInitializer of s_expression list * s_type_name
	| SArrayInitializer of s_expression list * s_type_name
	| SLiteral of s_literal
	| SQualifiedId of s_qualified_id * s_type_name
	| SMember of s_expression * s_qualified_id * s_type_name
	| SCall of s_expression * s_expression list * s_type_name
	| SIndex of s_expression * s_expression list * s_type_name
	| SBinaryOp of s_expression * s_binary_op * s_expression * s_type_name
	| SPrefixUnaryOp of s_prefix_op * s_expression * s_type_name
	| SAssignment of s_expression * s_expression * s_type_name
	| SNoop

type s_locals =
	| SLocals of s_binding list

type s_parameters =
	| SParameters of s_binding list

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

	| SParallelBlock of s_parallel_expression list (* Invocation parameters passed to kickoff function *)
		* s_capture (* Capture list: references to outside variables *)
		* s_statement (* Locals and their statements *)

	| SAtomicBlock of s_statement (* code in the atomic block *)


type s_function_definition = {
	func_name : s_qualified_id;
	func_parameters : s_parameters;
     func_return_type : s_type_name;
	func_body : s_statement list;
}

type s_basic_definition = 
	| SVariableDefinition of s_variable_definition
	| SFunctionDefinition of s_function_definition

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

type s_attributes = {
     attr_parallelism : bool;
	attr_arrays : int;
	attr_strings : bool;
}

type s_environment = {
	env_usings : string list;
	env_symbols : s_type_name StringMap.t;
	env_definitions : s_type_name StringMap.t;
	env_imports : s_module list;
	env_loops : s_loop list;
}

type s_program = 
	| SProgram of s_attributes * s_environment * s_definition list

(* Helping functions *)
let rec coerce_type_name_of_s_expression injected = function
	| SObjectInitializer(a, _) -> SObjectInitializer(a, injected)
	| SArrayInitializer(a, _) -> SArrayInitializer(a, injected)
	| SQualifiedId(a, _) -> SQualifiedId(a, injected)
	| SMember(a, b, _) -> SMember(a, b, injected)
	| SCall(a, b, _) -> SCall(a, b, injected)
	| SIndex(a, b, _) -> SIndex(a, b, injected)
	| SBinaryOp(a, b, c, _) -> SBinaryOp(a, b, c, injected)
	| SPrefixUnaryOp(a, b, _) -> SPrefixUnaryOp(a, b, injected)
	| SAssignment(a, b, _) -> SAssignment(a, b, injected)
	| e -> e

let unqualify = function
	| SBuiltinType(bt, _) -> SBuiltinType(bt, no_qualifiers)
	| SArray(tn, d, _) -> SArray(tn, d, no_qualifiers)
	| SSizedArray(tn, d, il, _) -> SSizedArray(tn, d, il, no_qualifiers)
	| SFunction(tn, pl, _) -> SFunction(tn, pl, no_qualifiers)
	| t -> t

let string_of_qualified_id qid =
	( String.concat "." qid )

let parameter_bindings = function
	| SParameters( bl ) -> bl

let type_name_of_s_literal = function
	| SBoolLit(_) -> bool_t
	| SIntLit(_) -> int32_t
	| SInt64Lit(_) -> int64_t
	| SFloatLit(_) -> float64_t
	| SStringLit(_) -> string_t

let rec type_name_of_s_expression = function
	| SObjectInitializer(_, t) -> t
	| SArrayInitializer(_, t) -> t
	| SLiteral(lit) -> type_name_of_s_literal lit
	| SQualifiedId(_, t) -> t
	| SMember(_, _, t) -> t
	| SCall(_, _, t) -> t
	| SIndex(_, _, t) -> t
	| SBinaryOp(_, _, _, t) -> t
	| SPrefixUnaryOp(_, _, t) -> t
	| SAssignment(_, _, t) -> t
	| SNoop -> void_t

let rec return_type_name = function
	| SFunction(rt,_, _) -> rt
	| t -> t 

let mangled_name_of_type_qualifier = function
	| (_, referencess) -> if referencess then "p!" else "!"

let type_name_of_s_function_definition fdef =
	let bl = parameter_bindings fdef.func_parameters in
	let argst = List.map ( fun (_, t) -> t ) bl in
	let rt = fdef.func_return_type in
	SFunction( rt, argst, no_qualifiers )

let mangled_name_of_builtin_type = function
	| Ast.Void -> "v"
	| Ast.Auto -> "a"
	| Ast.Bool -> "b"
	| Ast.Int(n) -> "i" ^ string_of_int n
	| Ast.Float(n) -> "f" ^ string_of_int n
	| Ast.String -> "s"
	| Ast.Memory -> "m"

let rec mangled_name_of_s_type_name = function
	| SBuiltinType( bt, tq ) -> mangled_name_of_type_qualifier tq ^ mangled_name_of_builtin_type bt
	| SArray( tn, dims, tq ) -> mangled_name_of_type_qualifier tq ^ "a" ^ string_of_int dims ^ ";" ^ mangled_name_of_s_type_name tn
	| SSizedArray( tn, dims, sizes, tq ) -> mangled_name_of_type_qualifier tq ^ "a" ^ string_of_int dims ^ ";" ^ mangled_name_of_s_type_name tn
	| SFunction( rt, pl, tq ) -> mangled_name_of_type_qualifier tq ^ "r;" ^ ( String.concat ";" ( List.map mangled_name_of_s_type_name pl ) ) ^ ";" ^ mangled_name_of_s_type_name rt
	| _ -> "UNSUPPORTED"

let mangle_name_args qid tnl =
	string_of_qualified_id qid ^ 
	if ( List.length tnl ) > 0 then
		"_" ^ ( String.concat "_" ( List.map mangled_name_of_s_type_name tnl ) )
	else
		""
let mangle_name qid = function
	| SFunction(rt, pl, tq) -> mangle_name_args qid pl
	| _ -> string_of_qualified_id qid
