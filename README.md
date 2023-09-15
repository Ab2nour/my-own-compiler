# Présentation du projet
Il s'agit d'un projet de L3 visant à créer son propre (petit) langage de programmation.

![Extrait de code](
  img/example-code.svg
  "Exemple de code avec le langage créé"
)

Le langage est réalisé à l'aide de deux outils :
- **ANTLR4** pour gérer la grammaire, l'analyse lexicale et syntaxique,
- **MVàP** (Machine Virtuelle à Pile), qu'on peut considérer comme de l'assembleur simplifié sur plusieurs points, soit un langage de (très) bas niveau.

## Structure du projet
Le projet est structuré de cette façon :
- [`projet-compilation/`](https://github.com/Ab2nour/projet-compilation/tree/main/)
  - [`docs/`](https://github.com/Ab2nour/projet-compilation/tree/main/docs) : Documentation du projet
  - [`tests/`](https://github.com/Ab2nour/projet-compilation/tree/main/tests) : Tests
  - [`tools/`](https://github.com/Ab2nour/projet-compilation/tree/main/tests) : Fonctions utiles, **ANTLR4** _(v4.9.2)_ et **MVaP**
  - [`Calculette.g4`](https://github.com/Ab2nour/projet-compilation/blob/main/Calculette.g4) : la grammaire du langage


# MVaP et ANTLR4
On utilise une version spécifique de MVaP et ANTLR4, qui est disponible dans le dossier `tools`.


## Initialisation
On suppose que, à chaque commande exécutée, on se situe dans le dossier racine `projet-compilation` : 
```bash
cd projet-compilation # on suppose qu'on est dans ce dossier
```

On commence par charger les fonctions :
```bash
. tools/functions.sh # (on peut remplacer le "." par "bash")
```

## Utilisation
### `mvap`
On utilise principalement la commande `mvap` qui permet de tout faire (génération des fichiers ANTLR4, génération du code MVaP avec `grun`, puis compilation et exécution du code MVaP).
```bash
mvap 'print(2 + 3)' # affiche 5
mvap -f fichier.txt # prend en entrée fichier.txt
```

### `mvap_debug`
En cas de problème, on utilise la commande `mvap_debug`, avec la même syntaxe :
```bash
mvap_debug 'print(2 + 3)'
mvap_debug -f fichier.txt
```

Cette commande affichera d'abord tous les *tokens* reconnus par la grammaire, puis le code MVaP généré, et enfin la trace d'exécution MVaP.

# Problèmes courants
## Windows (WSL)
### ``syntax error near unexpected token `$'{\r''``
Ce problème vient de la différence dans la façon dont sont gérés les retours à la ligne entre Windows et Linux.

Il suffit de sélectionner tout le code dans `tools/functions.sh` (Ctrl+A), puis de le copier/coller directement dans le terminal, et faire `Entrée`.


