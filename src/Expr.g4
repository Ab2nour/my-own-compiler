grammar Expr;

// Start rule
prog
    : (declaration end_statement)*
    (print end_statement)*
    EOF
;

declaration: var=IDENTIFIER '=' e=expr;

// Arithmetic expressions
expr
    : op1=expr symbol=('*'|'/') op2=expr # MulDiv
    | op1=expr symbol=('+'|'-') op2=expr # AddSub
    | INT # Int
    | IDENTIFIER # Var
    | L_PARENTHESIS expr R_PARENTHESIS # Paren
;

// Print function
print
    : PRINT L_PARENTHESIS
        e=expr
    R_PARENTHESIS
;

end_statement: (NEWLINE | SEMICOLON)+;

// Tokens
PRINT : 'print';

INT: [0-9]+;
fragment DIGIT : ('0'..'9');

L_PARENTHESIS: '(';
R_PARENTHESIS: ')';

COMMA: ',';
SEMICOLON: ';';

NEWLINE: BACKSLASH_R? BACKSLASH_N;
fragment BACKSLASH_N: '\n';
fragment BACKSLASH_R: '\r';

IDENTIFIER: (LETTER | UNDERSCORE) (LETTER | DIGIT | UNDERSCORE)*;
fragment LETTER : [a-z] | [A-Z];
fragment UNDERSCORE : '_';

UNMATCH : . -> skip;
