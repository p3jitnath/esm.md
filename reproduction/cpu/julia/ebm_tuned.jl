module BudykoSellers

@inline function halo!(q)
    @inbounds q[1],q[end] = q[2],q[end-1]
    nothing
end

@inline function update!(q,base,out,work,coeff,par,beta,scale,::Val{final},::Val{scaled},lo,hi) where {final,scaled}
    n = length(q)-2
    @inbounds intercept,slope,threshold = par[4],par[5],par[6]
    @inbounds begin
        @simd ivdep for i in lo:hi
            east = coeff[i,1]*(q[i+1]-q[i])
            west = coeff[i-1,1]*(q[i]-q[i-1])
            forcing = ifelse(q[i]<=threshold,coeff[i,3],coeff[i,2])
            r = forcing-(intercept+slope*q[i])
            diffusion = scaled ? (east-west)*scale : (east-west)/scale
            ell = r+diffusion
            e = q[i]+beta*ell
            out[i] = final ? base[i]*0.5+e*0.5 : e
        end
    end
    nothing
end

"""
    step!(q, stage, out, work, coeff, parameters)

Evaluate both stages in formulations/budyko_sellers.md using disjoint
Vector{Float64} state and work buffers of length n+2, a contiguous coefficient
array of shape (n+2,3), and six immutable parameters C,dt,delta,A,B,Tf.
Preserve q's interior, copy its pole ghosts, and return nothing.
"""
function step!(q,stage,out,work,coeff,parameters)
    beta = parameters[2]/parameters[1]
    scaled = frexp(parameters[3])[1]==0.5 && parameters[3]>=floatmin(Float64)
    scale = scaled ? 1.0/parameters[3] : parameters[3]
    if scaled
        complete!(q,stage,out,work,coeff,parameters,beta,scale,Val(true))
    else
        complete!(q,stage,out,work,coeff,parameters,beta,scale,Val(false))
    end
    nothing
end

@inline function complete!(q,stage,out,work,coeff,par,beta,scale,scaled)
    n = length(q)-2
    halo!(q)
    if n>=8192
        @inbounds for lo in 2:512:n+1
            hi = min(n+1,lo+511)
            first = lo==2 ? lo : lo+1
            last = min(n+1,hi+1)
            update!(q,q,stage,work,coeff,par,beta,scale,Val(false),scaled,first,last)
            lo==2 && (stage[1]=stage[2])
            last==n+1 && (stage[n+2]=stage[n+1])
            update!(stage,q,out,work,coeff,par,beta,scale,Val(true),scaled,lo,hi)
        end
    else
        update!(q,q,stage,work,coeff,par,beta,scale,Val(false),scaled,2,n+1)
        halo!(stage)
        update!(stage,q,out,work,coeff,par,beta,scale,Val(true),scaled,2,n+1)
    end
    halo!(out)
    nothing
end

"""
    run!(q, stage, out, work, coeff, parameters, nsteps)

Run complete steps without allocating numerical buffers; the final state
is out after an odd count and q after an even count, and zero leaves every
buffer unchanged. Return nothing.
"""
function run!(q,stage,out,work,coeff,parameters,nsteps)
    nsteps==0 && return nothing
    scaled = frexp(parameters[3])[1]==0.5 && parameters[3]>=floatmin(Float64)
    if scaled
        repeated!(q,stage,out,work,coeff,parameters,nsteps,Val(true))
    else
        repeated!(q,stage,out,work,coeff,parameters,nsteps,Val(false))
    end
    nothing
end

@inline function repeated!(q,stage,out,work,coeff,par,nsteps,::Val{scaled}) where scaled
    beta = par[2]/par[1]
    scale = scaled ? 1.0/par[3] : par[3]
    for k in 1:2:nsteps
        complete!(q,stage,out,work,coeff,par,beta,scale,Val(scaled))
        k<nsteps && complete!(out,stage,q,work,coeff,par,beta,scale,Val(scaled))
    end
    nothing
end
end
