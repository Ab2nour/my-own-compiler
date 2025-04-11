grammar Expr;
prog:	expr EOF ;
expr:	op1=expr symbol=('*'|'/') op2=expr # MulDiv
    |	op1=expr symbol=('+'|'-') op2=expr # AddSub
    |	INT # Int
    |	'(' expr ')' # Paren
    ;
NEWLINE : [\r\n]+ -> skip;
INT     : [0-9]+ ;
