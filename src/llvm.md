# Exemples

```llvm
define i32 @main() {
entry:
    ; Allocation pour a et b
    %a = alloca i32, align 4
    %b = alloca i32, align 4

    ; Initialisation de a et b
    store i32 5, i32* %a
    store i32 3, i32* %b

    ; Charger les valeurs de a et b
    %a_val = load i32, i32* %a
    %b_val = load i32, i32* %b

    ; Additionner a et b
    %sum = add i32 %a_val, %b_val

    ; Retourner le résultat
    ret i32 %sum
}
```
