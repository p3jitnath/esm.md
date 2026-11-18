using CUDA
using Printf

const ROOT = @__DIR__
const LIB = ENV["GPU_DRIVER_LIBRARY"]
const MODEL,NAME = ARGS[1:2]
const CANARY = UInt64(0x7ff4deadbeef5678)
const variant = endswith(NAME,"_vanilla") ? "vanilla" : "solver"
include(joinpath(ROOT,"src",MODEL,variant*".jl"))
const Solver = getfield(Main,Symbol(MODEL == "eb" ? "EnergyBalanceGPU" : "ShallowWaterGPU",variant == "vanilla" ? "Vanilla" : "Optimised"))
CUDA.device!(0)
function checked(result)
    result == 0 && return nothing
    message = unsafe_string(ccall((:gpu_error,LIB),Cstring,()))
    error(message)
end
checked(ccall((:gpu_init,LIB),Cint,(Cint,),0))
const STREAM = CUDA.stream()
checked(ccall((:gpu_set_stream,LIB),Cint,(UInt64,),UInt(STREAM.handle)))
syncgpu() = checked(ccall((:gpu_sync,LIB),Cint,()))

mutable struct Buffer
    raw::Vector{UInt64}
    allocation::UInt64
    pointer::UInt64
    view::CuVector{Float64}
end
function Buffer(values)
    raw = fill(CANARY,length(values)+32)
    raw[17:end-16] .= reinterpret(UInt64,vec(values))
    allocation = Ref{UInt64}()
    checked(ccall((:gpu_alloc,LIB),Cint,(UInt64,Ref{UInt64}),sizeof(raw),allocation))
    pointer = allocation[]+128
    view = unsafe_wrap(CuArray,CuPtr{Float64}(pointer),(length(values),);own=false)
    b = Buffer(raw,allocation[],pointer,view)
    checked(ccall((:gpu_upload,LIB),Cint,(UInt64,Ptr{UInt64},UInt64),b.allocation,raw,sizeof(raw)))
    b
end
function upload!(b,values)
    checked(ccall((:gpu_upload,LIB),Cint,(UInt64,Ptr{Float64},UInt64),b.pointer,values,sizeof(values)))
end
function readbuffer(b)
    checked(ccall((:gpu_download,LIB),Cint,(Ptr{UInt64},UInt64,UInt64),b.raw,b.allocation,sizeof(b.raw)))
    all(==(CANARY),b.raw[1:16]) && all(==(CANARY),b.raw[end-15:end]) || error("A Julia GPU guard changed")
    copy(reinterpret(Float64,b.raw[17:end-16]))
end
function closebuffer!(b)
    checked(ccall((:gpu_free,LIB),Cint,(UInt64,),b.allocation))
end

function loadinput(path)
    open(path,"r") do io
        magic = String(read(io,8))
        if magic == "ESMJG002"
            nx,ny,count = Int(read(io,UInt64)),Int(read(io,UInt64)),Int(read(io,UInt64))
            count == (MODEL == "eb" ? 6 : 5) || error("Wrong complete-bank array count")
            sizes = [Int(read(io,UInt64)) for _ in 1:count]
            host = [read!(io,Vector{Float64}(undef,n)) for n in sizes]
            eof(io) || error("Trailing complete-bank bytes")
            expected = MODEL == "eb" ? [nx+2,nx+2,nx+2,nx+2,3*(nx+2),6] : [3*(nx+2)*(ny+2),3*(nx+2)*(ny+2),3*(nx+2)*(ny+2),5*(nx+2)*(ny+2),4]
            sizes == expected || error("Wrong complete-bank shapes")
            return nx,ny,host
        end
        if MODEL == "eb"
            magic == "ESMEB001" || error("Wrong energy-balance input")
            n = Int(read(io,UInt64)); read(io,UInt64); read(io,UInt64)
            par = [read(io,Float64) for _ in 1:7][1:6]
            seed = [read(io,Float64) for _ in 1:n]
            coeff = [read(io,Float64) for _ in 1:3*(n+2)]
            q = fill(NaN,n+2); q[2:end-1] .= seed
            host = [q,fill(NaN,n+2),fill(NaN,n+2),fill(NaN,n+2),coeff,par]
            return n,1,host
        end
        magic == "ESMSW001" || error("Wrong shallow-water input")
        nx,ny = Int(read(io,UInt64)),Int(read(io,UInt64))
        read(io,UInt64); read(io,UInt64)
        par = [read(io,Float64) for _ in 1:5][1:4]
        seed = reshape([read(io,Float64) for _ in 1:3*nx*ny],nx,ny,3)
        q = fill(NaN,nx+2,ny+2,3); q[2:end-1,2:end-1,:] .= seed
        s = (nx+2)*(ny+2)
        host = [vec(q),fill(NaN,3*s),fill(NaN,3*s),fill(NaN,5*s),par]
        return nx,ny,host
    end
end

function enqueue(nx,ny,b,steps,block)
    arrays = [a.view for a in b]
    if MODEL == "eb"
        Solver.enqueue(Int32(nx),arrays...,steps,STREAM,block)
    else
        Solver.enqueue(Int32(nx),Int32(ny),arrays...,steps,STREAM,block)
    end
end

function interior(nx,ny,q)
    MODEL == "eb" && return q[2:end-1]
    vec(copy(reshape(q,nx+2,ny+2,3)[2:end-1,2:end-1,:]))
end
function canonical(path,nx,ny,q,par,steps,phase)
    open(path,"w") do io
        if MODEL == "eb"
            write(io,"ESMEB001",UInt64(nx),UInt64(steps),UInt64(phase),par,steps*par[2])
        else
            write(io,"ESMSW001",UInt64(nx),UInt64(ny),UInt64(steps),UInt64(phase),par,steps*par[4])
        end
        write(io,interior(nx,ny,q))
    end
end

function trace(input,path,prefix,steps,block)
    nx,ny,host = loadinput(input)
    b = Buffer.(host)
    par = host[end]
    q,stage,out = b[1:3]
    initial = interior(nx,ny,host[1])
    try
        if nx == ny == 1
            enqueue(nx,ny,b,0,block)
            for (original,current) in zip(host,readbuffer.(b))
                reinterpret(UInt64,vec(original)) == reinterpret(UInt64,current) || error("Julia changed a zero-step buffer")
            end
        end
        open(path,"w") do io
            for _ in 1:steps
                enqueue(nx,ny,b,1,block)
                snapshots = readbuffer.(b)
                reinterpret(UInt64,interior(nx,ny,snapshots[1])) == reinterpret(UInt64,initial) || error("Julia changed an input interior")
                for i in (MODEL == "eb" ? (5,6) : (5,))
                    reinterpret(UInt64,snapshots[i]) == reinterpret(UInt64,host[i]) || error("Julia changed an immutable input")
                end
                write(io,snapshots[2],snapshots[3])
                initial = interior(nx,ny,snapshots[3])
                b[1],b[3] = b[3],b[1]
            end
        end
        canonical(prefix*"-p1.bin",nx,ny,readbuffer(b[2]),par,steps,1)
        canonical(prefix*"-p2.bin",nx,ny,readbuffer(b[1]),par,steps,2)
        println("OK"); flush(stdout)
    finally
        closebuffer!.(b)
    end
end

function snapshots(prefix,nx,ny,b,host,steps)
    start = time_ns()
    values = readbuffer.(b)
    transfer_ns = time_ns()-start
    for i in (MODEL == "eb" ? (5,6) : (5,))
        reinterpret(UInt64,values[i]) == reinterpret(UInt64,host[i]) || error("Julia changed an immutable input")
    end
    open(prefix*".raw","w") do io
        for value in values
            write(io,value)
        end
    end
    open(prefix*".guarded.raw","w") do io
        for buffer in b
            write(io,buffer.raw)
        end
    end
    if steps > 0
        canonical(prefix*"-p1.bin",nx,ny,values[2],host[end],steps,1)
        canonical(prefix*"-p2.bin",nx,ny,values[isodd(steps) ? 3 : 1],host[end],steps,2)
    end
    transfer_ns
end

function benchmark(input,prefix,steps,block,timed=true)
    nx,ny,host = loadinput(input)
    start = time_ns()
    b = Buffer.(host)
    allocation_ns = time_ns()-start
    graph = Ref{Ptr{Cvoid}}(C_NULL)
    try
        start = time_ns()
        enqueue(nx,ny,b,1,block); syncgpu()
        compile_warm_ns = time_ns()-start
        upload!.(b,host)
        captured = time_ns()
        checked(ccall((:gpu_capture_begin,LIB),Cint,()))
        enqueue(nx,ny,b,steps,block)
        checked(ccall((:gpu_capture_end,LIB),Cint,(Ref{Ptr{Cvoid}},),graph))
        capture_ns = time_ns()-captured
        nodes = Ref{UInt64}()
        checked(ccall((:gpu_graph_nodes,LIB),Cint,(Ptr{Cvoid},Ref{UInt64}),graph[],nodes))
        enqueue(nx,ny,b,steps,block)
        snapshots(prefix*"-ordinary",nx,ny,b,host,steps)
        upload!.(b,host)
        checked(ccall((:gpu_graph_launch,LIB),Cint,(Ptr{Cvoid},),graph[])); syncgpu()
        snapshots(prefix*"-replay",nx,ny,b,host,steps)
        upload!.(b,host)
        if !timed
            println("CHECK\t",nodes[]); flush(stdout)
            return
        end
        warmed = time_ns()
        while time_ns()-warmed < 30_000_000
            checked(ccall((:gpu_graph_launch,LIB),Cint,(Ptr{Cvoid},),graph[])); syncgpu()
            upload!.(b,host)
        end
        start = time_ns()
        upload!.(b,host)
        upload_ns = time_ns()-start
        elapsed = Ref{Cfloat}()
        start = time_ns()
        checked(ccall((:gpu_graph_time,LIB),Cint,(Ptr{Cvoid},Ref{Cfloat}),graph[],elapsed))
        host_wait_ns = time_ns()-start
        download_ns = snapshots(prefix,nx,ny,b,host,steps)
        println("TIME\t",Float64(elapsed[]),"\t",capture_ns,"\t",compile_warm_ns,
                "\t",allocation_ns,"\t",upload_ns,"\t",download_ns,"\t",host_wait_ns,
                "\t",nodes[],"\t",join([a.pointer for a in b],',')); flush(stdout)
    finally
        graph[] != C_NULL && checked(ccall((:gpu_graph_close,LIB),Cint,(Ptr{Cvoid},),graph[]))
        closebuffer!.(b)
    end
end

function audit(input,prefix,block)
    nx,ny,host = loadinput(input)
    b = Buffer.(host)
    try
        open(prefix*".ptx","w") do io
            CUDA.@device_code_ptx io=io enqueue(nx,ny,b,1,block)
        end
        syncgpu()
        upload!.(b,host)
        open(prefix*".sass","w") do io
            CUDA.@device_code_sass io=io raw=true enqueue(nx,ny,b,1,block)
        end
        syncgpu()
        readbuffer.(b)
        println("AUDITED"); flush(stdout)
    finally
        closebuffer!.(b)
    end
end

# CUDA 12.6 nvdisasm can expand inline line tables without completing.
# This read-only audit disassembles the same CUPTI-captured machine-code bytes.
@eval CUDA.CUDATools function disassemble_cubin(io::IO,cubin::Vector{Cchar};raw::Bool)
    mktemp() do path,file
        write(file,cubin)
        flush(file)
        run(pipeline(`cuobjdump --dump-resource-usage --dump-sass $path`,stdout=io))
    end
end

# A prepared graph owns its complete buffers until CLOSE or process exit.
const PREPARED = Dict{String,Any}()

function prepare_graph(id,input,prefix,steps,block)
    haskey(PREPARED,id) && error("Prepared graph ID already exists")
    nx,ny,host = loadinput(input)
    start = time_ns()
    b = Buffer.(host)
    allocation_ns = time_ns()-start
    graph = Ref{Ptr{Cvoid}}(C_NULL)
    try
        start = time_ns()
        enqueue(nx,ny,b,1,block)
        syncgpu()
        jit_ns = time_ns()-start
        upload!.(b,host)
        start = time_ns()
        checked(ccall((:gpu_capture_begin,LIB),Cint,()))
        enqueue(nx,ny,b,steps,block)
        checked(ccall((:gpu_capture_end,LIB),Cint,(Ref{Ptr{Cvoid}},),graph))
        capture_ns = time_ns()-start
        nodes = Ref{UInt64}()
        checked(ccall((:gpu_graph_nodes,LIB),Cint,(Ptr{Cvoid},Ref{UInt64}),graph[],nodes))
        enqueue(nx,ny,b,steps,block)
        syncgpu()
        snapshots(prefix*"-ordinary",nx,ny,b,host,steps)
        upload!.(b,host)
        checked(ccall((:gpu_graph_launch,LIB),Cint,(Ptr{Cvoid},),graph[]))
        syncgpu()
        snapshots(prefix*"-replay",nx,ny,b,host,steps)
        start = time_ns()
        while time_ns()-start < 30_000_000
            upload!.(b,host)
            checked(ccall((:gpu_graph_launch,LIB),Cint,(Ptr{Cvoid},),graph[]))
            syncgpu()
        end
        warm_ns = time_ns()-start
        upload!.(b,host)
        PREPARED[id] = (;nx,ny,host,b,steps,graph=graph[],block)
        println("PREPARED\t",id,"\t",nodes[],"\t",allocation_ns,"\t",jit_ns,"\t",capture_ns,"\t",warm_ns,"\t",join([a.pointer for a in b],','))
        flush(stdout)
    catch
        graph[] != C_NULL && checked(ccall((:gpu_graph_close,LIB),Cint,(Ptr{Cvoid},),graph[]))
        closebuffer!.(b)
        rethrow()
    end
end

function run_graph(id,prefix,timed)
    state = PREPARED[id]
    upload!.(state.b,state.host)
    warm_ns = UInt64(0)
    if timed
        warm_start = time_ns()
        while time_ns()-warm_start < 30_000_000
            checked(ccall((:gpu_graph_launch,LIB),Cint,(Ptr{Cvoid},),state.graph))
            syncgpu()
            upload!.(state.b,state.host)
        end
        warm_ns = time_ns()-warm_start
        elapsed = Ref{Cfloat}()
        checked(ccall((:gpu_graph_time,LIB),Cint,(Ptr{Cvoid},Ref{Cfloat}),state.graph,elapsed))
        seconds = Float64(elapsed[])/1000.0
    else
        checked(ccall((:gpu_graph_launch,LIB),Cint,(Ptr{Cvoid},),state.graph))
        syncgpu()
        seconds = 0.0
    end
    snapshots(prefix,state.nx,state.ny,state.b,state.host,state.steps)
    println(timed ? "TIME" : "CHECK","\t",seconds,"\t",id,"\t",prefix*".raw","\t",prefix*".guarded.raw","\t",warm_ns)
    flush(stdout)
end

function close_graph(id)
    state = pop!(PREPARED,id)
    checked(ccall((:gpu_graph_close,LIB),Cint,(Ptr{Cvoid},),state.graph))
    closebuffer!.(state.b)
    println("CLOSED\t",id)
    flush(stdout)
end

println("READY\t",VERSION,"\t",Base.pkgversion(CUDA)); flush(stdout)
for line in eachline(stdin)
    fields = split(line,'\t')
    if fields[1] == "QUIT"
        for id in collect(keys(PREPARED))
            close_graph(id)
        end
        break
    elseif fields[1] == "PREP"
        prepare_graph(fields[2],fields[3],fields[4],parse(Int,fields[5]),parse(Int,fields[6]))
    elseif fields[1] == "RUN" || fields[1] == "REPLAY"
        run_graph(fields[2],fields[3],fields[1] == "RUN")
    elseif fields[1] == "CLOSE"
        close_graph(fields[2])
    elseif fields[1] == "TRACE"
        trace(fields[2],fields[3],fields[4],parse(Int,fields[5]),parse(Int,fields[6]))
    elseif fields[1] == "BENCH"
        benchmark(fields[2],fields[3],parse(Int,fields[4]),parse(Int,fields[5]))
    elseif fields[1] == "GRAPH"
        benchmark(fields[2],fields[3],parse(Int,fields[4]),parse(Int,fields[5]),false)
    elseif fields[1] == "AUDIT"
        audit(fields[2],fields[3],parse(Int,fields[4]))
    else
        error("Unknown Julia GPU command")
    end
end
