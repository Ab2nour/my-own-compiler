import sys
from pathlib import Path

from antlr4 import *

from src.LlvmVisitor import LlvmVisitor
from src.MvapVisitor import MVapVisitor
from src.generated.ExprLexer import ExprLexer
from src.generated.ExprParser import ExprParser
from src.EvalVisitor import EvalVisitor


def main():
    input_string = "x = 5; y = x+1; print(x+y+3); print(42);"  # input("Entrez une expression : ")
    input_stream = InputStream(input_string)
    lexer = ExprLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = ExprParser(stream)
    tree = parser.prog()

    # visitor = EvalVisitor()
    # result = visitor.visit(tree)
    # print(f"Résultat = {result}")
    #
    # mvap_visitor = MVapVisitor()
    # result = mvap_visitor.visit(tree)
    # print(f"Résultat =\n{result}")

    llvm_visitor = LlvmVisitor()
    result = llvm_visitor.visit(tree)
    print(f"Résultat =\n{result}")

    with Path("temp.ll").open("w", encoding="utf-8") as file:
        file.write(f"{result}")


if __name__ == "__main__":
    main()
