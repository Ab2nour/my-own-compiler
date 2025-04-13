from typing import TYPE_CHECKING

from src.generated.ExprParser import ExprParser

if TYPE_CHECKING:
    from src.llvm_visitor import LlvmVisitor


def handle_variable(visitor: "LlvmVisitor", ctx: ExprParser.VarContext) -> str:
    variable_name = ctx.IDENTIFIER().getText()
    variable_id = visitor.symbol_table.variables[variable_name]

    if not visitor.symbol_table.variables_is_loaded[variable_name]:
        visitor.code_builder.emit_lines(
            f"%{variable_id}_val = load i32, i32* %{variable_id}"
        )
        visitor.symbol_table.variables_is_loaded[variable_name] = True

    return f"%{variable_id}_val"
