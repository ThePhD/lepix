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

(* A listing of exceptions and the methods that power them
to make the parser more expressive *)

(* Driver and Related class of errors *)
let option_error_exit_code = 1

(* Option Errors *)
exception NoOption
exception BadOption of string
exception MissingOption of string
exception OptionFileNotFound of string

(* Compiler class of Errors *)
let compiler_error_exit_code = 2
(* Lexer Errors *)
exception PreUnknownCharacter of string * ( Lexing.position * Lexing.position )
exception UnknownCharacter of string * ( Lexing.position * Lexing.position )
exception BadNumericLiteral of string * ( Lexing.position * Lexing.position )

(* Parser Errors *)
exception MissingEoF
exception BadToken

(* Semantic and Codegen Errors *)
exception Unsupported of string
exception FunctionAlreadyExists of string
exception VariableAlreadyExists of string
exception IdentifierNotFound of string
exception TypeMismatch of string

exception UnknownVariable of string
exception UnknownFunction of string
exception BadPrintfArgument
exception BadFunctionCall of string
exception FunctionLookupFailure of string * string
exception VariableLookupFailure of string * string
exception InvalidMainSignature of string
exception InvalidFunctionSignature of string * string
exception InvalidBinaryOperation of string
exception InvalidUnaryOperation of string
