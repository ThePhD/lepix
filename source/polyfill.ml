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

(* In Javascript, there's a concept called 'Polyfill'. It's the concept that
stuff that's missing can be filled over by libraries implemented by regular people
because the committee that oversees Javascript can't just decide to
make certain implementations and other things standard.

This is that thing, for OCrapml. *)

(* Integer *)
let int_of_bool b = if b then 1 else 0

(* String *)
let string_to_list s =
	let l = ref [] in
	let acc c =
		l := c :: !l; ()
	in
	String.iter acc s;
	List.rev !l

let foldi f value start_index len =
	let end_index = start_index + len - 1 in
	if start_index >= end_index then value else
	let accumulated = ref value 
	in
	for i = start_index to end_index do
		accumulated := ( f !accumulated i )
	done;
	!accumulated

let iteri f start_index len =
	let end_index = start_index + len - 1 in
	if start_index < end_index then
		for i = start_index to end_index do
			( f i )
		done

let string_split v s =
	let e = String.length s
	and vlen = String.length v 
	in 
	if vlen >= e then [s] else
	let forward_search start =
		let acc found idx =
			found && ( s.[start + idx] = v.[idx] )
		in
		foldi acc true 1 (vlen - 1)
	in
	let add_sub start len =
		let fresh = ( String.sub s start len ) in 
		slist := fresh :: !slist;
		start + len + vlen
	in
	let acc (b, slist, last) start =
		if (b < last) then (b, slist, last) else
		if ( s.[b] = v.[0] ) then
			let len = start - !lastmatch in
			if (forward_search b) then 
				(add_sub start len)
			else
				(1 + b, slist, last) 
		else 
			(1 + b, slist, last)
	in
	let (b, slist) = foldi acc (0, []) 0 e;
	(* Return complete split list *)
	List.rev slist
