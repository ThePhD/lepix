#include "preamble/array2_preamble.h"

// fun main() : int {
int main () {
	// var a : int = 24 * 2 + 1;
	// a == 49
	int a = 24 * 2 + 1;
	// var b : int = a % 8;
	// b == 1
	int b = a % 8;
	// var c : int[[6, 2]] = [
	// 	0, 2, 4, 6, 8, 10;
	// 	1, 3, 5, 7, 9, 11;
	// ];
	lepix_array_n2_owner c = {
		(unsigned char*)malloc(6 * 2 * sizeof(int)),
		{ 6, 2 }
	};
	{
		int* c_fill = (int*)c.memory;
		c_fill[0] = 0; c_fill[1] = 2; c_fill[2] = 4; c_fill[3] = 6; c_fill[4] = 8; c_fill[5] = 10;
		c_fill[6] = 1; c_fill[7] = 3; c_fill[8] = 5; c_fill[9] = 7; c_fill[10] = 9; c_fill[11] = 11;
	}

	//var value : int = a + b + c[0, 4];
	int value = a + b + c.memory[(0 * c.dimensions[0] + 4) * sizeof(int)];
	// value == 58
	// return value;
	{
		free(c.memory);
	}
	return value;
//}
}
