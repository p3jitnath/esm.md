module ShallowWaterGPUVanilla
using CUDA
const add = CUDA.add_rn
const sub = CUDA.sub_rn
const mul = CUDA.mul_rn
const divide = CUDA.div_rn

function halo(nx, ny, q)
    t = (blockIdx().x-1)*blockDim().x+threadIdx().x-1
    p,s = nx+2,(nx+2)*(ny+2)
    t >= 3*s && return nothing
    a,j,i = t÷s,(t%s)÷p,t%p
    0 < i <= nx && 0 < j <= ny && return nothing
    ii = i == 0 ? nx : i == nx+1 ? Int32(1) : i
    jj = j == 0 ? ny : j == ny+1 ? Int32(1) : j
    @inbounds q[t+1] = q[a*s+jj*p+ii+1]
    nothing
end

function prepare(nx, ny, q, work, par)
    t = (blockIdx().x-1)*blockDim().x+threadIdx().x-1
    s = (nx+2)*(ny+2)
    t >= s && return nothing
    @inbounds begin
        h,mx,my = q[t+1],q[s+t+1],q[2*s+t+1]
        u,v = divide(mx,h),divide(my,h)
        z = mul(par[1],h)
        c = sqrt(z)
        pressure = mul(mul(z,h),0.5)
        work[t+1] = add(mul(mx,u),pressure)
        work[s+t+1] = mul(mx,v)
        work[2*s+t+1] = add(mul(my,v),pressure)
        work[3*s+t+1] = add(abs(u),c)
        work[4*s+t+1] = add(abs(v),c)
    end
    nothing
end

@inline function face(ql,qr,fl,fr,sl,sr)
    alpha = sl >= sr ? sl : sr
    sub(mul(add(fl,fr),0.5),mul(mul(alpha,0.5),sub(qr,ql)))
end

function update(nx,ny,q,base,out,work,par,final)
    t = (blockIdx().x-1)*blockDim().x+threadIdx().x-1
    t >= nx*ny && return nothing
    p,s = nx+2,(nx+2)*(ny+2)
    k = (t÷nx+1)*p+t%nx+1
    sx,sy = 3*s,4*s
    @inbounds for a in Int32(0):Int32(2)
        b = a*s+k
        if a == 0
            fx0,fxe,fxw = q[s+k+1],q[s+k+2],q[s+k]
            fy0,fyn,fys = q[2*s+k+1],q[2*s+k+p+1],q[2*s+k-p+1]
        else
            fx0,fxe,fxw = work[(a-1)*s+k+1],work[(a-1)*s+k+2],work[(a-1)*s+k]
            fy0,fyn,fys = work[a*s+k+1],work[a*s+k+p+1],work[a*s+k-p+1]
        end
        east = face(q[b+1],q[b+2],fx0,fxe,work[sx+k+1],work[sx+k+2])
        west = face(q[b],q[b+1],fxw,fx0,work[sx+k],work[sx+k+1])
        north = face(q[b+1],q[b+p+1],fy0,fyn,work[sy+k+1],work[sy+k+p+1])
        south = face(q[b-p+1],q[b+1],fys,fy0,work[sy+k-p+1],work[sy+k+1])
        ell = -add(divide(sub(east,west),par[2]),divide(sub(north,south),par[3]))
        e = add(q[b+1],mul(par[4],ell))
        out[b+1] = final == 0 ? e : add(mul(base[b+1],0.5),mul(e,0.5))
    end
    nothing
end

"""
    enqueue(nx, ny, q, stage, out, work, par, steps, stream, block=128)

Queue both complete FP64 stages and periodic boundaries on one stream. Flat
disjoint CuVector{Float64} states have 3*(nx+2)*(ny+2) values, scratch has five
fields, and par contains g,dx,dy,dt in SI units. Return nothing. Preserve input
interior values for one step, return out for odd counts and q for even counts,
and leave every buffer unchanged for zero steps.
"""
function enqueue(nx,ny,q,stage,out,work,par,steps,stream,block=128)
    s = Int(nx+2)*Int(ny+2)
    cells,halos,points = cld(Int(nx)*Int(ny),block),cld(3*s,block),cld(s,block)
    for _ in 1:steps
        @cuda threads=block blocks=halos stream=stream halo(nx,ny,q)
        @cuda threads=block blocks=points stream=stream prepare(nx,ny,q,work,par)
        @cuda threads=block blocks=cells stream=stream update(nx,ny,q,q,stage,work,par,Int32(0))
        @cuda threads=block blocks=halos stream=stream halo(nx,ny,stage)
        @cuda threads=block blocks=points stream=stream prepare(nx,ny,stage,work,par)
        @cuda threads=block blocks=cells stream=stream update(nx,ny,stage,q,out,work,par,Int32(1))
        @cuda threads=block blocks=halos stream=stream halo(nx,ny,out)
        q,out = out,q
    end
    nothing
end
end
