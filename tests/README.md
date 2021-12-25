# Fonctionnement des tests
Chaque test est constitué d'un fichier `nom_fichier.test` contenant les entrées des tests et les sorties attendues.


## Format attendu

Les entrées sont séparées par `-----` et la sortie est séparée par l'entrée par `==out==`.

_Les espaces et retours à la ligne sont optionnels mais très fortement recommandés._
  
Un exemple vaut mieux qu'un long discours...  


### Exemple : `exemple.test`
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


### Note pour les sorties :
MVaP ne permet pas d'afficher les sorties sur des lignes différentes : celles-ci sont donc toutes sur la même ligne, séparées par un espace.  
Cependant, pour des raisons de lisibilité, dans les fichiers `.test`, on peut mettre des retours à la ligne dans les *sorties*, qui seront automatiquement converties en espace par le script Python `launch_tests.py`.
