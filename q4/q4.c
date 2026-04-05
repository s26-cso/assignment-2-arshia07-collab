#include <stdio.h>
#include <dlfcn.h>

typedef int (*fptr)(int, int);

int main() {

    char op[6];
    int a, b;

    while (scanf("%s %d %d", op, &a, &b) == 3)  {

        char libraryname[20];
        sprintf(libraryname, "./lib%s.so", op);

        void* handle = dlopen(libraryname, RTLD_LAZY);

        if (handle == NULL) {
            printf("Error \n");
            continue;
        }

        fptr function = (fptr)dlsym(handle, op);

        if (function == NULL) {
            printf("Error \n");
            dlclose(handle);
            continue;
        }

        int result = function(a, b);

        printf("%d\n", result);

        dlclose(handle);
    }

    return 0;
}