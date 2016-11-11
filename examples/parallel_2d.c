// -- PREAMBLE
// -- ARRAY PREAMBLE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

struct lepix_array_n1_;
struct lepix_array_n2_;

typedef struct lepix_array_n1_ lepix_array_n1;
typedef struct lepix_array_n2_ lepix_array_n2;
typedef lepix_array_n1 lepix_array_n1_owner;
typedef lepix_array_n2 lepix_array_n2_owner;

struct lepix_array_n1_ {
	unsigned char* memory;
	ptrdiff_t dimensions[1];
};

struct lepix_array_n2_ {
	unsigned char* memory;
	ptrdiff_t dimensions[2];
} ;

// -- PARALLEL PREAMBLE
struct lepix_thread_handle_;
struct lepix_parallel_transfer_;
struct lepix_thread_pool_;

typedef struct lepix_parallel_transfer_ lepix_parallel_transfer;
typedef struct lepix_thread_handle_ lepix_thread_handle;
typedef struct lepix_thread_pool_ lepix_thread_pool;

typedef void (lepix_work_function)(lepix_parallel_transfer*, lepix_thread_handle*);

void* lepix_thread_work_spin_(void* h);

struct lepix_parallel_transfer_ {
	// -- TRANSFER VARIABLES IN WELL-DEFINED MEMORY ORDERING
	lepix_work_function* work;
	bool work_done;
	ptrdiff_t work_index;
	ptrdiff_t work_count;
	ptrdiff_t invocation_id;
	ptrdiff_t invocation_count;
	void** local_variables; // -- ONE POINTER PER LOCAL
	ptrdiff_t local_variables_size; // -- NUMBER OF LOCALS BUT REALLY NOT NEEDED EXCEPT MAYBE SANITY
	pthread_mutex_t work_lock;
	pthread_mutexattr_t work_lock_attributes;
};

void lepix_create_parallel_transfer_ (lepix_parallel_transfer* transfer, lepix_work_function* work, ptrdiff_t invocation_id, ptrdiff_t invocation_count, ptrdiff_t work_index, ptrdiff_t work_count, void** locals, ptrdiff_t locals_size) {
	transfer->work = work;
	transfer->work_done = false;
	transfer->work_index = work_index;
	transfer->work_count = work_count;
	transfer->invocation_id = invocation_id;
	transfer->invocation_count = invocation_count;
	transfer->local_variables = locals;
	transfer->local_variables_size = locals_size;
	pthread_mutexattr_init(&transfer->work_lock_attributes);
	pthread_mutex_init(&transfer->work_lock, &transfer->work_lock_attributes);
}

void lepix_parallel_transfer_dead_(lepix_parallel_transfer* transfer) {
	lepix_create_parallel_transfer_(transfer, NULL, 0, 0, 0, 0, NULL, 0);
}

struct lepix_thread_handle_ {
	pthread_t thread;
	pthread_attr_t attributes;

	// -- WAIT EVENT FOR WHEN WORK IS READY
	pthread_condattr_t ready_wait_attributes;
	pthread_cond_t ready_wait;
	pthread_mutexattr_t ready_wait_lock_attributes;
	pthread_mutex_t ready_wait_lock;

	// -- WAIT EVEN FOR WHEN WORK IS DONE
	pthread_condattr_t completed_wait_attributes;
	pthread_cond_t completed_wait;
	pthread_mutexattr_t completed_wait_lock_attributes;
	pthread_mutex_t completed_wait_lock;

	ptrdiff_t index;
	lepix_parallel_transfer* transfer;
};

struct lepix_thread_pool_ {
	lepix_thread_handle* threads;
	ptrdiff_t threads_size;
};

ptrdiff_t lepix_hardware_concurrency_ () {
	return 2; // -- TODO: REPLACE WITH LOGIC FOR VARIOUS PLATFORMS
}

ptrdiff_t lepix_concurrency_multiplicity_ () {
	return 1; // -- TODO: REPLACE WITH LOGIC FOR VARIOUS CORES (MAYBE IF WE GET PAID LOL)
}

void lepix_create_pool_(lepix_thread_pool* pool) {
	pool->threads_size = lepix_hardware_concurrency_() * lepix_concurrency_multiplicity_();
	pool->threads = (lepix_thread_handle*)malloc(sizeof(lepix_thread_handle) * pool->threads_size);
	for (int i = 0; i < pool->threads_size; ++i) {
		lepix_thread_handle* handle = &pool->threads[i];
		handle->transfer = NULL;

		pthread_mutexattr_t* readywaitmutexattr = &handle->ready_wait_lock_attributes;
		pthread_condattr_t* readywaitattr = &handle->ready_wait_attributes;
		pthread_mutex_t* readywaitmutex = &handle->ready_wait_lock;
		pthread_cond_t* readywait = &handle->ready_wait;
		
		pthread_mutexattr_t* completedwaitmutexattr = &handle->completed_wait_lock_attributes;
		pthread_condattr_t* completedwaitattr = &handle->completed_wait_attributes;
		pthread_mutex_t* completedwaitmutex = &handle->completed_wait_lock;
		pthread_cond_t* completedwait = &handle->completed_wait;
		
		pthread_attr_t* attr = &handle->attributes;
		pthread_t* t = &handle->thread;
		
		pthread_attr_init(attr);
		pthread_attr_setdetachstate(attr, PTHREAD_CREATE_JOINABLE);

		pthread_condattr_init(readywaitattr);
		pthread_mutexattr_init(readywaitmutexattr);
		pthread_mutex_init(readywaitmutex, readywaitmutexattr);
		pthread_cond_init(readywait, readywaitattr);
		
		pthread_condattr_init(completedwaitattr);
		pthread_mutexattr_init(completedwaitmutexattr);
		pthread_mutex_init(completedwaitmutex, completedwaitmutexattr);
		pthread_cond_init(completedwait, completedwaitattr);

		pthread_create(t, attr, &lepix_thread_work_spin_, (void*)handle);
	}
}

void lepix_destroy_pool_(lepix_thread_pool* pool) {
	lepix_parallel_transfer* dead_transfers = (lepix_parallel_transfer*)malloc(sizeof(lepix_parallel_transfer) * pool->threads_size);
	for (int i = 0; i < pool->threads_size; i++) {
		lepix_thread_handle* handle = &pool->threads[i];
		lepix_parallel_transfer* dead_transfer = &dead_transfers[i];
		lepix_parallel_transfer_dead_(dead_transfer);
		pthread_t* t = &handle->thread;

		// Trigger event for "ready data" that has
		// NULL work, causing exit
		handle->transfer = dead_transfer;
		pthread_cond_signal(&handle->ready_wait);
		pthread_join(*t, NULL);
	}
	free(dead_transfers);

	for (int i = 0; i < pool->threads_size; ++i) {
		lepix_thread_handle* handle = &pool->threads[i];
		pthread_mutexattr_t* readywaitmutexattr = &handle->ready_wait_lock_attributes;
		pthread_condattr_t* readywaitattr = &handle->ready_wait_attributes;
		pthread_mutex_t* readywaitmutex = &handle->ready_wait_lock;
		pthread_cond_t* readywait = &handle->ready_wait;
		
		pthread_mutexattr_t* completedwaitmutexattr = &handle->completed_wait_lock_attributes;
		pthread_condattr_t* completedwaitattr = &handle->completed_wait_attributes;
		pthread_mutex_t* completedwaitmutex = &handle->completed_wait_lock;
		pthread_cond_t* completedwait = &handle->completed_wait;
		
		pthread_attr_t* attr = &handle->attributes;
		//pthread_t t = handle->thread;
		
		pthread_cond_destroy(readywait);
		pthread_mutex_destroy(readywaitmutex);
		pthread_mutexattr_destroy(readywaitmutexattr);
		pthread_condattr_destroy(readywaitattr);

		pthread_cond_destroy(completedwait);
		pthread_mutex_destroy(completedwaitmutex);
		pthread_mutexattr_destroy(completedwaitmutexattr);
		pthread_condattr_destroy(completedwaitattr);

		pthread_attr_destroy(attr);
		// -- ALL THREADS SHOULD HAVE EXITED WITH STATUS BY NOW
	}
}

void* lepix_thread_work_spin_(void* h) {
	lepix_thread_handle* handle = (lepix_thread_handle*)h;
	int result = 0;
	while (result == 0) {
		pthread_mutex_lock(&handle->ready_wait_lock);
		if (handle->transfer == NULL) {
			result = pthread_cond_wait(&handle->ready_wait, &handle->ready_wait_lock);
		}
		if (result != 0 || handle->transfer == NULL) {
			continue;
		}
		else if (handle->transfer->work == NULL) {
			// -- TODO: BETTER SIGNALING
			break;
		}
		lepix_parallel_transfer* transfer = handle->transfer;
		pthread_mutex_unlock(&handle->ready_wait_lock);

		// Perform work, and lock inside
		transfer->work(transfer, handle);
		
		pthread_mutex_lock(&handle->completed_wait_lock);
		handle->transfer = NULL;
		transfer->work_done = true;
		pthread_cond_signal(&handle->completed_wait);
		pthread_mutex_unlock(&handle->completed_wait_lock);
	}
	pthread_exit(NULL);
	return NULL;
}

void lepix_launch_parallel_work_(lepix_thread_pool* pool, lepix_work_function* func, ptrdiff_t invocations, void** locals, ptrdiff_t locals_size) {
	// -- TODO: SMARTER SELECTION OF TARGET ARRAYS
	typedef struct {
		pthread_mutex_t* completed_wait_lock;
		pthread_cond_t* completed_wait;
		lepix_parallel_transfer transfer;
	} local_work;
	int local_work_size = pool->threads_size;
	local_work* local_work_list = (local_work*)malloc(sizeof(local_work) * local_work_size);
	if (invocations == 0) {
		invocations = local_work_size;
	}
	for (ptrdiff_t inv = 0; inv < invocations;) {
		ptrdiff_t dispatched = 0;
		for (ptrdiff_t i = 0; i < local_work_size && inv < invocations; ++i, ++inv, ++dispatched) {
			lepix_thread_handle* handle = &pool->threads[i];
			local_work* work = &local_work_list[i];
			work->completed_wait_lock = &handle->completed_wait_lock;
			work->completed_wait = &handle->completed_wait;
			lepix_parallel_transfer* transfer = &work->transfer;

			lepix_create_parallel_transfer_(transfer, func, inv, invocations, i, local_work_size, locals, locals_size);

			pthread_mutex_lock(&handle->ready_wait_lock);
			handle->transfer = transfer;
			pthread_cond_signal(&handle->ready_wait);
			pthread_mutex_unlock(&handle->ready_wait_lock);
		}
		for (ptrdiff_t i = 0; i < dispatched; ++i) {
			local_work* work = &local_work_list[i];
			lepix_parallel_transfer* transfer = &work->transfer;
			pthread_mutex_lock(work->completed_wait_lock);
			if (transfer->work_done) {
				pthread_mutex_unlock(work->completed_wait_lock);
				continue;
			}
			pthread_cond_wait(work->completed_wait, work->completed_wait_lock);
			pthread_mutex_unlock(work->completed_wait_lock);
		}
	}
	free(local_work_list);
}

lepix_thread_pool pool_;

// -- BUILT-IN PREABLE
// -- MAPPING FUNCTION FOR THREAD INDICES
struct lepix_cursor_1_ {
	ptrdiff_t offset;
	ptrdiff_t size;
};

typedef struct lepix_cursor_1_ lepix_bounds1;

lepix_bounds1 lepix_lib_bounds_for_1(ptrdiff_t threadindex, ptrdiff_t threadcount, ptrdiff_t dimension) {
	lepix_bounds1 c;
	c.size = dimension / threadcount;
	if (c.size == 0) {
		c.size = dimension;
	}
	c.offset = c.size * threadindex;
	if (c.offset + c.size > dimension) {
		c.size = dimension - c.size;
	}
	return c;
}

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
		lepix_array_n1 inner = {
			&values->memory[ outer * values->dimensions[0] * sizeof(int)],
			{ values->dimensions[0] }
		};

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
		}
		// }
		// -- END SYNCHRONIZED BLOCK
	}
	// }
}
// -- END PARALLEL BLOCK

// fun main () : int { -- SCOPE BEGIN
int main (int argc, char* argv[]) {
	// -- MAIN SCOPE ENTER
	{
		// -- PARALLEL BLOCK DETECTED: GENERATING THREAD POOL
		lepix_create_pool_(&pool_);
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
		lepix_launch_parallel_work_(&pool_, &lepix_parallel_main_0, 0, local_bucket_, 2);
	// } 
	// -- END PARALLEL SCOPE
	}

	printf("%d", sum);

// } 
	// SCOPE EXIT
	{
		// MEMORY DESTROY
		free(values.memory);
	}
	// -- MAIN SCOPE EXIT
	{ 
		// -- PARALLEL INVOCATION DESTROY
		lepix_destroy_pool_(&pool_);
	}
}

// -- END PROGRAM TEXT