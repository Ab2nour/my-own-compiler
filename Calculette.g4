grammar Calculette;

// règles de la grammaire
start 
 : expr fin_expression {System.out.println($expr.code + "WRITE\n" + "POP\n" + "HALT\n");}
 | bool fin_expression {System.out.println($bool.code + "WRITE\n" + "POP\n" + "HALT\n");}
;

// expression arithmétique
expr returns [String code]
 : '(' a=expr ')' {$code = $a.code;}
 | a=expr '^' b=expr {
     //todo: décrémenter b jusqu'à trouver 0 et multiplier a par a pendant ce temps
     $code = $a.code + $b.code + "DIV\n";

    }
 | a=expr '/' b=expr {$code = $a.code + $b.code + "DIV\n";}
 | a=expr '*' b=expr {$code = $a.code + $b.code + "MUL\n";}
 | a=expr '+' b=expr {$code = $a.code + $b.code + "ADD\n";}
 | a=expr '-' b=expr {$code = $a.code + $b.code + "SUB\n";}
 | '-' ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';} 
 | ENTIER {$code = "PUSHI " + $ENTIER.int + '\n';}
;

// expression booléenne
bool returns [String code]
 : '(' a=bool ')' {$code = $a.code;}
 | 'not' a=bool {$code = "PUSHI 1\n" + $a.code + "SUB\n";} // (not a) === (1 - a)
 | c=expr '<>' d=expr {$code = $c.code + $d.code + "NEQ\n";}
 | c=expr '<=' d=expr {$code = $c.code + $d.code + "INFEQ\n";}
 | c=expr '<' d=expr {$code = $c.code + $d.code + "INF\n";}
 | c=expr '>=' d=expr {$code = $c.code + $d.code + "SUPEQ\n";}
 | c=expr '>' d=expr {$code = $c.code + $d.code + "SUP\n";}
 | a=bool 'and' b=bool {$code = $a.code + $b.code + "MUL\n";} // (a and b) === (a * b)
 | a=bool 'or' b=bool // (a or b) === ((a+b) <> 0)
  {
    $code = $a.code + $b.code + "ADD\n";
    $code += "PUSHI 0\n" + "NEQ\n";
  }
 | a=bool 'or_lazy' b=bool // tentative de or avec lazy evaluation
    {
        $code = $a.code + '\n' + "PUSHG 0\n";

        $code += "PUSHI 1\n"; // if
        $code += "NEQ \n"; // (a == true) === not (a <> 1)
        $code += "JUMPF else\n";

        $code += $b.code + '\n'; // then
        $code += "ADD\n" + "PUSHI 1\n" + "SUPEQ\n";
        $code += "JUMP else\n";
        $code += "LABEL else\n" ; //else
    }
 | a=bool 'xor' b=bool // (a xor b) === (a <> b)
  {
    $code = $a.code + $b.code + "NEQ\n";
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
