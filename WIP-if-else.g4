
structure_if returns [String code]
 @init {
   String instruction_if = new String();
   String label_if = nouveauLabel();
 }
 : IF L_PARENTHESE expr_bool R_PARENTHESE L_ACCOLADE NEWLINE*
      (instruction fin_expression+ {instruction_if += $instruction.code;})+
   R_ACCOLADE {
   $code = $expr_bool.code;
   $code += "JUMPF " + label_if + "\n";
   $code += instruction_if;
   $code += "LABEL " + label_if + "\n";
 }
 | IF L_PARENTHESE expr_bool R_PARENTHESE NEWLINE?
      instruction POINT_VIRGULE? NEWLINE {
   instruction_if += $instruction.code;

   $code = $expr_bool.code;
   $code += "JUMPF " + label_if + "\n";
   $code += instruction_if;
   $code += "LABEL " + label_if + "\n";
  }
;

structure_else returns [String code]
 @init {
   String instruction_else = new String();
   String label_else = nouveauLabel();
 }
 : ELSE L_ACCOLADE NEWLINE*
      (instruction fin_expression+ {instruction_else += $instruction.code;})+
   R_ACCOLADE {
   $code += "JUMP " + label_else + "\n";
   $code += "LABEL " + label_if + "\n";
   $code += instruction_else;
   $code += "LABEL " + label_else + "\n";
 }
 | IF L_PARENTHESE expr_bool R_PARENTHESE NEWLINE*
      instruction NEWLINE {instruction_if += $instruction.code;}
   ELSE (IF) NEWLINE*
      instruction NEWLINE+ {instruction_else += $instruction.code;}
   R_ACCOLADE {

   $code = $expr_bool.code;
   $code += "JUMPF " + label_if + "\n";
   $code += instruction_if;
   $code += "JUMP " + label_else + "\n";
   $code += "LABEL " + label_if + "\n";
   $code += instruction_else;
   $code += "LABEL " + label_else + "\n";
 }
;
