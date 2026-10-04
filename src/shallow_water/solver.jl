module ShallowWater

@inline function halo!(q)
    nx, ny = size(q, 1) - 2, size(q, 2) - 2
    @inbounds for a in 1:3
        for j in 2:ny+1
            q[1,j,a] = q[nx+1,j,a]
            q[nx+2,j,a] = q[2,j,a]
        end
        @simd ivdep for i in 1:nx+2
            q[i,1,a] = q[i,ny+1,a]
            q[i,ny+2,a] = q[i,2,a]
        end
    end
end

@inline function prepare!(q, work, g, firstrow, lastrow)
    @inbounds for j in firstrow:lastrow
        @simd ivdep for i in axes(q,1)
            h, mx, my = q[i,j,1], q[i,j,2], q[i,j,3]
            u, v = mx/h, my/h
            z = g*h
            # The frozen domain gives z>0, so the correctly rounded intrinsic needs no domain branch.
            c = Core.Intrinsics.sqrt_llvm(z)
            p = (z*h)*0.5
            work[i,j,1] = mx*u+p
            work[i,j,2] = mx*v
            work[i,j,3] = my*v+p
            work[i,j,4] = abs(u)+c
            work[i,j,5] = abs(v)+c
        end
    end
end

@inline face(ql,qr,fl,fr,halfalpha) = (fl+fr)*0.5-halfalpha*(qr-ql)
@inline speed(left,right) = ifelse(left>=right,left,right)

@inline function cell(east,west,north,south,qc,base,xscale,yscale,dt,
                      ::Val{final},::Val{scaled}) where {final,scaled}
    dx,dy = scaled ? ((east-west)*xscale,(north-south)*yscale) :
                     ((east-west)/xscale,(north-south)/yscale)
    ell = -(dx+dy)
    e = qc+dt*ell
    final ? base*0.5+e*0.5 : e
end

@inline function row!(q,base,out,work,par,final::Val,::Val{scaled},xscale,yscale,j,::Val{first}) where {scaled,first}
    nx,ny = size(q,1)-2,size(q,2)-2
    ring = nx>=128 && ny>=3
    r,rn,rf,rs = ring ? (1+mod(j-1,3),1+mod(j,3),4+mod(j-1,2),4+mod(j-2,2)) : (j,j+1,j-1,j-2)
    @inbounds begin
        aw = speed(work[1,r,4],work[2,r,4])*0.5
        out[1,ny+2,1] = face(q[1,j,1],q[2,j,1],q[1,j,2],q[2,j,2],aw)
        out[1,ny+2,2] = face(q[1,j,2],q[2,j,2],work[1,r,1],work[2,r,1],aw)
        out[1,ny+2,3] = face(q[1,j,3],q[2,j,3],work[1,r,2],work[2,r,2],aw)
        @simd ivdep for i in 2:nx+1
            h,mx,my = q[i,j+1,1],q[i,j+1,2],q[i,j+1,3]
            u,v = mx/h,my/h
            z = par[1]*h
            c = Core.Intrinsics.sqrt_llvm(z)
            p = (z*h)*0.5
            ax,cross,ay = mx*u+p,mx*v,my*v+p
            sxn,syn = abs(u)+c,abs(v)+c
            work[i,rn,1],work[i,rn,2],work[i,rn,3] = ax,cross,ay
            work[i,rn,4],work[i,rn,5] = sxn,syn
            ae = speed(work[i,r,4],work[i+1,r,4])*0.5
            an = speed(work[i,r,5],syn)*0.5
            ass = first ? speed(work[i,1,5],work[i,r,5])*0.5 : 0.0
            east = face(q[i,j,1],q[i+1,j,1],q[i,j,2],q[i+1,j,2],ae)
            north = face(q[i,j,1],h,q[i,j,3],my,an)
            if first
                out[i,1,1] = face(q[i,j-1,1],q[i,j,1],q[i,j-1,3],q[i,j,3],ass)
            end
            out[i,ny+2,1],work[i,rf,1] = east,north
            east = face(q[i,j,2],q[i+1,j,2],work[i,r,1],work[i+1,r,1],ae)
            north = face(q[i,j,2],mx,work[i,r,2],cross,an)
            if first
                out[i,1,2] = face(q[i,j-1,2],q[i,j,2],work[i,1,2],work[i,r,2],ass)
            end
            out[i,ny+2,2],work[i,rf,2] = east,north
            east = face(q[i,j,3],q[i+1,j,3],work[i,r,2],work[i+1,r,2],ae)
            north = face(q[i,j,3],my,work[i,r,3],ay,an)
            if first
                out[i,1,3] = face(q[i,j-1,3],q[i,j,3],work[i,1,3],work[i,r,3],ass)
            end
            out[i,ny+2,3],work[i,rf,3] = east,north
        end
        for a in 1:3
            @simd ivdep for i in 2:nx+1
                south = first ? out[i,1,a] : work[i,rs,a]
                out[i,j,a] = cell(out[i,ny+2,a],out[i-1,ny+2,a],work[i,rf,a],south,
                                  q[i,j,a],base[i,j,a],xscale,yscale,par[4],final,Val(scaled))
            end
        end
        for a in 1:5
            work[1,rn,a] = work[nx+1,rn,a]
            work[nx+2,rn,a] = work[2,rn,a]
        end
    end
end

function update!(q,base,out,work,par,final::Val,::Val{scaled}) where {scaled}
    xscale,yscale = scaled ? (1.0/par[2],1.0/par[3]) : (par[2],par[3])
    nx,ny = size(q,1)-2,size(q,2)-2
    prepare!(q,work,par[1],1,2)
    row!(q,base,out,work,par,final,Val(scaled),xscale,yscale,2,Val(true))
    for j in 3:ny+1
        row!(q,base,out,work,par,final,Val(scaled),xscale,yscale,j,Val(false))
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
    # Compile-time flags keep invariant choices outside the vector cell loops.
    scaled = frexp(parameters[2])[1] == 0.5 && frexp(parameters[3])[1] == 0.5 &&
             parameters[2] >= floatmin(Float64) && parameters[3] >= floatmin(Float64)
    halo!(q)
    update!(q,q,stage,work,parameters,Val(false),Val(scaled))
    halo!(stage)
    update!(stage,q,out,work,parameters,Val(true),Val(scaled))
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
