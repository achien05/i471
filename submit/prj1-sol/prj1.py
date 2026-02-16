#!/usr/bin/env python3
#problem areas in comments int list, tuple, and map
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
#bool: \wtrue\w|\wfalse\w

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
        if(peek('tuple')):
            kind = lookahead.kind
            consume('tuple')
            #if(not peek('}')):
            #    t = dataLiteral()
            #    while(peek(',')):
            #        consume(',')
            #        t1 = dataLiteral()
            #        t = Ast(kind, t, t1)
            #else:
            #    t = Ast(kind)
            consume('}')
        elif(peek('list')):
            kind = lookahead.kind
            consume('list')
            #if(not peek(']')):
            #    t = dataLiteral()
            #    while(peek(',')):
            #        consume(',')
            #        t1 = dataLiteral()                
            #        t = Ast(kind, t, t1)
            #else:
            #    t = Ast(kind)
            consume(']')
        elif(peek('map')):
            kind = lookahead.kind
            consume('map')
            #if(not peek('}')):
            #    t = keyPair()
            #    while(peek(',')):
            #        consume(',')
            #        t1 = keyPair()
            #        t = Ast(kind, t, t1)
            #else:
            #    t = Ast(kind)
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
            kind = lookahead.kind
            t = dataLiteral()
            consume('=')
            consume('>')
            t1 = dataLiteral()
            t = Ast(kind, t, t1)
        return t
    def primitiveLiteral():
        if(peek('bool')):
            value = lookahead.lexeme
            consume('bool')
            ast = Ast('bool')
            ast["%v"] = value.lower() == "true"
            return ast
        elif(peek('int')):
            value = int(lookahead.lexeme)
            consume('int')
            ast = Ast('int')
            ast["%v"] = value
            return ast
        elif(peek('atom')):
            t = atom()
            return t
        else:
            print("indeterminate value")
            sys.exit(1)
    def atom():
        if(peek('KEY')):
            value = lookahead.lexeme
            consume('KEY')
            ast = Ast('atom')
            ast["%v"] = value
            return ast    
        else:
            value = lookahead.lexeme
            consume('atom')
            ast = Ast('atom')
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
    LIST_RE = re.compile(r'\[')
    TUPLE_RE = re.compile(r'\{')
    MAP_RE = re.compile(r'\%\{')
    INT_RE = re.compile(r'\d+(_\d+)*')
    ATOM_RE = re.compile(r':[_a-zA-Z][_0-9a-zA-Z]*')
    KEY_RE = re.compile(r'[_a-zA-Z][_0-9a-zA-Z]*:')
    BOOL_RE = re.compile(r'\wtrue\w|\wfalse\w')
    CHAR_RE = re.compile(r'.')
    def next_match(text):
        m = SPACE_RE.match(text)
        if (m): return (m, None)
        m = LIST_RE.match(text)
        if (m): return (m, 'list')
        m = TUPLE_RE.match(text)
        if (m): return (m, 'tuple')
        m = MAP_RE.match(text)
        if (m): return (m, 'map')
        m = BOOL_RE.match(text)
        if (m): return (m, 'bool')
        m = ATOM_RE.match(text)
        if (m): return (m, 'atom')
        m = KEY_RE.match(text)
        if (m): return (m, 'KEY')
        m = INT_RE.match(text)
        if (m): return (m, 'int')
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
    text = sys.stdin.read()
    asts = parse(text)
    #sys.stdout.write(json.dumps(asts, separators=(',', ':')))
    print(json.dumps(asts, separators=(',', ':'))) #no whitespace

#def readFile(path):
#    with open(path, 'r') as file:
#        content = file.read()
#    return content


def usage():
    print(f'usage: {sys.argv[0]} DATA_FILE')
    sys.exit(1)

#use a dict so that we can add attributes dynamically
def Ast(tag, *kids):
    return {'%k': tag, '%v': kids }

Token = namedtuple('Token', ['kind', 'lexeme'])

if __name__ == "__main__":
    main()
