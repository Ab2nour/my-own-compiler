grammar Calculette;
// règles de la grammaire
start 
 : expr fin_expression {System.out.println($expr.code + "WRITE\n" + "POP\n" + "HALT\n");} ;

expr returns [String code]
 : '(' a=expr ')' {$code = $a.code;}
 | a=expr '/' b=expr {$code = $a.code + $b.code + "DIV" + '\n';}
 | a=expr '*' b=expr {$code = $a.code + $b.code + "MUL" + '\n';}
 | a=expr '+' b=expr {$code = $a.code + $b.code + "ADD" + '\n';}
 | a=expr '-' b=expr {$code = $a.code + $b.code + "SUB" + '\n';} // inversé ?
 | '-' ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';} 
 | ENTIER {$code = "PUSHI " + $ENTIER.int + '\n';}
 | a=expr '>' b=expr //todo
 | bool {$code = $bool.code;}
;

bool returns [String code]
 : '(' a=bool ')' {$code = $a.code;}
 | 'not' a=bool {$code = "PUSHI 1" + '\n' + $a.code + "SUB" + '\n';}
 | a=bool '->' b=bool // (not a or b) === (1 + a*b - a)
 {
 $code = "PUSHI 1" + '\n';
 $code += $a.code + $b.code + "MUL" + '\n';
 $code += "ADD" + '\n';
 $code += $a.code + '\n';
 $code += "SUB" + '\n'; 
 } 
 | a=bool 'and' b=bool {$code = $a.code + $b.code + "MUL" + '\n';} // a*b
 | a=bool 'or' b=bool // b - a*b + a
 {
 $code = $b.code + '\n';
 $code += $a.code + $b.code + "MUL" + '\n';
 $code += "SUB" + '\n';
 $code += $a.code + '\n';
 $code += "ADD" + '\n';
 }
 | BOOL {$code = "PUSHI" + $BOOL.text + '\n';}
;

fin_expression
 : EOF | NEWLINE | ';'
;

// règles du lexer. Skip pour dire ne rien faire
NEWLINE : '\r'? '\n' -> skip;
WS : (' '|'\t')+ -> skip;
ENTIER : ('0'..'9')+;
BOOL : 'true' { setText("1"); } | 'false' { setText("0"); };
UNMATCH : . -> skip;
