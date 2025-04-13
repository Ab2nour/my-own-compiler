from typing import TYPE_CHECKING

from src.generated.ExprParser import ExprParser
from src.code_generation.print import print_code

if TYPE_CHECKING:
    from src.llvm_visitor import LlvmVisitor


def handle_print(visitor: "LlvmVisitor", ctx: ExprParser.PrintContext) -> None:
    expr = visitor.visit(ctx.e)
    code = print_code(expr)
    visitor.code_builder.emit_lines(code)
