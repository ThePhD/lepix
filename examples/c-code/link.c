#include <dlfcn.h>
#include <stdio.h>

int main() {
	typedef int(func_t)();
	void* libexternal = dlopen("./libexternal.so", RTLD_NOW | RTLD_GLOBAL);
	func_t* ext_func;
	*(void **)(&ext_func) = dlsym(libexternal, "ext_func");
	int v = ext_func();
	dlclose(libexternal);
	return 0;
}
