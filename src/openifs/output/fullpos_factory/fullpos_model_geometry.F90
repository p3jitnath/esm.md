!> Fill the Gaussian Fullpos model geometry from the live canonical geometry.
module forecast_fullpos_model_geometry
  use iso_fortran_env, only: int32, int64, real64
  use type_fpusergeo, only: tfpusergeo
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: initialize_native_fullpos_model_geometry, release_native_fullpos_model_geometry
#include "trans_inq.h"
contains
  !> Angles contains source ELATC,ELONC,ELON0,ELAT0 preimages, in radians.
 !! These four explicit upstream words are required even on the Gaussian route:
 !! the source multiplies them before its later global consistency corrections.
 !! They are never fabricated from unrelated Gaussian metadata.
 integer(int32) function initialize_native_fullpos_model_geometry(geometry,constants,domain,regional_angles,configuration,boyd,output) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(forecast_physical_constants), intent(in) :: constants
    character(*), intent(in) :: domain
    real(real64), intent(in) :: regional_angles(4)
    integer(int32), intent(in) :: configuration, boyd
    type(tfpusergeo), intent(inout) :: output
    type(tfpusergeo) :: work
    real(real64) :: degrees, tolerance, difference
    real(real64), volatile :: angle_value
    integer :: n, j, ierr
    status = 2; n = geometry%dimensions%ndglg
    if (.not. geometry%initialized .or. n < 2 .or. n > 4096) return
    if (boyd /= 0 .or. configuration < 0 .or. configuration > 2) return
    if (allocated(output%nfprgri) .or. allocated(output%nfpmen)) return
    if (allocated(output%fpmu)) return
    if (.not. allocated(geometry%stream%nloeng) .or. .not. allocated(geometry%cutoffs%nmeng)) return
    if (lbound(geometry%stream%nloeng, 1) > 1 .or. ubound(geometry%stream%nloeng, 1) < n) return
    if (lbound(geometry%cutoffs%nmeng, 1) > 1 .or. ubound(geometry%cutoffs%nmeng, 1) < n) return
    degrees = 180.0_real64/constants%rpi
    work%cfpdom = domain; work%nlat = n; work%nlon = geometry%dimensions%ndlon
    work%nfpmax = geometry%dimensions%nsmax; work%nmfpmax = geometry%dimensions%nmsmax
    work%nfpgux = geometry%dimensions%ndguxg; work%nfplux = geometry%dimensions%ndluxg
    angle_value = regional_angles(1)*degrees; work%rlatc = angle_value
    angle_value = regional_angles(2)*degrees; work%rlonc = angle_value
    angle_value = regional_angles(3)*degrees; work%fplon0 = angle_value
    angle_value = regional_angles(4)*degrees; work%fplat0 = angle_value
    work%cfpgrid = 'GAUSS'
    work%nfpedom = 1
    work%nfphtyp = geometry%configuration%values%nhtyp
    work%nfpttyp = geometry%configuration%values%nsttyp
    work%fpmucen = geometry%configuration%values%rmucen
    work%fplocen = geometry%configuration%values%rlocen
    work%fpstret = geometry%configuration%values%rstret
    allocate (work%nfprgri(n), stat=ierr); if (ierr /= 0) goto900
    work%nfprgri = huge(0_int32)
    allocate (work%nfpmen(n), stat=ierr); if (ierr /= 0) goto900
    work%nfpmen = huge(0_int32)
    allocate (work%fpmu(n), stat=ierr); if (ierr /= 0) goto900
    work%fpmu = huge(0.0_real64)
    work%nfprgri = geometry%stream%nloeng(1:n)
    ! Source CHECK_FPUSERGEO global branches, in their declared order.
    if (work%nfpttyp == 1) then
      work%fpmucen = 1.0_real64; work%fplocen = 0.0_real64
    end if
    work%nfplux = 0; work%nfpgux = 0; work%fplon0 = 0.0_real64; work%fplat0 = 0.0_real64
    work%lfpmrt = .false.; work%lfpmap = .true.; work%nfpbwx = 0; work%nfpbwy = 0
    work%rlonc = work%fplocen; work%rlatc = work%fpmucen
    work%nfpttyp = max(1, min(work%nfpttyp, 2))
    work%nfphtyp = max(0, min(work%nfphtyp, 2))
    if (work%nfphtyp == 0) then
      work%nfprgri = work%nlon
    else
      do j = 1, (n + 1)/2
        work%nfprgri(j) = max(1, min(work%nfprgri(j), work%nlon))
        work%nfprgri(n + 1 - j) = work%nfprgri(j)
      end do
    end if
    work%nfpmax = max(0, work%nfpmax); work%nmfpmax = max(0, work%nmfpmax)
    tolerance = epsilon(1.0_real64)*100.0_real64
    difference = work%fpstret - 1.0_real64
    if (abs(difference) < tolerance) work%fpstret = 1.0_real64
    work%lfpmodelspec = work%nfpmax == geometry%dimensions%nsmax
    work%lfpmodelgrid = work%nlon == geometry%dimensions%ndlon .and. work%nlat == n
    if (work%lfpmodelgrid) work%lfpmodelgrid = all(work%nfprgri == geometry%stream%nloeng(1:n))
    work%lfpmodelcore = work%lfpmodelgrid
    tolerance = epsilon(1.0_real64)*10000.0_real64
    work%lfpcoord = (.not. work%lfpmodelcore) .or. abs(work%fpstret - geometry%configuration%values%rstret) > tolerance .or. &
                    work%nfpttyp /= geometry%configuration%values%nsttyp .or. &
                    abs(work%fpmucen - geometry%configuration%values%rmucen) > tolerance .or. &
                    abs(work%fplocen - geometry%configuration%values%rlocen) > tolerance
    work%lfpbiper = .false.; work%lfplamcorext = .false.; work%lfpmapf = .false.
    work%lfposbufshape = work%lfpcoord
    work%nfpsizeg = sum(work%nfprgri); work%nfpsizeg_dep = work%nfpsizeg
    work%nfpdist = 0; if (work%lfposbufshape) work%nfpdist = 2
    work%nfpresol = geometry%transform_resolution%resolution
    work%nspec2g = geometry%dimensions%nspec2g
    work%nspec2 = geometry%partition%nspec2
    work%ngptot = geometry%partition%ngptot
    work%nfpmen = geometry%cutoffs%nmeng(1:n)
    call trans_inq(kresol=work%nfpresol, pmu=work%fpmu)
    call move_alloc(work%nfprgri, output%nfprgri)
    call move_alloc(work%nfpmen, output%nfpmen)
    call move_alloc(work%fpmu, output%fpmu)
    output%cfpdom = work%cfpdom
    output%cfpgrid = work%cfpgrid
    output%nlat = work%nlat
    output%nlon = work%nlon
    output%nfphtyp = work%nfphtyp
    output%nfpttyp = work%nfpttyp
    output%fpmucen = work%fpmucen
    output%fplocen = work%fplocen
    output%fpstret = work%fpstret
    output%rdely = work%rdely
    output%rdelx = work%rdelx
    output%nfprlx = work%nfprlx
    output%nfprux = work%nfprux
    output%nfprly = work%nfprly
    output%nfpruy = work%nfpruy
    output%nfpgux = work%nfpgux
    output%nfplux = work%nfplux
    output%nfpbwx = work%nfpbwx
    output%nfpbwy = work%nfpbwy
    output%rlatc = work%rlatc
    output%rlonc = work%rlonc
    output%fplon0 = work%fplon0
    output%fplat0 = work%fplat0
    output%lfpmrt = work%lfpmrt
    output%lfpmap = work%lfpmap
    output%fplx = work%fplx
    output%fply = work%fply
    output%nfpbzonl = work%nfpbzonl
    output%nfpbzong = work%nfpbzong
    output%nfpedom = work%nfpedom
    output%nfpmax = work%nfpmax
    output%nmfpmax = work%nmfpmax
    output%nfpnoextzl = work%nfpnoextzl
    output%nfpnoextzg = work%nfpnoextzg
    output%lfpmodelspec = work%lfpmodelspec
    output%lfpmodelgrid = work%lfpmodelgrid
    output%lfpmodelcore = work%lfpmodelcore
    output%lfpcoord = work%lfpcoord
    output%lfpbiper = work%lfpbiper
    output%lfplamcorext = work%lfplamcorext
    output%lfpmapf = work%lfpmapf
    output%lfposbufshape = work%lfposbufshape
    output%nfpdist = work%nfpdist
    output%nfpresol = work%nfpresol
    output%nspec2 = work%nspec2
    output%nspec2g = work%nspec2g
    output%ngptot = work%ngptot
    output%ngptotx = work%ngptotx
    output%nfpsizeg = work%nfpsizeg
    output%nfpsizeg_dep = work%nfpsizeg_dep
    status = 0; return
900 status = 1
  end function
  subroutine release_native_fullpos_model_geometry(output)
    type(tfpusergeo), intent(inout) :: output
    if (allocated(output%nfprgri)) deallocate (output%nfprgri)
    if (allocated(output%nfpmen)) deallocate (output%nfpmen)
    if (allocated(output%fpmu)) deallocate (output%fpmu)
  end subroutine
end module
