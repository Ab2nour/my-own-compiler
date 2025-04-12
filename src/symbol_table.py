from dataclasses import dataclass


@dataclass
class SymbolInfo:
    name: str
    var_type: str
    initialized: bool
    llvm_id: str


class SymbolTableTemp:
    def __init__(self):
        self.scopes = [{}]  # La pile de scopes (scope global au début)

    def push_scope(self):
        self.scopes.append({})  # Nouveau scope (fonction)

    def pop_scope(self):
        if len(self.scopes) <= 1:
            raise Exception("Cannot pop global scope")
        self.scopes.pop()

    def declare(self, name: str, var_type: str, llvm_id: str):
        current_scope = self.scopes[-1]
        if name in current_scope:
            raise Exception(f"Variable '{name}' already declared in this scope")
        current_scope[name] = SymbolInfo(name, var_type, False, llvm_id)

    def initialize(self, name: str):
        info = self.lookup(name)
        info.initialized = True

    def lookup(self, name: str):
        # D'abord, recherche dans les scopes internes (du plus local au plus global)
        for scope in reversed(self.scopes):
            if name in scope:
                return scope[name]
        # Si on ne trouve rien dans le scope actuel, on va chercher dans le global
        if len(self.scopes) == 1:  # On est dans le scope global
            raise Exception(f"Variable '{name}' not declared")
        return None  # Laisser la possibilité de lever une exception si la variable n'existe pas

    def dump(self):
        print("=== Symbol Table ===")
        for i, scope in enumerate(reversed(self.scopes)):
            print(f"Scope {len(self.scopes) - 1 - i}:")
            for sym in scope.values():
                status = "✅" if sym.initialized else "❌"
                print(
                    f"  {sym.name} : type={sym.var_type}, init={status}, llvm_id={sym.llvm_id}"
                )


class SymbolTable:
    def __init__(self):
        self.scopes = [{}]
        self.variable_count: int = 0
        self.variables: dict[str, str] = dict()
        self.variables_is_loaded: dict[str, bool] = dict()

    def push_scope(self):
        self.scopes.append({})

    def get_variable_count(self):
        current_variable_count = self.variable_count
        self.variable_count += 1
        return f"var{current_variable_count}"
