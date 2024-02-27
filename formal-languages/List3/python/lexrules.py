P = 1234577

tokens = (
    'NUM',
    'ADD',
    'SUB',
    'MUL',
    'DIV',
    'POW',
    'L_BRA', 
    'R_BRA', 
    'EOL',
    'ERROR', 
    'COMMENT', 
    'BREAK_LINE' 
)

# 'ENDL',
#     'LPAREN',
#     'RPAREN',
#     'COMMENT',
#     'LINE_CONT',
#     'ERR',
# def t_NUM(t):
#     r'\d+'
#     t.value = int(t.value) % P
#     return t

t_NUM     = r'\d+'
t_ADD     = r'\+'
t_SUB     = r'[-]'
t_MUL     = r'\*'
t_DIV     = r'[/]'
t_POW     = r'\^'
t_L_BRA   = r'\('
t_R_BRA   = r'\)'
t_EOL     = r'\n'
t_ERROR   = r'.'

# t_ADD = r'\+'
# t_SUB = r'[-]'
# t_MUL = r'\*'
# t_DIV = r'[/]'
# t_POW = r'\^'
# t_ENDL = r'\n'
# t_LPAREN = r'\('
# t_RPAREN = r'\)'
# t_ERR = r'.'
t_ignore = ' \t'
t_ignore_COMMENT = r'^\#(.*\\\n)*.*$'
t_ignore_BREAK_LINE = r'\\\n'

def t_error(_):
    pass