echo; echo
echo -------------------- Expressions Arithmétiques --------------------
echo
test_expr 'print(3 + 5)' '8'
test_expr '3 * 5' '15'
test_expr '3*5' '15'
test_expr '3 - 5' '-2'
test_expr '6 / 3' '2'
test_expr '5 / 2' '2'
test_expr '5 * 8 + 2 * 1' '42'
test_expr '5 * (8 + 2) * 1' '50'
test_expr '6 * 4 / 5 + 38' '42'
test_expr '2*(5+2 * 8+ 3) - 6' '42'
test_expr '5+5;
2+2' '10 4'
test_expr '5+5;2+2' '10 4'
test_expr '5+5;
2+2;' '10 4'
test_expr '5 + 3

4 + 5' '8 9'
test_expr '2 + 2 * 2' '6'
test_expr '-2' '-2'
test_expr '-2 + 3' '1'
test_expr '42
24+24-6
5*8+2*1
6*4/5+38
42+1+2+-3
5*8+2*-1/-1
(5*6*7*11 + 2)/11*5-1008
(5*6*7*11 + 2)/(11*5)
(5*6*7*11 + 2)/11/5
(5*6*7*11 + 2)/(11/5)-1114' '42 42 42 42 42 42 42 42 42 42'
echo; echo
echo ----------------------------- Booléens ----------------------------
echo
test_expr 'true and false or true and not true' '0'
test_expr 'true or false and false' '1'
test_expr 'true or (false or false)' '1'
test_expr 'false or (true and not false)' '1'
test_expr '(not true and false) or (true and not false)' '1'
test_expr 'true and false or true and not true
true or false and false
true or (false or false)
false or (true and not false)
(not true and false) or (true and not false)' '0 1 1 1 1'
echo; echo
echo --------------------------- Commentaires --------------------------
echo
test_expr '42 // ceci doit être ignoré 2+2
42' '42 42'
test_expr '42; // ceci doit être ignoré 2+2
42' '42 42'
test_expr '42 /* ignoré 2+2 */
42' '42 42'
test_expr '42; /* ignoré 2+2 */' '42'
test_expr '42 /* ignoré 2+2
ignoré 2+2
ignoré 2+2 */' '42'
echo; echo
echo --------------------------- Déclarations --------------------------
echo
test_expr 'int x;
2+2
print(x)
x = 3
print(x)
x = 5
print(x)' '0 3 5'
