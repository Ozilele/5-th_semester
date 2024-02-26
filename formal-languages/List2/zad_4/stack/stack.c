#include "stack.h"
#include <stdlib.h>
#include <stdio.h>

Stack* new_stack(int size) {
    Stack* stack = malloc(sizeof(Stack));
    stack->memory = malloc(sizeof(int) * size);
    stack->index = 0;
    stack->size = size;
    return stack;
}

void push(Stack* stack, int number) {
    stack->memory[stack->index++] = number;

    if (stack->index == stack->size) {
        stack->memory = realloc(stack->memory, stack->size*2);
        stack->size *= 2;
    }

}

int pop(Stack* stack, int* error) {
    if (stack->index == 0) {
        *error = 1;
        return -1;
    }

    int returnValue = stack->memory[--stack->index];

    if (stack->index < stack->size/4) {
        stack->memory = realloc(stack->memory, stack->size/2);
        stack->size /= 2;
    }

    return returnValue;
}