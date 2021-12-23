
import java.io.DataOutputStream;
import java.io.FileOutputStream;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.misc.NotNull;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.TerminalNode;

/**
 * This class generates MVaP assembled code.
 */
public class MVaPAssemblerListener extends MVaPBaseListener {

    MVaPParser parser;
    DataOutputStream output;
    boolean debug;
    int size = 0;

    public MVaPAssemblerListener(MVaPParser parser, String output, boolean debug) { 
	this.parser = parser;
	try {
	    this.output = output == null ?
		new DataOutputStream(System.out)
		: new DataOutputStream(new FileOutputStream(output));
	} catch(Exception e) {
	    e.printStackTrace();
	    System.exit(1);
	}
	this.debug = debug;
	if (debug) {
	    System.err.println(" Adr |  Instruction"); 
	    System.err.println("-----+---------------"); 
	}
    }

    private void outInt(int i) {
	try {
	    output.writeInt(i);
	} catch(Exception e) {
	    e.printStackTrace();
	    System.exit(2);
	}
	++size;
    }
    /**
     * {@inheritDoc}
     * <p/>
     */
    @Override public void enterInstr1(@NotNull MVaPParser.Instr1Context ctx) {
	if (debug)
	    System.err.println(String.format("%4d | ", size) + ctx.commande1().getText()); //+ " → " + ctx.commande1().getStart().getType());

	outInt(ctx.commande1().getStart().getType());
    }

    /**
     * {@inheritDoc}
     * <p/>
     */
    @Override public void enterSaut(@NotNull MVaPParser.SautContext ctx) {
	Integer l = parser.getLabels().get(Integer.parseInt(ctx.ENTIER().getText())); 
	if (debug)
	    System.err.println(String.format("%4d | ", size) + ctx.commandeSaut().getText() + " " + l);

	outInt(ctx.commandeSaut().getStart().getType());
	outInt(l);
    }

    /**
     * {@inheritDoc}
     * <p/>
     */
    @Override public void enterInstr2(@NotNull MVaPParser.Instr2Context ctx) { 
	if (debug)
	    System.err.println(String.format("%4d | ", size) + ctx.commande2().getText() + " " + ctx.ENTIER().getText());

	outInt(ctx.commande2().getStart().getType());
	outInt(Integer.parseInt(ctx.ENTIER().getText()));
    }

    /**
     * {@inheritDoc}
     * <p/>
     */
    @Override public void enterInstr2f(@NotNull MVaPParser.Instr2fContext ctx) { 
	if (debug)
	    System.err.println(String.format("%4d | ", size) + "PUSHF" + " " + ctx.FLOAT().getText());

	outInt(MVaPParser.PUSHF);
	long d = Double.doubleToRawLongBits(Double.parseDouble(ctx.FLOAT().getText()));
	outInt(Pile.lowIntOfLong(d));
	outInt(Pile.highIntOfLong(d));
    }
}
