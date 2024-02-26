%{
    #include <stdio.h>
    #include <stdlib.h>
    #ifndef STACK
    #define STACK

    char *error = "";
    typedef struct {
        int top;
        int size;
        int* items;
    } Stack;


    Stack* new_stack(int size);
    int size(Stack* stack);
    int isEmpty(Stack* stack);
    int isFull(Stack* stack);
    void push(Stack* stack, int number);
    int pop(Stack* stack);

#endif

Stack* new_stack(int size) {
    Stack* stack = malloc(sizeof(Stack));
    stack->size = size;
    stack->top = -1;
    stack->items = (int*)malloc(sizeof(int) * size);
    return stack;
}

int size(Stack *stack) {
    return stack->top + 1;
}

int isEmpty(Stack *stack) {
    return stack->top == -1;
}

int isFull(Stack *stack) {
    return stack->top == stack->size - 1;
}

void push(Stack* stack, int number) {
    if(isFull(stack)) {
        error = "stack overflow";
        return;
    }
    stack->items[++stack->top] = number;
}

int pop(Stack* stack) {
    if(isEmpty(stack)) {
        error = "Błąd: za mała liczba argumentow";
        return 0;
    }
    return stack->items[stack->top--];
}

    Stack* stack;

    int power(int base, unsigned int exponent) {
        int res = 1;
        for (int i = 0; i < exponent; i++) res *= base;
        return res;
    }

    int getResult() {
        if(size(stack) > 1) {
            error = "Błąd: za mała liczba operatorów";
            return 0;
        } else if(isEmpty(stack)) { // enter case - (stack is empty)
            error = "Błąd: za mała liczba argumentów";
            return 0;
        }
        return pop(stack);
    }

    int checkError() {
        if(strcmp(error, "")) return 1;
        else return 0;
    }
%}

%x ISERROR

%%

\-?[0-9]+       { push(stack, atoi(yytext)); if(checkError() == 1) BEGIN(ISERROR); }

\+ {
    int b = pop(stack);
    int a = pop(stack);
    push(stack, a + b);
    if(checkError() == 1) {
        BEGIN(ISERROR);
    }
}

\- {
    int b = pop(stack);
    int a = pop(stack); 
    push(stack, a - b);
    if(checkError() == 1) {
        BEGIN(ISERROR);
    }
}

\* {
    int b = pop(stack);
    int a = pop(stack);
    push(stack, a * b);
    if(checkError() == 1) {
        BEGIN(ISERROR);
    }
}

\/ {    
    int b = pop(stack);
    int a = pop(stack);
    if(b == 0) {
        error = "Błąd: dzielenie przez 0";
        // return;
    } else {
        push(stack, a / b); 
    }
    if(checkError() == 1) {
        BEGIN(ISERROR);
    }
}

\% {
    int b = pop(stack);
    int a = pop(stack);
    if(b == 0) {
        error = "Błąd: dzielenie przez 0";
        // return;
    } else {
        push(stack, a % b);
    }
    if(checkError() == 1) {
        BEGIN(ISERROR);
    }
}

\^ {
    int b = pop(stack);
    int a = pop(stack);
    if(a == 0) {
        push(stack, 1);
        // return;
    }
    int result = 1;
    for(int i = 0; i < b; i++) {
        result *= a;
    }
    push(stack, result);

    if(checkError() == 1) {
        BEGIN(ISERROR);
    }
}

\n {
    int result = getResult();
    if(checkError() == 1) {
        printf("%s\n", error);
    } else {
        printf("%d\n", result);
    }
    stack = new_stack(70);
    error = "";
}

" "         {} 
.           { printf("Błąd: zły symbol \".\""); BEGIN(ISERROR); }

<ISERROR>.    {}
<ISERROR>\n   {
    printf("%s\n", error); 
    stack = new_stack(70); 
    error = ""; 
    BEGIN(INITIAL);
}

%%

int yywrap() {}

int main() {
    stack = new_stack(70);
    yylex();
    return 0;
}


