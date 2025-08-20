def print_code(expr: str) -> str:
    return (
        "call i32 @printf(i8* getelementptr ([4 x i8], [4 x i8]* "
        f"@format_string, i32 0, i32 0), i32 {expr})"
    )
