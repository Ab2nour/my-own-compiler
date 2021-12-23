/**
 * Une pile d'ints qui peut empiler (et dépiler) des longs ou des doubles
 * qui prennent la place de 2 ints.
 *
 * @author Jacques.Madelaine@unicaen.fr 2011
 * sur les (bonnes) suggestions de Sylvain.Sauvage@unicaen.fr
 */ 
public class Pile {
    // comme on ne peut pas changer la signature de l'analyseur généré par ANTLR
    // on gère un message d'exception et non une exception...
    private String exception = null;
    public String getException() { return exception; }

    private int[] pile ;
    int haut = 0;

    public Pile() {
	this(1000);
    }

    public Pile(int size) {
	pile = new int[size];
    } 

    public Pile(int[] ints) {
	pile = ints;
	haut = ints.length;
    } 

    private void _push(int i) {
	try {
	    pile[haut++] = i;
	} catch (ArrayIndexOutOfBoundsException e) {
	    exception = "StackOverflow " + String.valueOf(haut);	 
	    throw e;
	}
    }
    
    private int _pop() {
	return pile[--haut];
    }

    public static int uint2int(long ui) {
	// la transformation en long fait le boulot
	return (int)ui;
    }

    public static long int2uint(int i) {
	long ui = i & 0xffffffffL;
	return ui;
    }

    public static long twoInts2long(int ihigh, int ilow) {
	long high = int2uint(ihigh);
	long low = int2uint(ilow);
	long l = high << 32 | low;
	// System.err.printf("twoInts2long : %16x ← %16x %16x ← %8x %8x \n", l, high, low, ihigh, ilow);
	return l;
    }

    public static int lowIntOfLong(long l) {
	long llow = l & 0xffffffffL;
	return uint2int(llow);
    }

    public static int highIntOfLong(long l) {
	long lhigh = l >>> 32; // >>> met des 0 à gauche
	return uint2int(lhigh);
    }

    public void push(int i) {
	_push(i);
    }

    public int pop_int() {
	return _pop();
    }

    public int peek_int() {
	return pile[haut-1];
    }

    void set(int index, int i) { 
	try {
	    	pile[index] = i;
	} catch (ArrayIndexOutOfBoundsException e) {
	    exception = "Access out of stack "+ String.valueOf(index);
	    throw e;
	}
    }
   
    int get_int(int index) { 
	try {
	    return pile[index]; 
	} catch (ArrayIndexOutOfBoundsException e) {
	    exception = "Access out of stack "+ String.valueOf(index);
	    throw e;
	}

    }

    public void push(long l) {
	// System.err.printf("push : %16x → %8x %8x\n", l, highIntOfLong(l), lowIntOfLong(l));
	_push(lowIntOfLong(l));
	_push(highIntOfLong(l));
    }

    public long pop_long() {
	int ihigh = _pop();
	int ilow = _pop();
	long l = twoInts2long(ihigh, ilow);
	// System.err.printf("pop :  %16x ← %8x %8x\n", l, ihigh, ilow);
	return l;
    }

    public long peek_long() {
	return get_long(haut-1);
    }

    public long get_long(int index) {
	int ihigh = get_int(index);
	int ilow = get_int(index-1);
	long l = twoInts2long(ihigh, ilow);
	return l;
    }

    public void push(double d) {
	// System.err.println("push :"+d);
	push(Double.doubleToRawLongBits(d));
    }

    public double pop_double() {
	return Double.longBitsToDouble(pop_long());
    }

    public double peek_double() {
	return Double.longBitsToDouble(peek_long());
    }

    public double get_double(int index) {
	// System.err.print("Pile.get_double("+index+") ");
	double d = Double.longBitsToDouble(get_long(index));
	// System.err.print(" → "+ d);
	return d;
    }

    public String toString() {
	return toString(false);
    }

    public String toString(boolean toHex) {
	StringBuffer buf = new StringBuffer(haut*5);
	buf.append("[ ");
	for(int i = 0; i < haut; i++) 
	    if (toHex)
		buf.append(Integer.toHexString(pile[i])+" ");
	    else
		buf.append(pile[i]+" ");
	buf.append("] "+haut);
	return buf.toString();
    }

    public int getMaxSize() {
	return pile.length;
    }

    public int getSize() {
	return haut;
    }

    public static void main(String[] args) {
	Pile p = new Pile();
	try {
	double d = 12.34;
	int i = 1234;
	p.push(i);
	p.push(d);
	double e = p.pop_double();
	System.out.println(d + " : " + e);
	int j = p.pop_int();
	System.out.println(i + " : " + j);
	d = -1;
	p.push(d);
	e = p.pop_double();
	System.out.println(d + " : " + e);

	d = Double.longBitsToDouble(0x8000000080000000L);
	p.push(d);
	e = p.pop_double();
	System.out.println(d + " : " + e);

	long l = 0x8000000080000000L;
	p.push(l);
	long ll = p.pop_long();
	System.out.println(l + " : " + ll);

	p.push(0X80000000);
	p.push(0X80000000);
	ll = p.pop_long();
	System.out.println(l + " : " + ll);

	p.push(0X80000001);
	p.push(0X80000001);

	System.out.println(p);

	for (i = 0 ; i < 1000000; i++)
	    p.push(i);
	} catch(Exception e) {
	    System.err.println(e);
	}
    }
}
