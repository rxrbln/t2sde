#define _GNU_SOURCE
#include <fenv.h>
#include <stdio.h>

int main(void) {
    fedisableexcept(FE_INVALID | FE_DIVBYZERO /*| FE_OVERFLOW  | FE_UNDERFLOW*/);
    float a = 1., b = 0.;
    float c = a/b;
    printf("Exiting normally.\n"); 
    return (int)c;
}
