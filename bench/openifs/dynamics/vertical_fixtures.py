"""Freeze independent polynomial and physical fixtures for vertical operators.

The generator uses exact rational constraints rather than the OpenIFS spline
construction. It writes binary FP64 inputs and analytical targets before assembly.
"""
import hashlib
import json
import math
import struct
from fractions import Fraction as F
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / ".runtime/openifs/verdisint/fixtures"
PREP = ROOT / ".runtime/openifs/verdisint/preparation"
GRID = ROOT / ".runtime/openifs/verdisint/trace-grid2-7189435/logs"

def evaluation(coefficients, x, derivative=0, integral=False):
    """Evaluate a polynomial or its derivative or top integral exactly.

    Parameters
    ----------
    coefficients : sequence of Fraction
        Coefficients from constant term to highest power.
    x : Fraction
        Dimensionless eta location.
    derivative : int
        Zero, one, or two derivatives.
    integral : bool
        Select the integral from eta zero to x.

    Returns
    -------
    Fraction
        Exact result, with the input field's unit.
    """
    if integral:
        return sum((c * x ** (j+1) / (j+1) for j,c in enumerate(coefficients)), F(0))
    return sum((c * F(math.factorial(j), math.factorial(j-derivative))
                * x ** (j-derivative) for j,c in enumerate(coefficients)
                if j >= derivative), F(0))

def invert(matrix):
    """Invert a small rational constraint matrix with exact elimination.

    Parameters
    ----------
    matrix : list of list of Fraction
        Square constraints on polynomial coefficients.

    Returns
    -------
    list of list of Fraction
        Inverse matrix.

    Raises
    ------
    ValueError
        If the constraints do not select a unique polynomial.
    """
    n=len(matrix)
    rows=[list(row)+[F(i==j) for j in range(n)] for i,row in enumerate(matrix)]
    for column in range(n):
        pivot=next((i for i in range(column,n) if rows[i][column]),None)
        if pivot is None:
            raise ValueError("nonunique polynomial constraints")
        rows[column],rows[pivot]=rows[pivot],rows[column]
        scale=rows[column][column]
        rows[column]=[x/scale for x in rows[column]]
        for i in range(n):
            if i != column:
                scale=rows[i][column]
                rows[i]=[a-scale*b for a,b in zip(rows[i],rows[column])]
    return [row[n:] for row in rows]

def operator(nodes, output, kind, bc=None, implicit=False):
    """Build an independent operator from exact interpolation constraints.

    Parameters
    ----------
    nodes, output : sequence of Fraction
        Dimensionless input full levels and output eta locations.
    kind : str
        Integral, first derivative, or second derivative.
    bc : str or None
        Two value/derivative endpoint digits, or no endpoint constraints.
    implicit : bool
        Retain only interior columns for homogeneous endpoint constraints.

    Returns
    -------
    list of list of Fraction
        Complete operator in mathematical row order.
    """
    constraints=[(x,0) for x in nodes]
    if bc is not None:
        constraints=[(F(0),int(bc[0]))]+constraints+[(F(1),int(bc[1]))]
    degree=len(constraints)
    basis=[[F(int(j==i)) for j in range(degree)] for i in range(degree)]
    system=[[evaluation(b,x,d) for b in basis] for x,d in constraints]
    inverse=invert(system)
    columns=[[inverse[j][c] for j in range(degree)] for c in range(degree)]
    result=[[evaluation(c,x,0,True) if kind=="integral" else
             evaluation(c,x,1 if kind=="first" else 2)
             for c in columns] for x in output]
    if implicit:
        result=[row[1:-1] for row in result]
    return result

def flatten(matrix):
    """Return FP64 coefficients in Fortran column order.

    Parameters
    ----------
    matrix : list of list of fractions.Fraction
        Exact coefficient rows; eta is dimensionless.

    Returns
    -------
    list of float
        The coefficients, with every column stored before the next column.
    """
    return [float(matrix[r][c]) for c in range(len(matrix[0]))
            for r in range(len(matrix))] if matrix and matrix[0] else []

def polynomial_for(bc, implicit, levels, unconstrained=False):
    """Choose a polynomial compatible with the declared boundary fixture.

    Parameters
    ----------
    bc : str or None
        Two endpoint selectors: zero for a value and one for a derivative.
    implicit : bool
        Whether the endpoint constraints are included in the basis.
    levels : int
        Number of distinct interior eta locations.
    unconstrained : bool, optional
        Whether endpoint constraints are absent.

    Returns
    -------
    list of fractions.Fraction
        Polynomial coefficients in increasing powers of dimensionless eta.

    Notes
    -----
    The returned field satisfies the fixture's homogeneous endpoint constraints.
    """
    if unconstrained:
        return [F(1),F(-2)][:levels] if levels<3 else [F(1),F(-2),F(3)]
    if not implicit:
        return [F(1),F(2),F(-1),F(1),F(1)]
    if bc=="01":
        return [F(0),F(2),F(-1)]
    if bc=="10":
        return [F(1),F(0),F(-1)]
    return [F(1),F(0),F(3),F(-2)]

def main():
    """Write the frozen input archive, C manifest, and science identities.

    Returns
    -------
    None
        The files are written to the directory given on the command line.

    Notes
    -----
    This preparation generates independent rational fixtures, not a solver stage.
    """
    if OUT.exists():
        raise SystemExit("preserve existing fixture freeze")
    OUT.mkdir(parents=True)
    dispatch=json.loads((PREP/"operator-dispatch.json").read_text())["records"]
    matrices={}
    coefficient_records={}
    for levels,nodes in [(1,[F(1,2)]),(2,[F(1,4),F(3,4)]),
                         (3,[F(1,4),F(1,2),F(3,4)])]:
        full=nodes+[F(1)]
        half=[F(0),F(3,8),F(5,8),F(1)] if levels==3 else [F(j,levels) for j in range(levels+1)]
        fields={}
        fields["RINTE"]=operator(nodes,full,"integral")
        fields["RDERI"]=operator(nodes,nodes,"first")
        fields["RDDERI"]=operator(nodes,nodes,"second")
        for bc in ["00","01","10","11"]:
            fields["RDERBF"+bc]=operator(nodes,nodes,"first",bc)
            if bc!="00":
                fields["RDERBF"+bc+"_IMPL"]=operator(nodes,nodes,"first",bc,True)
        for bc in ["00","11"]:
            fields["RINTBF"+bc]=operator(nodes,full,"integral",bc)
        fields["RINTBF11_IMPL"]=operator(nodes,full,"integral","11",True)
        for bc in ["00","01"]:
            fields["RDERBH"+bc]=operator(nodes,half,"first",bc)
        fields["RDERBH01_IMPL"]=operator(nodes,half,"first","01",True)
        for bc in ["01","11"]:
            fields["RDDERBF"+bc]=operator(nodes,nodes,"second",bc)
        for bc in ["01","10","11"]:
            fields["RDDERBF"+bc+"_IMPL"]=operator(nodes,nodes,"second",bc,True)
        fields["RDERGW"]=operator([F(0)]+nodes,half,"first")
        matrices[levels]=fields
        coefficient_records[str(levels)]={name:{"rows":len(a),"columns":len(a[0]),
            "rational_rows":[[str(x) for x in row] for row in a],
            "fp64_hex":[struct.pack("<d",x).hex() for x in flatten(a)]} for name,a in fields.items()}
    offsets={name:64+88*i for i,name in enumerate(
        ["RINTE","RINTBF00","RINTBF11","RDERI","RDERB","RDERBF00",
         "RDERBF01","RDERBF10","RDERBF11","RDERBH00","RDERBH01","RDDERI",
         "RDDERBF01","RDDERBF11","RINTBF11_IMPL","RDERBF01_IMPL",
         "RDERBF10_IMPL","RDERBF11_IMPL","RDERBH01_IMPL","RDDERBF01_IMPL",
         "RDDERBF10_IMPL","RDDERBF11_IMPL","RINTGW","RDERGW"])}
    data=bytearray()
    cases=[]
    def append(values):
        offset=len(data)
        data.extend(struct.pack("<"+"d"*len(values),*values))
        return offset
    def add(name,entry,p,start,end,levels,n,m,ibc,chunk,op,bc,mat,inputs,
            expected,tolerance,flags=1|8|16,matrix_descriptor=0):
        flags |= 32 if tolerance and levels < 19 else 0
        initial=[-17.0-(i%29)/32.0 for i in range(p*m)]
        targets=list(initial)
        if end>=start:
            for r in range(m):
                for point in range(start-1,end):
                    targets[point+p*r]=float(expected(point,r))
        cases.append(dict(name=name,entry=entry,p=p,start=start,end=end,l=levels,
            n=n,m=m,ibc=ibc,chunk=chunk,op=op,bc=bc,flags=flags,
            descriptor=matrix_descriptor,tolerance=tolerance,
            matrix=append(mat),input=append(inputs),initial=append(initial),target=append(targets)))
    nodes_by_l={1:[F(1,2)],2:[F(1,4),F(3,4)],3:[F(1,4),F(1,2),F(3,4)]}
    def wrapper_case(record,levels,p,start,end,chunk,name,flags=1|8|16):
        op,bc,ibc=record["operation"],record["boundary"],record["ibc"]
        nodes=nodes_by_l[levels]
        half=[F(0),F(3,8),F(5,8),F(1)] if levels==3 else [F(j,levels) for j in range(levels+1)]
        n=eval(record["input_columns"],{"__builtins__":{}},{"L":levels})
        m=eval(record["output_rows"],{"__builtins__":{}},{"L":levels})
        field=record["matrix"]
        is_integral=op in ["ITOP","IBOT"]
        no_bc=field in ["RINTE","RDERI","RDDERI"]
        implicit=field.endswith("_IMPL")
        selected_bc="11" if is_integral and not no_bc else bc
        poly=polynomial_for(selected_bc,implicit,levels,no_bc)
        if is_integral and not no_bc:
            poly=[F(1)] if levels==1 else [F(1),F(0),F(3),F(-2)]
        if op=="DEGW":
            poly=[F(1),F(-2),F(3)][:levels+1]
        def scale(point):
            return F((point%5)-2,2) if point%5!=2 else F(3,4)
        if is_integral:
            values=[F(-3)]+[evaluation(poly,x) for x in nodes]+[F(7)]
        elif op=="DEGW":
            values=[evaluation(poly,F(0))]+[evaluation(poly,x) for x in nodes]+[F(7)]
        elif no_bc or implicit:
            values=[F(-3)]+[evaluation(poly,x) for x in nodes]+[F(7)]
        else:
            values=[evaluation(poly,F(0),int(bc[0]))]+[evaluation(poly,x) for x in nodes]+[evaluation(poly,F(1),int(bc[1]))]
        inputs=[float(values[j]*scale(point)) for j in range(levels+2) for point in range(p)]
        locations=nodes+[F(1)] if is_integral else half if op in ["HDER","DEGW"] else nodes
        kind=0 if is_integral else 2 if op=="DDER" else 1
        def target(point,row):
            value=evaluation(poly,locations[row],kind,is_integral)
            if op=="IBOT": value-=evaluation(poly,F(1),0,True)
            return value*scale(point)
        add(name,4,p,start,end,levels,n,m,ibc,chunk,op,bc,
            flatten(matrices[levels][field]),inputs,target,4096*2**-52,
            flags,offsets[field])
    defined=[r for r in dispatch if r["status"]=="defined_selection"]
    for index,r in enumerate(defined):
        wrapper_case(r,3,5,1,4,2,"all-defined-%03d"%index)
    for levels in [1,2]:
        for op,ibc,bc in [("ITOP",0,"11"),("IBOT",3,"11"),("FDER",0,"11"),("DDER",0,"11")]:
            r=next(r for r in defined if (r["operation"],r["ibc"],r["boundary"])==(op,ibc,bc))
            wrapper_case(r,levels,1,1,1,1,"small-%d-%s"%(levels,op),flags=1)
    r=next(r for r in defined if (r["operation"],r["ibc"],r["boundary"])==("IBOT",3,"11"))
    for start,end,chunk,flags,name in [(2,5,2,1|16,"offset-integral"),
         (1,0,1,1,"empty-integral"),(1,4,24,2|16,"protected-integral"),
         (1,5,2,1|4|16,"parallel-integral")]:
        wrapper_case(r,3,5,start,end,chunk,name,flags)
    r=next(r for r in defined if (r["operation"],r["ibc"],r["boundary"])==("DDER",0,"11"))
    wrapper_case(r,3,5,1,0,1,"empty-derivative",flags=1)
    wrapper_case(r,3,5,1,5,1,"protected-L-column-derivative",flags=2)
    # Complete helpers receive the same independent rectangular polynomial matrices.
    for entry,op,field,kind,type_ in [(2,"ITOP","RINTE","integral",0),
         (2,"IBOT","RINTE","integral",1),(3,"FDER","RDERI","first",0),
         (3,"DDER","RDDERI","second",0),(3,"HDER","RDERBH00","first",0)]:
        levels=3;p=5;nodes=nodes_by_l[3];rows=nodes+[F(1)] if entry==2 else [F(0),F(3,8),F(5,8),F(1)] if op=="HDER" else nodes
        n=len(matrices[3][field][0]);m=len(rows)
        poly=[F(1),F(2),F(3)] if field!="RDERBH00" else [F(1),F(2),F(3),F(-1),F(1)]
        values=[evaluation(poly,x) for x in nodes]
        if field=="RDERBH00":values=[evaluation(poly,F(0))]+values+[evaluation(poly,F(1))]
        inp=[float(values[j]*F(point+1,4)) for j in range(n) for point in range(p)]
        def target(point,row,rows=rows,poly=poly,kind=kind,type_=type_):
            value=evaluation(poly,rows[row],0 if kind=="integral" else 1 if kind=="first" else 2,kind=="integral")
            if type_:value-=evaluation(poly,F(1),0,True)
            return value*F(point+1,4)
        add("helper-"+op,entry,p,1,4,levels,n,m,type_,2,op,"00",flatten(matrices[3][field]),inp,target,4096*2**-52)
    # Closed-form matrix identity uses sum of squares, with exact dyadic values.
    p,m,k=5,3,7
    a=[(i+1)*(c+1)/8 for c in range(k) for i in range(p)]
    b=[(r+1)*(c+1)/16 for c in range(k) for r in range(m)]
    add("matrix-sum-squares",1,p,1,4,0,k,m,0,0,"NT  ","00",b,a,
        lambda point,row:(point+1)*(row+1)*k*(k+1)*(2*k+1)/6/128,0)
    witnesses=[("separate-rounding",[-1,1+2**-27],[1,1-2**-27],0),
               ("ordered-reduction",[2**53,1,-2**53],[1,1,1],0),
               ("gradual-underflow",[2**-1074,2**-1074,-2**-1074],[1,1,1],2**-1074),
               ("signed-zero",[-0.0],[1],0.0)]
    for name,a,b,target in witnesses:
        add(name,1,1,1,1,0,len(a),1,0,0,"NT  ","00",b,a,
            lambda point,row,target=target:target,0)
    add("empty-inner",1,5,1,4,0,0,3,0,0,"NT  ","00",[],[],
        lambda point,row:0.0,0)
    add("empty-points",1,5,1,0,0,7,3,0,0,"NT  ","00",[0.0]*21,[0.0]*35,
        lambda point,row:0.0,0)
    actual=struct.unpack("<420d",(GRID/"matrix-001.bin").read_bytes())
    eta=struct.unpack("<21d",(GRID/"eta-full.bin").read_bytes())
    actual_cases=[]
    for p in [1,8,19,24,506]:
        for chunk in [1,24]:
            for op in ["ITOP","IBOT"]:
                for kind in ["water","signed-rate","hydrostatic","quartic"]:
                    levels=19;n=21;m=20;end=p if p!=24 else 8
                    if kind=="water":constant=float(F(1,100)*F(100000)/F(981,100))
                    elif kind=="signed-rate":constant=float(-F(1,1000000)*F(100000)/F(981,100))
                    elif kind=="hydrostatic":constant=float(-F(287)*F(250)*F(3))
                    else:constant=1.0
                    inp=[]
                    for j,x in enumerate(eta):
                        value=constant if kind!="quartic" else float(F(x)**2*(1-F(x))**2)
                        # Endpoint input values are ignored by the defined integral path.
                        if j in [0,20]:value=-7.0 if j==0 else 11.0
                        inp.extend([value]*p)
                    def target(point,row,kind=kind,constant=constant,op=op):
                        x=F(eta[row+1])
                        if kind=="quartic":v=x**3/F(3)-x**4/F(2)+x**5/F(5)
                        else:v=F(constant)*x
                        if op=="IBOT":v-=F(1,30) if kind=="quartic" else F(constant)
                        return v
                    tol=1e-6 if kind=="quartic" else 1e-11*max(1,abs(constant))
                    name="actual-%d-%d-%s-%s"%(p,chunk,op,kind)
                    add(name,4,p,1,end,19,21,20,3,chunk,op,"11",actual,inp,target,tol,1|8|16,offsets["RINTBF11"])
                    actual_cases.append(name)
    (OUT/"corpus.bin").write_bytes(data)
    (OUT/"corpus.json").write_text(json.dumps({"format":"little-endian FP64 slices",
        "cases":cases,"actual_science_cases":actual_cases,"source_dispatch_sha256":
        hashlib.sha256((PREP/"operator-dispatch.json").read_bytes()).hexdigest()},indent=2)+"\n")
    (OUT/"rational-operators.json").write_text(json.dumps(coefficient_records,indent=2)+"\n")
    header=["/* Frozen metadata for independent numerical fixtures. */",
        "static const struct fixture_case fixtures[] = {"]
    for c in cases:
        header.append('{%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,"%s","%s",%d,%d,%d,%d,%.17g,"%s"},'%
            tuple([c[x] for x in ["entry","p","start","end","l","n","m","ibc","chunk","descriptor","flags"]]+
                  [c["op"],c["bc"]]+[c[x] for x in ["matrix","input","initial","target","tolerance","name"]]))
    header+=["};", "static const size_t fixture_count = sizeof(fixtures)/sizeof(fixtures[0]);"]
    (OUT/"corpus.h").write_text("\n".join(header)+"\n")
    manifest={p.name:{"bytes":p.stat().st_size,"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
              for p in OUT.iterdir() if p.is_file()}
    (OUT/"manifest.json").write_text(json.dumps({"cases":len(cases),"files":manifest},indent=2)+"\n")
    print(json.dumps({"cases":len(cases),"corpus_bytes":len(data),"sha256":manifest["corpus.bin"]["sha256"]},indent=2))

if __name__ == "__main__":
    main()
