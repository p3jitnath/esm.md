variant = ARGS[1]=="julia_vanilla" ? "vanilla" : "solver"
include(joinpath(@__DIR__,"..","src","budyko_sellers",variant*".jl"))
using .BudykoSellers
const FP_LIBRARY=joinpath(@__DIR__,".build","libfp_env.so")
const COUNTER_LIBRARY=joinpath(@__DIR__,".build","libcounters.so")
const CANARY=UInt64(0x7ff4deadbeef5678)

function guarded(shape)
    raw=fill(CANARY,prod(shape)+32)
    array=unsafe_wrap(Array,Ptr{Float64}(pointer(raw,17)),shape;own=false)
    fill!(array,NaN)
    array,raw
end
function read_input(path)
    open(path,"r") do io
        String(read(io,8))=="ESMEB001" || error("Invalid EBM magic")
        n=Int(read(io,UInt64)); read(io,UInt64); read(io,UInt64)
        parameters=read!(io,Vector{Float64}(undef,7))
        par,pholder=guarded((6,)); copyto!(par,@view parameters[1:6])
        pairs=[guarded((n+2,)) for _ in 1:4]
        q,stage,out,work=[pair[1] for pair in pairs]
        holders=[pair[2] for pair in pairs]; push!(holders,pholder)
        coefficients,cholder=guarded((n+2,3)); push!(holders,cholder)
        GC.@preserve holders begin
            q[2:n+1]=read!(io,Vector{Float64}(undef,n))
            read!(io,coefficients)
        end
        eof(io) || error("Unexpected input bytes")
        q,stage,out,work,coefficients,par,holders
    end
end
function write_output(path,q,par,nsteps,phase)
    open(path,"w") do io
        write(io,codeunits("ESMEB001"))
        for value in (length(q)-2,nsteps,phase)
            write(io,UInt64(value))
        end
        write(io,par); write(io,nsteps*par[2]); write(io,q[2:end-1])
    end
end
function check_buffers(holders,q,stage,out,coeff,par,savedcoeff,savedpar)
    for raw in holders
        all(==(CANARY),@view raw[1:16]) && all(==(CANARY),@view raw[end-15:end]) || error("EBM guard changed")
    end
    reinterpret(UInt64,coeff)==reinterpret(UInt64,savedcoeff) || error("Coefficient input changed")
    reinterpret(UInt64,par)==reinterpret(UInt64,savedpar) || error("Parameter input changed")
    for state in (q,stage,out)
        bits=reinterpret(UInt64,state)
        bits[1]==bits[2] && bits[end]==bits[end-1] || error("Pole ghost differs")
    end
end
function trace(input,path,prefix,nsteps)
    q,stage,out,work,coeff,par,holders=read_input(input)
    savedcoeff,savedpar=copy(coeff),copy(par)
    GC.@preserve holders begin
        open(path,"w") do io
            for _ in 1:nsteps
                saved=copy(q[2:end-1])
                BudykoSellers.step!(q,stage,out,work,coeff,par)
                reinterpret(UInt64,saved)==reinterpret(UInt64,q[2:end-1]) || error("Input interior changed")
                check_buffers(holders,q,stage,out,coeff,par,savedcoeff,savedpar)
                write(io,stage); write(io,out)
                q,out=out,q
            end
        end
        write_output(prefix*"-p1.bin",stage,par,nsteps,1)
        write_output(prefix*"-p2.bin",q,par,nsteps,2)
        trial,s,o,w,c,p,h=read_input(input)
        GC.@preserve h begin
            BudykoSellers.run!(trial,s,o,w,c,p,nsteps)
            final=isodd(nsteps) ? o : trial
            reinterpret(UInt64,stage)==reinterpret(UInt64,s) || error("Repeated stage differs")
            reinterpret(UInt64,q)==reinterpret(UInt64,final) || error("Repeated state differs")
            check_buffers(h,trial,s,o,c,p,savedcoeff,savedpar)
            if length(q)==3
                saved=[copy(a) for a in (trial,s,o,w,c,p)]
                BudykoSellers.run!(trial,s,o,w,c,p,0)
                all(reinterpret(UInt64,a)==reinterpret(UInt64,b) for (a,b) in zip(saved,(trial,s,o,w,c,p))) || error("Zero steps changed storage")
            end
        end
    end
end
function cpu_ticks()
    result=Dict{Int,Vector{Int}}()
    for line in eachline("/proc/stat")
        fields=split(line)
        startswith(fields[1],"cpu") && length(fields[1])>3 || continue
        cpu=tryparse(Int,fields[1][4:end])
        isnothing(cpu) || (result[cpu]=parse.(Int,fields[2:9]))
    end
    result
end
function foreign_load(before,after)
    busy=0.0
    for cpu in keys(before)
        cpu==1 && continue
        delta=after[cpu].-before[cpu]; total=sum(delta)
        total>0 && (busy+=(total-delta[4]-delta[5])/total)
    end
    busy
end
function batch(input,prefix,nsteps)
    q,stage,out,work,coeff,par,holders=read_input(input)
    seed,savedcoeff,savedpar=copy(q),copy(coeff),copy(par)
    counters=zeros(UInt64,7)
    GC.@preserve holders begin
        BudykoSellers.run!(q,stage,out,work,coeff,par,2)
        allocated=@allocated BudykoSellers.run!(q,stage,out,work,coeff,par,2)
        for a in (q,stage,out,work)
            fill!(a,NaN)
        end
        copyto!(q,seed)
        enabled=GC.enable(false)
        before=cpu_ticks()
        ccall((:counters_begin,COUNTER_LIBRARY),Cint,())==0 || error("Cannot start PMU")
        elapsed=try
            start=time_ns()
            BudykoSellers.run!(q,stage,out,work,coeff,par,nsteps)
            time_ns()-start
        finally
            GC.enable(enabled)
        end
        ccall((:counters_end,COUNTER_LIBRARY),Cint,(Ptr{UInt64},),counters)==0 || error("Cannot read PMU")
        foreign=foreign_load(before,cpu_ticks())
        check_buffers(holders,q,stage,out,coeff,par,savedcoeff,savedpar)
        write_output(prefix*"-p1.bin",stage,par,nsteps,1)
        write_output(prefix*"-p2.bin",isodd(nsteps) ? out : q,par,nsteps,2)
        elapsed,allocated,foreign,counters
    end
end
fpcr()=ccall((:sw_fpcr,FP_LIBRARY),UInt64,())
vector_bytes()=ccall((:sw_vector_bytes,FP_LIBRARY),UInt64,())
println("READY\t",VERSION,"\t",fpcr(),"\t",vector_bytes()); flush(stdout)
for line in eachline(stdin)
    fields=split(line,'\t')
    try
        fpcr()==0 || error("FPCR changed")
        if fields[1]=="TRACE"
            trace(fields[2],fields[3],fields[4],parse(Int,fields[5]))
            println("OK")
        elseif fields[1]=="BENCH"
            stats=@timed @eval batch($(fields[2]),$(fields[3]),$(parse(Int,fields[4])))
            elapsed,allocated,foreign,counters=stats.value
            println("BENCH\t",elapsed,"\t",allocated,"\t",foreign,"\t",join(counters,","),"\t",stats.time,"\t",stats.compile_time,"\t",Sys.maxrss())
        elseif fields[1]=="QUIT"
            break
        else
            error("Unknown command")
        end
        fpcr()==0 || error("Solver changed FPCR")
    catch exception
        showerror(stderr,exception,catch_backtrace()); println(stderr)
        println("ERROR\t",sprint(showerror,exception))
    end
    flush(stdout)
end
