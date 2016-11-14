#include "preamble/array1_preamble.h"

// fun main() : int {
int main(int argc, char* arv[]) {
	// var x : int[] = [11, 22, 44, 88];
	lepix_array_n1_owner x = {
		(unsigned char*)malloc(4 * sizeof(int)),
		{ 4 }
	};
	{
		int* x_fill = (int*)x.memory;
		x_fill[0] = 11; x_fill[1] = 22; x_fill[2] = 44; x_fill[3] = 88;
	}
	// lib.print(x[3]);
	printf("%d", *((int*)&x.memory[3 * sizeof(int)]));
// }
	{
		free(x.memory);
	}
	return 0;
}
