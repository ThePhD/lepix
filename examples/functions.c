#include "preamble/array1_preamble.h"

// fun sum(arr : int[]) : int {
int sum (lepix_array_n1 arr_temp) {
	lepix_array_n1_owner arr = {
		(unsigned char*)malloc(arr_temp.dimensions[0] * sizeof(int)),
		{ arr_temp.dimensions[0] }
	};
	memcpy(arr.memory, arr_temp.memory, arr_temp.dimensions[0] * sizeof(int));
	// var sum : int = 0;
	int x = 0;
	// for (var i : int = 0; i < arr.size(); i += 1) {
	for (int i = 0; i < arr.dimensions[0]; ++i) {		
		// x += arr[i];
		x += *(int*)(&arr.memory[i * sizeof(int)]);
	// }
	}
	// return x;
	{
		free(arr.memory);
	}
	return x;
//}
}

//fun numbers() : int[] {
lepix_array_n1_owner numbers () {
// return[1, 2, 3];
	lepix_array_n1_owner tmp = {
		(unsigned char*)malloc(3 * sizeof(int)),
		{ 3 }
	};
	{
		int* tmp_fill = (int*)tmp.memory;
		tmp_fill[0] = 1; tmp_fill[1] = 2; tmp_fill[2] = 3;
	}
	return tmp;
// }
}

// fun main() : int {
int main(int argc, char* argv[]) {
//	return sum(numbers());
	lepix_array_n1_owner tmp1 = numbers();
	int tmp2 = sum(*((lepix_array_n1*)&tmp1));
	{
		free(tmp1.memory);
	}
	return tmp2;
}
