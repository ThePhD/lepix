#include "preamble/array1_preamble.h"
#include "preamble/lib_preamble.h"

// fun get_array() : int[] {
lepix_array_n1_owner get_array() {
	// return[11, 22, 44, 88];
	lepix_array_n1_owner ret = {
		(unsigned char*)malloc(4 * sizeof(int)),
		{ 4 }
	};
	{
		int* ret_fill = (int*)ret.memory;
		ret_fill[0] = 11; ret_fill[1] = 22; ret_fill[2] = 44; ret_fill[3] = 88;
	}
	return ret;
// }
}

//fun main() : int {
int main(int argc, char* argv[]) {
	
	// lib.print(get_array()[3]);
	{
		lepix_array_n1_owner tmp = get_array();
		printf("%d", *((int*)&tmp.memory[3 * sizeof(int)]));
		free(tmp.memory);
	}
// }
	return 0;
}
