#pragma once
// -- ARRAY 2 PREAMBLE
#include "memory_preamble.h"
#include <stddef.h>

struct lepix_array_n2_;

typedef struct lepix_array_n2_ lepix_array_n2;
typedef lepix_array_n2 lepix_array_n2_owner;

struct lepix_array_n2_ {
	unsigned char* memory;
	ptrdiff_t dimensions[2];
};
