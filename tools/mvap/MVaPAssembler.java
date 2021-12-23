import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.DataOutputStream;
import java.io.FileOutputStream;

public class MVaPAssembler {
    private static void usage() {
	System.err.println("Usage : java MVaPAssembler.class [-d] [fichier_mvap]\n");
	System.exit(1);
    }

    public static void main(String[] args) throws Exception {
	boolean debug = false;
	String input = null;
	for(int i=0; i< args.length;i++) {
	    if ("-d".equals(args[i])) 
		debug = true;
	    else if(input == null)
		input = args[i];
	    else {
		usage();
		return;
	    }
	}
	String output = input == null ? null : input + ".cbap";
	ANTLRInputStream inputStream = input == null
	    ? new ANTLRInputStream(System.in) 
	    : new ANTLRFileStream(input);
	MVaPLexer lexer = new MVaPLexer(inputStream);
	CommonTokenStream tokens = new CommonTokenStream(lexer);
	MVaPParser parser = new MVaPParser(tokens);
	ParseTree tree = parser.program(); // parse
	// System.out.println(tree.toStringTree(parser));
	ParseTreeWalker walker = new ParseTreeWalker(); // create standard walker
	MVaPAssemblerListener assembler = new MVaPAssemblerListener(parser, output, debug);
	walker.walk(assembler, tree); // initiate walk of tree with listener
    }
}

