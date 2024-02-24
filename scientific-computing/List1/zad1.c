#include <stdio.h>
#include <float.h>

int main() {
    printf("Machine epsilon of float = %.10e\n", FLT_EPSILON);
    printf("Machine epsilon of double = %.10e\n", DBL_EPSILON);
    printf("Maximum value of type float = %.10e\n", FLT_MAX);
    printf("Maximum value of type double = %.10e\n", DBL_MAX);
    return 0;
}