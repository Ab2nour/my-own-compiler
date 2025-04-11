# Compile grammar

Run `uv run antlr4 src/Expr.g4 -Dlanguage=Python3 -visitor -o src/generated`

In case of timeout, add version `-v <antlr4-version>`: `uv run antlr4 src/Expr.g4 -Dlanguage=Python3 -visitor -o src/generated -v 4.13.2
`

You can otherwise edit `.venv/Lib/site-packages/antlr4_tool_runner.py`.

# Run grammar

Run `uv run src/main.py`.

Type whatever you want, according to the grammar, for example `3*(5+2)`.

You should get a `temp.ll` file.

# Run LLVM code

Run `clang temp.ll -o temp`.

Execute `temp`.
