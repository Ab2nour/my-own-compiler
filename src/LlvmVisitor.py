from typing_extensions import override

from src.generated.ExprVisitor import ExprVisitor
from src.generated.ExprParser import ExprParser

symbols_dict: dict[str, str] = {
    "+": "add",
    "-": "sub",
    "*": "mul",
    "/": "div",
}

template_start = """@.str = private unnamed_addr constant [12 x i8] c"Result: %d\\0A\\00", align 1

declare i32 @printf(i8*, ...)  ; Déclaration de printf

define i32 @main() {
entry:
"""

template_end = """    ; Retourner 0 (code de sortie)
    ret i32 0
}"""


class LlvmVisitor(ExprVisitor):
    @override
    def __init__(self):
        super().__init__()
        self.variable_count: int = 0
        self.code:str = ""

    def getVariableCount(self):
        current_variable_count = self.variable_count
        self.variable_count += 1
        return current_variable_count

    @override
    def visitProg(self, ctx):
        code = template_start

        self.visit(ctx.expr())
        code += self.code

        print_code = f"""    %format_str = getelementptr inbounds [16 x i8], [16 x i8]* @.str, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %format_str, i32 %{self.getVariableCount() - 1})"""

        code += print_code
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
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())
