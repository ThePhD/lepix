// -- PREAMBLE
// -- ARRAY PREAMBLE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct {
	unsigned char* memory;
	ptrdiff_t dimensions[1];
} lepix_array_n1_;

// -- SIGNIFIES OWNERSHIP IN C: COMPILER HOLDS THIS INFORMATION
// -- SANITY TAG MOSTLY
typedef struct {
	unsigned char* memory;
	ptrdiff_t dimensions[1];
} lepix_array_n1_owner_;

typedef struct {
	unsigned char* memory;
	ptrdiff_t dimensions[2];
} lepix_array_n2_;

// -- SIGNIFIES OWNERSHIP IN C: COMPILER HOLDS THIS INFORMATION
// -- MENTAL TAG MOSTLY
typedef struct {
	unsigned char* memory;
	ptrdiff_t dimensions[2];
} lepix_array_n2_owner_;

// -- PARALLEL PREAMBLE
typedef struct {
	// -- TRANSFER VARIABLES IN WELL-DEFINED MEMORY ORDERING
	ptrdiff_t work_index;
	ptrdiff_t work_count;	
	pthread_mutex_t work_mutex;
	void (* work)(lepix_thread_handle_* thread, lepix_parallel_transfer_* pt);
	void** local_variables; // -- ONE POINTER PER LOCAL
	ptrdiff_t local_variables_size; // -- NUMBER OF LOCALS BUT REALLY NOT NEEDED EXCEPT MAYBE SANITY
} lepix_parallel_transfer_;

typedef struct {
	pthread_t thread;
	pthread_attr_t attributes;
	pthread_cond_t wait;
	pthread_mutex_t wait_mutex;
	ptrdiff_t index;
	lepix_parallel_transfer_* data;
} lepix_thread_handle_;

typedef struct {
	lepix_thread_handle_ threads;
	ptrdiff_t threads_size;
} lepix_thread_pool_;

ptrdiff_t lepix_hardware_concurrency_ () {
	return 4; // -- TODO: REPLACE WITH LOGIC FOR VARIOUS PLATFORMS
}

ptrdiff_t lepix_concurrency_multiplicity_ () {
	return 1; // -- TODO: REPLACE WITH LOGIC FOR VARIOUS CORES (MAYBE IF WE GET PAID LOL)
}

void lepix_thread_work_spin_(void* h) {
	lepix_thread_handle_* handle = (lepix_thread_handle_*)h;
	pthread_mutex_lock(&handle->wait_mutex);
	while (true) {
     	pthread_cond_wait(&handle->wait, &handle->wait_mutex);
     	if (handle.data == 0x00000001) {
     		// -- TODO: BETTER SIGNALING
     		break;
     	}
     	handle->work(handle, handle.data)
	}
     pthread_mutex_unlock(&handle->wait_mutex);
}

void lepix_create_pool_(lepix_thread_pool_* p) {
	p->threads_size = lepix_hardware_concurrency_() * lepix_concurrency_multiplicity_();
	p->threads = malloc(sizeof(lepix_thread_handle_) * p->threads_size);
	for (int i = 0; i < p->threads_size; ++i) {
		pthread_t* t = &p->threads[i].thread;
		pthread_attr_t* attr = &p->threads[i].attributes;
		pthread_mutex_t* waitmutex = &p->threads[i].wait_mutex;
		pthread_cond_t* wait = &p->threads[i].wait;
		pthread_condattr_t* waitattr = &p->threads[i].wait_attributes;

		pthread_attr_init(attr);
		pthread_attr_setdetachstate(attr, PTHREAD_CREATE_JOINABLE);

		pthread_condattr_init(waitattr);
		pthread_mutex_init(waitmutex, waitattr);

		pthread_cond_init()
		pthread_create(t, attr, &lepix_thread_work_spin_, (void*)&p->threads[i]);
	}
}

void lepix_launch_parallel_work_(lepix_thread_pool_* pool, void** locals, ptrdiff_t locals_size) {
		// -- TODO: SMARTER SELECTION OF TARGET ARRAYS
		int local_work_count = lepix_hardware_concurrency_();
		pthread_mutex_t* local_work_lock_list = malloc(sizeof(pthread_mutex_t*) * local_work_count)
		pthread_cond_t* local_work_wait_list = malloc(sizeof(pthread_cond_t*) * local_work_count)
		lepix_parallel_transfer_ pt_list = malloc(sizeof(lepix_parallel_transfer_) * local_work_count);
		for (int i = 0; i < local_work_count; ++i) {
			lepix_thread_handle_* handle = &pool->threads[i];
			lepix_parallel_transfer_* pt = &pt_list[i];
			*pt = lepix_parallel_transfer_{
				i,
				local_work_count,
				locals,
				locals_size,
				{}
			};
			pthread_mutex_init(pt.work_mutex, NULL);
			pthread_mutex_lock(pt.work_mutex);
			local_work_lock_list[i] = pt->mutex;
			local_work_wait_list[i] = handle->wait;
			handle->data = pt;
			pthread_cond_signal(&handle->wait);
		}
		for (int i = 0; i < local_work_count; ++i) {
			pthread_cond_wait(&local_work_wait_list[i], &local_work_lock_list[i]);
			pthread_mutex_unlock(&local_work_lock_list[i]);
		}
		free(local_work_lock_list);
		free(local_work_wait_list);
		free(pt_list);
}

void lepix_destroy_pool_(lepix_thread_pool_* pool) {
	for (i = 0; i < pool.thread_size; i++) {
		pthread_join(&pool->threads[i], NULL);
	}

	for (int i = 0; i < pool->threads_size; ++i) {
		pthread_t* t = &p->threads[i].thread;
		pthread_attr_t* attr = &pool->threads[i].attributes;
		pthread_mutex_t* waitmutex = &pool->threads[i].wait_mutex;
		pthread_cond_t* wait = &pool->threads[i].wait;
		pthread_condattr_t* waitattr = &pool->threads[i].wait_attributes;

		pthread_condattr_destroy(waitattr);
		pthread_cond_destroy(wait);
		pthread_mutex_destroy(waitmutex);

		pthread_attr_destroy(attr);
		// -- ALL THREADS SHOULD HAVE EXITED WITH STATUS BY NOW
	}
}

// -- END PREAMBLE

// -- BEGIN PROGRAM TEXT

// -- PARALLEL BLOCK DETECTED: DUMP CONTENTS HERE
// -- lepix_parallel_{SCOPE-NAME}_{COMPILER-UNIQUE-INCREMENTAL-ID}
// -- BEGIN PARALLEL BLOCK lepix_parallel_main_0
void lepix_parallel_main_0 (lepix_thread_handle_* thread, lepix_parallel_transfer_* pt) {
	// -- DUPLICATE SCOPE'S LOCAL VARIABLES
	lepix_array_n2_* values = (lepix_array_n2_*)pt->local_variables[0];
	int* sum = (int*)pt->local_variables[1];
	// -- USE LOCALLY DEFINED COMPILER VARIABLES TO REPLACE "lang." IDENTIFIERS
	int lepix_thread_count_ = pt->work_count;
	int lepix_thread_index_ = pt->work_index;
	
	// var outersize: int = values.bounds[0] + ( values.bounds[0] % lang.thread_count ) / lang.thread_count;
	int outersize = values->dimensions[0] + ( values->dimensions[0] % lepix_thread_count_ ) / lepix_thread_count_;
	// for (var outer : int = 0 to outersize) {
	for (int outer = 0; outer < outersize; ++outer) {
		// slice
		// var inner : int[] = values[outer];
		lepix_array_n1_ inner {
			&values->memory[ outer * values->dimensions[0] * sizeof(int)],
			{ values->dimensions[0] }
		};
		//var localsum : int = 0;
		int localsum = 0;
		
		//for (var i : int = 0 to inner.size()) {
		for (var i : int = 0 to inner->dimensions[0]) {
			//localsum = localsum + inner[i];
			localsum = localsum + inner.memory[i * sizeof(int)];
		}
		//}
		
		// atomic {
		// -- BEGIN SYNCHRONIZED BLOCK
		{
			pthread_mutex_lock (&pt->work_mutex);
			sum = sum + local_sum;
			pthread_mutex_unlock (&pt->work_mutex);
		}
		// }
		// -- END SYNCHRONIZED BLOCK
	}
	// }
	pthread_exit(NULL);
}
// -- END PARALLEL BLOCK

// fun main () : int { -- SCOPE BEGIN
int main (int argc, char* argv[]) {
	// -- BEGIN PRE-MAIN
	// -- PARALLEL BLOCK DETECTED: GENERATING THREAD POOL
	lepix_thread_pool_ pool_;
	lepix_create_pool_(&pool);
	// -- END PRE-MEIN

	// var values : int [[]] = [ ... ];
	lepix_array_n2_owner_ values = {
		malloc(sizeof(int) * 2 * 4),
		{ 2, 4 }
	};

	// var int : sum = 0;
	int sum = 0;

	// parallel { 
	// -- BEGIN PARALLEL SCOPE
	{
		// -- 2 LOCAL VARIABLES IN ABOVE SCOPES
		// -- MUST BE TRANSFERRED WITH REST OF INFO
		void* local_bucket_[2] = { &values, &sum };
		lepix_launch_parallel_work_(pool_, local_bucket_, 2);
	// } 
	// -- END PARALLEL SCOPE
	}

// } 
	{ // -- SCOPE EXIT
		// -- PARALLEL INVOCATION DESTROY
		lepix_destroy_pool_(&pool_);
		// MEMORY DESTROY
		free(values.memory);
	}
}

// -- END PROGRAM TEXT