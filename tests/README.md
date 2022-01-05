# Fonctionnement des tests
Chaque test est constitué d'un fichier `nom_fichier.xml` contenant les entrées des tests et les sorties attendues.


## Format attendu

On attend que les tests soient au format `xml`.
  
Un exemple vaut mieux qu'un long discours...  


### Exemple : `exemple.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<tests titre="Exemple" description="Ces tests vont juste servir d'exemple">
    <test>
      <titre>Premier test</titre>
      <description>Ceci est le test numéro 1</description>
      <entree>entrée1</entree>
      <sortie>sortie1</sortie>
    </test>
    
    <test>
      <!-- description optionnelle -->
      <titre>Plusieurs lignes</titre>
      <entree>
          entrée2
          sur
          plusieurs lignes
      </entree>
      <sortie>
          sortie2
          sur
          plusieurs lignes
      </sortie>
    </test>
    
    <test>
      <!-- titre et description optionnels -->
      <entree>entrée 3</entree>
      <sortie>sortie3</sortie>
    </test>
</tests>
``` 

_Les espaces et retours à la ligne sont optionnels mais très fortement recommandés._

### Note pour les sorties :
MVaP ne permet pas d'afficher les sorties sur des lignes différentes : celles-ci sont donc toutes sur la même ligne, séparées par un espace.  
Cependant, pour des raisons de lisibilité, dans les fichiers `.test`, on peut mettre des retours à la ligne dans les *sorties*, qui seront automatiquement converties en espace par le script Python `launch_tests.py`.
