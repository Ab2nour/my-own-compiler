from typing import TYPE_CHECKING

from src.code_generation.arithmetic import arithmetic_code
from src.generated.ExprParser import ExprParser

if TYPE_CHECKING:
    from src.llvm_visitor import LlvmVisitor

symbols_dict: dict[str, str] = {
    "+": "add",
    "-": "sub",
    "*": "mul",
    "/": "div",
}


def handle_arithmetic_operation(
    visitor: "LlvmVisitor", ctx: ExprParser.MulDivContext | ExprParser.AddSubContext
) -> str:
    op1 = visitor.visit(ctx.op1)
    op2 = visitor.visit(ctx.op2)
    symbol_text = symbols_dict[ctx.symbol.text]

    variable_count = visitor.symbol_table.get_variable_count()

    code = arithmetic_code(symbol_text, op1, op2, variable_count)
    visitor.code_builder.emit_lines(code)

    return f"%{variable_count}"


def handle_mul_div(visitor: "LlvmVisitor", ctx: ExprParser.MulDivContext) -> str:
    return handle_arithmetic_operation(visitor, ctx)


def handle_add_sub(visitor: "LlvmVisitor", ctx: ExprParser.AddSubContext) -> str:
    return handle_arithmetic_operation(visitor, ctx)
