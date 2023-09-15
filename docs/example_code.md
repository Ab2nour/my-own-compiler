```py
int n = 100;

# This code demonstrates the if/else flow
if (n < 11) { # not executed 🙅🏻
  n++;
} else if (n < 40) { # not executed 🙅🏻
  n *= 10;
} else { # executed ✅
  int a, b;
  a = 2^3^2; 
  b = 400 + 35 * 2;
  n = a - b; # equals to 42
}

print(n); # outputs 42
```