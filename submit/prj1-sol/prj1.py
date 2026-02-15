#!/usr/bin/env python3

import re
import sys
from collections import namedtuple
import json
 
#whitespace and #: \w*|#.*
#Sentence: dL*			parser
#dL: lL|tL|mL|pL               	parser Include all Literals except primitive
#pL: int|atom|bool           	parser
#lL: [ (dl, )* dl ]          	parser
#tL: { (dl, )* dl }          	parser
#mL: \% { (kp, )* kp? }       parser
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
            if(peek('{') or peek('[') or peek('%') or peek('INT') or peek('BOOL') or peek('ATOM')):
                t = dataLiteral()
                while(peek(',')):
                    consume(',')
                    t1 = dataLiteral()
                    t = Ast("tuple", t, t1)
                #peek('}')
            else:
                t = Ast("tuple", "[]")
            consume('}')
        elif(peek('[')):
            consume('[')
            if(peek('{') or peek('[') or peek('%') or peek('INT') or peek('BOOL') or peek('ATOM')):
                t = dataLiteral()
                while(peek(',')):
                    consume(',')
                    t1 = dataLiteral()                
                    t = Ast("list", t, t1)
            else:
                t = Ast("list", "[]")
            #peek(']')
            consume(']')
        elif(peek('%')):
            consume('%')
            #peek('{')
            consume('{')
            if(peek('KEY') or peek('ATOM')):
                t = keyPair()
                while(peek(',')):
                    consume(',')
                    t1 = keyPair()
                    t = Ast("map", t, t1)
            else:
                t = Ast("map", "[]")
            #peek('}')
            consume('}')
        else:
            t = primitiveLiteral()
        return t
    def keyPair():
        if(peek('KEY')):
            t = atom()
            t1 = dataLiteral()
            t = Ast("atom", t, t1)
        else:
            t = atom()
            consume('=')
            consume('>')
            t1 = dataLiteral
            t = Ast("atom", t, t1)
        #return t
    def primitiveLiteral():
        if(peek('BOOL')):
            value = bool(lookahead.lexeme)
            consume('BOOL')
            ast = Ast('BOOL')
            ast["%v"] = value
            return ast
        elif(peek('INT')):
            value = int(lookahead.lexeme)
            consume('INT')
            ast = Ast('INT')
            ast["%v"] = value
            return ast
        else:
            t = atom()
            return t
    def atom():
        if(peek('KEY')):
            value = lookahead.lexeme
            consume('KEY')
            ast = Ast('ATOM')
            ast["%v"] = value
            return ast    
        else:
            value = lookahead.lexeme
            consume('ATOM')
            ast = Ast('ATOM')
            ast["%v"] = value
            return ast
    

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
    INT_RE = re.compile(r'\d+(_\d+)*')
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
    #text = sys.stdin.read()
    text = input()
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
    return { '%k': tag, } if len(kids) == 0 else { '%k': tag, '%v': kids }

Token = namedtuple('Token', ['kind', 'lexeme'])

if __name__ == "__main__":
    main()
