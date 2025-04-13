from typing import Final

TAB: Final[str] = "    "

template_start = """declare i32 @printf(i8*, ...)

@format_string = constant [4 x i8] c"%d\\0A\\00"

define i32 @main() {
entry:
"""

template_end = """
    ret i32 0
}"""


class LlvmCodeBuilder:
    def __init__(self):
        self.code: str = ""

    def emit_lines(self, *lines: str):
        for line in lines:
            self.code += TAB + line + "\n"

    def get_code(self) -> str:
        code = template_start + self.code + template_end
        return code
