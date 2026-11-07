!> Native scalar spline factors and inverse, with the accepted arithmetic order.
!! All matrices have dimensionless FP64 entries in contiguous column order.
!! The supported square dimension is 1 through 24. The live spline uses 4 and 21.
!! The caller owns disjoint matrix, pivot and status storage. Rejection returns 2
!! before mutation; completed calculations return 0 and set the LAPACK info word.
module forecast_spline_scalar_inverse
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  use, intrinsic :: ieee_exceptions, only: ieee_set_flag, ieee_inexact, ieee_underflow, ieee_overflow
  implicit none
  private
  public :: spline_lu_factor, spline_upper_inverse, spline_inverse_from_lu
  public :: rounded_product_sum
  integer, parameter :: limb_bits=26, limb_count=166
  integer(c_int64_t), parameter :: limb_base=67108864_c_int64_t, limb_mask=67108863_c_int64_t
  integer(c_int64_t), parameter :: fraction_mask=int(z'000FFFFFFFFFFFFF',c_int64_t)
contains
  !> Factor a finite square matrix in place into lower and upper factors.
  !! matrix has shape (n,n), intent(inout), and dimensionless entries. pivots has
  !! at least n int32 cells, intent(inout), and receives one-based row indices.
  !! info is int32, intent(inout): it becomes zero or the first zero-pivot index
  !! after admission, and remains unchanged when the function returns 2.
  integer(c_int) function spline_lu_factor(matrix,pivots,info) result(status)
    real(c_double), contiguous, intent(inout) :: matrix(:,:)
    integer(c_int), contiguous, intent(inout) :: pivots(:)
    integer(c_int), intent(inout) :: info
    integer :: n,j,k,i,p
    real(c_double) :: pivot,largest,trial,temporary,reciprocal,factor
    status=2_c_int
    n=size(matrix,1)
    if(n<1.or.n>24.or.size(matrix,2)/=n.or.size(pivots)<n) return
    if(.not.all(ieee_is_finite(matrix))) return
    info=0_c_int
    do j=1,n
      p=j
      pivot=matrix(j,j)
      largest=abs(pivot)
      do i=j+1,n
        trial=abs(matrix(i,j))
        if(trial>largest) then
          p=i
          pivot=matrix(i,j)
          largest=trial
        end if
      end do
      pivots(j)=int(p,c_int)
      if(pivot/=0.0_c_double) then
        if(p/=j) then
          do k=1,n
            temporary=matrix(j,k)
            matrix(j,k)=matrix(p,k)
            matrix(p,k)=temporary
          end do
        end if
        if(j<n) then
          if(largest>=tiny(1.0_c_double)) then
            reciprocal=1.0_c_double/pivot
            do i=j+1,n
              matrix(i,j)=reciprocal*matrix(i,j)
            end do
          else
            do i=j+1,n
              matrix(i,j)=matrix(i,j)/pivot
            end do
          end if
        end if
      else if(info==0_c_int) then
        info=int(j,c_int)
      end if
      do k=j+1,n
        if(matrix(j,k)==0.0_c_double) cycle
        factor=(-1.0_c_double)*matrix(j,k)
        do i=j+1,n
          matrix(i,k)=rounded_product_sum(matrix(i,j),factor,matrix(i,k))
        end do
      end do
    end do
    status=0_c_int
  end function spline_lu_factor

  !> Replace the upper triangle by its inverse; preserve the lower triangle.
  !! matrix has shape (n,n), intent(inout), and dimensionless entries. info is
  !! int32, intent(inout), and receives zero or the first zero diagonal index.
  !! A singular matrix stays unchanged. Rejection returns 2 without mutation.
  integer(c_int) function spline_upper_inverse(matrix,info) result(status)
    real(c_double), contiguous, intent(inout) :: matrix(:,:)
    integer(c_int), intent(inout) :: info
    integer :: n,j,k,i
    real(c_double) :: scale,temporary
    status=2_c_int
    n=size(matrix,1)
    if(n<1.or.n>24.or.size(matrix,2)/=n) return
    if(.not.all(ieee_is_finite(matrix))) return
    do j=1,n
      if(matrix(j,j)==0.0_c_double) then
        info=int(j,c_int)
        status=0_c_int
        return
      end if
    end do
    info=0_c_int
    do j=1,n
      matrix(j,j)=1.0_c_double/matrix(j,j)
      scale=-matrix(j,j)
      do k=1,j-1
        temporary=matrix(k,j)
        if(temporary==0.0_c_double) cycle
        do i=1,k-1
          matrix(i,j)=rounded_product_sum(matrix(i,k),temporary,matrix(i,j))
        end do
        matrix(k,j)=temporary*matrix(k,k)
      end do
      do i=1,j-1
        matrix(i,j)=scale*matrix(i,j)
      end do
    end do
    status=0_c_int
  end function spline_upper_inverse

  !> Form a complete inverse from the accepted in-place LU factors and pivots.
  !! matrix has shape (n,n), intent(inout), and dimensionless entries. pivots has
  !! at least n int32 cells, intent(in), with j <= pivots(j) <= n. info is int32,
  !! intent(inout), and receives zero or a singular diagonal index. A singular
  !! matrix stays unchanged. Rejection returns 2 before mutation.
  integer(c_int) function spline_inverse_from_lu(matrix,pivots,info) result(status)
    real(c_double), contiguous, intent(inout) :: matrix(:,:)
    integer(c_int), contiguous, intent(in) :: pivots(:)
    integer(c_int), intent(inout) :: info
    integer :: n,j,k,i,p
    real(c_double) :: work(24),factor,temporary
    status=2_c_int
    n=size(matrix,1)
    if(n<1.or.n>24.or.size(matrix,2)/=n.or.size(pivots)<n) return
    do j=1,n
      if(pivots(j)<j.or.pivots(j)>n) return
    end do
    status=spline_upper_inverse(matrix,info)
    if(status/=0_c_int.or.info/=0_c_int) return
    do j=n,1,-1
      do i=j+1,n
        work(i)=matrix(i,j)
        matrix(i,j)=0.0_c_double
      end do
      do k=j+1,n
        factor=(-1.0_c_double)*work(k)
        do i=1,n
          matrix(i,j)=rounded_product_sum(matrix(i,k),factor,matrix(i,j))
        end do
      end do
    end do
    do j=n-1,1,-1
      p=int(pivots(j))
      if(p==j) cycle
      do i=1,n
        temporary=matrix(i,j)
        matrix(i,j)=matrix(i,p)
        matrix(i,p)=temporary
      end do
    end do
    status=0_c_int
  end function spline_inverse_from_lu

  !> Return the exact real expression a*b+c rounded once to FP64, ties to even.
  !! a, b and c are finite dimensionless real(c_double) scalars, intent(in).
  !! The caller selects nearest rounding and gradual underflow. Integer limbs
  !! retain the complete exact magnitude on the common scale 2**(-2148).
  !! Existing IEEE flags stay set. The function adds the accepted inexact,
  !! tiny-before-rounding underflow and overflow flags; it uses no floating
  !! multiplication, addition or fused operation to calculate the result.
  real(c_double) function rounded_product_sum(a,b,c) result(value)
    real(c_double), intent(in) :: a,b,c
    integer(c_int64_t) :: wa,wb,wc,ma,mb,mc,da(0:2),db(0:2),dp(0:5),carry,t
    integer(c_int64_t) :: product(0:limb_count-1),addend(0:limb_count-1),total(0:limb_count-1)
    integer(c_int64_t) :: significand,word
    integer :: ea,eb,ec,sa,sb,sc,sp,sign_result,i,j,k,comparison,borrow,h,exponent,shift
    logical :: discarded,up,tiny_result
    wa=transfer(a,wa)
    wb=transfer(b,wb)
    wc=transfer(c,wc)
    call decode_word(wa,ma,ea,sa)
    call decode_word(wb,mb,eb,sb)
    call decode_word(wc,mc,ec,sc)
    sp=ieor(sa,sb)
    if(ma==0_c_int64_t.or.mb==0_c_int64_t) then
      word=wc
      if(mc==0_c_int64_t) word=shiftl(int(iand(sp,sc),c_int64_t),63)
      value=transfer(word,value)
      return
    end if
    do i=0,2
      da(i)=iand(shiftr(ma,limb_bits*i),limb_mask)
      db(i)=iand(shiftr(mb,limb_bits*i),limb_mask)
    end do
    dp=0_c_int64_t
    do i=0,2
      carry=0_c_int64_t
      do j=0,2
        k=i+j
        t=dp(k)+da(i)*db(j)+carry
        dp(k)=iand(t,limb_mask)
        carry=shiftr(t,limb_bits)
      end do
      dp(i+3)=carry
    end do
    product=0_c_int64_t
    addend=0_c_int64_t
    do i=0,5
      call insert_digit(product,dp(i),ea+eb+2148+limb_bits*i)
    end do
    do i=0,2
      t=iand(shiftr(mc,limb_bits*i),limb_mask)
      call insert_digit(addend,t,ec+2148+limb_bits*i)
    end do
    sign_result=sp
    if(sp==sc) then
      carry=0_c_int64_t
      do i=0,limb_count-1
        t=product(i)+addend(i)+carry
        total(i)=iand(t,limb_mask)
        carry=shiftr(t,limb_bits)
      end do
    else
      comparison=0
      do i=limb_count-1,0,-1
        if(product(i)>addend(i)) then
          comparison=1
          exit
        else if(product(i)<addend(i)) then
          comparison=-1
          exit
        end if
      end do
      if(comparison==0) then
        word=0_c_int64_t
        value=transfer(word,value)
        return
      end if
      borrow=0
      if(comparison>0) then
        do i=0,limb_count-1
          t=product(i)-addend(i)-int(borrow,c_int64_t)
          borrow=0
          if(t<0_c_int64_t) then
            t=t+limb_base
            borrow=1
          end if
          total(i)=t
        end do
      else
        sign_result=sc
        do i=0,limb_count-1
          t=addend(i)-product(i)-int(borrow,c_int64_t)
          borrow=0
          if(t<0_c_int64_t) then
            t=t+limb_base
            borrow=1
          end if
          total(i)=t
        end do
      end if
    end if
    h=-1
    do i=limb_count-1,0,-1
      if(total(i)==0_c_int64_t) cycle
      h=limb_bits*i+(bit_size(total(i))-1-leadz(total(i)))
      exit
    end do
    if(h<0) then
      word=shiftl(int(sign_result,c_int64_t),63)
      value=transfer(word,value)
      return
    end if
    exponent=h-2148
    tiny_result=exponent<(-1022)
    shift=h-52
    if(tiny_result) shift=1074
    significand=0_c_int64_t
    do i=h,shift,-1
      significand=shiftl(significand,1)
      if(test_bit(total,i)) significand=ibset(significand,0)
    end do
    discarded=any_below(total,shift)
    up=.false.
    if(test_bit(total,shift-1)) up=any_below(total,shift-1).or.btest(significand,0)
    if(up) significand=significand+1_c_int64_t
    if(tiny_result) then
      word=ior(significand,shiftl(int(sign_result,c_int64_t),63))
      if(discarded) then
        call ieee_set_flag(ieee_underflow,.true.)
        call ieee_set_flag(ieee_inexact,.true.)
      end if
    else
      if(btest(significand,53)) then
        significand=shiftr(significand,1)
        exponent=exponent+1
      end if
      if(exponent>1023) then
        word=ior(int(z'7FF0000000000000',c_int64_t),shiftl(int(sign_result,c_int64_t),63))
        call ieee_set_flag(ieee_overflow,.true.)
        call ieee_set_flag(ieee_inexact,.true.)
      else
        word=ior(shiftl(int(exponent+1023,c_int64_t),52),iand(significand,fraction_mask))
        word=ior(word,shiftl(int(sign_result,c_int64_t),63))
        if(discarded) call ieee_set_flag(ieee_inexact,.true.)
      end if
    end if
    value=transfer(word,value)
  end function rounded_product_sum

  !> Decode a finite FP64 word as (-1)**sign * magnitude * 2**exponent.
  pure subroutine decode_word(word,magnitude,exponent,sign)
    integer(c_int64_t), intent(in) :: word
    integer(c_int64_t), intent(out) :: magnitude
    integer, intent(out) :: exponent,sign
    integer :: encoded_exponent
    encoded_exponent=int(ibits(word,52,11))
    magnitude=iand(word,fraction_mask)
    exponent=-1074
    if(encoded_exponent/=0) then
      magnitude=ibset(magnitude,52)
      exponent=encoded_exponent-1075
    end if
    sign=int(ibits(word,63,1))
  end subroutine decode_word

  !> Insert one nonnegative base-2**26 digit at an exact binary bit position.
  pure subroutine insert_digit(words,digit,position)
    integer(c_int64_t), intent(inout) :: words(0:limb_count-1)
    integer(c_int64_t), intent(in) :: digit
    integer, intent(in) :: position
    integer :: index,offset
    if(digit==0_c_int64_t) return
    index=position/limb_bits
    offset=mod(position,limb_bits)
    words(index)=ior(words(index),iand(shiftl(digit,offset),limb_mask))
    if(offset/=0) words(index+1)=ior(words(index+1),shiftr(digit,limb_bits-offset))
  end subroutine insert_digit

  !> Report whether a nonnegative exact integer has a set bit below position.
  pure logical function any_below(words,position) result(found)
    integer(c_int64_t), intent(in) :: words(0:limb_count-1)
    integer, intent(in) :: position
    integer :: index,offset
    found=.false.
    if(position<=0) return
    index=position/limb_bits
    offset=mod(position,limb_bits)
    if(index>0) found=any(words(0:index-1)/=0_c_int64_t)
    if(offset/=0) found=found.or.iand(words(index),shiftl(1_c_int64_t,offset)-1_c_int64_t)/=0_c_int64_t
  end function any_below

  !> Read one bit from the nonnegative exact integer without floating arithmetic.
  pure logical function test_bit(words,position) result(found)
    integer(c_int64_t), intent(in) :: words(0:limb_count-1)
    integer, intent(in) :: position
    found=.false.
    if(position<0) return
    found=btest(words(position/limb_bits),mod(position,limb_bits))
  end function test_bit
end module forecast_spline_scalar_inverse
