!> Apply every source declaration store to the actual native user-geometry type.
!! Angles are in degrees and lengths follow the later produced model geometry.
!! NFPRGRI, NFPMEN and FPMU must be absent native owners. Refusal changes nothing.
!! All source-unwritten named members retain their incoming values.
module forecast_fullpos_user_geometry_declaration_defaults
  use iso_fortran_env, only: int32, real64
  use type_fpusergeo, only: tfpusergeo
  implicit none
  private
  public :: initialize_fullpos_user_geometry_declaration_defaults
contains
  integer(int32) function initialize_fullpos_user_geometry_declaration_defaults(output) result(status)
    type(tfpusergeo), intent(inout) :: output
    status = 2
    if (allocated(output%nfprgri) .or. allocated(output%nfpmen) .or. allocated(output%fpmu)) return
    output%nlat = 0_int32
    output%nlon = 0_int32
    output%nfphtyp = 0_int32
    output%nfpttyp = 1_int32
    output%fpmucen = 0_real64
    output%fplocen = 0_real64
    output%fpstret = 0_real64
    output%rdely = 0_real64
    output%rdelx = 0_real64
    output%nfprlx = 0_int32
    output%nfprux = 0_int32
    output%nfprly = 0_int32
    output%nfpruy = 0_int32
    output%nfpgux = 0_int32
    output%nfplux = 0_int32
    output%nfpbwx = 0_int32
    output%nfpbwy = 0_int32
    output%rlatc = 0_real64
    output%rlonc = 0_real64
    output%fplon0 = 0_real64
    output%fplat0 = 0_real64
    output%lfpmrt = .false.
    output%lfpmap = .false.
    output%fplx = 0_real64
    output%fply = 0_real64
    output%nfpbzonl = 0_int32
    output%nfpbzong = 0_int32
    output%nfpedom = 1_int32
    output%nfpmax = 0_int32
    output%nmfpmax = 0_int32
    output%nfpnoextzl = 0_int32
    output%nfpnoextzg = 0_int32
    output%nfpdist = 0_int32
    output%nfpresol = 0_int32
    output%nspec2 = 0_int32
    output%nspec2g = 0_int32
    output%ngptot = 0_int32
    output%ngptotx = 0_int32
    output%nfpsizeg = 0_int32
    output%nfpsizeg_dep = 0_int32
    status = 0
  end function
end module
