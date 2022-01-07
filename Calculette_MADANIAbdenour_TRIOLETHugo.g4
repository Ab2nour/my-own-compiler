grammar Calculette_MADANIAbdenour_TRIOLETHugo;

@header {
    import java.util.HashMap;
}

@members {
    // place de la pile à laquelle on stocke la variable
    // et, au passage, nombre de variables
    int place_variable = 0;

    /* Renvoie la place de la prochaine variable disponible */
    int placeProchaineVariable() {
        return place_variable++;
    }
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
calcul returns [String code]
    @init {$code = new String(); $code += fonctions_builtin();}
    @after {
        for (int i = 0; i < place_variable; i++) {
            $code += "POP\n"; // on pop toutes les variables de la pile
        }
        $code += "HALT\n";
        System.out.println($code);
    }
    : (declaration fin_expression+ {$code += $declaration.code;})*
    (instruction fin_expression+ {$code += $instruction.code;})*
    EOF
;

/* ----------------------------------------------------------------------
# Déclaration de variable. 
Syntaxes acceptées :

int x;

int x, y, z;

int x,
    y;
---------------------------------------------------------------------- */
declaration returns [String code]
    @init {
        $code = new String();
    }
    : TYPE (id=IDENTIFIANT VIRGULE NEWLINE* {
        memory.put($id.text, placeProchaineVariable());
        $code += "PUSHI 0\n";
    })* 
    id=IDENTIFIANT {
        memory.put($id.text, placeProchaineVariable());
        $code += "PUSHI 0\n";
    }
    //todo : déclaration & assignation simultanées | TYPE id=IDENTIFIANT EGAL expr
;


/* ----------------------------------------------------------------------
# Bloc d'instructions
(utilisé uniquement dans les structures (if, do while, ...))

Syntaxe :

{
    instructions;
}
---------------------------------------------------------------------- */
bloc_instructions returns [String code]
    @init {
        $code = new String();
    }
    : L_ACCOLADE NEWLINE*
        (instruction fin_expression+ {$code += $instruction.code;})+
    R_ACCOLADE
;


/* ----------------------------------------------------------------------
# Instruction unique
---------------------------------------------------------------------- */
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


/* ----------------------------------------------------------------------
# Structure conditionnelle
---------------------------------------------------------------------- */
structure_conditionnelle returns [String code]
    : structure_if {$code = $structure_if.code;}
;


/* ----------------------------------------------------------------------
# If / Else

Syntaxes :

    if (cond) instruction;

    if (cond) instruction else instruction

    if (cond) instruction
    else instruction


    if (cond) {instructions;}

    if (cond) {
        instructions;
    } else {
        instructions;
    }

    if (cond) {
        instructions;
    } else if (cond) {
        instructions;
    } else {
        instructions;
    }

---------------------------------------------------------------------- */
structure_if returns [String code]
    @init {
        String instruction_if = new String();
        String instruction_else = new String();

        String label_if = nouveauLabel();
        String label_else = nouveauLabel();
    }
    : IF L_PARENTHESE expr_bool R_PARENTHESE NEWLINE*
        (bloc_instructions {instruction_if += $bloc_instructions.code;}
        | instruction POINT_VIRGULE? {instruction_if += $instruction.code;}
        ) NEWLINE*
    (ELSE NEWLINE*
        (bloc_instructions {instruction_else += $bloc_instructions.code;}
        | instruction POINT_VIRGULE? {instruction_else += $instruction.code;}
        | structure_if {instruction_else += $structure_if.code;}
        ))? {
            $code = $expr_bool.code;

            $code += "JUMPF " + label_if + "\n";
            $code += instruction_if;

            if (instruction_else != "") {$code += "JUMP " + label_else + "\n";}

            $code += "LABEL " + label_if + "\n";

            if (instruction_else != "") {
                $code += instruction_else;
                $code += "LABEL " + label_else + "\n";
            }
        }
;

boucle returns [String code]
    : boucle_do_while {$code = $boucle_do_while.code;}
;

boucle_do_while returns [String code]
    @init {
        String code_instruction = new String();
    }
    : DO NEWLINE* (bloc_instructions {code_instruction += $bloc_instructions.code;}
        | instruction POINT_VIRGULE? {code_instruction += $instruction.code;}) NEWLINE*
    WHILE L_PARENTHESE expr_bool R_PARENTHESE {
        String label_instructions = nouveauLabel(); // instructions du do while
        String label_condition = nouveauLabel(); // vérification de la condition
        String label_fin = nouveauLabel(); // fin du do while

        $code = "JUMP " + label_instructions + "\n";

        $code += "LABEL " + label_condition + "\n";
        $code += $expr_bool.code;
        $code += "JUMPF" + label_fin + "\n";

        $code += "LABEL " + label_instructions + "\n";
        $code += code_instruction;
        $code += "JUMP " + label_condition + "\n";

        $code += "LABEL " + label_fin + "\n";
    }
;

fonction_builtin returns [String code]
    : print {$code = $print.code;} 
    | read {$code = $read.code;}
;

print returns [String code]
    @init {
        $code = new String();
        String code_arguments = new String();
        String code_affichage = "WRITE\nPOP\n";
    }
    : PRINT L_PARENTHESE 
        (expr VIRGULE {$code += $expr.code + code_affichage;})* e=expr
    R_PARENTHESE {
        $code += $e.code + code_affichage;
    }
;

read returns [String code]
    : READ L_PARENTHESE id=IDENTIFIANT R_PARENTHESE {
        $code = "READ\n";
        $code += "STOREG " + memory.get($id.text) + "\n";
    }
;

affectation returns [String code]
    : id=IDENTIFIANT EGAL expr {
        $code = $expr.code;
        $code += "STOREG " + memory.get($id.text) + "\n";
    }
    | raccourci_affectation {$code = $raccourci_affectation.code;}
    | incr_ou_decr {$code = $incr_ou_decr.code;}
;

raccourci_affectation returns [String code]
    : id=IDENTIFIANT operateur=(PLUS | MOINS | MUL_OU_DIV) EGAL expr {
        $code = "PUSHG " + memory.get($id.text) + "\n";
        $code += $expr.code;
        $code += $operateur.getText() + "\n";
        $code += "STOREG " + memory.get($id.text) + "\n";
    }
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


// expression flottante
expr_float returns [String code]
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

nombre_float returns [String code]
    : MOINS ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';}
    | ENTIER {$code = "PUSHI " + $ENTIER.int + '\n';}
;

// expression booléenne
expr_bool returns [String code]
    : L_PARENTHESE a=expr_bool R_PARENTHESE {$code = $a.code;}
    | NOT a=expr_bool {$code = "PUSHI 1\n" + $a.code + "SUB\n";} // (not a) === (1 - a)
    | c=expr_arith OP_COMPARAISON d=expr_arith {
        $code = $c.code + $d.code + $OP_COMPARAISON.text + "\n";
    }
    | a=expr_bool AND b=expr_bool {$code = $a.code + $b.code + "MUL\n";} // (a and b) === (a * b)
    | a=expr_bool OR b=expr_bool { // (a or b) === ((a+b) <> 0)
        $code = $a.code + $b.code + "ADD\n";
        $code += "PUSHI 0\n" + "NEQ\n";
    }
    | a=expr_bool OR_LAZY b=expr_bool { // tentative de or avec lazy evaluation    
        $code = $a.code + '\n' + "PUSHG 0\n";

        $code += "PUSHI 1\n"; // if
        $code += "NEQ \n"; // (a == true) === not (a <> 1)
        $code += "JUMPF else\n";

        $code += $b.code + '\n'; // then
        $code += "ADD\n" + "PUSHI 1\n" + "SUPEQ\n";
        $code += "JUMP else\n";
        $code += "LABEL else\n" ; //else
    }
    | a=expr_bool XOR b=expr_bool { // (a xor b) === (a <> b)
        $code = $a.code + $b.code + "NEQ\n";
    }
    | BOOLEEN {$code = "PUSHI " + $BOOLEEN.getText() + "\n";}
    | id=IDENTIFIANT {$code = "PUSHG " + memory.get($id.text) + "\n";}
;


fin_expression
    : NEWLINE | POINT_VIRGULE
;

// règles du lexer. Skip pour dire ne rien faire
NEWLINE : BACKSLASH_R? BACKSLASH_N;
fragment BACKSLASH_N : '\n';
fragment BACKSLASH_R : '\r';

POINT_VIRGULE : ';';
VIRGULE : ',';
POINT : '.';


WHITESPACE : (ESPACE | TAB)+ -> skip;
fragment ESPACE : ' ';
fragment TAB : '\t';

ENTIER : CHIFFRE+; // todo: les nombres commençant par 0 exemple : "042" ?
FLOAT : CHIFFRE+ (POINT | VIRGULE) CHIFFRE+ | CHIFFRE+ FLOAT_EXPONENT CHIFFRE+;

fragment CHIFFRE : ('0'..'9');
fragment FLOAT_EXPONENT : 'e';

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
    : '==' { setText("EQUAL"); }
    | '<>' { setText("NEQ"); }
    | '<=' { setText("INFEQ"); }
    | '<' { setText("INF"); }
    | '>=' { setText("SUPEQ"); }
    | '>' { setText("SUP"); }
;

// Opérateurs booléens
AND : 'and';
OR : 'or';
OR_LAZY : 'or_lazy';
XOR : 'xor';
NOT : 'not';

// Déclaration de variables
TYPE : INT | BOOL_TYPE | FLOAT_TYPE;
INT : 'int';
BOOL_TYPE : 'bool';
FLOAT_TYPE : 'float';


// Structures de contrôle et boucles :
IF : 'if' | 'si';
ELSE : 'else' | 'sinon';
WHILE : 'while' | 'tantque';
FOR : 'for' | 'pour';
DO : 'do' | 'repeter';

EGAL : '=';

// Fonctions built-in
PRINT : 'print' | 'afficher';
READ : 'read' | 'lire';


IDENTIFIANT : (LETTRE | UNDERSCORE) (LETTRE | CHIFFRE | UNDERSCORE)*;

fragment LETTRE : [a-z] | [A-Z];
fragment UNDERSCORE : '_';

UNMATCH : . -> skip;
