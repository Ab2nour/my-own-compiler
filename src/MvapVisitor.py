from typing_extensions import override

from src.generated.ExprVisitor import ExprVisitor
from src.generated.ExprParser import ExprParser

symbols_dict: dict[str, str] = {
    "+": "ADD",
    "-": "SUB",
    "*": "MUL",
    "/": "DIV",
}


class MVapVisitor(ExprVisitor):
    @override
    def visitProg(self, ctx):
        return self.visit(ctx.expr())

    @override
    def visitMulDiv(self, ctx: ExprParser.MulDivContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        return f"{op1}{op2}{symbol_text}\n"

    @override
    def visitAddSub(self, ctx: ExprParser.AddSubContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        return f"{op1}{op2}{symbol_text}\n"

    @override
    def visitInt(self, ctx: ExprParser.IntContext):
        int_value = int(ctx.INT().getText())
        return f"PUSHI {int_value}\n"

    @override
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())
