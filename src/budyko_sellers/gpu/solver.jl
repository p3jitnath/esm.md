module EnergyBalanceGPUOptimised
using CUDA
const add = CUDA.add_rn
const sub = CUDA.sub_rn
const mul = CUDA.mul_rn
const divide = CUDA.div_rn

function halo(n, q)
    t = (blockIdx().x-1)*blockDim().x+threadIdx().x-1
    @inbounds if t == 0
        q[1] = q[2]
    elseif t == 1
        q[n+2] = q[n+1]
    end
    nothing
end

function faces(n, q, work, coeff)
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x-1
    i > n && return nothing
    @inbounds work[i+1] = i == 0 || i == n ? 0.0 : mul(coeff[i+1], sub(q[i+2], q[i+1]))
    nothing
end

function update(n, q, base, out, work, coeff, par, final)
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    i > n && return nothing
    p = n+2
    @inbounds begin
        i == 1 && (q[1] = q[i+1])
        i == n && (q[n+2] = q[i+1])
        right = i < n ? mul(coeff[i+1],sub(q[i+2],q[i+1])) : 0.0
        left = i > 1 ? mul(coeff[i],sub(q[i+1],q[i])) : 0.0
        forcing = q[i+1] <= par[6] ? coeff[2*p+i+1] : coeff[p+i+1]
        r = sub(forcing, add(par[4], mul(par[5], q[i+1])))
        ell = add(r, divide(sub(right,left), par[3]))
        e = add(q[i+1], mul(divide(par[2], par[1]), ell))
        value = final == 0 ? e : add(mul(base[i+1],0.5),mul(e,0.5))
        out[i+1] = value
        i == 1 && (out[1] = value)
        i == n && (out[n+2] = value)
    end
    nothing
end

"""
    enqueue(n, q, stage, out, work, coeff, par, steps, stream, block=128)

Queue both FP64 stages and pole boundaries on `stream`. Disjoint `CuVector{Float64}`
states and scratch have n+2 values, coeff has three fields, and par contains
C,dt,delta,A,B,Tf in contract units. Preserve the input interior for one step.
Return nothing. Zero steps leave every buffer unchanged, and repeated steps
place the last state in out for an odd count and q for an even count.
"""
function enqueue(n, q, stage, out, work, coeff, par, steps, stream, block=128)
    grid = cld(Int(n), block)
    for _ in 1:steps
        @cuda threads=block blocks=grid stream=stream update(n,q,q,stage,work,coeff,par,Int32(0))
        @cuda threads=block blocks=grid stream=stream update(n,stage,q,out,work,coeff,par,Int32(1))
        q,out = out,q
    end
    nothing
end
end
