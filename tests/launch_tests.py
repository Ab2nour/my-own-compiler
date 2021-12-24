# ---------- Imports ----------
import subprocess


# ---------- Fonctions ----------
def test(entree, sortie):
    """
    Etant donné une entrée et une sortie attendue,
    vérifie si le résultat de l'entrée par ANTLR+MVaP
    produit bien le bon résultat.
    """
    s = subprocess.run(["test", f"'{entree}'", f"'{sortie}'"], executable='/bin/bash',
        capture_output=True)
    print(s)


# ---------- Code ----------
s = subprocess.run(["cd", "tests"], executable='/bin/bash', capture_output=True)

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

s = subprocess.run(["source", "tools/functions.sh"], executable='/bin/bash',
    capture_output=True)
print(s)

for e, s in tests:
    test(e, s)
