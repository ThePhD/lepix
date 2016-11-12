#pragma once
// -- ARRAY 3 PREAMBLE
#include "memory_preamble.h"
#include <stddef.h>

struct lepix_array_n3_;

typedef struct lepix_array_n3_ lepix_array_n3;
typedef lepix_array_n3 lepix_array_n3_owner;

struct lepix_array_n3_ {
	unsigned char* memory;
	ptrdiff_t dimensions[3];
};
