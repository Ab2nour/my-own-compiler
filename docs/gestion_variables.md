# Introduction
> Comment gérer les variables en MVaP ?

Une variable correspond principalement à deux choses : son **nom**, et son **adresse**.

On va utiliser les `HashMap` de Java, pour associer le nom à l'adresse (et d'autres informations comme le type, ...).

Soit `adresse_variable` l'adresse de notre variable dans la pile.
- pour **récupérer** la valeur de la variable en haut de pile, on fait `PUSHG adresse_variable`,
- pour **stocker** la valeur en haut de la pile dans la variable, on fait `STOREG adresse_variable`.

# Exemple

Soit `variable` un entier de valeur inconnue.
Voici un exemple de pile, avec le bas de la pile à gauche, et le sommet à droite (on empile à droite)

`bas [2, 5, variable, 6, 3, 87] sommet`  
`     0  1     2      3  4   5` ← *places dans la pile*
 
La place de `variable` dans la pile est 2.
On a donc, dans la `HashMap` : `variable → 2`

Maintenant, on veut exécuter l'instruction `variable = variable + 10`.

**1) On met `variable` en haut de pile**

  `PUSHG 2`

  `bas [2, 5, variable, 6, 3, 87, variable] sommet`

**2) On rajoute 10 dans la pile**
  `PUSHI 10`

  début [2, 5, variable, 6, 3, 87, variable, 10] fin
ADD

début [2, 5, variable, 6, 3, 87, variable+10] fin
STOREG adresse => pile[adresse] = sommet de pile
STOREG 2
début [2, 5, variable+10, 6, 3, 87] fin
HashMap['variable'] = 2
autre exemple, la pile est vide
int x
HashMap['x'] = 0
