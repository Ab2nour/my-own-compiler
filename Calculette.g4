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
 : '(' a=expr_arith ')' {$code = $a.code;}
 | a=expr_arith '^' b=expr_arith {
     //todo: décrémenter b jusqu'à trouver 0 et multiplier a par a pendant ce temps
     $code = $a.code + $b.code + "DIV\n";

    }
 | a=expr_arith OP_ARITH_SIMPLE b=expr_arith
   {$code = $a.code + $b.code + $OP_ARITH_SIMPLE.text + "\n";}
 | '-' ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';} 
 | ENTIER {$code = "PUSHI " + $ENTIER.int + '\n';}
;

// expression booléenne
expr_bool returns [String code]
 : '(' a=expr_bool ')' {$code = $a.code;}
 | 'not' a=expr_bool {$code = "PUSHI 1\n" + $a.code + "SUB\n";} // (not a) === (1 - a)
 | c=expr_arith OP_COMPARAISON d=expr_arith
   {$code = $c.code + $d.code + $OP_COMPARAISON.text + "\n";}
 | a=expr_bool AND b=expr_bool {$code = $a.code + $b.code + "MUL\n";} // (a and b) === (a * b)
 | a=expr_bool OR b=expr_bool // (a or b) === ((a+b) <> 0)
  {
    $code = $a.code + $b.code + "ADD\n";
    $code += "PUSHI 0\n" + "NEQ\n";
  }
 | a=expr_bool 'or_lazy' b=expr_bool // tentative de or avec lazy evaluation
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
 | a=expr_bool 'xor' b=expr_bool // (a xor b) === (a <> b)
  {
    $code = $a.code + $b.code + "NEQ\n";
  }
 | BOOL {$code = "PUSHI" + $BOOL.text + '\n';}
;


fin_expression
 : (EOF | NEWLINE | ';')+
;

// règles du lexer. Skip pour dire ne rien faire
NEWLINE : '\r'? '\n' -> skip;
WS : (' ' | '\t')+ -> skip;

ENTIER : ('0'..'9')+;
BOOL : 'true' { setText("1"); } | 'false' { setText("0"); };

// une des quatres opérations arithmétiques simples
OP_ARITH_SIMPLE 
 : '+' { setText("ADD"); }
 | '-' { setText("SUB"); }
 | '*' { setText("MUL"); }
 | '/' { setText("DIV"); }
;

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

UNMATCH : . -> skip;
