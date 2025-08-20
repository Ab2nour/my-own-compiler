from typing_extensions import override

from src.compiler_logic.variable import handle_variable
from src.generated.ExprVisitor import ExprVisitor
from src.generated.ExprParser import ExprParser

from src.compiler_logic.arithmetic import handle_mul_div, handle_add_sub
from src.compiler_logic.declaration import handle_declaration
from src.compiler_logic.print import handle_print
from src.llvm_code_builder import LlvmCodeBuilder
from src.symbol_table import SymbolTable


class LlvmVisitor(ExprVisitor):
    @override
    def __init__(self):
        super().__init__()
        self.code_builder: LlvmCodeBuilder = LlvmCodeBuilder()
        self.symbol_table: SymbolTable = SymbolTable()

    @override
    def visitProg(self, ctx: ExprParser.ProgContext):
        self.visitChildren(ctx)
        return self.code_builder.get_code()  # todo: move to compiler_logic

    @override
    def visitMulDiv(self, ctx: ExprParser.MulDivContext) -> str:
        return handle_mul_div(self, ctx)

    @override
    def visitAddSub(self, ctx: ExprParser.AddSubContext) -> str:
        return handle_add_sub(self, ctx)

    @override
    def visitVar(self, ctx: ExprParser.VarContext) -> str:
        return handle_variable(self, ctx)

    @override
    def visitPrint(self, ctx: ExprParser.PrintContext):
        return handle_print(self, ctx)

    @override
    def visitDeclaration(self, ctx: ExprParser.DeclarationContext):
        return handle_declaration(self, ctx)

    @override
    def visitIf(self, ctx: ExprParser.IfContext):
        # todo
        pass

    @override
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())  # todo: move to compiler_logic

    @override
    def visitInt(self, ctx: ExprParser.IntContext):
        int_value = int(ctx.INT().getText())
        return f"{int_value}"  # todo: move to compiler_logic

    @override
    def visitTrue(self, ctx: ExprParser.TrueContext):
        return "1"

    @override
    def visitFalse(self, ctx: ExprParser.FalseContext):
        return "0"
