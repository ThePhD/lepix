// -- BUILT-IN PREABLE
// -- MAPPING FUNCTION FOR THREAD INDICES
#include <stddef.h>
#include <stdio.h>

struct lepix_bounds_1_ {
	ptrdiff_t offset;
	ptrdiff_t size;
};

typedef struct lepix_bounds_1_ lepix_bounds1;

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
