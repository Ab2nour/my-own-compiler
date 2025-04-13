from typing import TYPE_CHECKING

from src.code_generation.declaration import declaration_code
from src.generated.ExprParser import ExprParser

if TYPE_CHECKING:
    from src.llvm_visitor import LlvmVisitor


def handle_declaration(
    visitor: "LlvmVisitor", ctx: ExprParser.DeclarationContext
) -> None:
    variable_name = ctx.IDENTIFIER().getText()
    variable_value = visitor.visit(ctx.e)

    visitor.symbol_table.declare_variable(variable_name)
    variable_id = visitor.symbol_table.variables[variable_name]

    code = declaration_code(variable_id, variable_value)
    visitor.code_builder.emit_lines(*code)
