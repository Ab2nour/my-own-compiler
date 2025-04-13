def declaration_code(variable_id: str, variable_value: str) -> tuple[str, str]:
    return (
        f"%{variable_id} = alloca i32, align 4",
        f"store i32 {variable_value}, i32* %{variable_id}",
    )
