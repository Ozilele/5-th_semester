from ply import lex, yacc

import lexrules
import yaccrules
import sys

def main():
    # with open(sys.stdin.fileno(), 'r', encoding='utf-8') as file:
    #     for line in file:
    #         print("Linia ze strumienia wejściowego:", line.strip())
    lexer = lex.lex(module=lexrules)
    parser = yacc.yacc(module=yaccrules)
    while True:
        text = ""
        while True:
            try:
                text += input()
            except EOFError:
                return
            text += '\n'
            if not text.endswith('\\\n'):
                break
        parser.parse(text, lexer=lexer)

main()