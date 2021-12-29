grammar Calculette;

@header {
    import java.util.HashMap;
}

@members {
    // place de la pile à laquelle on stocke la variable
    // et, au passage, nombre de variables
    int place_variable = 0; 
    HashMap<String, Integer> memory = new HashMap<String, Integer>();

    int label_actuel = 0;
    String nouveauLabel() {
       return Integer.toString(label_actuel++);
    }

    final String label_exp = nouveauLabel();

    String fonction_exp() {
      String label_while = nouveauLabel();
      String label_return = nouveauLabel();

      String code = "LABEL " + label_exp + "\n" +
      "PUSHI 1\n" +
      "STOREL -5\n" +
      "LABEL " + label_while + "\n" +
      "PUSHL -3\n" +
      "PUSHI 0\n" +
      "SUP\n" +
      "JUMPF " + label_return + "\n" +
      "PUSHL -5\n" +
      "PUSHL -4\n" +
      "MUL\n" +
      "STOREL -5\n" +
      "PUSHL -3\n" +
      "PUSHI 1\n" +
      "SUB\n" +
      "STOREL -3\n" +
      "JUMP " + label_while + "\n" +
      "LABEL " + label_return + "\n" +
      "RETURN\n";

      return code;
    }


    String fonctions_builtin() {
      String label_debut = nouveauLabel();
      String code = new String();
      code += "JUMP " + label_debut + "\n";
      code += fonction_exp();
      code += "LABEL " + label_debut + "\n";

      return code;
    }
}

// règles de la grammaire
start returns [String code]
 @init {$code = new String(); $code += fonctions_builtin();}
 @after {
   for (int i = 0; i < place_variable; i++) {
      $code += "POP\n"; // on pop toutes les variables de la pile
   }
   System.out.println($code + "HALT\n");
 }
 : (declaration fin_expression+ {$code += $declaration.code;})*
 (instruction fin_expression+ {$code += $instruction.code;})* EOF
;

declaration returns [String code]
 : TYPE id=IDENTIFIANT {
   memory.put($id.text, place_variable);
   place_variable++;
   $code = "PUSHI 0\n";
 }
 | TYPE (IDENTIFIANT VIRGULE)* IDENTIFIANT
 | TYPE affectation
;

instruction returns [String code]
 : affectation {$code = $affectation.code;}
 | fonction_builtin {$code = $fonction_builtin.code;}
 | structure_conditionnelle {$code = $structure_conditionnelle.code;}
 | boucle {$code = $boucle.code;}
  // Une instruction qui ne contient qu'une expr est
  // inutile et sans effet de bord : on POP donc
  // le résultat de celle-ci.
 | expr {$code = $expr.code + "POP\n";}
;

structure_conditionnelle returns [String code]
 @init {
   String code_if = new String();
   String code_else = new String();

   String label_if = nouveauLabel();
   String label_else = nouveauLabel();
 }
 : IF (expr_bool) L_ACCOLADE 
      (instruction fin_expression+ {code_if += $instruction.code;})+
   R_ACCOLADE {
   $code = $expr_bool.code;
   $code += "JUMPF " + label_if + "\n";
   $code += code_if;
   $code += "LABEL " + label_if + "\n";
 }
 | IF (expr_bool) L_ACCOLADE 
      (instruction fin_expression+ {code_if += $instruction.code;})+
   R_ACCOLADE ELSE L_ACCOLADE
      (instruction fin_expression+ {code_else += $instruction.code;})+
   R_ACCOLADE {

   $code = $expr_bool.code;
   $code += "JUMPF " + label_if + "\n";
   $code += code_if;
   $code += "JUMP " + label_else + "\n";
   $code += "LABEL " + label_if + "\n";
   $code += code_else;
   $code += "LABEL " + label_else + "\n";
 }
;

boucle returns [String code]
 @init {
   String code_instruction = new String();
 }
 : WHILE (expr_bool) L_ACCOLADE 
      (instruction fin_expression+ {code_instruction += $instruction.code;})+
   R_ACCOLADE {
     // TODO !!!
   $code = $expr_bool.code;
   $code += "JUMPF " + label_actuel + "\n";
   $code += code_instruction;
   $code += "LABEL " + label_actuel + "\n";

   label_actuel++;
 }
;

fonction_builtin returns [String code]
 : PRINT L_PARENTHESE expr R_PARENTHESE {
   $code = $expr.code;
   $code += "WRITE\nPOP\n";
 }
;

affectation returns [String code]
 : id=IDENTIFIANT EGAL expr {
   $code = $expr.code;
   $code += "STOREG " + memory.get($id.text) + "\n";
 }
 | id=IDENTIFIANT PLUS EGAL expr {
   $code = "PUSHG " + memory.get($id.text) + "\n";
   $code += $expr.code;
   $code += "ADD\n";
   $code += "STOREG " + memory.get($id.text) + "\n";
 }
 | incr_ou_decr
;

incr_ou_decr returns [String code]
 : id=IDENTIFIANT operateur=(INCREMENTATION | DECREMENTATION) {
   $code = "PUSHG " + memory.get($id.text) + "\n";
   $code += "PUSHI 1\n";
   $code += $operateur.getText() + "\n";
   $code += "STOREG " + memory.get($id.text) + "\n";
 }
;

expr returns [String code]
 : expr_arith {$code = $expr_arith.code;}
 | expr_bool {$code = $expr_bool.code;}
;


// expression arithmétique
expr_arith returns [String code]
 : L_PARENTHESE a=expr_arith R_PARENTHESE {$code = $a.code;}
 //todo: gérer les exposants négatifs
 | <assoc=right> a=expr_arith EXP b=expr_arith {
    $code = "PUSHI 0\n";
    $code += $a.code + $b.code;
    $code += "CALL " + label_exp + "\n";
    $code += "POP\nPOP\n";
  }
 | a=expr_arith MUL_OU_DIV b=expr_arith {$code = $a.code + $b.code + $MUL_OU_DIV.getText() + "\n";}
 | a=expr_arith PLUS b=expr_arith {$code = $a.code + $b.code + $PLUS.getText() + "\n";}
 | a=expr_arith MOINS b=expr_arith {$code = $a.code + $b.code + $MOINS.getText() + "\n";}
 | nombre_entier {$code = $nombre_entier.code;}
 | id=IDENTIFIANT {$code = "PUSHG " + memory.get($id.text) + "\n";}
;

nombre_entier returns [String code]
 : MOINS ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';}
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
 | BOOLEEN {$code = "PUSHI " + $BOOLEEN.getText() + '\n';}
 | id=IDENTIFIANT {$code = "PUSHG " + memory.get($id.text) + "\n";}
;


fin_expression
 : NEWLINE | ';'
;

// règles du lexer. Skip pour dire ne rien faire
NEWLINE : BACKSLASH_R? BACKSLASH_N;
fragment BACKSLASH_N : '\n';
fragment BACKSLASH_R : '\r';


WHITESPACE : (ESPACE| TAB)+ -> skip;
fragment ESPACE : ' ';
fragment TAB : '\t';

ENTIER : CHIFFRE+; // todo: les nombres commençant par 0 exemple : "042" ?
fragment CHIFFRE : ('0'..'9');

BOOLEEN : TRUE { setText("1"); } | FALSE { setText("0"); };

fragment TRUE : 'true';
fragment FALSE : 'false';

// parenthèses
L_PARENTHESE : '(';
R_PARENTHESE : ')';
L_ACCOLADE : '{';
R_ACCOLADE : '}';

// commentaire
COMMENTAIRE
 : (L_COMMENT .*? R_COMMENT
 // ANTLR4: on ne peut pas mettre de tokens dans les sets avec un '~' devant 
 // -> on est obligé de mettre \n plutôt que BACKSLASH_N dans SLASH_COMMENT.
 | SLASH_COMMENT .*? ~('\n' | '\r')*
 ) -> skip
; 

fragment SLASH_COMMENT : '//';
fragment L_COMMENT : '/*';
fragment R_COMMENT : '*/';

MUL_OU_DIV
 : SYMBOLE_FOIS { setText("MUL"); }
 | SYMBOLE_DIV { setText("DIV"); }
;

EXP : '^' | SYMBOLE_FOIS SYMBOLE_FOIS;
PLUS : SYMBOLE_PLUS { setText("ADD"); };
MOINS : SYMBOLE_MOINS { setText("SUB"); };

INCREMENTATION : SYMBOLE_PLUS SYMBOLE_PLUS { setText("ADD"); };
DECREMENTATION : SYMBOLE_MOINS SYMBOLE_MOINS { setText("SUB"); };

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

// Déclaration de variables
TYPE : INT | BOOL_TYPE | FLOAT;
INT: 'int';
BOOL_TYPE: 'bool';
FLOAT: 'float';


// Structures de contrôle et boucles :
IF : 'if';
ELSE : 'else';
WHILE : 'while';
FOR : 'for';

VIRGULE : ',';
EGAL : '=';

// Fonctions built-in
PRINT : 'print' | 'afficher';
READ : 'read' | 'lire';


IDENTIFIANT : LETTRE (LETTRE | CHIFFRE)*;

fragment LETTRE : [a-z] | [A-Z];

UNMATCH : . -> skip;
