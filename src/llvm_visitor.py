from typing_extensions import override

from src.generated.ExprVisitor import ExprVisitor
from src.generated.ExprParser import ExprParser

from src.llvm_builder import LlvmBuilder
from src.symbol_table import SymbolTable

symbols_dict: dict[str, str] = {
    "+": "add",
    "-": "sub",
    "*": "mul",
    "/": "div",
}


class LlvmVisitor(ExprVisitor):
    @override
    def __init__(self):
        super().__init__()
        self.builder: LlvmBuilder = LlvmBuilder()
        self.symbol_table: SymbolTable = SymbolTable()

    @override
    def visitProg(self, ctx: ExprParser.ProgContext):
        self.visitChildren(ctx)
        return self.builder.get_code()

    @override
    def visitMulDiv(self, ctx: ExprParser.MulDivContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        variable_count = self.symbol_table.get_variable_count()
        self.builder.emit_lines(f"%{variable_count} = {symbol_text} i32 {op1}, {op2}")

        return f"%{variable_count}"

    @override
    def visitAddSub(self, ctx: ExprParser.AddSubContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        variable_count = self.symbol_table.get_variable_count()
        self.builder.emit_lines(f"%{variable_count} = {symbol_text} i32 {op1}, {op2}")

        return f"%{variable_count}"

    @override
    def visitInt(self, ctx: ExprParser.IntContext):
        int_value = int(ctx.INT().getText())
        return f"{int_value}"

    @override
    def visitVar(self, ctx: ExprParser.VarContext):
        variable_name = ctx.IDENTIFIER().getText()
        variable_id = self.symbol_table.variables[variable_name]

        if not self.symbol_table.variables_is_loaded[variable_name]:
            self.builder.emit_lines(
                f"%{variable_id}_val = load i32, i32* %{variable_id}"
            )
            self.symbol_table.variables_is_loaded[variable_name] = True

        return f"%{variable_id}_val"

    @override
    def visitPrint(self, ctx: ExprParser.PrintContext):
        expr = self.visit(ctx.e)
        print_code = (
            f"call i32 @printf(i8* getelementptr ([4 x i8], [4 x i8]* "
            f"@format_string, i32 0, i32 0), i32 {expr})"
        )

        self.builder.emit_lines(print_code)

    @override
    def visitDeclaration(self, ctx: ExprParser.DeclarationContext):
        variable_name = ctx.IDENTIFIER().getText()
        variable_value = self.visit(ctx.e)

        variable_id = f"{variable_name}_{self.symbol_table.get_variable_count()}"
        self.symbol_table.variables[variable_name] = variable_id
        self.symbol_table.variables_is_loaded[variable_name] = False

        self.builder.emit_lines(
            f"%{variable_id} = alloca i32, align 4",
            f"store i32 {variable_value}, i32* %{variable_id}",
        )

    @override
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())
