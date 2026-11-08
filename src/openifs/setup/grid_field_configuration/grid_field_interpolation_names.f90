module grid_field_interpolation_names_port
  !! Select the exact twelve-character interpolation label.
  !! flags has ten int32 logical words in source order:
  !! LSLHD,LCOMAD,LVSPLIP,LHV,LQM,LQMH,LQM3D,LQML3D,LINTLIN,LVWENO.
  !! Each is zero or one. The label changes only on success (status zero).
  use, intrinsic :: iso_fortran_env, only: int32
  use grid_field_component_types_port, only: grid_field_mode_supported
  implicit none
  private
  public :: grid_field_interpolation_name
contains
  integer(int32) function grid_field_interpolation_name(flags, name) result(status)
    integer(int32), contiguous, intent(in) :: flags(:)
    character(len=12), intent(inout) :: name
    integer(int32) :: choice, i
    character(len=12), parameter :: names(0:22) = [character(len=12) :: &
                                                   'LAITQM(SLD) ', 'LAITQMH(SLD)', 'LAITRI(SLD) ', 'LAITVSPCQM  ', &
                                                   'LIN(MAD)    ', 'LIN         ', 'LAITRWENOQM ', 'LAITRWENOQM3', &
                                                   'LAITRWENOQMH', 'LAITRWENO   ', 'LAIHVTQM    ', 'LAIHVTQMH   ', &
                                                   'LAIHVT      ', 'LAITQM3(MAD)', 'LAITQM3D    ', 'LAITQML(MAD)', &
                                                   'LAITQML3D   ', 'LAITQM(MAD) ', 'LAITQM      ', 'LAITQMH(MAD)', &
                                                   'LAITQMH     ', 'LAITRI(MAD) ', 'LAITRI      ']
    status = 2_int32
    if (size(flags) /= 10) return
    if (.not. grid_field_mode_supported()) return
    do i = 1, 10
      if (flags(i) < 0 .or. flags(i) > 1) return
    end do
    if (flags(1) /= 0) then
      if (flags(5) /= 0) then
        choice = 0
      else if (flags(6) /= 0) then
        choice = 1
      else
        choice = 2
      end if
    else if (flags(3) /= 0) then
      choice = 3
    else if (flags(9) /= 0) then
      choice = 5
      if (flags(2) /= 0) choice = 4
    else if (flags(10) /= 0) then
      if (flags(5) /= 0) then
        choice = 6
      else if (flags(7) /= 0) then
        choice = 7
      else if (flags(6) /= 0) then
        choice = 8
      else
        choice = 9
      end if
    else if (flags(4) /= 0) then
      if (flags(5) /= 0) then
        choice = 10
      else if (flags(6) /= 0) then
        choice = 11
      else
        choice = 12
      end if
    else if (flags(7) /= 0) then
      choice = 14
      if (flags(2) /= 0) choice = 13
    else if (flags(8) /= 0) then
      choice = 16
      if (flags(2) /= 0) choice = 15
    else if (flags(5) /= 0) then
      choice = 18
      if (flags(2) /= 0) choice = 17
    else if (flags(6) /= 0) then
      choice = 20
      if (flags(2) /= 0) choice = 19
    else
      choice = 22
      if (flags(2) /= 0) choice = 21
    end if
    name = names(choice)
    status = 0_int32
  end function
end module grid_field_interpolation_names_port
