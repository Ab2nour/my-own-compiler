# ---------- Imports ----------
import subprocess
import os


# ---------- Fonctions ----------
def test(entree, sortie):
    """
    Etant donné une entrée et une sortie attendue,
    vérifie si le résultat de l'entrée par ANTLR+MVaP
    produit bien le bon résultat.
    """
    s = subprocess.run([f"test_expr '{entree}' '{sortie}'"], executable='/bin/bash',
        capture_output=True)
    print(s)


# ---------- Code ----------
s = subprocess.run(["cd tests"], executable='/bin/bash', capture_output=True)
print(s)

print(f'dossier courant : {os.getcwd()}')

s = subprocess.run(["pwd"], executable='/bin/bash', capture_output=True)
print(s)

with open('booleens.test') as fichier_test:
    tests = fichier_test.read()

    # On sépare tous les tests
    tests = tests.split('-----')

    # Au sein de chaque test, on sépare entrée et sortie attendue
    tests = list(map(lambda x: x.split('==out=='), tests))

    # On enlève les espaces et sauts à la ligne
    for i in range(len(tests)):
        tests[i][0] = tests[i][0].strip()
        tests[i][1] = tests[i][1].strip()


subprocess.run(["ls", "-l", "/dev/null"], capture_output=True)

s = subprocess.run(["test_expr '41+1' '42'"], executable='/bin/bash',
    capture_output=True)
print(s)
s = subprocess.run(["test_expr", "'41+1'", "'42'"], executable='/bin/bash',
    capture_output=True)
print(s)

for e, s in tests:
    test(e, s)
