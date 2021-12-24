# Fonctionnement des tests
Chaque test est constitué d'un fichier `nom_fichier.test` contenant les entrées des tests et les sorties attendues.

Voici le format attendu :

`nom_fichier.test`
```
entrée1

==out==
sortie1

-----
entrée2
sur
plusieurs lignes

==out==
sortie2
sur
plusieurs lignes

-----
entrée 3

==out==
sortie3
``` 

Les entrées sont séparées par `-----` et la sortie est séparée par l'entrée par `==out==`.

_Les espaces et retours à la ligne sont optionnels mais très fortement recommandés._


