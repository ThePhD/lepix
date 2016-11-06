/* Adapted from https://computing.llnl.gov/tutorials/pthreads/ */

// not compile time constants?
// program that takes some number, allocate 2d array of that size
// what is hello world?

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

// arr[8][100], each thread sums rows eg arr[0][100] and arr[1][100]
#define NTHREADS 4
#define ARRAY_COLS 100
#define ARRAY_ROWS 8
#define ITERATIONS ARRAY_ROWS / NTHREADS

int sum = 0;
int arr[ARRAY_ROWS][ARRAY_COLS]; //do this dynamically 
pthread_mutex_t sum_mutex;


void* do_work(void* num) 
{
  int i, j, start, end;
  int* int_num;
  int local_sum = 0;

  /* Sum my part of the global array, keep local sum */
  int_num = (int *) num;
  start = *int_num * ITERATIONS;
  end = start + ITERATIONS;
  printf ("Thread %d summing arr[%d][%d] through arr[%d][%d]\n", *int_num, start, ARRAY_COLS, end-1, ARRAY_COLS); 
  for (i = start; i < end; i++) {
    for (j = 0; j < ARRAY_COLS; j++) {
      local_sum += arr[i][j];
    }
  }

  /* Lock the mutex and update the global sum, then exit */
  pthread_mutex_lock (&sum_mutex);
  sum = sum + local_sum;
  pthread_mutex_unlock (&sum_mutex);
  pthread_exit(NULL);
}


int main(int argc, char *argv[])
{
  int i, j;
  int start, thread_nums[NTHREADS];
  pthread_t threads[NTHREADS];
  pthread_attr_t attr;

  /* Initialize array */
  for (i = 0; i < ARRAY_ROWS; i++) {
    for (j = 0; j < ARRAY_COLS; j++) {
      arr[i][j] = i * 100 + j;
    }
  }

  /* Pthreads setup: initialize mutex and explicitly create threads in a
     joinable state (for portability).  Pass each thread its loop offset */
  pthread_mutex_init(&sum_mutex, NULL);
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  for (i = 0; i < NTHREADS; i++) {
    thread_nums[i] = i;
    pthread_create(&threads[i], &attr, do_work, (void *) &thread_nums[i]);
  }

  /* Wait for all threads to complete then print global sum */ 
  for (i = 0; i < NTHREADS; i++) {
    pthread_join(threads[i], NULL);
  }
  printf ("Threaded array sum = %d\n", sum);

  sum = 0;
  for (i = 0; i < ARRAY_ROWS; i++) { 
    for (j = 0; j < ARRAY_COLS; j++) {
      sum += arr[i][j];
    } 
  }
  printf("Loop array sum = %d\n", sum);

  /* Clean up and exit */
  pthread_attr_destroy(&attr);
  pthread_mutex_destroy(&sum_mutex);
  pthread_exit(NULL);
}
