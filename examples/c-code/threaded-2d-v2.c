/* Adapted from https://computing.llnl.gov/tutorials/pthreads/ */

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

// arr[8][100], each thread sums columns eg arr[0][0 to 25] through arr[8][0 to 25]
#define NTHREADS 4
#define ARRAY_COLS 100
#define ARRAY_ROWS 8
#define ITERATIONS_COLS ARRAY_COLS / NTHREADS

int sum = 0;
int arr[ARRAY_ROWS][ARRAY_COLS];
pthread_mutex_t sum_mutex;


void* do_work(void* num) 
{
  int i, j;
  int cols_start, cols_end;
  int* int_num;
  int local_sum = 0;

  /* Sum my part of the global array, keep local sum */
  int_num = (int *) num;
  cols_start = *int_num * ITERATIONS_COLS;
  cols_end = cols_start + ITERATIONS_COLS;
  printf ("Thread %d summing columns [%d] through [%d] from indices [%d] to [%d]\n", 
    *int_num, 0, ARRAY_ROWS-1, cols_start, cols_end-1); 
  for (i = 0; i < ARRAY_ROWS; i++) {
    for (j = cols_start; j < cols_end; j++) {
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

  /* Initialize array */
  for (i = 0; i < ARRAY_ROWS; i++) {
    for (j = 0; j < ARRAY_COLS; j++) {
      arr[i][j] = i * 100 + j;
    }
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
  for (i = 0; i < ARRAY_ROWS; i++) { 
    for (j = 0; j < ARRAY_COLS; j++) {
      sum += arr[i][j];
    } 
  }
  printf("Loop array sum = %d\n", sum);

  /* Clean up and exit */
  pthread_mutex_destroy(&sum_mutex);
  pthread_exit(NULL);
}
