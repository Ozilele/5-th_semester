import math
import re
from lexrules import tokens, P
from field_solver import FieldSolver

P = 1234577
fs = FieldSolver(P)
exponent_fs = FieldSolver(P - 1)

tokens = tokens[:-3]
rpn = []
errorMessage = ''
# zero_div = False
precedence = (
    ('left', 'ADD', 'SUB'),
    ('left', 'MUL', 'DIV'),
    ('left', 'NEG'),
    ('right', 'POW')
)

def p_line_expression(p):
    'line : expression EOL'
    global rpn, errorMessage
    if errorMessage != '':
        print(''.join(rpn))
        print(errorMessage)
    else:
        print(''.join(rpn))
        print(f'Wynik: {p[1]}')
    rpn = []
    errorMessage = ''

def p_line_error(p):
    'line : error EOL'
    global rpn, errorMessage
    if errorMessage != '':
        print(errorMessage)

    rpn = []
    errorMessage = ''

def p_line_eol(p):
    'line : EOL'
    pass

def p_expression_num(p):
    'expression : NUM'
    global rpn, fs
    num = fs.convert_to_field_element(int(p[1]))
    rpn.append(f'{num} ')
    p[0] = num

def p_expression_add(p):
    'expression : expression ADD expression'
    global rpn, fs
    rpn.append('+ ')
    p[0] = fs.add(p[1], p[3])

def p_expression_sub(p):
    'expression : expression SUB expression'
    global rpn, fs
    rpn.append('- ')
    p[0] = fs.subtract(p[1], p[3])

def p_expression_mul(p):
    'expression : expression MUL expression'
    global rpn, fs
    rpn.append('* ')
    p[0] = fs.multiply(p[1], p[3])

def p_expression_div(p):
    'expression : expression DIV expression'
    global rpn, errorMessage, fs
    rpn.append('/ ')
    result = fs.divide(p[1], p[3])
    if result is None:
        errorMessage = f'ERROR: {p[3]} nie jest odwracalne w GF({P})'
        raise SyntaxError
    else:
        p[0] = result

def p_expression_neg(p):
    'expression : SUB expression %prec NEG'
    global rpn, fs
    opposite = fs.opposite(p[2])
    value_len = int(math.floor(math.log10(abs(p[2] % P)))) + 1
    dzialanie_len = sum(len(x) for x in rpn)

    if value_len >= dzialanie_len:
        rpn = []
    else:
        pattern = re.compile(f".*{'.' * (dzialanie_len - value_len)}")
        rpn = [re.sub(pattern, '', element) for element in rpn]
    # print(f"rpn to {rpn}")
    base = f"{opposite} "
    rpn.append(base)
    p[0] = fs.opposite(p[2])

def p_expression_pow(p):
    'expression : expression POW exponent'
    global rpn, fs
    p[0] = fs.power(p[1], p[3])
    rpn.append('^ ')

def p_expression_neg_parent(p):
    'expression : SUB L_BRA expression R_BRA'
    global rpn, fs
    rpn.append("- ")
    p[0] = P - p[3]

def p_expression_parent(p):
    'expression : L_BRA expression R_BRA'
    p[0] = p[2]


def p_exponent_num(p):
    'exponent : NUM'
    global rpn, exponent_fs
    num = exponent_fs.convert_to_field_element(int(p[1]))
    rpn.append(f'{num} ')
    p[0] = p[1] = num

def p_exponent_parent(p):
    'exponent : L_BRA exponent R_BRA'
    p[0] = p[2]

def p_exponent_add(p):
    'exponent : exponent ADD exponent'
    global rpn, exponent_fs
    rpn.append('+ ')
    p[0] = exponent_fs.add(p[1], p[3])

def p_exponent_sub(p):
    'exponent : exponent SUB exponent'
    global rpn, exponent_fs
    rpn.append('- ')
    p[0] = exponent_fs.subtract(p[1], p[3])

def p_exponent_mul(p):
    'exponent : exponent MUL exponent'
    global rpn, exponent_fs
    rpn.append('* ')
    p[0] = exponent_fs.multiply(p[1], p[3])

def p_exponent_div(p):
    'exponent : exponent DIV exponent'
    global rpn, errorMessage, exponent_fs
    rpn.append('/ ')
    result = exponent_fs.divide(p[1], p[3])
    if result is None:
        errorMessage = f'ERROR: {p[3]} nie jest odwracalne w GF({P-1})'
        raise SyntaxError
    else:
        p[0] = result

def p_exponent_neg(p):
    'exponent : SUB exponent %prec NEG'
    global rpn, exponent_fs
    rpn = rpn[:-1]
    rpn.append(str(exponent_fs.opposite(p[2])) + ' ')
    p[0] = exponent_fs.opposite(p[2])

def p_error(p):
    global rpn, errorMessage
    print('ERROR: Błąd składni')
    rpn = []
    errorMessage = ''

