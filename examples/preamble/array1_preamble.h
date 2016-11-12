#pragma once
// -- ARRAY 1 PREAMBLE
#include "memory_preamble.h"
#include "bounds1_preamble.h"
#include <stddef.h>

struct lepix_array_n1_;

typedef struct lepix_array_n1_ lepix_array_n1;
typedef lepix_array_n1 lepix_array_n1_owner;

struct lepix_array_n1_ {
	unsigned char* memory;
	ptrdiff_t dimensions[1];
};
