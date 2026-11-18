module ShallowWater

@inline function halo!(q)
    nx, ny = size(q, 1) - 2, size(q, 2) - 2
    @inbounds for a in 1:3
        for j in 2:ny+1
            q[1,j,a] = q[nx+1,j,a]
            q[nx+2,j,a] = q[2,j,a]
        end
        @simd for i in 1:nx+2
            q[i,1,a] = q[i,ny+1,a]
            q[i,ny+2,a] = q[i,2,a]
        end
    end
end

function prepare!(q, work, g)
    @inbounds for j in axes(q,2)
        @simd for i in axes(q,1)
            h, mx, my = q[i,j,1], q[i,j,2], q[i,j,3]
            u, v = mx/h, my/h
            z = g*h
            c = sqrt(z)
            p = (z*h)*0.5
            work[i,j,1] = mx*u+p
            work[i,j,2] = mx*v
            work[i,j,3] = my*v+p
            work[i,j,4] = abs(u)+c
            work[i,j,5] = abs(v)+c
        end
    end
end

@inline face(ql,qr,fl,fr,alpha) = (fl+fr)*0.5-(alpha*0.5)*(qr-ql)

function component!(q, base, out, fx, fy, sx, sy, par, final)
    @inbounds for j in 2:size(q,2)-1
        @simd for i in 2:size(q,1)-1
            east = face(q[i,j],q[i+1,j],fx[i,j],fx[i+1,j],max(sx[i,j],sx[i+1,j]))
            west = face(q[i-1,j],q[i,j],fx[i-1,j],fx[i,j],max(sx[i-1,j],sx[i,j]))
            north = face(q[i,j],q[i,j+1],fy[i,j],fy[i,j+1],max(sy[i,j],sy[i,j+1]))
            south = face(q[i,j-1],q[i,j],fy[i,j-1],fy[i,j],max(sy[i,j-1],sy[i,j]))
            dx, dy = (east-west)/par[2], (north-south)/par[3]
            ell = -(dx+dy)
            e = q[i,j]+par[4]*ell
            out[i,j] = final ? base[i,j]*0.5+e*0.5 : e
        end
    end
end

function update!(q, base, out, work, par, final)
    @views begin
        component!(q[:,:,1],base[:,:,1],out[:,:,1],q[:,:,2],q[:,:,3],
                   work[:,:,4],work[:,:,5],par,final)
        component!(q[:,:,2],base[:,:,2],out[:,:,2],work[:,:,1],work[:,:,2],
                   work[:,:,4],work[:,:,5],par,final)
        component!(q[:,:,3],base[:,:,3],out[:,:,3],work[:,:,2],work[:,:,3],
                   work[:,:,4],work[:,:,5],par,final)
    end
end

"""
    step!(q, stage, out, work, parameters)

Evaluate the complete step in formulations/shallow_water.md using disjoint
Array{Float64,3} buffers of shape (nx+2, ny+2, 3), a five-field work array,
and four SI parameters g, dx, dy, dt. Preserve q's interior, copy its halos,
and write both output states with periodic halos; return nothing.
"""
function step!(q, stage, out, work, parameters)
    halo!(q)
    prepare!(q,work,parameters[1])
    update!(q,q,stage,work,parameters,false)
    halo!(stage)
    prepare!(stage,work,parameters[1])
    update!(stage,q,out,work,parameters,true)
    halo!(out)
    nothing
end

"""
    run!(q, stage, out, work, parameters, nsteps)

Run nsteps complete updates with the buffers described by step!. Repeated
updates may overwrite both q and out; final state is out for an odd count
and q for an even count. Return nothing without allocating state buffers.
"""
function run!(q, stage, out, work, parameters, nsteps)
    for n in 1:2:nsteps
        step!(q,stage,out,work,parameters)
        n < nsteps && step!(out,stage,q,work,parameters)
    end
    nothing
end

end
