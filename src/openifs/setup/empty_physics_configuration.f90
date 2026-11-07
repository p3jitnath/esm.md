!> Check the selected empty physics configuration group in bounded bytes.
!! Match the exact caller-supplied group name after a line-leading marker
!! within columns1 to10. This interface performs no numerical calculation.
module forecast_empty_physics_configuration
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: require_empty_physics_group
contains
  !> Return0 for an empty first matching group and2 for a refusal.
  !! text contains1 to262144 source bytes and group_name contains1 to16
  !! exact bytes. No case conversion or trailing-blank removal is applied.
  !! Spaces, tabs, CR and LF are allowed before the marker and in the body.
  !! An exclamation comment in the body ends at LF. All inputs stay unchanged.
  integer(int32) function require_empty_physics_group(text,group_name) result(status)
    character(len=*),intent(in) :: text,group_name
    integer :: i,j,k,n,g,column,code
    logical :: matched
    status=2
    n=len(text)
    g=len(group_name)
    if(n<1 .or. n>262144 .or. g<1 .or. g>16)return
    i=1
    column=0
    do while(i<=n)
      code=iachar(text(i:i))
      if(code==10)then
        column=0
        i=i+1
        cycle
      end if
      column=column+1
      if(code==32 .or. code==9 .or. code==13)then
        i=i+1
        cycle
      end if
      if(code==38 .and. column<=10)then
        j=i+1
        if(j+g>n)return
        matched=.true.
        do k=1,g
          if(text(j+k-1:j+k-1)/=group_name(k:k))then
            matched=.false.
            exit
          end if
        end do
        if(matched)then
          j=j+g
          code=iachar(text(j:j))
          if(space(code) .or. code==47)then
            i=j
            do while(i<=n)
              code=iachar(text(i:i))
              if(code==47)then
                status=0
                return
              end if
              if(code==33)then
                do
                  i=i+1
                  if(i>n)return
                  if(iachar(text(i:i))==10)exit
                end do
              else if(.not.space(code))then
                return
              end if
              i=i+1
            end do
            return
          end if
        end if
      end if
      do
        i=i+1
        if(i>n)return
        if(iachar(text(i:i))==10)exit
      end do
      i=i+1
      column=0
    end do
  end function

  logical function space(code)
    integer,intent(in) :: code
    space=code==32 .or. code==9 .or. code==10 .or. code==13
  end function
end module forecast_empty_physics_configuration
