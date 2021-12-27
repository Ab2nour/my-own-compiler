#!/usr/bin/bash
# ---------------- Fonctions ----------------            
function initialisation () {
    export CLASSPATH=.:tools/antlr-4.9.2-complete.jar:tools/mvap/MVaP.jar:$CLASSPATH
    cd tools/mvap
    jar cfm MVaP.jar META-INF/MANIFEST.MF *.class
    cd ../..
}

function antlr4 () {
    java -Xmx500M -cp "tools/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool $@
}

function grun () {
    java -Xmx500M -cp "tools/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig $@
}

function compileMVAP () {
    java -cp $CLASSPATH MVaPAssembler $@
}

function execMVAP () {
    java -jar tools/mvap/MVaP.jar $@
}


function mvap () {
    # Utilisation :
    # mvap 'expression' -> évalue une expression
    # mvap -f fichier.txt -> évalue un fichier
    initialisation

    antlr4 Calculette.g4                
    javac *.java

    
    if [ "$1" = "-f" ] ## si c'est un fichier
    then
        nom_fichier="$2"
    else
    echo "❌ $expr = $resultat   (!= $resultat_attendu)"      
    let "nb_tests_faux+=1"
    fi

    expr="$1"

    echo "$expr" | grun Calculette 'start' > fichier.mvap

    compileMVAP fichier.mvap

    execMVAP fichier.mvap.cbap
}


function mvap_fichier () {
    #
    initialisation

    antlr4 Calculette.g4                
    javac *.java

    expr="$1"

    echo "$expr" | grun Calculette 'start' > fichier.mvap

    compileMVAP fichier.mvap

    execMVAP fichier.mvap.cbap
}


function init_mvap () {
    # Effectue l'initialisation nécessaire à la fonction `mvap_sans_init`
    initialisation

    antlr4 Calculette.g4                
    javac *.java
}


function mvap_sans_init () {
    # Idem que mvap, mais ici on ne compile pas avec antlr4 et javac
    # On considère donc que l'initialisation des fichiers de la
    # grammaire a déjà été effectuée.
    expr="$1"

    echo "$expr" | grun Calculette 'start' > fichier.mvap

    compileMVAP fichier.mvap

    execMVAP fichier.mvap.cbap
}


function mvap_debug () {
    # Mode debug pour grun (option `-tokens`)
    # Mode debug pour mvap (option `-d`)
    initialisation

    antlr4 Calculette.g4                
    javac *.java

    expr="$1"

    echo "$expr" | grun Calculette 'start' -tokens
    echo "$expr" | grun Calculette 'start' > fichier.mvap

    compileMVAP fichier.mvap

    execMVAP fichier.mvap.cbap -d
}


function test_expr () {
    ### Cette fonction teste une expression
    # D'abord l'expression
    # Puis la valeur attendue

    let "nb_tests+=1"

    expr=$1
    resultat_attendu=$2

    resultat=$(mvap_sans_init "$expr" | xargs) # xargs trims whitespace

    if [ "$resultat" = "$resultat_attendu" ] then
        echo "✅ $expr = $resultat"
    else
        echo "❌ $expr = $resultat   (!= $resultat_attendu)"      
        let "nb_tests_faux+=1"
    fi
}

function affiche_bilan () {
    # On affiche le bilan des tests
    echo; echo
    echo "-------------------------------------------------------------------"
    echo "🤵 $nb_tests tests ont été effectués."  
    echo
    echo "✅ Il y a $(( nb_tests - nb_tests_faux )) tests passés avec succès."  


    if (( $nb_tests_faux > 0 )) then
        echo "❌ Il y a $nb_tests_faux tests faux."  
        exit 42
    fi
}
