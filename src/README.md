Run `uv run antlr4 src/Expr.g4 -Dlanguage=Python3 -visitor -o src/generated`

In case of timeout, add version `-v <antlr4-version>`: `uv run antlr4 src/Expr.g4 -Dlanguage=Python3 -visitor -o src/generated -v 4.13.2
`

You can otherwise edit `.venv/Lib/site-packages/antlr4_tool_runner.py`.
