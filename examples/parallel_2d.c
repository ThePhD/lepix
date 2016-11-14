// -- PREAMBLE
// -- BEGIN PREABMLE

#include "preamble/array1_preamble.h"
#include "preamble/array2_preamble.h"
#include "preamble/parallel_preamble.h"
#include "preamble/lib_preamble.h"

// -- END PREAMBLE

// -- BEGIN PROGRAM TEXT

// -- PARALLEL BLOCK DETECTED: DUMP CONTENTS HERE
// -- lepix_parallel_{SCOPE-NAME}_{COMPILER-UNIQUE-INCREMENTAL-ID}
// -- BEGIN PARALLEL BLOCK lepix_parallel_main_0
void lepix_parallel_main_0 (lepix_parallel_transfer* transfer, lepix_thread_handle* thread) {
	// -- DUPLICATE SCOPE'S LOCAL VARIABLES
	lepix_array_n2* values = (lepix_array_n2*)transfer->local_variables[0];
	int* sum = (int*)transfer->local_variables[1];
	// -- USE LOCALLY DEFINED COMPILER VARIABLES TO REPLACE "lang." IDENTIFIERS
	int lepix_thread_count_ = transfer->work_count;
	int lepix_thread_index_ = transfer->work_index;
	
	// var outersize: int = values.bounds[0] + ( values.bounds[0] % lang.thread_count ) / lang.thread_count;
	lepix_bounds1 c = lepix_lib_bounds_for_1(lepix_thread_index_, lepix_thread_count_, values->dimensions[1]);
	// for (var outer : int = c.offset to c.offset + c.size) {
	for (int outer = c.offset; outer < c.offset + c.size; ++outer) {
		// slice
		// var inner : int[] = values[outer];
		lepix_array_n1_owner inner = {
			(unsigned char*)malloc(values->dimensions[0] * sizeof(int)),
			{ values->dimensions[0] }
		};
		memcpy(inner.memory, &values->memory[outer * values->dimensions[0] * sizeof(int)], inner.dimensions[0] * sizeof(int));
		//var localsum : int = 0;
		int localsum = 0;		
		//for (var i : int = 0 to inner.size()) {
		for (int i = 0; i < inner.dimensions[0]; ++i) {
			//localsum = localsum + inner[i];
			localsum = localsum + inner.memory[i * sizeof(int)];
		}
		//}
		
		// atomic {
		// -- BEGIN SYNCHRONIZED BLOCK
		{
			pthread_mutex_lock(&transfer->work_lock);
			*sum = *sum + localsum;
			pthread_mutex_unlock (&transfer->work_lock);
		// }
		}
		// -- END SYNCHRONIZED BLOCK
		{
			free(inner.memory);
		}
	}
	// }
}
// -- END PARALLEL BLOCK

// fun main () : int { -- SCOPE BEGIN
int main (int argc, char* argv[]) {
	// -- MAIN SCOPE ENTER
	{
		// -- PARALLEL BLOCK DETECTED: GENERATING THREAD POOL
		lepix_create_pool_(&lepix_pool_);
	}

	// var values : int [[]] = [ ... ];
	lepix_array_n2_owner values = {
		(unsigned char*)malloc(sizeof(int) * 2 * 4),
		{ 2, 4 }
	};
	{
		int* values_fill = (int*)values.memory;
		values_fill[0] = 0; values_fill[1] = 1; values_fill[2] = 2; values_fill[3] = 3; 
		values_fill[4] = 4; values_fill[5] = 5; values_fill[6] = 6; values_fill[7] = 7;
	}

	// var int : sum = 0;
	int sum = 0;

	// parallel { 
	// -- BEGIN PARALLEL SCOPE
	{
		// -- 2 LOCAL VARIABLES IN ABOVE SCOPES
		// -- MUST BE TRANSFERRED WITH REST OF INFO
		void* local_bucket_[2] = { &values, &sum };
		lepix_launch_parallel_work_(&lepix_pool_, &lepix_parallel_main_0, 0, local_bucket_, 2);
	// } 
	// -- END PARALLEL SCOPE
	}

// } 
	// SCOPE EXIT
	{
		// MEMORY DESTROY
		free(values.memory);
	}
	// -- MAIN SCOPE EXIT
	{ 
		// -- PARALLEL INVOCATION DESTROY
		lepix_destroy_pool_(&lepix_pool_);
	}

	return sum;
}

// -- END PROGRAM TEXT
