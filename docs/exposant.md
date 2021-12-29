**Attention** aux INT overflow avec MVaP : `2^3^4` suffit à faire un INT overflow par exemple.

Ce code MVAP affiche le résultat de 2^3.
```py
JUMP 4

# ---------- fonction EXP(nombre, exposant) ----------
# Renvoie résultat = nombre^exposant
#
# Places locales :
#   résultat -> -5
#   nombre -> -4
#   exposant -> -3
LABEL 0
    # à chaque étape i, 0 <= i <= exposant, résultat stocke la valeur nombre^i
    # et contient la valeur nombre^exposant à la fin
    PUSHI 1 # résultat = 1
    STOREL -5

    LABEL 1 # while exposant > 0
        PUSHL -3 # exposant
        PUSHI 0
        SUP # if (exposant > 0)
        JUMPF 2

        # résultat *= nombre
        PUSHL -5 # résultat
        PUSHL -4 # nombre
        MUL
        STOREL -5

        # exposant -= 1
        PUSHL -3
        PUSHI 1
        SUB
        STOREL -3

        JUMP 1

        # ici on a résultat = nombre^exposant
        LABEL 2
            RETURN

LABEL 4
    PUSHI 0 # résultat -> -5
    PUSHI 2 # nombre -> -4
    PUSHI 3 # exposant -> -3

    CALL 0 # EXP(2, 3)

    POP # exposant
    POP # nombre

    WRITE # print(résultat)
    POP # résultat
HALT
```

