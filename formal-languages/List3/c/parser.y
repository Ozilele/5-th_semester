%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <math.h>
  
  #define YYSTYPE int
  #define P 1234577

  extern int yylex();
  extern int yyparse();

  int yyerror(const char *s);
  int p_subtract(int x, int y, int p);
  int p_divide(long int x, int y, int p);

  int find_reverse(int a, int p);
  int findNWD(int x);
  int extended_euclidean(int a, int b, int *x, int *y);
  int p_exponentiation(long int base, int exponent); 
  int convertToFieldElement(int number, int p);
  void addToDzialanie(int a, int b);
  int opposite(int number, int p);

  char error_msg[1000];
  char dzialanie[1000];
  int open_parentheses_count = 0;
  int close_parentheses_count = 0;
  int count_minus = 0;
%}

%token NUM
%token ERR
%token TILDE
%left '+' '-'
%left '*' '/'
%left UMINUS
%left NEG
%nonassoc '^'

%%

input:  
    | input line
;

line: 
    expr '\n' { 
      printf("Wynik: %s\n", dzialanie);
      printf("= %d\n", $1);
      dzialanie[0] = '\0';
      count_minus = 0;
      $$ = 0;
      $1 = 0;
    }
    | expr '\\' {
      printf("Wynik %s\n", dzialanie);
      printf("= %d\n", $1);
      dzialanie[0] = '\0';
      $$ = 0;
      $1 = 0;
    }
    | error '\n' {
      if(strlen(error_msg) == 0) {
        strcat(error_msg, " składni.");
      }
      printf("Błąd %s\n", error_msg);
      strcpy(dzialanie, "");
      strcpy(error_msg, "");
    }
;
expr: 
    NUM {
      int result = convertToFieldElement($1, P);
      $$ = result;
      char base[20];
      snprintf(base, sizeof(base), "%d ", result); 
      strcat(dzialanie, base); 
    }
    | expr '+' expr                 { strcat(dzialanie, "+ "); $$ = ($1 + $3) % P; }
    | expr '-' expr                 { strcat(dzialanie, "- "); $$ = p_subtract($1, $3, P); }
    | expr '*' expr                 { strcat(dzialanie, "* "); $$ = ($1 * $3) % P; }
    | expr '/' expr                 { 
      int result = p_divide($1, $3, P);
      if(result != -1) {
        $$ = result;
      }
      else {
        sprintf(error_msg, "%d nie jest odwracalne modulo %d", $3, P);
        YYERROR;
      }
      strcat(dzialanie, "/ ");
    }
    | '-' expr %prec UMINUS {
      int opp = opposite($2, P);
      $$ = opp;
      int len = floor(log10(abs($2 % P))) + 1;
      size_t dzial_len = strlen(dzialanie);
      int i = (int)dzial_len - len - 1;
      while(i < (int)dzial_len) {
        dzialanie[i] = '\0';
        i++;
      }
      char base[20];
      snprintf(base, sizeof(base), "%d ", opp); 
      strcat(dzialanie, base);
    }
    | expr '^' exponent {
      int result = p_exponentiation($1, $3);
      $$ = result;
      strcat(dzialanie, "^ ");
    } 
    | '-' '(' expr ')'              { 
      strcat(dzialanie, "- "); 
      $$ = P - $3;
    }
    | '(' expr ')'                  { $$ = $2; }
;

exponent:
    NUM                         { 
      int result = convertToFieldElement($1, P - 1);
      $$ = result; 
      char base[20];
      snprintf(base, sizeof(base), "%d ", result); 
      strcat(dzialanie, base); 
    }
    | exponent '+' exponent  {
      strcat(dzialanie, "+ "); 
      $$ = ($1 + $3) % (P - 1);
    }
    | exponent '-' exponent {
      strcat(dzialanie, "- "); 
      $$ = p_subtract($1, $3, P - 1);
    }
    | exponent '*' exponent {
      strcat(dzialanie, "* "); 
      $$ = ($1 * $3) % (P - 1);
    }
    | exponent '/' exponent {
      int result = p_divide($1, $3, P - 1);
      if(result != -1) {
        $$ = result;
      }
      else {
        sprintf(error_msg, "%d nie jest odwracalne modulo %d", $3, P - 1);
        YYERROR;
      }
      strcat(dzialanie, "/ ");
    }
    | '-' exponent %prec UMINUS {
      int opp = opposite($2, P - 1);
      $$ = opp;
      int len = floor(log10(abs($2 % P))) + 1;
      size_t dzial_len = strlen(dzialanie);
      int i = (int)dzial_len - len - 1;
      while(i < (int)dzial_len) {
        dzialanie[i] = '\0';
        i++;
      }
      char base[20];
      snprintf(base, sizeof(base), "%d ", opp); 
      strcat(dzialanie, base);
    }
    | '(' exponent ')' { 
      $$ = $2; 
    }
;
%%


int opposite(int number, int p) {
  return (-number + p) % p; 
}

int convertToFieldElement(int number, int p) {
  while(number < 0) {
    number += p;
  }
  return number % p;
}

int p_subtract(int x, int y, int p) {
  int value = (x - y) % p;
  if(value < 0) {
    value += p;
  }
  return value;
}

// algorytm Euklidesa rozw ax + by = NWD(a, b)
int extended_euclidean(int a, int b, int *x, int *y) {
  if(a == 0) {
    *x = 0;
    *y = 1;
    return b;
  }
  int x1, y1;
  int d = extended_euclidean(b % a, a, &x1, &y1);
  *x = y1 - (b / a) * x1;
  *y = x1;
  return d;
}

void addToDzialanie(int a, int b) {
  char base[20];
  snprintf(base, sizeof(base), "%d ", a); 
  char newbase[20];
  snprintf(newbase, sizeof(newbase), "%d ", b); 
  strcat(dzialanie, base); 
  strcat(dzialanie, newbase);
}

int find_reverse(int a, int p) {
  int x, y;
  int d = extended_euclidean(a, p, &x, &y);
  if(d == 1) {
    return ((x % p) + p) % p;
  }
  return -1;
}

int findNWD(int x) {
  int tmp;
  int nwd = extended_euclidean(x, P, &tmp, &tmp);
  return (nwd == 1) ? tmp : -1;
}

int p_divide(long int x, int y, int p) {
  long int inv = find_reverse(y, p);
  if(inv == -1) {
    return -1;
  } else {
    return (int)((x * inv) % p);
  }
}

// skorzystanie z małego twierdzenia fermata, 1234577 jest liczbą pierwszą 
int p_exponentiation(long int base, int exponent) {
  if(exponent == 0) {
    return 1;
  }

  int reverse_base = findNWD(base);
  if(reverse_base == -1) {
    snprintf(error_msg, sizeof(error_msg), "Wartość %ld nie jest odwracalna modulo %d", base, P - 1); 
    return -1;
  }
  // rozkład wykładnika na postać binarną
  long int curr = p_exponentiation(base, exponent / 2);
  if(exponent % 2 == 0) {
    return (int)((curr * curr) % P);
  } else {
    return (int)((base * curr * curr) % P);
  }
}

int yyerror(const char *s) {
  return 0;
}

int main() {
  while(1) {
    yyparse();
  }
  return 0;
}