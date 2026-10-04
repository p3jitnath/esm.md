module BudykoSellers

@inline function halo!(q)
    @inbounds q[1],q[end] = q[2],q[end-1]
    nothing
end

function update!(q,base,out,work,coeff,par,final)
    n = length(q)-2
    beta = par[2]/par[1]
    @inbounds begin
        work[1],work[n+1] = 0.0,0.0
        for i in 2:n
            work[i] = coeff[i,1]*(q[i+1]-q[i])
        end
        for i in 2:n+1
            forcing = q[i]<=par[6] ? coeff[i,3] : coeff[i,2]
            r = forcing-(par[4]+par[5]*q[i])
            ell = r+(work[i]-work[i-1])/par[3]
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
    halo!(q)
    update!(q,q,stage,work,coeff,parameters,false)
    halo!(stage)
    update!(stage,q,out,work,coeff,parameters,true)
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
    for k in 1:2:nsteps
        step!(q,stage,out,work,coeff,parameters)
        k<nsteps && step!(out,stage,q,work,coeff,parameters)
    end
    nothing
end
end
