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

let string_split v s =
	let b = ref 0 in
	let e = String.length s in
	let vlen = String.length v in
	let lastmatch = ref 0 in
	if vlen >= e then
		[s]
	else
		let slist = ref [] in
		let add_sub start len =
			let fresh = ( String.sub s start len ) in 
			slist := fresh :: !slist;
			lastmatch := start + len + vlen;
			b := !lastmatch;
		in
		while (!b < e) do
			if s.[!b] <> v.[0] then
				b := 1 + !b
			else 
				let start = !b in
				let currb = ref (1 + start) in
				let found = ref true in
				for vb = 1 to (vlen - 1) do
					found := !found && ( s.[!currb] = v.[vb] );
					currb := !currb + 1
				done;
				let len = start - !lastmatch in
				if !found then (add_sub !lastmatch len)
		done;
		if !lastmatch < e then
			add_sub !lastmatch (e - !lastmatch);

		(* Return complete split list *)
		List.rev !slist
