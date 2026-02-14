#!/usr/bin/env python3

import re
import sys
from collections import namedtuple
import json
 
#whitespace and #: \w*|#.*
#Sentence: dL*			parser
#dL: lL|tL|mL|pL               	parser Include all Literals except primitive
#pL: int|atom|bool           	parser
#lL: \[ (dl, )* dl \]          	parser
#tL: \{ (dl, )* dl \}          	parser
#mL: \% \{ (kp, )* kp? \}       parser
#kP: dL => dL | keydL          	parser
#int: \d+(_*\d+)*            
#atom: :[_a-zA-Z][_0-9a-zA-Z]*
#key: [_a-zA-Z][_0-9a-zA-Z]*:
#bool: true|false

def parse(text):

    def peek(kind): return lookahead.kind == kind
    def consume(kind):
        nonlocal lookahead
        if (lookahead.kind == kind):
            lookahead = nextToken()
        else:
            print(f'expecting {kind} at {lookahead.lexeme}',
                  file=sys.stderr)
            sys.exit(1)
    def nextToken():
        nonlocal index
        if (index >= len(tokens)):
            return Token('EOF', '<EOF>')
        else:
            tok = tokens[index]
            index += 1
            return tok

    def sentence():
        asts = []
        while (not peek('EOF')):
            asts.append(dataLiteral())
        return asts
    def dataLiteral():
        if(peek('{')):
            consume('{')
            while()
                t = dataLiteral()
                consume(',')
            if()
                t1 = dataLiteral()
            #peek('}')
            consume('}')
            t = Ast(kind, t, t1)
        elif(peek('[')):
            consume('[')
            while()
                t = dataLiteral()
                consume(',')
            if()
                t1 = dataLiteral()
            #peek(']')
            consume(']')
            t = Ast(kind, t, t1)
        elif(peek('%')):
            consume('%')
            #peek('{')
            consume('{')
            while()
                t = keyPair()
                consume(',')
            if()
                t1 = keyPair()
            #peek('}')
            consume('}')
            t = Ast(kind, t, t1)
        else:
            t = primitiveLiteral()
        return t
    def keyPair()
        t = dataLiteral()
        if(peek('KEY')):
            t1 = dataLiteral()
            t = Ast(kind, t, t1)
        else:
            consume('=')
            consume('>')
            t1 = dataLiteral
            t = Ast(kind, t, t1)
        return t
    def primitiveLiteral()
        if(peek('BOOL')):
            value = bool(lookahead.lexeme)
            consume('BOOL')
            ast = Ast('BOOL')
            ast['value'] = value
        elif(peek('INT')):
            value = int(lookahead.lexeme)
            consume('INT')
            ast = Ast('INT')
            ast['value'] = value
        elif(peek('KEY')):
            value = lookahead.lexeme
            consume('KEY')
            ast = Ast('KEY')
            ast['value'] = value
        else:
            value = lookahead.lexeme
            consume('ATOM')
            ast = Ast('ATOM')
            ast['value'] = value

        
    

    #begin parse()
    tokens = scan(text)
    index = 0
    lookahead = nextToken()
    value = sentence()
    if (not peek('EOF')):
        print(f'expecting <EOF>, got {lookahead.lexeme}', file=sys.stderr)
        sys.exit(1)
    return value

def scan(text):
    SPACE_RE = re.compile(r'\s+|#.*')
    INT_RE = re.compile(r'\d+(_*\d+)*')
    ATOM_RE = re.compile(r':[_a-zA-Z][_0-9a-zA-Z]*')
    KEY_RE = re.compile(r'[_a-zA-Z][_0-9a-zA-Z]*:')
    BOOL_RE = re.compile(r'true|false')
    CHAR_RE = re.compile(r'.')
    def next_match(text):
        m = SPACE_RE.match(text)
        if (m): return (m, None)
        m = BOOL_RE.match(text)
        if (m): return (m, 'BOOL')
        m = ATOM_RE.match(text)
        if (m): return (m, 'ATOM')
        m = KEY_RE.match(text)
        if (m): return (m, 'KEY')
        m = INT_RE.match(text)
        if (m): return (m, 'INT')
        m = CHAR_RE.match(text)  #must be last: match any char
        if (m): return (m, m.group())

    tokens = []
    while (len(text) > 0):
        (match, kind) = next_match(text)
        lexeme = match.group()
        if (kind): tokens.append(Token(kind, lexeme))
        text = text[len(lexeme):]
    return tokens

def main():
#    if (len(sys.argv) != 2): usage();
#   contents = readFile(sys.argv[1]);
    text = sys.stdin.read()
    asts = parse(text)
    print(json.dumps(asts, separators=(',', ':'))) #no whitespace

def readFile(path):
    with open(path, 'r') as file:
        content = file.read()
    return content


def usage():
    print(f'usage: {sys.argv[0]} DATA_FILE')
    sys.exit(1)

#use a dict so that we can add attributes dynamically
def Ast(tag, *kids):
    return { 'tag': tag, } if len(kids) == 0 else { 'tag': tag, 'kids': kids }

Token = namedtuple('Token', ['kind', 'lexeme'])

if __name__ == "__main__":
    main()
