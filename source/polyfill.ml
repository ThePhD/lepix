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

(* In Javascript, there's a concept called 'Polyfill'. It's the concept that
stuff that's missing can be filled over by libraries implemented by regular people
because the committee that oversees Javascript can't just decide to
make certain implementations and other things standard.

This is that thing, for OCrapml. *)

(* Algorithm *)
let foldi f value start_index len =
	let end_index = start_index + len - 1 in
	if start_index >= end_index then value else
	let accumulated = ref value 
	in
	for i = start_index to end_index do
		accumulated := ( f !accumulated i )
	done;
	!accumulated	

let foldi_to f value start_index end_index =
	foldi f value start_index (end_index - start_index)

(* Integer *)
let rec powi n = function
	| 0 -> 1
	| 1 -> n
	| x -> n * ( powi n  x - 1 )

let int_of_bool b = if b then 1 else 0

let int_of_string_base b s =
	let len = (String.length s) in
	let acc num i = let c = s.[i] in
		let v = if c >= '0' || c <= '9' then 
				int_of_char c - int_of_char '0'
			else
				if c >= 'A' || c <= 'Z' then
					int_of_char c - int_of_char 'A' + 10
				else 
					if c >= 'a' || c <= 'z' then 
						int_of_char c - int_of_char '0' + 10
					else 0
		and place = len - 1 - i
		in
		num + ( v * ( powi b place ) ) 
	in
	foldi acc 0 0 len

(* Num *)

exception BadBase of string
exception DigitGreaterThanBase of string

let num_of_string_base_part b s =
	if b > 36 || b < 1 then raise(BadBase "num_of_string_base: base cannot be greater than 36 or less than 1") else
	let n0 = Num.num_of_int 0 in
	let len = (String.length s) in
	if len < 1 then n0 else
	let (mid, starter) = try ( ( String.index s '.' ), 1 ) with _ -> (len - 1, 0)
	and nb = Num.num_of_int b
	in
	let acc (n, skipval) i = let c = s.[i] in
		if c = '.' then (n, skipval - 1) else
		let v = if c >= '0' && c <= '9' then 
				( int_of_char c ) - ( int_of_char '0' )
			else
				if c >= 'A' && c <= 'Z' then
					( int_of_char c ) - ( int_of_char 'A' ) + 10
				else 
					if c >= 'a' && c <= 'z' then 
						int_of_char c - ( int_of_char 'a' ) + 10
					else 0
		and place = mid - i - skipval
		in
		if v > b then raise(DigitGreaterThanBase ("num_of_string_base: digit '" ^ (String.make 1 c) ^ "' (" ^ (string_of_int v) ^ ") is higher than what base '" ^ (string_of_int b) ^ "' can handle")) else
		let nv = Num.num_of_int v
		and nplace = Num.num_of_int place 
		in
		(Num.add_num n ( Num.mult_num nv ( Num.power_num nb nplace ) ), skipval)
	in
	let (n, _) = foldi acc (n0, starter) 0 len in
	n

let num_of_string_base b s =
	num_of_string_base_part b s

let num_of_string s =
	let slen = String.length s in
	try
		let eidx = String.index s 'e' in
		if eidx < 1 then raise(Not_found);
		let eidxp1 = ( eidx + 1 ) in
		let nval = num_of_string_base_part 10 (String.sub s 0 eidx)
		and eval = if eidxp1 < slen then num_of_string_base_part 10 (String.sub s eidxp1 (slen - eidxp1)) else ( Num.num_of_int 0 )
		in
		Num.mult_num nval ( Num.power_num (Num.num_of_int 10) eval )
	with 
		| Not_found -> num_of_string_base_part 10 s

(* Char *)
let is_whitespace = function
	| ' ' -> true
	| '\t' -> true
	| '\n' -> true
	| '\r' -> true
	| _ -> false

(* String *)
let string_to_list s =
	let l = ref [] in
	let acc c =
		l := c :: !l; ()
	in
	String.iter acc s;
	List.rev !l

let iteri f start_index len =
	let end_index = start_index + len - 1 in
	if start_index < end_index then
		for i = start_index to end_index do
			( f i )
		done

type split_option =
	| RemoveDelimeter
	| KeepDelimeter

let string_split_with v s opt =
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
	let add_sub len slist start =
		if len < 1 then ( start, slist ) else
		let fresh = ( String.sub s start len ) 
		and last = start + len + vlen in
		begin match opt with
			| RemoveDelimeter -> ( last, fresh :: slist )
			| KeepDelimeter -> 
				let slist = v :: slist in
				( last, fresh :: slist )
		end
	in
	let acc (last, slist) start =
		if (start < last) then (last, slist) else
		if ( s.[start] = v.[0] ) then
			if (forward_search start) then 
				let len = start - last in
				(add_sub len slist last )
			else
				(last, slist) 
		else 
			if ( start = ( e - 1 ) ) then
				let len = e - last in
				(add_sub len slist last )			
			else
				(last, slist)
	in
	let (_, slist) = ( foldi acc (0, []) 0 e ) in
	(* Return complete split list *)
	List.rev slist

let string_starts_with str pre =
	let prelen = (String.length pre) in
	prelen <= (String.length str ) && pre = (String.sub str 0 prelen)

let string_split v s =
	string_split_with v s RemoveDelimeter
