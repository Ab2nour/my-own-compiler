grammar Calculette_MADANIAbdenour_TRIOLETHugo;

/*
Notes :

 - Nous avons à la fois implémenté les mots-clés anglais, 
mais aussi les mots-clés en français (cf Parser plus bas).

- Tous les tests du professeur sont passés avec succès.

- La gestion des floats est partielle : on ne peut pas
(encore) les stocker dans des variables.

 */


/* ############################# Imports ################################ */
@header {
    import java.util.HashMap;
}

/* ####################### Variables globales ########################### */
@members {
    // place de la pile à laquelle on stocke la variable
    // et, au passage, nombre de variables
    int place_variable = 0;

    /* Renvoie la place de la prochaine variable disponible */
    int placeProchaineVariable() {
        return place_variable++;
    }

    // Adresse dans la pile
    HashMap<String, Integer> adresse_pile = new HashMap<String, Integer>();
    // Type des variables
    HashMap<String, String> type_variable = new HashMap<String, String>();

    int label_actuel = 0;

    // Renvoie le prochain label disponible
    String nouveauLabel() {
        return Integer.toString(label_actuel++);
    }

    final String label_exp = nouveauLabel();

    // code de la fonction exponentielle en MVAP
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

    // nos fonctions built-in qu'on rajoute à chaque code MVAP
    // pour l'instant : juste l'exposant entier
    String fonctions_builtin() {
        String label_debut = nouveauLabel();
        String code = new String();
        code += "JUMP " + label_debut + "\n";
        code += fonction_exp();
        code += "LABEL " + label_debut + "\n";

        return code;
    }
}


/* ############################ PARSER ############################### */

/* ----------------------------------------------------------------------
# Règle d'entrée de la grammaire (start)
---------------------------------------------------------------------- */
calcul returns [String code]
    @init {$code = new String(); $code += fonctions_builtin();}
    @after {
        for (int i = 0; i < place_variable; i++) {
            $code += "POP\n"; // on pop toutes les variables de la pile
        }
        $code += "HALT\n";
        System.out.println($code);
    }
    : (declaration fin_instruction+ {$code += $declaration.code;})*
    (instruction fin_instruction+ {$code += $instruction.code;})*
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
        adresse_pile.put($id.text, placeProchaineVariable());
        type_variable.put($id.text, $TYPE.text);

        $code += "PUSHI 0\n";
    })* 
    id=IDENTIFIANT {
        adresse_pile.put($id.text, placeProchaineVariable());
        type_variable.put($id.text, $TYPE.text);

        $code += "PUSHI 0\n";
    }
    //todo : déclaration & assignation simultanées | TYPE id=IDENTIFIANT EGAL expr
;


/* ----------------------------------------------------------------------
# Bloc d'instructions
(utilisé uniquement dans les structures (if, do while, ...))

Syntaxes:

{
    instructions;
}

{instructions;}
---------------------------------------------------------------------- */
bloc_instructions returns [String code]
    @init {
        $code = new String();
    }
    : L_ACCOLADE NEWLINE*
        (instruction fin_instruction+ {$code += $instruction.code;})+
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

    // Une instruction qui ne contient qu'une expr est inutile 
    // et sans effet de bord : on POP donc le résultat de celle-ci.
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

/* ----------------------------------------------------------------------
# Boucles
---------------------------------------------------------------------- */
boucle returns [String code]
    : boucle_do_while {$code = $boucle_do_while.code;}
;

/* ----------------------------------------------------------------------
# Do While

Syntaxes :

do instruction while (cond)

do instruction;
while (cond)

do {instructions;} while (cond)

do {
    instructions;
} while (cond)
---------------------------------------------------------------------- */
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


/* ----------------------------------------------------------------------
# Fonctions Built-in
---------------------------------------------------------------------- */
fonction_builtin returns [String code]
    : print {$code = $print.code;} 
    | read {$code = $read.code;}
;


/* ----------------------------------------------------------------------
# Print

Syntaxes :

print(x)

print(x, y, z)

printf(epsilon) // epsilon est un float
---------------------------------------------------------------------- */
print returns [String code]
    @init {
        $code = new String();
        String code_arguments = new String();
        String code_affichage = "WRITE\nPOP\n";
        String code_affichage_float = "WRITEF\nPOP\n";
    }
    : PRINT L_PARENTHESE 
        (expr VIRGULE {$code += $expr.code + code_affichage;})* e=expr
    R_PARENTHESE {
        $code += $e.code + code_affichage;
    }
    // code à part pour les floats
    | PRINT_FLOAT L_PARENTHESE 
        (expr_float VIRGULE {$code += $expr_float.code + code_affichage;})* e=expr_float
    R_PARENTHESE {
        $code += $e.code + code_affichage_float;
    }
;


/* ----------------------------------------------------------------------
# Read

Syntaxes :

read(x)
---------------------------------------------------------------------- */
read returns [String code]
    : READ L_PARENTHESE id=IDENTIFIANT R_PARENTHESE {
        $code = "READ\n";
        $code += "STOREG " + adresse_pile.get($id.text) + "\n";
    }
;


/* ----------------------------------------------------------------------
# Affectations

Syntaxes : 

x = 5

x = 3 * x

x += 1

x *= 2

x++
---------------------------------------------------------------------- */
affectation returns [String code]
    : id=IDENTIFIANT EGAL expr {
        $code = $expr.code;
        $code += "STOREG " + adresse_pile.get($id.text) + "\n";
    }
    | raccourci_affectation {$code = $raccourci_affectation.code;}
    | incr_ou_decr {$code = $incr_ou_decr.code;}
;


/* ----------------------------------------------------------------------
# Raccourcis d'affectation

Syntaxes : 

x += 42

x -= 42

x *= 42

x /= 1
---------------------------------------------------------------------- */
raccourci_affectation returns [String code]
    : id=IDENTIFIANT operateur=(PLUS | MOINS | MUL_OU_DIV) EGAL expr {
        $code = "PUSHG " + adresse_pile.get($id.text) + "\n";
        $code += $expr.code;
        $code += $operateur.getText() + "\n";
        $code += "STOREG " + adresse_pile.get($id.text) + "\n";
    }
;


/* ----------------------------------------------------------------------
# Incrémentation / Décrémentation

Syntaxes : 

x++

x--
---------------------------------------------------------------------- */
incr_ou_decr returns [String code]
    : id=IDENTIFIANT operateur=(INCREMENTATION | DECREMENTATION) {
        $code = "PUSHG " + adresse_pile.get($id.text) + "\n";
        $code += "PUSHI 1\n";
        $code += $operateur.getText() + "\n";
        $code += "STOREG " + adresse_pile.get($id.text) + "\n";
    }
;


/* ----------------------------------------------------------------------
# Expression (arithmétique OU booléenne)

Les floats sont gérés à part pour l'instant.
---------------------------------------------------------------------- */
expr returns [String code]
    : expr_arith {$code = $expr_arith.code;}
    | expr_bool {$code = $expr_bool.code;}
;


/* ----------------------------------------------------------------------
# Expression arithmétique

La division et multiplication ont la même priorité.

L'exposant est associatif à droite, càd :
a^b^c => on évalue a^(b^c)
a^b^c^d => on évalue a^(b^(c^d))

exposant : x^y ou x**y (comme en Python)
---------------------------------------------------------------------- */
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
    | id=IDENTIFIANT {$code = "PUSHG " + adresse_pile.get($id.text) + "\n";}
    | MOINS id=IDENTIFIANT {$code = "PUSHG " + adresse_pile.get($id.text) + "\n" + "PUSHI -1\n" + "MUL\n";}
;


/* ----------------------------------------------------------------------
# Nombre entier (positif ou négatif)
---------------------------------------------------------------------- */
nombre_entier returns [String code]
    : MOINS ENTIER {$code = "PUSHI " + -$ENTIER.int + '\n';}
    | ENTIER {$code = "PUSHI " + $ENTIER.int + '\n';}
;


/* ----------------------------------------------------------------------
# Expression booléenne
---------------------------------------------------------------------- */
expr_bool returns [String code]
    : L_PARENTHESE a=expr_bool R_PARENTHESE {$code = $a.code;}
    // (not a) === (1 - a)
    | NOT a=expr_bool {
        $code = "PUSHI 1\n" + $a.code + "SUB\n";
    }    
    | c=expr_arith OP_COMPARAISON d=expr_arith {
        $code = $c.code + $d.code + $OP_COMPARAISON.text + "\n";
    }
    // (a and b) === (a * b)
    | a=expr_bool AND b=expr_bool {
        $code = $a.code + $b.code + "MUL\n";
    }
    // (a or b) === ((a+b) <> 0)
    | a=expr_bool OR b=expr_bool {
        $code = $a.code + $b.code + "ADD\n";
        $code += "PUSHI 0\n" + "NEQ\n";
    }
    // (a xor b) === (a <> b)
    | a=expr_bool XOR b=expr_bool { 
        $code = $a.code + $b.code + "NEQ\n";
    }
    | BOOLEEN {$code = "PUSHI " + $BOOLEEN.getText() + "\n";}
    | id=IDENTIFIANT {$code = "PUSHG " + adresse_pile.get($id.text) + "\n";}
;


/* ----------------------------------------------------------------------
# Expression flottante
---------------------------------------------------------------------- */
expr_float returns [String code]
    : L_PARENTHESE a=expr_float R_PARENTHESE {$code = $a.code;}
    | a=expr_float MUL_OU_DIV b=expr_float {$code = $a.code + $b.code + $MUL_OU_DIV.getText() + "\n";}
    | a=expr_float PLUS b=expr_float {$code = $a.code + $b.code + $PLUS.getText() + "\n";}
    | a=expr_float MOINS b=expr_float {$code = $a.code + $b.code + $MOINS.getText() + "\n";}
    | nombre_float {$code = $nombre_float.code;}
;


/* ----------------------------------------------------------------------
# Nombre flottant
---------------------------------------------------------------------- */
nombre_float returns [String code]
    : MOINS FLOAT {$code = "PUSHF -" + Float.parseFloat($FLOAT.text) + '\n';}
    | FLOAT {$code = "PUSHF " + Float.parseFloat($FLOAT.text) + '\n';}
;


/* ----------------------------------------------------------------------
# Fin d'instruction
---------------------------------------------------------------------- */
fin_instruction
    : NEWLINE | POINT_VIRGULE
;


/* ############################# LEXER ############################### */
/* ----------------------------------------------------------------------
# Fin instruction
---------------------------------------------------------------------- */
NEWLINE : BACKSLASH_R? BACKSLASH_N;
fragment BACKSLASH_N : '\n';
fragment BACKSLASH_R : '\r';

POINT_VIRGULE : ';';


/* ----------------------------------------------------------------------
# Autres
---------------------------------------------------------------------- */
VIRGULE : ',';
POINT : '.';


/* ----------------------------------------------------------------------
# Mise en page
---------------------------------------------------------------------- */
WHITESPACE : (ESPACE | TAB)+ -> skip;
fragment ESPACE : ' ';
fragment TAB : '\t';


/* ----------------------------------------------------------------------
# Nombres
---------------------------------------------------------------------- */
ENTIER : CHIFFRE+; // todo: les nombres commençant par 0 exemple : "042" ?
FLOAT : CHIFFRE+ (POINT | VIRGULE) CHIFFRE+ | CHIFFRE+ FLOAT_EXPONENT CHIFFRE+;

fragment CHIFFRE : ('0'..'9');
fragment FLOAT_EXPONENT : 'e';


/* ----------------------------------------------------------------------
# Booléens
---------------------------------------------------------------------- */
BOOLEEN : TRUE { setText("1"); } | FALSE { setText("0"); };

fragment TRUE : 'true';
fragment FALSE : 'false';


/* ----------------------------------------------------------------------
# Parenthèses
---------------------------------------------------------------------- */
// 
L_PARENTHESE : '(';
R_PARENTHESE : ')';
L_ACCOLADE : '{';
R_ACCOLADE : '}';


/* ----------------------------------------------------------------------
# Commentaires

Syntaxes :

// commentaire

/* commentaire 
sur plusieurs lignes*/
/* ------------------------------------------------------------------- */
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


/* ----------------------------------------------------------------------
# Opérations arithmétiques
---------------------------------------------------------------------- */
MUL_OU_DIV
    : SYMBOLE_FOIS { setText("MUL"); }
    | SYMBOLE_DIV { setText("DIV"); }
;

EXP : '^' | SYMBOLE_FOIS SYMBOLE_FOIS;
PLUS : SYMBOLE_PLUS { setText("ADD"); };
MOINS : SYMBOLE_MOINS { setText("SUB"); };

fragment SYMBOLE_PLUS : '+';
fragment SYMBOLE_MOINS : '-';
fragment SYMBOLE_FOIS : '*';
fragment SYMBOLE_DIV : '/';


/* ----------------------------------------------------------------------
# Symboles d'affectation
---------------------------------------------------------------------- */
EGAL : '='; // égal d'affectation
INCREMENTATION : SYMBOLE_PLUS SYMBOLE_PLUS { setText("ADD"); };
DECREMENTATION : SYMBOLE_MOINS SYMBOLE_MOINS { setText("SUB"); };


/* ----------------------------------------------------------------------
# Opérateurs de comparaison
---------------------------------------------------------------------- */
OP_COMPARAISON
    : '==' { setText("EQUAL"); }
    | '<>' { setText("NEQ"); }
    | '<=' { setText("INFEQ"); }
    | '<' { setText("INF"); }
    | '>=' { setText("SUPEQ"); }
    | '>' { setText("SUP"); }
;


/* ----------------------------------------------------------------------
# Opérateurs booléens
---------------------------------------------------------------------- */
AND : 'and';
OR : 'or';
OR_LAZY : 'or_lazy';
XOR : 'xor';
NOT : 'not';


/* ----------------------------------------------------------------------
# Déclaration de variables
---------------------------------------------------------------------- */
TYPE : INT | BOOL_TYPE | FLOAT_TYPE;
INT : 'int';
BOOL_TYPE : 'bool';
FLOAT_TYPE : 'float';


/* ----------------------------------------------------------------------
# Structures de contrôle et boucles
---------------------------------------------------------------------- */
IF : 'if' | 'si';
ELSE : 'else' | 'sinon';
WHILE : 'while' | 'tantque';
FOR : 'for' | 'pour';
DO : 'do' | 'repeter';


/* ----------------------------------------------------------------------
# Fonctions built-in d'entrées/sorties

PRINT_FLOAT sert à afficher les floats.
---------------------------------------------------------------------- */
PRINT : 'print' | 'afficher';
READ : 'read' | 'lire';

PRINT_FLOAT : 'printf' | 'afficherf';

/* ----------------------------------------------------------------------
# Identifiant (variables, pourrait servir aux noms de fonction)

/!\ Important : à placer après tous les mots-clés.

Syntaxes possibles:

x

variable

variable123

CONSTANTE

NouvelleClasse

nomVariable

camelCase

snake_case

_private
---------------------------------------------------------------------- */
IDENTIFIANT : (LETTRE | UNDERSCORE) (LETTRE | CHIFFRE | UNDERSCORE)*;

fragment LETTRE : [a-z] | [A-Z];
fragment UNDERSCORE : '_';


/* ----------------------------------------------------------------------
# Non mentionné dans le Lexer : on skip.
---------------------------------------------------------------------- */
UNMATCH : . -> skip;
