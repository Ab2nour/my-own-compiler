grammar Expr;

// Start rule
prog
    : (p=print end_instruction)*
    EOF
;

// Arithmetic expressions
expr
    : op1=expr symbol=('*'|'/') op2=expr # MulDiv
    | op1=expr symbol=('+'|'-') op2=expr # AddSub
    | INT # Int
    | L_PARENTHESIS expr R_PARENTHESIS # Paren
;

print
    : PRINT L_PARENTHESIS
        e=expr
    R_PARENTHESIS
;

end_instruction: NEWLINE | SEMICOLON;

// Tokens
PRINT : 'print';

INT: [0-9]+;

L_PARENTHESIS: '(';
R_PARENTHESIS: ')';

COMMA: ',';
SEMICOLON: ';';

NEWLINE: BACKSLASH_R? BACKSLASH_N;
fragment BACKSLASH_N: '\n';
fragment BACKSLASH_R: '\r';
