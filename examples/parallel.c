#include "preamble/parallel_preamble.h"

// -- BEGIN PROGRAM TEXT
// -- PARALLEL BLOCK DETECTED
void lepix_parallel_main_0(lepix_parallel_transfer* transfer, lepix_thread_handle* thread) {
	// -- LOCAL VARIABLES
	int* x = (int*)transfer->local_variables[0];

	//atomic {
	pthread_mutex_lock(&transfer->work_lock);
		//x = x + 1;
		*x = *x + 1;
	//}
	pthread_mutex_unlock(&transfer->work_lock);
}

// fun main() : int {
int main(int argc, char* arv[]) {
	{
		lepix_create_pool_(&lepix_pool_);
	}
	//var x : int = 0;
	int x = 0;
	//parallel(invocations = 2) {
	{
		void* locals[1] = { &x };
		lepix_launch_parallel_work_(&lepix_pool_, lepix_parallel_main_0, 2, locals, 1);
	}
	//}
	// x == 2
	{
		lepix_destroy_pool_(&lepix_pool_);
	}
	return x;
//}
}

// -- END PROGRAM TEXT
