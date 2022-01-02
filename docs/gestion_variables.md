# Introduction
> Comment gérer les variables en MVaP ?

Une variable correspond principalement à deux choses : son **nom**, et son **adresse**.

On va utiliser les `HashMap` de Java, pour associer le nom à l'adresse (et d'autres informations comme le type, ...).

Soit `adresse_variable` l'adresse de notre variable dans la pile.
- pour **récupérer** la valeur de la variable en haut de pile, on fait `PUSHG adresse_variable`,
- pour **stocker** la valeur en haut de la pile dans la variable, on fait `STOREG adresse_variable`.

# Exemple
