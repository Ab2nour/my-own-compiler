grammar Calculette;

// règles de la grammaire
start 
 @after {System.out.println("HALT\n");}
 : (expr fin_expression {System.out.println($expr.code);})+
;

expr returns [String code]
 : expr_arith {$code = $expr_arith.code + "WRITE\n" + "POP\n";}
 | expr_bool {$code = $expr_bool.code + "WRITE\n" + "POP\n";}
;


// expression arithmétique
expr_arith returns [String code]
 : L_PARENTHESE a=expr_arith R_PARENTHESE {$code = $a.code;}
 | a=expr_arith '^' b=expr_arith {
     //todo: décrémenter b jusqu'à trouver 0 et multiplier a par a pendant ce temps
     $code = $a.code + $b.code + "DIV\n";

    }
 | a=expr_arith MUL_OU_DIV b=expr_arith {$code = $a.code + $b.code + $MUL_OU_DIV.getText() + "\n";}
 | a=expr_arith ADD_OU_SUB b=expr_arith {$code = $a.code + $b.code + $ADD_OU_SUB.getText() + "\n";}
 | nombre_entier {$code = $nombre_entier.code;}
;

nombre_entier returns [String code]
 : MOINS_UNAIRE ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';}
 | ENTIER {$code = "PUSHI " + $ENTIER.int + '\n';}
;

// expression booléenne
expr_bool returns [String code]
 : L_PARENTHESE a=expr_bool R_PARENTHESE {$code = $a.code;}
 | NOT a=expr_bool {$code = "PUSHI 1\n" + $a.code + "SUB\n";} // (not a) === (1 - a)
 | c=expr_arith OP_COMPARAISON d=expr_arith
   {$code = $c.code + $d.code + $OP_COMPARAISON.text + "\n";}
 | a=expr_bool AND b=expr_bool {$code = $a.code + $b.code + "MUL\n";} // (a and b) === (a * b)
 | a=expr_bool OR b=expr_bool // (a or b) === ((a+b) <> 0)
  {
    $code = $a.code + $b.code + "ADD\n";
    $code += "PUSHI 0\n" + "NEQ\n";
  }
 | a=expr_bool OR_LAZY b=expr_bool // tentative de or avec lazy evaluation
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
 | a=expr_bool XOR b=expr_bool // (a xor b) === (a <> b)
  {$code = $a.code + $b.code + "NEQ\n";}
 | BOOL {$code = "PUSHI" + $BOOL.text + '\n';}
;


fin_expression
 : EOF | NEWLINE | ';'
;

// règles du lexer. Skip pour dire ne rien faire
NEWLINE : '\r'? '\n' -> skip;
WS : (' ' | '\t')+ -> skip;

ENTIER : ('0'..'9')+;
BOOL : 'true' { setText("1"); } | 'false' { setText("0"); };

// parenthèses
L_PARENTHESE : '(';
R_PARENTHESE : ')';

MUL_OU_DIV
 : SYMBOLE_FOIS { setText("MUL"); }
 | SYMBOLE_DIV { setText("DIV"); }
;

ADD_OU_SUB
 : SYMBOLE_PLUS { setText("ADD"); }
 | MOINS { setText("SUB"); }
;

MOINS : SYMBOLE_MOINS;
MOINS_UNAIRE : SYMBOLE_MOINS;

fragment SYMBOLE_PLUS : '+';
fragment SYMBOLE_MOINS : '-';
fragment SYMBOLE_FOIS : '*';
fragment SYMBOLE_DIV : '/';


// un des opérateurs de comparaison
OP_COMPARAISON
 : '==' { setText("EQ"); }
 | '<>' { setText("NEQ"); }
 | '<=' { setText("INFEQ"); }
 | '<' { setText("INF"); }
 | '>=' { setText("SUPEQ"); }
 | '>' { setText("SUP"); }
;

// Symboles de comparaison
AND : 'and';
OR : 'or';
OR_LAZY : 'or_lazy';
XOR : 'xor';
NOT : 'not';

UNMATCH : . -> skip;
