import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;

/**
 * Code Binaire pour Machine Virtuelle à Pile.
 * Les flottants sont des double Java qui prennent la place de 2 ints.
 * Les adresses sont des int.
 * CALL empile l'adresse de retour et la valeur du framePointer dans la pile.
 */
public class CBaP {

    private int pc = 0;
    private int fp = 0;
    private Pile stack;
    private Pile program;
    public static final int SizeofDouble = 2;

    private boolean _debug = false;
    
    public CBaP(Pile program, boolean debug, int stackSize) {
	this.program = program;
	this._debug = debug;
	this.stack = new Pile(stackSize);
    }

    public int dumpInstruction(int ii, PrintStream out) {
	int i = ii;
	switch(program.get_int(i)) {                                               
	case MVaPLexer.ADD:    out.print("ADD   ");            	break;
	case MVaPLexer.SUB:    out.print("SUB   ");            	break;
	case MVaPLexer.MUL:    out.print("MUL   ");            	break;
	case MVaPLexer.DIV:    out.print("DIV   ");            	break;
	case MVaPLexer.INF:    out.print("INF   ");            	break;
	case MVaPLexer.INFEQ:  out.print("INFEQ ");          	break;
	case MVaPLexer.SUP:    out.print("SUP   ");            	break;
	case MVaPLexer.SUPEQ:  out.print("SUPEQ ");      	break;
	case MVaPLexer.EQUAL:  out.print("EQUAL ");      	break;
	case MVaPLexer.NEQ:  out.print("NEQ   ");              	break;
								   	
	case MVaPLexer.FADD:  out.print("FADD  ");            	break;     	
	case MVaPLexer.FSUB:  out.print("FSUB  ");            	break; 		
	case MVaPLexer.FMUL:  out.print("FMUL  ");            	break; 		
	case MVaPLexer.FDIV:  out.print("FDIV  ");        	        break;   	
	case MVaPLexer.FINF:  out.print("FINF  ");         	        break; 		 		
	case MVaPLexer.FINFEQ:  out.print("FINFEQ");        	break; 		 	
	case MVaPLexer.FSUP:  out.print("FSUP  ");            	break; 		 		
	case MVaPLexer.FSUPEQ:  out.print("FSUPEQ");      	break; 		 	
	case MVaPLexer.FEQUAL:  out.print("FEQUAL");      	break; 		 	
	case MVaPLexer.FNEQ:  out.print("FNEQ  ");            	break; 		 		
	case MVaPLexer.ITOF:  out.print("ITOF  ");        	        break; 		 		
	case MVaPLexer.FTOI:  out.print("FTOI  ");        	        break; 		 		
								   	
	case MVaPLexer.RETURN: out.print("RETURN");      	break;
	case MVaPLexer.POP:    out.print("POP   ");            	break;      
	case MVaPLexer.POPF:    out.print("POPF  ");            	break;      
	case MVaPLexer.READ:   out.print("READ  ");           	break;      
	case MVaPLexer.READF:   out.print("READF ");           	break;      
	case MVaPLexer.WRITE:  out.print("WRITE ");          	break;      
	case MVaPLexer.WRITEF:  out.print("WRITEF");      	break;      
	case MVaPLexer.PADD:    out.print("PADD  ");          	break;    
	case MVaPLexer.PUSHGP:  out.print("PUSHGP");     	break;    
	case MVaPLexer.PUSHFP:  out.print("PUSHFP");      	break;    
	case MVaPLexer.DUP:    out.print("DUP   ");            	break;      

	case MVaPLexer.PUSHI:  out.print("PUSHI ");  out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.PUSHG:  out.print("PUSHG ");  out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.STOREG: out.print("STOREG"); out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.PUSHL:  out.print("PUSHL ");  out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.STOREL: out.print("STOREL"); out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.PUSHR:    out.print("PUSHR "); out.format("%7d ", program.get_int(++i));  break;    
	case MVaPLexer.STORER:  out.print("STORER"); out.format("%7d ", program.get_int(++i));  break;    
	case MVaPLexer.FREE:    out.print("FREE  "); out.format("%7d ", program.get_int(++i));  break;	
	case MVaPLexer.ALLOC:  out.print("ALLOC "); out.format("%7d ", program.get_int(++i));  break;

	case MVaPLexer.PUSHF:  out.print("PUSHF ");  ++i; out.format("%7.3f ", program.get_double(++i));  break;

	case MVaPLexer.JUMP:   out.print("JUMP  ");   out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.JUMPF:  out.print("JUMPF ");  out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.JUMPI: out.print("JUMPI "); out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.CALL:   out.print("CALL  ");   out.format("%7d ", program.get_int(++i));  break;
	case MVaPLexer.HALT:   out.print("HALT  ");            	break;      
	default: System.err.println("Code inconnu "+program.get_int(i)+" ligne "+i);
	}
	if (i == ii) out.print("        ");
	return i;
    }
       
    public void dumpProgram(PrintStream out) {
	// out.println(program.toString(true));
	// out.println(program.toString());
	out.println(" Adr |  Instruction"); 
	out.println("-----+---------------"); 
        for(int i = 0; i < program.getSize(); i++) {
            out.format("%4d | ", i); 
	    i = dumpInstruction(i, out);
            out.println();
        }
    }

    private void _call(int label) {
	push(pc+1); 
	push(fp); 
	fp = size(); 
	pc = label; 
    }

    private void _return() {
	while(size() > fp)
	    pop();
	fp = pop();
	pc = pop();
    }

    private BufferedReader input = null;
    private int _read() {
	try {
	    if (input == null)
		input = new BufferedReader(new InputStreamReader(System.in));
	    return Integer.parseInt(input.readLine());
	} catch (Exception e) {
	    System.err.println(e);
	    System.exit(1);
	    return 0;
	}
    }

    private double _read_double() {
	try {
	    if (input == null)
		input = new BufferedReader(new InputStreamReader(System.in));
	    return Double.parseDouble(input.readLine());
	} catch (Exception e) {
	    System.err.println(e);
	    System.exit(1);
	    return 0;
	}
    }

    public boolean execute() {
	if (_debug) {
	    dumpProgram(System.out);
	    System.err.println();
	    System.err.println("  pc |               |    fp   pile");
	    System.err.println("====================================================");
	}
	pc = 0;
	while (true) {
	    if (_debug) {
		System.err.format("%4d | ", pc);
		dumpInstruction(pc, System.err);
		System.err.format("|  %4d %s\n", fp, stack.toString());
	    }
	    try {
		int p1, p2; // utile pour être sûr de l'ordre des pop() !
		double d1, d2;
		switch(program.get_int(pc++)) {                                               
		case MVaPLexer.ADD:    p1 = pop(); p2 = pop(); push(p2 +  p1);  	break;
		case MVaPLexer.SUB:    p1 = pop(); p2 = pop(); push(p2 -  p1);  	break;
		case MVaPLexer.MUL:    p1 = pop(); p2 = pop(); push(p2 *  p1);  	break;
		case MVaPLexer.DIV:     p1 = pop(); p2 = pop(); push(p2 /  p1);   	break;
		case MVaPLexer.INF:  	 p1 = pop(); p2 = pop(); push(p2 <  p1 ? 1 : 0);	break;
		case MVaPLexer.INFEQ:  p1 = pop(); p2 = pop(); push(p2 <= p1 ? 1 : 0);	break;
		case MVaPLexer.SUP:  	 p1 = pop(); p2 = pop(); push(p2 >  p1 ? 1 : 0);  	break;
		case MVaPLexer.SUPEQ: p1 = pop(); p2 = pop(); push(p2 >= p1 ? 1 : 0);  	break;
		case MVaPLexer.EQUAL: p1 = pop(); p2 = pop(); push(p2 == p1 ? 1 : 0); 	break;
		case MVaPLexer.NEQ:    p1 = pop(); p2 = pop(); push(p2 != p1 ? 1 : 0); 	break;

		case MVaPLexer.FADD:    d1 = pop_double(); d2 = pop_double(); push(d2 +  d1);  	break;
		case MVaPLexer.FSUB:    d1 = pop_double(); d2 = pop_double(); push(d2 -  d1);  	break;
		case MVaPLexer.FMUL:    d1 = pop_double(); d2 = pop_double(); push(d2 *  d1);  	break;
		case MVaPLexer.FDIV:     d1 = pop_double(); d2 = pop_double(); push(d2 /  d1);   	break;
		case MVaPLexer.FINF:  	  d1 = pop_double(); d2 = pop_double(); push(d2 <  d1 ? 1 : 0);	break;
		case MVaPLexer.FINFEQ: d1 = pop_double(); d2 = pop_double(); push(d2 <= d1 ? 1 : 0);	break;
		case MVaPLexer.FSUP:    d1 = pop_double(); d2 = pop_double(); push(d2 >  d1 ? 1 : 0);  	break;
		case MVaPLexer.FSUPEQ: d1 = pop_double(); d2 = pop_double(); push(d2 >= d1 ? 1 : 0);  	break;
		case MVaPLexer.FEQUAL: d1 = pop_double(); d2 = pop_double(); push(d2 == d1 ? 1 : 0);  	break;
		case MVaPLexer.FNEQ:    d1 = pop_double(); d2 = pop_double(); push(d2 != d1 ? 1 : 0); 	break;

		case MVaPLexer.FTOI:    push((int)pop_double()); 	break;
		case MVaPLexer.ITOF:    push((double)pop()); 		break;

		case MVaPLexer.RETURN: _return();                                   		break; 
		case MVaPLexer.POP:    pop();                                	   		break;      
		case MVaPLexer.POPF:   pop_double();                                		break;      
		case MVaPLexer.READ:   push(_read());                                     	break;      
		case MVaPLexer.READF:  push(_read_double());                                    break;      
		case MVaPLexer.WRITE:  System.out.format("%7d\n", peek());                  	break;      
		case MVaPLexer.WRITEF: System.out.format("%7.3f\n", peek_double());             break;      
		case MVaPLexer.PADD:   p1 = pop(); p2 = pop(); push(p2 +  p1);  	break;
		case MVaPLexer.PUSHGP: push(0);                               	   		break;  
		case MVaPLexer.PUSHFP:  push(fp);                               	   		break;  
		case MVaPLexer.DUP:    push(peek());                                		break;      
		    
		case MVaPLexer.PUSHI:  push(program.get_int(pc++));                 	break;
		case MVaPLexer.PUSHG:  push(get(program.get_int(pc++)));   	     	break;
		case MVaPLexer.STOREG: set(program.get_int(pc++), pop());	       	break;
		    // ajouter -2 si adresse négative ?
		case MVaPLexer.PUSHL:  push(get(fp+program.get_int(pc++))); 	break;
		case MVaPLexer.STOREL:set(fp+program.get_int(pc++), pop());	break;
		case MVaPLexer.PUSHR: push(get(pop()+program.get_int(pc++))); 	break;
		case MVaPLexer.STORER:p1 = pop(); p2 = pop(); set(p2+program.get_int(pc++), p1);	break;
		case MVaPLexer.FREE: 	  doPop(program.get_int(pc++));              	break;
		case MVaPLexer.ALLOC:  doPush(program.get_int(pc++));              	break;

		case MVaPLexer.PUSHF:  push(program.get_int(pc++)); push(program.get_int(pc++)); break;

		case MVaPLexer.JUMP:   pc = program.get_int(pc);			           	break;
		case MVaPLexer.JUMPF:  if (pop() == 0) pc = program.get_int(pc); else pc++; break;
		case MVaPLexer.JUMPI:  pc = program.get_int(pc)+pop();			       	break;
		case MVaPLexer.CALL:   _call(program.get_int(pc));			   		break;
		case MVaPLexer.HALT:   
		    if (size() > 0) 
			System.err.println("HALT avec pile non vide : " + stack);
		    return true;               
		default: System.err.println("Code inconnu "+program.get_int(pc)+" ligne "+pc); return false;
		}
	    } catch (ArrayIndexOutOfBoundsException e) {
		System.err.println(stack.getException());
		return false;
	    }
        }
    }

    void push(int i) { stack.push(i); }
    int pop() { return stack.pop_int(); }
    void push(double d) { stack.push(d); }
    double pop_double() { return stack.pop_double(); } 
    int peek() { return stack.peek_int(); }
    double peek_double() { return stack.peek_double(); }
    int size() { return stack.getSize(); }
    void set(int index, int i) { stack.set(index, i); }
    int get(int index) { return stack.get_int(index); }

    void doPop(int nb) { for(; nb > 0; nb--) stack.pop_int(); }
    void doPush(int nb) { for(; nb > 0; nb--) stack.push(0); }


    public static Pile readProgram(String file) {
	try {
	    File f = new File(file);
	    int psize = (int)(f.length()/4);
	    int[] p = new int[psize];
	    DataInputStream in = new DataInputStream(new FileInputStream(f));
	    for (int i = 0; i < psize; i++)
		p[i] = in.readInt();
	    return new Pile(p);
	}  catch(Exception e) {
	    e.printStackTrace();
	    System.exit(1);
	} 
	return null;
    }

    public static void main(String args[]) {
	boolean debug = false;
	String inputFile = null; 
	int stackSize = 1000;
	for(int i=0; i< args.length;i++) {
	    if ("-d".equals(args[i])) debug = true;
	    else if ("-s".equals(args[i])) {
		i++;
		if (i > args.length) {
		    usage();
		    return;
		}
		stackSize = Integer.parseInt(args[i]);
	    }else if (inputFile == null)
		inputFile = args[i];
	    else {
		usage();
		return;
	    }
	}	
	Pile program = readProgram(inputFile);
	new CBaP(program, debug, stackSize).execute();
    }
    
    public static void usage() {
	System.err.println("Usage : java CBaP.class [ -d ] [ -s nnn ] filename");
    }
}
