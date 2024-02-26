#ifndef STACK
#define STACK

typedef struct {
    int* memory;
    int index;
    int size;
} Stack;


Stack* new_stack(int size);
void push(Stack* stack, int number);
int pop(Stack* stack, int* error);

#endif