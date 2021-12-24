# ---------- Imports ----------
import subprocess
import os


# ---------- Code ----------
print(f'dossier courant : {os.getcwd()}')


with open('tests/booleens.test') as fichier_test:
    tests = fichier_test.read()

    # On sépare tous les tests
    tests = tests.split('-----')

    # Au sein de chaque test, on sépare entrée et sortie attendue
    tests = list(map(lambda x: x.split('==out=='), tests))

    # On enlève les espaces et sauts à la ligne
    for i in range(len(tests)):
        tests[i][0] = tests[i][0].strip()
        tests[i][1] = tests[i][1].strip()


with open('launch_tests.sh', mode='w') as fichier_sortie:
    fichier_sortie.write(f"test_expr '41+1' '42'\n")
    fichier_sortie.write(f"echo 'hello world !!!!'\n")


    for entree, sortie in tests:
        fichier_sortie.write(f"test_expr '{entree}' '{sortie}'")
