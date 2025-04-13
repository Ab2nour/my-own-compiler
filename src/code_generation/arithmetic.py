def arithmetic_code(symbol_text: str, op1: str, op2: str, variable_count: str) -> str:
    return f"%{variable_count} = {symbol_text} i32 {op1}, {op2}"
