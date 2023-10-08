```bash
bash tools/functions.sh

antlr4 src/TranspilePython/TranspilePython.g4
javac -classpath /usr/share/java/antlr4-runtime.jar  src/TranspilePython/*.java
```
