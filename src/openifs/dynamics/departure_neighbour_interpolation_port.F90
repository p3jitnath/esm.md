module md2asm_departure_neighbour_interpolation
  !! Eight-neighbour LAITLI interpolation and LAMINMAXINT local field bounds.
  !! Fractions have no unit. Returned fields keep their input physical unit.
  use iso_fortran_env,only:int32,int64,real64
  implicit none
  private
  public::interpolate_eight_neighbours,bound_eight_neighbours
contains
  subroutine interpolate_eight_neighbours(source_pitch,pitch,first,last,levels,first_plane,last_plane, &
      latitude,longitude,indices,vertical,field,result,status)
    !! Coordinates and result use (cell,level); longitude and indices add
    !! two latitude-row planes. Source index values retain zero-origin bases.
    integer(int32),intent(in)::source_pitch,pitch,first,last,levels,first_plane,last_plane
    real(real64),intent(in)::latitude(:,:),longitude(:,:,:),vertical(:,:),field(:)
    integer(int32),intent(in)::indices(:,:,:)
    real(real64),intent(inout)::result(:,:)
    integer(int32),intent(out)::status
    integer(int64)::planes,total,a,k1,k2
    integer::cell,level,h,s,e
    real(real64)::upper_one,upper_two,upper,lower_one,lower_two,lower
    status=2
    planes=int(last_plane,int64)-int(first_plane,int64)+1_int64
    if(source_pitch<0.or.source_pitch>(huge(0_int32)-2)/2.or.pitch<0.or.levels<0)return
    if(pitch==huge(0_int32).or.levels==huge(0_int32).or.planes<1.or.planes>huge(0_int32))return
    if(2_int64*int(pitch,int64)*levels>huge(0_int32))return
    total=int(source_pitch,int64)*planes
    if(total>huge(0_int32))return
    if(first<1.or.int(first,int64)>int(pitch,int64)+1.or.last<0.or.last>pitch)return
    status=0
    if(levels==0.or.first>last)return
    status=2
    if(size(latitude,1)/=pitch.or.size(latitude,2)<levels)return
    if(size(vertical,1)/=pitch.or.size(vertical,2)<levels)return
    if(size(longitude,1)/=pitch.or.size(longitude,2)<levels.or.size(longitude,3)/=2)return
    if(size(indices,1)/=pitch.or.size(indices,2)<levels.or.size(indices,3)/=2)return
    if(size(result,1)/=pitch.or.size(result,2)<levels.or.size(field,kind=int64)/=total)return
    a=source_pitch
    do level=1,levels
      do cell=first,last
        if(.not.finite(latitude(cell,level)).or..not.finite(vertical(cell,level)))return
        if(.not.all(finite(longitude(cell,level,:))))return
        do s=1,2
          k1=int(indices(cell,level,s),int64)
          if(k1+a<0.or.k1+2*a+1>=total)return
          do h=1,2
            do e=0,1
              if(.not.finite(field(k1+h*a+e+1)))return
            end do
          end do
        end do
      end do
    end do
    do level=1,levels
      do cell=first,last
        k1=int(indices(cell,level,1),int64)+a+1
        k2=int(indices(cell,level,2),int64)+a+1
        upper_one=blend(field(k1),field(k1+1),longitude(cell,level,1))
        upper_two=blend(field(k2),field(k2+1),longitude(cell,level,2))
        upper=blend(upper_one,upper_two,latitude(cell,level))
        k1=k1+a
        k2=k2+a
        lower_one=blend(field(k1),field(k1+1),longitude(cell,level,1))
        lower_two=blend(field(k2),field(k2+1),longitude(cell,level,2))
        lower=blend(lower_one,lower_two,latitude(cell,level))
        result(cell,level)=blend(upper,lower,vertical(cell,level))
      end do
    end do
    status=0
  end subroutine

  subroutine bound_eight_neighbours(source_pitch,pitch,first,last,levels,first_plane,last_plane, &
      indices,field,minimum,status,maximum)
    !! Four complete index planes are supplied; only middle planes2 and3
    !! select neighbours. An absent maximum requests only the minimum.
    integer(int32),intent(in)::source_pitch,pitch,first,last,levels,first_plane,last_plane
    integer(int32),intent(in)::indices(:,:,:)
    real(real64),intent(in)::field(:)
    real(real64),intent(inout)::minimum(:,:)
    integer(int32),intent(out)::status
    real(real64),intent(inout),optional::maximum(:,:)
    integer(int64)::planes,total,a,k1,k2
    integer::cell,level,h,s,e,j
    real(real64)::values(8),lo,hi
    status=2
    planes=int(last_plane,int64)-int(first_plane,int64)+1
    if(source_pitch<0.or.source_pitch>1048576.or.pitch<0.or.pitch>4096.or.levels<0.or.levels>512)return
    if(planes<0.or.planes>1024)return
    total=int(source_pitch,int64)*planes
    if(total>huge(0_int32))return
    if(first<1.or.first>pitch+1.or.last<0.or.last>pitch)return
    status=0
    if(levels==0.or.first>last)return
    status=2
    if(size(indices,1)/=pitch.or.size(indices,2)<levels.or.size(indices,3)/=4)return
    if(size(field,kind=int64)/=total.or.size(minimum,1)/=pitch.or.size(minimum,2)<levels)return
    if(present(maximum))then
      if(size(maximum,1)/=pitch.or.size(maximum,2)<levels)return
    end if
    a=source_pitch
    do level=1,levels
      do cell=first,last
        do s=2,3
          k1=int(indices(cell,level,s),int64)
          if(k1+a<0.or.k1+2*a+1>=total)return
          do h=1,2
            do e=0,1
              if(.not.finite(field(k1+h*a+e+1)))return
            end do
          end do
        end do
      end do
    end do
    do level=1,levels
      do cell=first,last
        k1=int(indices(cell,level,2),int64)+a+1
        k2=int(indices(cell,level,3),int64)+a+1
        values=[field(k1),field(k1+1),field(k2),field(k2+1), &
          field(k1+a),field(k1+a+1),field(k2+a),field(k2+a+1)]
        lo=ordered_minimum(values(1),values(2))
        do j=3,8
          lo=ordered_minimum(lo,values(j))
        end do
        minimum(cell,level)=lo
        if(present(maximum))then
          hi=ordered_maximum(values(1),values(2))
          do j=3,8
            hi=ordered_maximum(hi,values(j))
          end do
          maximum(cell,level)=hi
        end if
      end do
    end do
    status=0
  end subroutine
  elemental logical function finite(value)
    real(real64),intent(in)::value
    finite=ibits(transfer(value,0_int64),52,11)/=2047_int64
  end function
  real(real64) function blend(a,b,fraction) result(value)
    real(real64),intent(in)::a,b,fraction
    real(real64)::difference,product
    difference=b-a
    product=fraction*difference
    value=a+product
  end function
  real(real64) function ordered_minimum(a,b) result(value)
    real(real64),intent(in)::a,b
    if(a==b)then
      value=a
      if(a==0.0_real64)value=transfer(ior(transfer(a,0_int64),transfer(b,0_int64)),0.0_real64)
    else if(a<b)then
      value=a
    else
      value=b
    end if
  end function
  real(real64) function ordered_maximum(a,b) result(value)
    real(real64),intent(in)::a,b
    if(a==b)then
      value=a
      if(a==0.0_real64)value=transfer(iand(transfer(a,0_int64),transfer(b,0_int64)),0.0_real64)
    else if(a>b)then
      value=a
    else
      value=b
    end if
  end function
end module md2asm_departure_neighbour_interpolation
