!> Emit original setup statements through public Fortran formatted I/O.
module forecast_geometry_and_radiation_reporting
  use iso_fortran_env, only: int32
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: write_radiation_interpolation_extent, report_distributed_local_geometry
contains
  !> UNIT is a live external Fortran unit. STATE is readonly; no format flags
 !! or I/O effects are removed. Return0 succeeds and1 reports an I/O error.
  integer(int32) function write_radiation_interpolation_extent(state, unit) result(status)
    type(native_interpolation_state), intent(in) :: state
    integer(int32), intent(in) :: unit
    integer :: error
    write (unit, '("SUECRAD: YD",A2,"%NASLB1=",I12)', iostat=error) state%cver, state%naslb1
    status = merge(1_int32, 0_int32, error /= 0)
  end function
  !> PHASE0 emits the allocation heading. Any nonzero phase emits the source
 !! final heading, named halo bounds and point count. Each statement runs
 !! in order; the returned status is the final statement's original result.
  integer(int32) function report_distributed_local_geometry(first_halo, last_halo, points, phase, unit) result(status)
    integer(int32), intent(in) :: first_halo, last_halo, points, phase, unit
    integer :: error
    if (phase == 0) then
      write (unit, "(' Allocations in SUGEM3:')", iostat=error)
    else
      write (unit, "(' Printings in SUGEM3:')", iostat=error)
      write (unit, '(2X,A,I5,A,I5)', iostat=error) ' NDGSAH = ', first_halo, ' NDGENH = ', last_halo
      write (unit, "(' NGPTOT =',I9)", iostat=error) points
    end if
    status = merge(1_int32, 0_int32, error /= 0)
  end function
end module forecast_geometry_and_radiation_reporting
