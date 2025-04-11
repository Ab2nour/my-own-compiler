# Exemples

print(3*(5+2))
```llvm
@.str = private unnamed_addr constant [12 x i8] c"Result: %d\0A\00", align 1

declare i32 @printf(i8*, ...)  ; Déclaration de printf

define i32 @main() {
entry:
%0 = add i32 5, 2
%1 = mul i32 3, %0
    %format_str = getelementptr inbounds [16 x i8], [16 x i8]* @.str, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %format_str, i32 %1)    ; Retourner 0 (code de sortie)
    ret i32 0
}
```


a = 5, b = 3, return a + b
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
