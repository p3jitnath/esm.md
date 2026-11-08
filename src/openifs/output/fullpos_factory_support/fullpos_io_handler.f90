!> Own the Fullpos output records while borrowing the canonical stream.
module forecast_fullpos_io_handler
  use iso_fortran_env, only: int32
  use yomfpop, only: tfpioh
  use yomfpgeometry, only: tfpgeometry
  use forecast_geometry_stream, only: native_geometry_stream
  use forecast_fullpos_io_scheme, only: native_fullpos_output_names
  use forecast_fullpos_grib_setup, only: initialize_native_fullpos_grib_setup, release_native_fullpos_grib_setup
  implicit none
  private
  public :: initialize_fullpos_io_handler, release_fullpos_io_handler
contains
  !> Allocate FA records then filename records and publish only a complete handler.
 !! All strings are borrowed. OUTPUT must have no live owners.
 integer(int32) function initialize_fullpos_io_handler(names,geometry,stream,experiment,grid_prefixes,spectral_path,output)result(status)
    type(native_fullpos_output_names), intent(in) :: names
    type(tfpgeometry), intent(in) :: geometry
    type(native_geometry_stream), intent(inout) :: stream
    character(*), intent(in) :: experiment, grid_prefixes, spectral_path
    type(tfpioh), intent(inout) :: output
    type(tfpioh) :: pending
    integer :: ierr
    status = 2
    if (allocated(output%yfpoph)) return
    if (allocated(output%yfpofn)) return
    if (.not. allocated(geometry%yfpusergeo)) return
    if (size(geometry%yfpusergeo) /= 1) return
    if (allocated(stream%nfpmax) .or. allocated(stream%numprocfp)) return
    allocate (pending%yfpoph(1), stat=ierr)
    if (ierr /= 0) then
      status = 1; return
    end if
    allocate (pending%yfpofn(1), stat=ierr)
    if (ierr /= 0) then
      deallocate (pending%yfpoph); status = 1; return
    end if
 status=initialize_native_fullpos_grib_setup(geometry%yfpgeo,geometry%yfpusergeo,names%climate_filename,experiment,grid_prefixes,spectral_path,pending%yfpofn,stream)
    if (status /= 0) then
      deallocate (pending%yfpoph); deallocate (pending%yfpofn); return
    end if
    output%ynamfpios%nfpgrib = names%controls%nfpgrib
    output%ynamfpios%nfpwrite = max(-1, min(1, names%controls%nfpwrite))
    output%ynamfpios%nfpxfld = names%controls%nfpxfld
    output%ynamfpios%nfpdigits = names%controls%nfpdigits
    output%ynamfpios%lfppgdfwr = names%controls%lfppgdfwr
    output%ynamfpios%lfphisfwr = names%controls%lfphisfwr
    call move_alloc(pending%yfpoph, output%yfpoph)
    call move_alloc(pending%yfpofn, output%yfpofn)
    status = 0
  end function
  !> Retire stream owners before the FA and filename owners.
  subroutine release_fullpos_io_handler(output, stream)
    type(tfpioh), intent(inout) :: output
    type(native_geometry_stream), intent(inout) :: stream
    call release_native_fullpos_grib_setup(stream)
    if (allocated(output%yfpoph)) deallocate (output%yfpoph)
    if (allocated(output%yfpofn)) deallocate (output%yfpofn)
  end subroutine
end module
