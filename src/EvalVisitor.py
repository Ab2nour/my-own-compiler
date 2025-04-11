from typing_extensions import override

from src.generated.ExprVisitor import ExprVisitor
from src.generated.ExprParser import ExprParser


class EvalVisitor(ExprVisitor):
    @override
    def visitProg(self, ctx):
        return self.visit(ctx.expr())

    @override
    def visitMulDiv(self, ctx: ExprParser.MulDivContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol = ctx.symbol.text

        match symbol:
            case "*":
                return op1 * op2
            case "/":
                return op1 // op2

    @override
    def visitAddSub(self, ctx: ExprParser.AddSubContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol = ctx.symbol.text

        match symbol:
            case "+":
                return op1 + op2
            case "-":
                return op1 - op2

    @override
    def visitInt(self, ctx: ExprParser.IntContext):
        return int(ctx.INT().getText())

    @override
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())
