#!/usr/bin/bash
# Script CI utilisé pour les Github Actions

# on récupère toutes les fonctions de functions.sh
source tools/functions.sh

init_mvap

python3 tests/launch_tests.py  # crée le fichier launch_tests.sh

nb_tests=0
nb_tests_faux=0

source launch_tests.sh
rm launch_tests.sh

affiche_bilan
