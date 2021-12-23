#!/usr/bin/bash


# ---------------- Entrées ----------------
fichier="$1"
option1="$2" # debug mvap
nom_fichier="${fichier%.*}"


# ---------------- Fonctions ----------------
function compileMVAP () {
    java -cp $CLASSPATH MVaPAssembler $@
}

function execMVAP () {
    java -jar mvap/MVaP.jar $@
}


# ---------------- Script ----------------
compileMVAP $fichier


if [ "$option1" = "-d" ]
then
execMVAP "$fichier.cbap" -d
else
execMVAP "$fichier.cbap"
fi
