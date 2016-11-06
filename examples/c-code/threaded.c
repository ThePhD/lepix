/* Adapted from https://computing.llnl.gov/tutorials/pthreads/ */

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

// arr[100], each thread sums 25 elements
#define NTHREADS 4
#define ARRAY_SIZE 100
#define ITERATIONS ARRAY_SIZE / NTHREADS

int sum = 0;
int arr[ARRAY_SIZE];
pthread_mutex_t sum_mutex;


void* do_work(void* num) 
{
  int i, start, end;
  int* int_num;
  int local_sum = 0;

  /* Sum my part of the global array, keep local sum */
  int_num = (int *) num;
  start = *int_num * ITERATIONS;
  end = start + ITERATIONS;
  printf ("Thread %d doing iterations %d to %d\n", *int_num, start, end-1); 
  for (i = start; i < end; i++) {
    local_sum += arr[i];
  }

  /* Lock the mutex and update the global sum, then exit */
  pthread_mutex_lock (&sum_mutex);
  sum = sum + local_sum;
  pthread_mutex_unlock (&sum_mutex);
  pthread_exit(NULL);
}


int main(int argc, char *argv[])
{
  int i, start, thread_nums[NTHREADS];
  pthread_t threads[NTHREADS];

  /* Initialize array */
  for (i = 0; i < ARRAY_SIZE; i++) {
    arr[i] = i;
  }

  /* Pthreads setup: initialize mutex and explicitly create threads in a
     joinable state (for portability).  Pass each thread its loop offset */
  pthread_mutex_init(&sum_mutex, NULL);

  for (i = 0; i < NTHREADS; i++) {
    thread_nums[i] = i;
    pthread_create(&threads[i], NULL, do_work, (void *) &thread_nums[i]);
  }

  /* Wait for all threads to complete then print global sum */ 
  for (i = 0; i < NTHREADS; i++) {
    pthread_join(threads[i], NULL);
  }
  printf ("Threaded array sum = %d\n", sum);

  sum = 0;
  for (i = 0; i < ARRAY_SIZE; i++) { 
    sum += arr[i]; 
  }
  printf("Loop array sum = %d\n", sum);

  /* Clean up and exit */
  pthread_mutex_destroy(&sum_mutex);
  pthread_exit(NULL);
}
