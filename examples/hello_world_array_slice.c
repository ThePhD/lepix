#include "preamble/array1_preamble.h"
#include "preamble/array2_preamble.h"
#include "preamble/lib_preamble.h"

// fun main() : int {
int main() {
	// var x : int[[]] = [[11], [22], [44], [88]];
	lepix_array_n2_owner x = {
		(unsigned char*)malloc(4 * 1 * sizeof(int)),
		{ 1, 4 }
	};
	// var y : int[] = x[3];
	lepix_array_n1_owner y = {
		(unsigned char*)malloc(1 * sizeof(int)),
		{ 1 }
	};
	// var z : int = x[0, 3];
	int z = *(int*)&x.memory[(3 * x.dimensions[0] + 0) * sizeof(int)];
	// lib.print(y[0] + z);
	printf("%d", y.memory[0 * sizeof(int)] + z);
	// }
	{
		free(x.memory);
		free(y.memory);
	}
	return 0;
}
