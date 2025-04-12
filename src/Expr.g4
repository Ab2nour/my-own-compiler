grammar Expr;

// Start rule
prog
    : (declaration end_statement)*
    (statement end_statement)*
    EOF
;

declaration: var=IDENTIFIER '=' e=expr;

// Arithmetic expression
expr
    : op1=expr symbol=('*'|'/') op2=expr # MulDiv
    | op1=expr symbol=('+'|'-') op2=expr # AddSub
    | INT # Int
    | IDENTIFIER # Var
    | L_PARENTHESIS expr R_PARENTHESIS # Paren
;

// Boolean expression
bool_expr
    : TRUE # True
    | FALSE # False
;

statement
    : print
    | if
;

// Print function
print
    : PRINT L_PARENTHESIS
        e=expr
    R_PARENTHESIS
;

if
    : IF L_PARENTHESIS b=bool_expr R_PARENTHESIS L_BRACKET
    statement end_statement
    R_BRACKET
;

end_statement: (NEWLINE | SEMICOLON)+;

// Tokens
PRINT : 'print';

IF: 'if';
TRUE: 'true';
FALSE: 'false';

INT: [0-9]+;
fragment DIGIT : ('0'..'9');

L_PARENTHESIS: '(';
R_PARENTHESIS: ')';
L_BRACKET: '{';
R_BRACKET: '}';

COMMA: ',';
SEMICOLON: ';';

NEWLINE: BACKSLASH_R? BACKSLASH_N;
fragment BACKSLASH_N: '\n';
fragment BACKSLASH_R: '\r';

IDENTIFIER: (LETTER | UNDERSCORE) (LETTER | DIGIT | UNDERSCORE)*;
fragment LETTER : [a-z] | [A-Z];
fragment UNDERSCORE : '_';

UNMATCH : . -> skip;
