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

@inline function euler(n,q,coeff,i,ratio,delta,A,B,Tf)
    p = n+2
    @inbounds begin
        value = q[i+1]
        right = i < n ? mul(coeff[i+1],sub(q[i+2],value)) : 0.0
        left = i > 1 ? mul(coeff[i],sub(value,q[i])) : 0.0
        forcing = value <= Tf ? coeff[2*p+i+1] : coeff[p+i+1]
        r = sub(forcing,add(A,mul(B,value)))
        ell = add(r,divide(sub(right,left),delta))
        add(value,mul(ratio,ell))
    end
end

function complete(n,q,stage,out,work,coeff,par)
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    i > n && return nothing
    p = n+2
    @inbounds begin
        ratio,delta = divide(par[2],par[1]),par[3]
        A,B,Tf = par[4],par[5],par[6]
        first = euler(n,q,coeff,i,ratio,delta,A,B,Tf)
        right = i < n ? mul(coeff[i+1],sub(euler(n,q,coeff,i+1,ratio,delta,A,B,Tf),first)) : 0.0
        left = i > 1 ? mul(coeff[i],sub(first,euler(n,q,coeff,i-1,ratio,delta,A,B,Tf))) : 0.0
        forcing = first <= Tf ? coeff[2*p+i+1] : coeff[p+i+1]
        r = sub(forcing,add(A,mul(B,first)))
        ell = add(r,divide(sub(right,left),delta))
        value = add(mul(q[i+1],0.5),mul(add(first,mul(ratio,ell)),0.5))
        stage[i+1],out[i+1] = first,value
        if i == 1
            q[1],stage[1],out[1] = q[i+1],first,value
        end
        if i == n
            q[n+2],stage[n+2],out[n+2] = q[i+1],first,value
        end
    end
    nothing
end

function persistent(n,q,stage,out,work,coeff,par,steps)
    shared = @cuStaticSharedMem(Float64,(130,3))
    i = threadIdx().x
    active = i <= n
    ratio = delta = A = B = Tf = kr = kl = warm = ice = 0.0
    @inbounds if active
        shared[i+1,1] = q[i+1]
        p = n+2
        ratio,delta = divide(par[2],par[1]),par[3]
        A,B,Tf = par[4],par[5],par[6]
        kr,kl,warm,ice = coeff[i+1],coeff[i],coeff[p+i+1],coeff[2*p+i+1]
    end
    sync_threads()
    source,result = Int32(1),Int32(3)
    for _ in Int32(1):steps
        phase_source,phase_result = source,Int32(2)
        for phase in Int32(0):Int32(1)
            @inbounds if active
                temperature = shared[i+1,phase_source]
                right = i < n ? mul(kr,sub(shared[i+2,phase_source],temperature)) : 0.0
                left = i > 1 ? mul(kl,sub(temperature,shared[i,phase_source])) : 0.0
                forcing = temperature <= Tf ? ice : warm
                r = sub(forcing,add(A,mul(B,temperature)))
                ell = add(r,divide(sub(right,left),delta))
                value = add(temperature,mul(ratio,ell))
                phase == 1 && (value = add(mul(shared[i+1,source],0.5),mul(value,0.5)))
                shared[i+1,phase_result] = value
            end
            sync_threads()
            phase_source,phase_result = Int32(2),result
        end
        source,result = result,source
    end
    @inbounds if active
        q[i+1],stage[i+1],out[i+1] = shared[i+1,1],shared[i+1,2],shared[i+1,3]
        if i == 1
            q[1],stage[1],out[1] = q[i+1],stage[i+1],out[i+1]
        end
        if i == n
            q[n+2],stage[n+2],out[n+2] = q[i+1],stage[i+1],out[i+1]
        end
    end
    nothing
end

"""
    enqueue(n, q, stage, out, work, coeff, par, steps, stream, block=128)

Queue complete FP64 updates and poles on `stream`. Disjoint `CuVector{Float64}`
states and scratch have n+2 values. Immutable coeff holds K,W,I and par holds
C,dt,delta,A,B,Tf in contract units. Return nothing. Zero steps change no buffer.
A nonempty batch of at most 128 bands stays in one block with two barriers per
step. Larger grids recompute neighbours from the original state and return
both stages with one launch per step. All paths preserve q/out alternation.
"""
function enqueue(n,q,stage,out,work,coeff,par,steps,stream,block=128)
    steps == 0 && return nothing
    if n <= 128
        @cuda threads=128 blocks=1 stream=stream persistent(n,q,stage,out,work,coeff,par,Int32(steps))
        return nothing
    end
    grid = cld(Int(n),block)
    for _ in 1:steps
        @cuda threads=block blocks=grid stream=stream complete(n,q,stage,out,work,coeff,par)
        q,out = out,q
    end
    nothing
end
end
