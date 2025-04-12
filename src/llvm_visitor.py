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
        self.variables: dict[str, str] = dict()
        self.variables_is_loaded: dict[str, bool] = dict()

    def get_variable_count(self):
        current_variable_count = self.variable_count
        self.variable_count += 1
        return f"var{current_variable_count}"

    @override
    def visitProg(self, ctx: ExprParser.ProgContext):
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

        variable_count = self.get_variable_count()
        self.code += f"%{variable_count} = {symbol_text} i32 {op1}, {op2}\n"

        return f"%{variable_count}"

    @override
    def visitAddSub(self, ctx: ExprParser.AddSubContext):
        op1 = self.visit(ctx.op1)
        op2 = self.visit(ctx.op2)
        symbol_text = symbols_dict[ctx.symbol.text]

        variable_count = self.get_variable_count()
        self.code += f"%{variable_count} = {symbol_text} i32 {op1}, {op2}\n"

        return f"%{variable_count}"

    @override
    def visitInt(self, ctx: ExprParser.IntContext):
        int_value = int(ctx.INT().getText())
        return f"{int_value}"

    @override
    def visitVar(self, ctx: ExprParser.VarContext):
        variable_name = ctx.IDENTIFIER().getText()
        variable_id = self.variables[variable_name]

        if not self.variables_is_loaded[variable_name]:
            self.code += f"%{variable_id}_val = load i32, i32* %{variable_id}\n"
            self.variables_is_loaded[variable_name] = True

        return f"%{variable_id}_val"

    @override
    def visitPrint(self, ctx: ExprParser.PrintContext):
        expr = self.visit(ctx.e)
        print_code = (
            f"call i32 @printf(i8* getelementptr ([4 x i8], [4 x i8]* "
            f"@format_string, i32 0, i32 0), i32 {expr})\n"
        )

        self.code += print_code

    @override
    def visitDeclaration(self, ctx: ExprParser.DeclarationContext):
        variable_name = ctx.IDENTIFIER().getText()
        variable_value = self.visit(ctx.e)

        variable_id = f"{variable_name}_{self.get_variable_count()}"
        self.variables[variable_name] = variable_id
        self.variables_is_loaded[variable_name] = False

        self.code += (
            f"%{variable_id} = alloca i32, align 4\nstore i32 {variable_value}, i32* %{variable_id}\n"
        )

    @override
    def visitParen(self, ctx: ExprParser.ParenContext):
        return self.visit(ctx.expr())
