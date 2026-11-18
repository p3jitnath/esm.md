module FreshJuliaCallbacks
"""
    CArray(pointer::Ptr{Float64}, dimensions::NTuple{N,Int})

Borrow contiguous caller-owned FP64 storage with column-major dimensions. The
view does not keep its owner alive, allocate numerical storage, or free storage.
The complete caller must retain the owner and valid bounds until return. State
views hold SW depth [m] and momenta [m²/s], or EBM temperatures [°C]; work views
have mixed scratch units. A write changes the borrowed caller-owned storage.
"""
struct CArray{N} <: AbstractArray{Float64,N}
    ptr::Ptr{Float64}
    dims::NTuple{N,Int}
end
Base.size(a::CArray) = a.dims
Base.IndexStyle(::Type{<:CArray}) = IndexLinear()
@inline Base.getindex(a::CArray, i::Int) = unsafe_load(a.ptr, i)
@inline Base.setindex!(a::CArray, v, i::Int) = unsafe_store!(a.ptr, Float64(v), i)
@inline Base.getindex(a::CArray{2}, i::Int, j::Int) = unsafe_load(a.ptr, i+(j-1)*a.dims[1])
@inline Base.setindex!(a::CArray{2}, v, i::Int, j::Int) =
    unsafe_store!(a.ptr, Float64(v), i+(j-1)*a.dims[1])
@inline Base.getindex(a::CArray{3}, i::Int, j::Int, k::Int) =
    unsafe_load(a.ptr, i+(j-1)*a.dims[1]+(k-1)*a.dims[1]*a.dims[2])
@inline Base.setindex!(a::CArray{3}, v, i::Int, j::Int, k::Int) =
    unsafe_store!(a.ptr, Float64(v), i+(j-1)*a.dims[1]+(k-1)*a.dims[1]*a.dims[2])

module SWTuned
include("sw_tuned.jl")
end
module SWVanilla
include("sw_vanilla.jl")
end
module EBTuned
include("ebm_tuned.jl")
end
module EBVanilla
include("ebm_vanilla.jl")
end

# Select the invariant spacing branch before repeated work so Julia can keep
# borrowed array descriptors on the stack. Each numerical call is unchanged.
function sw_tuned_repeated!(q, s, o, w, p, count, scaled::Val)
    for k = 1:2:count
        SWTuned.ShallowWater.halo!(q)
        SWTuned.ShallowWater.update!(q, q, s, w, p, Val(false), scaled)
        SWTuned.ShallowWater.halo!(s)
        SWTuned.ShallowWater.update!(s, q, o, w, p, Val(true), scaled)
        SWTuned.ShallowWater.halo!(o)
        if k<count
            SWTuned.ShallowWater.halo!(o)
            SWTuned.ShallowWater.update!(o, o, s, w, p, Val(false), scaled)
            SWTuned.ShallowWater.halo!(s)
            SWTuned.ShallowWater.update!(s, o, q, w, p, Val(true), scaled)
            SWTuned.ShallowWater.halo!(q)
        end
    end
    nothing
end
function sw_tuned_run!(q, s, o, w, p, count)
    count==0 && return nothing
    scaled=frexp(p[2])[1]==0.5 &&
           frexp(p[3])[1]==0.5 &&
           p[2]>=floatmin(Float64) &&
           p[3]>=floatmin(Float64)
    if scaled
        sw_tuned_repeated!(q, s, o, w, p, count, Val(true))
    else
        sw_tuned_repeated!(q, s, o, w, p, count, Val(false))
    end
    nothing
end
for (name, core) in
    ((:sw_tuned, SWTuned.ShallowWater), (:sw_vanilla, SWVanilla.ShallowWater))
    runner = name==:sw_tuned ? sw_tuned_run! : core.run!
    @eval function $name(
        nx::Cint,
        ny::Cint,
        q::Ptr{Float64},
        s::Ptr{Float64},
        o::Ptr{Float64},
        w::Ptr{Float64},
        p::Ptr{Float64},
        count::Cint,
    )::Cvoid
        dims=(Int(nx)+2, Int(ny)+2, 3)
        $runner(
            CArray(q, dims),
            CArray(s, dims),
            CArray(o, dims),
            CArray(w, (Int(nx)+2, Int(ny)+2, 5)),
            CArray(p, (4,)),
            Int(count),
        )
        nothing
    end
end
for (name, core) in
    ((:ebm_tuned, EBTuned.BudykoSellers), (:ebm_vanilla, EBVanilla.BudykoSellers))
    @eval function $name(
        n::Cint,
        q::Ptr{Float64},
        s::Ptr{Float64},
        o::Ptr{Float64},
        w::Ptr{Float64},
        c::Ptr{Float64},
        p::Ptr{Float64},
        count::Cint,
    )::Cvoid
        dims=(Int(n)+2,)
        $core.run!(
            CArray(q, dims),
            CArray(s, dims),
            CArray(o, dims),
            CArray(w, dims),
            CArray(c, (Int(n)+2, 3)),
            CArray(p, (6,)),
            Int(count),
        )
        nothing
    end
end
const sw_tuned_ptr=@cfunction(
    sw_tuned,
    Cvoid,
    (
        Cint,
        Cint,
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Cint,
    )
)
const sw_vanilla_ptr=@cfunction(
    sw_vanilla,
    Cvoid,
    (
        Cint,
        Cint,
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Cint,
    )
)
const ebm_tuned_ptr=@cfunction(
    ebm_tuned,
    Cvoid,
    (
        Cint,
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Cint,
    )
)
const ebm_vanilla_ptr=@cfunction(
    ebm_vanilla,
    Cvoid,
    (
        Cint,
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Cint,
    )
)

# Compilation and warm-up use ordinary Julia arrays before worker entry.
function warmup()
    for mod in (SWTuned.ShallowWater, SWVanilla.ShallowWater)
        for nx in (7, 128)
            q=ones(nx+2, 7, 3)
            q[:, :, 2].=0.0
            q[:, :, 3].=0.0
            s=copy(q)
            o=copy(q)
            w=zeros(nx+2, 7, 5)
            p=[9.81, 1.0, 1.0, 0.001]
            GC.@preserve q s o w p begin
                mod.run!(
                    CArray(pointer(q), size(q)),
                    CArray(pointer(s), size(s)),
                    CArray(pointer(o), size(o)),
                    CArray(pointer(w), size(w)),
                    CArray(pointer(p), size(p)),
                    2,
                )
            end
        end
    end
    for mod in (EBTuned.BudykoSellers, EBVanilla.BudykoSellers)
        q=fill(10.0, 34)
        s=copy(q)
        o=copy(q)
        w=zeros(34)
        c=zeros(34, 3)
        p=[1.0e8, 1.0, 0.25, 200.0, 2.0, -10.0]
        GC.@preserve q s o w c p begin
            mod.run!(
                CArray(pointer(q), size(q)),
                CArray(pointer(s), size(s)),
                CArray(pointer(o), size(o)),
                CArray(pointer(w), size(w)),
                CArray(pointer(c), size(c)),
                CArray(pointer(p), size(p)),
                2,
            )
        end
    end
    nothing
end
warmup()
using Libdl
const SW_COORD=Ref{Ptr{Cvoid}}(C_NULL)
const EB_COORD=Ref{Ptr{Cvoid}}(C_NULL)
const COORD_HANDLES=Any[]
function configure(model, path)
    lib=Libdl.dlopen(path)
    push!(COORD_HANDLES, lib)
    if model=="sw"
        SW_COORD[]=Libdl.dlsym(lib, :sw_run_tiles)
    else
        EB_COORD[]=Libdl.dlsym(lib, :eb_run_tiles)
    end
    nothing
end
function sw_tiles(
    kernel::Ptr{Cvoid},
    nx::Cint,
    ny::Cint,
    q::Ptr{Float64},
    s::Ptr{Float64},
    o::Ptr{Float64},
    p::Ptr{Float64},
    count::Cint,
    px::Cint,
    py::Cint,
    batch::Cint,
    w::Ptr{Float64},
    nw::Int64,
)::Cint
    fn=SW_COORD[]
    @ccall gc_safe=true $fn(
        kernel::Ptr{Cvoid},
        nx::Cint,
        ny::Cint,
        q::Ptr{Float64},
        s::Ptr{Float64},
        o::Ptr{Float64},
        p::Ptr{Float64},
        count::Cint,
        px::Cint,
        py::Cint,
        batch::Cint,
        w::Ptr{Float64},
        nw::Int64,
    )::Cint
end
function ebm_tiles(
    kernel::Ptr{Cvoid},
    n::Cint,
    q::Ptr{Float64},
    s::Ptr{Float64},
    o::Ptr{Float64},
    c::Ptr{Float64},
    p::Ptr{Float64},
    count::Cint,
    threads::Cint,
    batch::Cint,
    w::Ptr{Float64},
    nw::Int64,
)::Cint
    fn=EB_COORD[]
    @ccall gc_safe=true $fn(
        kernel::Ptr{Cvoid},
        n::Cint,
        q::Ptr{Float64},
        s::Ptr{Float64},
        o::Ptr{Float64},
        c::Ptr{Float64},
        p::Ptr{Float64},
        count::Cint,
        threads::Cint,
        batch::Cint,
        w::Ptr{Float64},
        nw::Int64,
    )::Cint
end
const sw_tiles_ptr=@cfunction(
    sw_tiles,
    Cint,
    (
        Ptr{Cvoid},
        Cint,
        Cint,
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Cint,
        Cint,
        Cint,
        Cint,
        Ptr{Float64},
        Int64,
    )
)
const ebm_tiles_ptr=@cfunction(
    ebm_tiles,
    Cint,
    (
        Ptr{Cvoid},
        Cint,
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Ptr{Float64},
        Cint,
        Cint,
        Cint,
        Ptr{Float64},
        Int64,
    )
)
function allocated_sw(
    fn::Ptr{Cvoid},
    nx::Cint,
    ny::Cint,
    q::Ptr{Float64},
    s::Ptr{Float64},
    o::Ptr{Float64},
    w::Ptr{Float64},
    p::Ptr{Float64},
    count::Cint,
)
    ccall(
        fn,
        Cvoid,
        (
            Cint,
            Cint,
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Cint,
        ),
        nx,
        ny,
        q,
        s,
        o,
        w,
        p,
        count,
    )
    @allocated ccall(
        fn,
        Cvoid,
        (
            Cint,
            Cint,
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Cint,
        ),
        nx,
        ny,
        q,
        s,
        o,
        w,
        p,
        count,
    )
end
function allocated_eb(
    fn::Ptr{Cvoid},
    n::Cint,
    q::Ptr{Float64},
    s::Ptr{Float64},
    o::Ptr{Float64},
    w::Ptr{Float64},
    c::Ptr{Float64},
    p::Ptr{Float64},
    count::Cint,
)
    ccall(
        fn,
        Cvoid,
        (
            Cint,
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Cint,
        ),
        n,
        q,
        s,
        o,
        w,
        c,
        p,
        count,
    )
    @allocated ccall(
        fn,
        Cvoid,
        (
            Cint,
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Ptr{Float64},
            Cint,
        ),
        n,
        q,
        s,
        o,
        w,
        c,
        p,
        count,
    )
end
function probe_allocations()
    records=Dict{String,Int}()
    nx=8
    ny=5
    q=ones(nx+2, ny+2, 3)
    q[:, :, 2].=0.0
    q[:, :, 3].=0.0
    s=copy(q)
    o=copy(q)
    w=zeros(nx+2, ny+2, 5)
    p=[9.81, 1.0, 1.0, 0.001]
    GC.@preserve q s o w p begin
        for (label, fn) in (("sw_tuned", sw_tuned_ptr), ("sw_vanilla", sw_vanilla_ptr))
            records[label]=allocated_sw(
                fn,
                Cint(nx),
                Cint(ny),
                pointer(q),
                pointer(s),
                pointer(o),
                pointer(w),
                pointer(p),
                Cint(2),
            )
        end
    end
    n=32
    q=fill(10.0, n+2)
    s=copy(q)
    o=copy(q)
    w=zeros(n+2)
    c=zeros(n+2, 3)
    p=[1.0e8, 1.0, 0.25, 200.0, 2.0, -10.0]
    GC.@preserve q s o w c p begin
        for (label, fn) in (("ebm_tuned", ebm_tuned_ptr), ("ebm_vanilla", ebm_vanilla_ptr))
            records[label]=allocated_eb(
                fn,
                Cint(n),
                pointer(q),
                pointer(s),
                pointer(o),
                pointer(w),
                pointer(c),
                pointer(p),
                Cint(2),
            )
        end
    end
    records
end
const ALLOCATIONS=probe_allocations()

end
