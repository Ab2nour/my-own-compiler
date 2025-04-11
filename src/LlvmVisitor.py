from typing_extensions import override

from src.generated.ExprVisitor import ExprVisitor
from src.generated.ExprParser import ExprParser

symbols_dict: dict[str, str] = {
    "+": "add",
    "-": "sub",
    "*": "mul",
    "/": "div",
}

template_start = """declare i32 @printf(i8*, ...)

@format_string = constant [4 x i8] c"%d\\0A\\00"

define i32 @main() {
entry:
"""

template_end = """
    ret i32 0
}"""


class LlvmVisitor(ExprVisitor):
    @override
    def __init__(self):
        super().__init__()
        self.variable_count: int = 0
        self.code: str = ""

    def getVariableCount(self):
        current_variable_count = self.variable_count
        self.variable_count += 1
        return f"var{current_variable_count}"

    @override
    def visitProg(self, ctx):
        code = template_start

        self.visitChildren(ctx)
        code += self.code

        code += template_end
        return code

    @override
    def visitMulDiv(self, ctx: ExprParser.MulDivContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        variable_count = self.getVariableCount()
        self.code += f"%{variable_count} = {symbol_text} i32 {op1}, {op2}\n"

        return f"%{variable_count}"

    @override
    def visitAddSub(self, ctx: ExprParser.AddSubContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        variable_count = self.getVariableCount()
        self.code += f"%{variable_count} = {symbol_text} i32 {op1}, {op2}\n"

        return f"%{variable_count}"

    @override
    def visitInt(self, ctx: ExprParser.IntContext):
        int_value = int(ctx.INT().getText())
        return f"{int_value}"

    @override
    def visitPrint(self, ctx: ExprParser.PrintContext):
        expr = self.visit(ctx.e)
        print_code = (
            f"call i32 @printf(i8* getelementptr ([4 x i8], [4 x i8]* "
            f"@format_string, i32 0, i32 0), i32 {expr})\n"
        )
        #todo self.variable_count += 2

        self.code += print_code

    @override
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())
