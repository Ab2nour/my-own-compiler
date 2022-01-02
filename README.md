## Présentation du projet
Il s'agit d'un projet de L3 visant à créer son propre (petit) langage de programmation, à l'aide de deux outils :
- **ANTLR4** pour gérer la grammaire, l'analyse lexicale et syntaxique,
- **MVàP** (Machine Virtuelle à Pile), qu'on peut considérer comme de l'assembleur simplifié sur plusieurs points, soit un langage de (très) bas niveau.

## MVaP et ANTLR4
On utilise une version spécifique de MVaP et ANTLR4, qui est disponible dans le dossier `tools`.


### Initialisation
On suppose que, à chaque commande exécutée, on se situe dans le dossier racine `projet-compilation` : 
```bash
cd projet-compilation # on suppose qu'on est dans ce dossier
```

On commence par charger les fonctions :
```bash
. tools/functions # (on peut remplacer le "." par "bash")
```


## Problèmes courants
### Windows (WSL)
#### ``syntax error near unexpected token `$'{\r''``
Ce problème vient de la différence dans la façon dont sont gérés les retours à la ligne entre Windows et Linux.

Il suffit de sélectionner tout le code dans `tools/functions.sh` (Ctrl+A), puis de le copier/coller directement dans le terminal, et faire `Entrée`.


