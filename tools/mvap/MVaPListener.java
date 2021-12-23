// Generated from MVaP.g4 by ANTLR 4.9.2

    import java.util.HashMap;

import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link MVaPParser}.
 */
public interface MVaPListener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link MVaPParser#program}.
	 * @param ctx the parse tree
	 */
	void enterProgram(MVaPParser.ProgramContext ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#program}.
	 * @param ctx the parse tree
	 */
	void exitProgram(MVaPParser.ProgramContext ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#instr}.
	 * @param ctx the parse tree
	 */
	void enterInstr(MVaPParser.InstrContext ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#instr}.
	 * @param ctx the parse tree
	 */
	void exitInstr(MVaPParser.InstrContext ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#commande1}.
	 * @param ctx the parse tree
	 */
	void enterCommande1(MVaPParser.Commande1Context ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#commande1}.
	 * @param ctx the parse tree
	 */
	void exitCommande1(MVaPParser.Commande1Context ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#instr1}.
	 * @param ctx the parse tree
	 */
	void enterInstr1(MVaPParser.Instr1Context ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#instr1}.
	 * @param ctx the parse tree
	 */
	void exitInstr1(MVaPParser.Instr1Context ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#commande2}.
	 * @param ctx the parse tree
	 */
	void enterCommande2(MVaPParser.Commande2Context ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#commande2}.
	 * @param ctx the parse tree
	 */
	void exitCommande2(MVaPParser.Commande2Context ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#instr2}.
	 * @param ctx the parse tree
	 */
	void enterInstr2(MVaPParser.Instr2Context ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#instr2}.
	 * @param ctx the parse tree
	 */
	void exitInstr2(MVaPParser.Instr2Context ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#instr2f}.
	 * @param ctx the parse tree
	 */
	void enterInstr2f(MVaPParser.Instr2fContext ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#instr2f}.
	 * @param ctx the parse tree
	 */
	void exitInstr2f(MVaPParser.Instr2fContext ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#commandeSaut}.
	 * @param ctx the parse tree
	 */
	void enterCommandeSaut(MVaPParser.CommandeSautContext ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#commandeSaut}.
	 * @param ctx the parse tree
	 */
	void exitCommandeSaut(MVaPParser.CommandeSautContext ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#saut}.
	 * @param ctx the parse tree
	 */
	void enterSaut(MVaPParser.SautContext ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#saut}.
	 * @param ctx the parse tree
	 */
	void exitSaut(MVaPParser.SautContext ctx);
	/**
	 * Enter a parse tree produced by {@link MVaPParser#label}.
	 * @param ctx the parse tree
	 */
	void enterLabel(MVaPParser.LabelContext ctx);
	/**
	 * Exit a parse tree produced by {@link MVaPParser#label}.
	 * @param ctx the parse tree
	 */
	void exitLabel(MVaPParser.LabelContext ctx);
}