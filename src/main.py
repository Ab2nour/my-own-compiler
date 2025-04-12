from pathlib import Path

from antlr4 import *

from src.llvm_visitor import LlvmVisitor
from src.generated.ExprLexer import ExprLexer
from src.generated.ExprParser import ExprParser


def main():
    input_string = "x = 5; y = x+1; if (true) {print(x);}; if (false) {print(y);}; print(x+y);"  # input("Entrez une expression : ")
    input_string = "x = 5; y = x+1; print(x+y+3); print(42);"
    print(f"{input_string = }")
    input_stream = InputStream(input_string)

    lexer = ExprLexer(input_stream)
    stream = CommonTokenStream(lexer)

    parser = ExprParser(stream)
    tree = parser.prog()

    llvm_visitor = LlvmVisitor()
    result = llvm_visitor.visit(tree)
    print(f"Résultat =\n{result}")

    with Path("temp.ll").open("w", encoding="utf-8") as file:
        file.write(f"{result}")


if __name__ == "__main__":
    main()
