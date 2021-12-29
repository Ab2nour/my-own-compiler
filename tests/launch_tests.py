# ---------- Imports ----------
import subprocess
import os


# ---------- Fonctions ----------
def add_tests(name, title):
    """
    Cette fonction ajoute les tests au fichier launch_tests.sh.

    ---
    name: nom du fichier de test (sans l'extension '.test')
    title: titre affiché dans le script Bash
    """
    with open(f'tests/{name}.test') as fichier_test:
        tests = fichier_test.read()

        # On sépare tous les tests
        tests = tests.split('-----')

        # Au sein de chaque test, on sépare entrée et sortie attendue
        tests = list(map(lambda x: x.split('==out=='), tests))

        # On enlève les espaces et sauts à la ligne
        for i in range(len(tests)):
            tests[i][0] = tests[i][0].strip()
            tests[i][1] = tests[i][1].strip()

            # on remplace retours à la ligne par espaces
            # car MVaP n'affiche pas de retour à la ligne
            tests[i][1] = tests[i][1].replace('\n', ' ') 


    with open('launch_tests.sh', mode='a') as fichier_sortie:
        fichier_sortie.write(f"echo; echo\n")

        padded_title = (' ' + title + ' ')
        fichier_sortie.write(f"echo {padded_title.center(67, '-')}\n")
        fichier_sortie.write(f"echo\n")

        for entree, sortie in tests:
            fichier_sortie.write(f"test_expr '{entree}' '{sortie}'\n")


# ---------- Code ----------
add_tests('expr_arithmetiques', 'Expressions Arithmétiques')
add_tests('booleens', 'Booléens')
add_tests('commentaires', 'Commentaires')
add_tests('declarations', 'Déclarations')
add_tests('exposants', 'Exposants')
