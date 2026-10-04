variant = length(ARGS) == 1 && ARGS[1] == "julia_vanilla" ? "vanilla" : "solver"
include(joinpath(@__DIR__, "..", "src", "shallow_water", variant*".jl"))
using .ShallowWater

const FP_LIBRARY = joinpath(@__DIR__, ".build", "libfp_env.so")
const COUNTER_LIBRARY = joinpath(@__DIR__, ".build", "libcounters.so")
const CANARY = UInt64(0x7ff4deadbeef5678)

function guarded(shape)
    raw = fill(CANARY, prod(shape)+32)
    array = unsafe_wrap(Array, Ptr{Float64}(pointer(raw,17)), shape; own=false)
    fill!(array, NaN)
    array, raw
end

function read_input(path)
    open(path,"r") do io
        String(read(io,8)) == "ESMSW001" || error("Invalid binary magic")
        nx, ny = Int(read(io,UInt64)), Int(read(io,UInt64))
        read(io,UInt64); read(io,UInt64)
        values = read!(io,Vector{Float64}(undef,5))
        1 <= nx <= 4096 && 1 <= ny <= 4096 || error("Invalid dimensions")
        pairs = [guarded((nx+2,ny+2,n)) for n in (3,3,3,5)]
        q, stage, out, work = [pair[1] for pair in pairs]
        holders = [pair[2] for pair in pairs]
        GC.@preserve holders begin
            for a in 1:3
                payload = read!(io,Matrix{Float64}(undef,nx,ny))
                @views q[2:nx+1,2:ny+1,a] .= payload
            end
        end
        eof(io) || error("Unexpected input bytes")
        q, stage, out, work, values[1:4], holders
    end
end

function write_output(path,q,parameters,n,phase)
    nx, ny = size(q,1)-2, size(q,2)-2
    open(path,"w") do io
        write(io,codeunits("ESMSW001"))
        for value in (nx,ny,n,phase)
            write(io,UInt64(value))
        end
        write(io,parameters)
        write(io,n*parameters[4])
        for a in 1:3
            write(io,q[2:nx+1,2:ny+1,a])
        end
    end
end

function check_guards(holders)
    for raw in holders
        all(==(CANARY),@view raw[1:16]) && all(==(CANARY),@view raw[end-15:end]) ||
            error("Julia changed a buffer guard")
    end
end

function check_halos(q)
    nx,ny = size(q,1)-2,size(q,2)-2
    bits = reinterpret(UInt64,q)
    @inbounds for a in 1:3, j in 1:ny+2
        for i in (1,nx+2)
            bits[i,j,a] == bits[2+mod(i-2,nx),2+mod(j-2,ny),a] ||
                error("Julia's side halo differs from BC01")
        end
    end
    @inbounds for a in 1:3, i in 1:nx+2
        for j in (1,ny+2)
            bits[i,j,a] == bits[2+mod(i-2,nx),2+mod(j-2,ny),a] ||
                error("Julia's row halo differs from BC01")
        end
    end
end

function trace(input,path,prefix,nsteps)
    q, stage, out, work, parameters, holders = read_input(input)
    nx,ny = size(q,1)-2,size(q,2)-2
    before = Array{Float64}(undef,nx,ny,3)
    GC.@preserve holders begin
        open(path,"w") do io
            for n in 1:nsteps
                @views before .= q[2:nx+1,2:ny+1,:]
                ShallowWater.step!(q,stage,out,work,parameters)
                reinterpret(UInt64,before) == reinterpret(UInt64,q[2:nx+1,2:ny+1,:]) ||
                    error("Julia changed the input interior")
                check_guards(holders)
                write(io,stage); write(io,out)
                q,out = out,q
            end
        end
        write_output(prefix*"-p1.bin",stage,parameters,nsteps,1)
        write_output(prefix*"-p2.bin",q,parameters,nsteps,2)
        trial,trial_stage,trial_out,trial_work,trial_parameters,trial_holders = read_input(input)
        GC.@preserve trial_holders begin
            ShallowWater.run!(trial,trial_stage,trial_out,trial_work,trial_parameters,nsteps)
            check_guards(trial_holders)
            final = isodd(nsteps) ? trial_out : trial
            reinterpret(UInt64,stage) == reinterpret(UInt64,trial_stage) ||
                error("Julia's repeated-entry stage differs from its trace")
            reinterpret(UInt64,q) == reinterpret(UInt64,final) ||
                error("Julia's repeated-entry state differs from its trace")
            reinterpret(UInt64,parameters) == reinterpret(UInt64,trial_parameters) ||
                error("Julia changed its repeated-entry parameters")
            if nx == ny == 1
                saved = [copy(array) for array in (trial,trial_stage,trial_out,trial_work)]
                ShallowWater.run!(trial,trial_stage,trial_out,trial_work,trial_parameters,0)
                for (before,array) in zip(saved,(trial,trial_stage,trial_out,trial_work))
                    reinterpret(UInt64,before) == reinterpret(UInt64,array) ||
                        error("Julia changed a buffer during zero steps")
                end
            end
        end
    end
end

function batch(input,prefix,nsteps)
    q,stage,out,work,parameters,holders = read_input(input)
    seed = copy(q)
    original_parameters = copy(parameters)
    counters = zeros(UInt64,7)
    GC.@preserve holders begin
        ShallowWater.run!(q,stage,out,work,parameters,2)
        allocated = @allocated ShallowWater.run!(q,stage,out,work,parameters,2)
        fill!(q,NaN); fill!(stage,NaN); fill!(out,NaN); fill!(work,NaN)
        copyto!(q,seed)
        enabled = GC.enable(false)
        ticks_before = cpu_ticks()
        ccall((:counters_begin,COUNTER_LIBRARY),Cint,()) == 0 || error("Cannot start Julia's PMU group")
        elapsed = try
            start = time_ns()
            ShallowWater.run!(q,stage,out,work,parameters,nsteps)
            time_ns()-start
        finally
            GC.enable(enabled)
        end
        ccall((:counters_end,COUNTER_LIBRARY),Cint,(Ptr{UInt64},),counters) == 0 ||
            error("Cannot read Julia's unmultiplexed PMU group")
        ticks_after = cpu_ticks()
        foreign = foreign_load(ticks_before,ticks_after)
        check_guards(holders)
        reinterpret(UInt64,parameters) == reinterpret(UInt64,original_parameters) ||
            error("Julia changed the parameter buffer")
        final = isodd(nsteps) ? out : q
        check_halos(stage); check_halos(final)
        write_output(prefix*"-p1.bin",stage,parameters,nsteps,1)
        write_output(prefix*"-p2.bin",final,parameters,nsteps,2)
        elapsed,allocated,foreign,counters,join((string(UInt(pointer(array))) for array in (q,stage,out,work,parameters)),",")
    end
end

function cpu_ticks()
    result = Dict{Int,Vector{Int}}()
    for line in eachline("/proc/stat")
        fields = split(line)
        startswith(fields[1],"cpu") && length(fields[1])>3 || continue
        cpu = tryparse(Int,fields[1][4:end])
        isnothing(cpu) || (result[cpu] = parse.(Int,fields[2:9]))
    end
    result
end

function foreign_load(before,after)
    busy = 0.0
    for cpu in keys(before)
        cpu == 1 && continue
        delta = after[cpu].-before[cpu]
        total = sum(delta)
        total>0 && (busy += (total-delta[4]-delta[5])/total)
    end
    busy
end

fpcr() = ccall((:sw_fpcr,FP_LIBRARY),UInt64,())
vector_bytes() = ccall((:sw_vector_bytes,FP_LIBRARY),UInt64,())

println("READY\t",VERSION,"\t",fpcr(),"\t",vector_bytes())
flush(stdout)
for line in eachline(stdin)
    fields = split(line,'\t')
    try
        fpcr() == 0 || error("Expected FPCR=0")
        if fields[1] == "TRACE"
            trace(fields[2],fields[3],fields[4],parse(Int,fields[5]))
        elseif fields[1] == "BENCH"
            stats = @timed @eval batch($(fields[2]),$(fields[3]),$(parse(Int,fields[4])))
            elapsed,allocated,foreign,counters,addresses = stats.value
            fpcr() == 0 || error("Julia changed FPCR")
            println("BENCH\t",elapsed,"\t",allocated,"\t",foreign,"\t",join(counters,","),"\t",stats.time,"\t",stats.compile_time,"\t",Sys.maxrss(),"\t",addresses)
            flush(stdout)
            continue
        elseif fields[1] == "QUIT"
            break
        else
            error("Unknown Julia driver command")
        end
        fpcr() == 0 || error("Julia changed FPCR")
        println("OK")
    catch exception
        showerror(stderr,exception,catch_backtrace())
        println(stderr)
        println("ERROR\t",sprint(showerror,exception))
    end
    flush(stdout)
end
