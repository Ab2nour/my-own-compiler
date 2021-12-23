#!/usr/bin/bash


# ---------------- Entrées ----------------
fichier="$1" # avec extension
option1="$2" # gui ou debug mvap
option2="$3" # debug mvap
nom_fichier="${fichier%.*}" # sans extension


# ---------------- Fonctions ----------------
function antlr4 () {
    java -Xmx500M -cp "$(pwd)/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool $@
}

function grun () {
    java -Xmx500M -cp "$(pwd)/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig $@
}

function compileMVAP () {
    java -cp $CLASSPATH MVaPAssembler $@
}

function execMVAP () {
    java -jar mvap/MVaP.jar $@
}


# ---------------- Script ----------------
antlr4 "$fichier"
javac *.java

read -p "Entrez votre expression : " expr


if [ "$option1" = "-gui" ] || [ "$option1" = "gui" ]
then
echo $expr | grun "$nom_fichier" 'start' -gui > fichier.mvap
else
echo $expr | grun "$nom_fichier" 'start' > fichier.mvap
fi


compileMVAP fichier.mvap


if [ "$option1" = "-d" ]
then
execMVAP fichier.mvap.cbap -d
else
execMVAP fichier.mvap.cbap
fi
