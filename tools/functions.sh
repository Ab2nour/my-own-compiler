#!/usr/bin/bash
# On suppose que le script est lancé depuis le dossier `projet-compilation`.

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

    init_mvap

    mvap_sans_init "$@"
}

function init_mvap () {
    # Effectue l'initialisation nécessaire à la fonction `mvap_sans_init`
    antlr4 Calculette_MADANIAbdenour_TRIOLETHugo.g4                
    javac *.java
}


function mvap_sans_init () {
    # Utilisation :
    # mvap_sans_init 'expression' -> évalue une expression
    # mvap_sans_init -f fichier.txt -> évalue un fichier
    #
    # Différence :
    # Idem que mvap, mais ici on ne compile pas avec antlr4 et javac
    # On considère donc que l'initialisation des fichiers de la
    # grammaire a déjà été effectuée.
    
    if [ "$1" = "-f" ]; then # si c'est un fichier
        nom_fichier="$2"
        cat "$nom_fichier" | grun Calculette_MADANIAbdenour_TRIOLETHugo 'calcul' > fichier.mvap
    else        
        expression="$1"
        echo "$expression" > entree.temp

        cat entree.temp | grun Calculette_MADANIAbdenour_TRIOLETHugo 'calcul' > fichier.mvap
        rm entree.temp
    fi

    compileMVAP fichier.mvap
    execMVAP fichier.mvap.cbap
}


function mvap_debug () {
    # Utilisation :
    # mvap_debug 'expression' -> évalue une expression
    # mvap_debug -f fichier.txt -> évalue un fichier
    #
    # Différences :
    # - Mode debug pour grun (option `-tokens`)
    # - Mode debug pour mvap (option `-d`)

    init_mvap

    expr="$1"

    if [ "$1" = "-f" ]; then # si c'est un fichier
        nom_fichier="$2"

        cat "$nom_fichier" | grun Calculette_MADANIAbdenour_TRIOLETHugo 'calcul' -tokens
        cat "$nom_fichier" | grun Calculette_MADANIAbdenour_TRIOLETHugo 'calcul' > fichier.mvap
    else        
        expression="$1"
        echo "$expression" > entree.temp

        cat entree.temp | grun Calculette_MADANIAbdenour_TRIOLETHugo 'calcul' -tokens
        cat entree.temp | grun Calculette_MADANIAbdenour_TRIOLETHugo 'calcul' > fichier.mvap

        rm entree.temp
    fi

    compileMVAP fichier.mvap
    execMVAP fichier.mvap.cbap -d
}


function test_expr () {
    ### Cette fonction teste une expression
    # D'abord l'expression
    # Puis la valeur attendue
    # $3 : entrée standard donnée au programme
    # $4 : description du test (affiché en cas d'erreur)

    let "nb_tests+=1"

    expr="$1"
    resultat_attendu="$2"
    stdin="$3"
    description="$4"

    resultat=$(echo "$stdin" | mvap_sans_init "$expr" | xargs) # xargs trims whitespace

    if [ "$resultat" = "$resultat_attendu" ]; then
        echo "✅ Test passé avec succès"
        echo "----- Entrée -----"
        echo "$expr"
        echo "----- Résultat attendu -----"
        echo "$resultat"
        echo; echo;
    else
        echo "❌ Echec du test"
        echo
        echo "----- Description -----"
        echo "$description"
        echo
        echo "----- Entrée -----"
        echo "$expr"
        echo "----- Résultat attendu -----"
        echo "$resultat_attendu"
        echo "----- Résultat obtenu ❌ -----"
        echo "$resultat"
        echo; echo;     
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


    if (( $nb_tests_faux > 0 )); then
        echo "❌ Il y a $nb_tests_faux tests faux."  
        exit 42
    fi
}

# On initialise MVaP
initialisation
