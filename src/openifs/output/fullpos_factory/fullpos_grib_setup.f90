!> Fill Fullpos filename records and the existing canonical stream namespace.
module forecast_fullpos_grib_setup
  use iso_fortran_env, only: int32
  use yomfpgeo, only: tfpgeo
  use type_fpusergeo, only: tfpusergeo
  use type_fpofn, only: tfpofn
  use forecast_geometry_stream, only: native_geometry_stream
  implicit none
  private
  public :: initialize_native_fullpos_grib_setup, release_native_fullpos_grib_setup
contains
  !> Construct source spectral, surface and model prefixes without time stamps.
 !! GEOMETRY owns source global point indices. USER contains the actual domains.
 !! Names CSH/CGG/CUA/CLI mutate; CSX/CSU retain their incoming characters.
 !! Stream owns exactly two new integer arrays, NFPMAX then NUMPROCFP.
 integer(int32) function initialize_native_fullpos_grib_setup(geometry,user,climate_names,experiment,grid_prefixes,spectral_path,names,stream) result(status)
    type(tfpgeo), intent(in) :: geometry
    type(tfpusergeo), intent(in) :: user(:)
    character(*), intent(in) :: climate_names(:), experiment, grid_prefixes, spectral_path
    type(tfpofn), intent(inout) :: names(:)
    type(native_geometry_stream), intent(inout) :: stream
    integer(int32), allocatable :: maximum(:), map(:)
    integer :: j, rank, i, k, n, domains, ierr
    status = 2; domains = size(user); n = geometry%nfprgpg
    if (domains < 1 .or. size(names) /= domains .or. size(climate_names) /= domains) return
    if (len(experiment) < 4 .or. len(grid_prefixes) < 10 .or. len(spectral_path) > 200) return
    if (stream%nproc < 1 .or. stream%nproc > 4096 .or. n < 1) return
    if (allocated(stream%nfpmax) .or. allocated(stream%numprocfp)) return
    if (.not. allocated(geometry%nfprgpnum) .or. .not. allocated(geometry%nfprgpind)) return
    if (size(geometry%nfprgpnum) /= stream%nproc) return
    if (size(geometry%nfprgpind, 2) /= stream%nproc) return
    if (any(geometry%nfprgpnum < 0) .or. any(geometry%nfprgpnum > size(geometry%nfprgpind, 1))) return
    do rank = 1, stream%nproc
    do i = 1, geometry%nfprgpnum(rank)
      k = geometry%nfprgpind(i, rank)
      if (k < 1 .or. k > n) return
    end do
    end do
    allocate (maximum(domains), stat=ierr); if (ierr /= 0) goto900
    do j = 1, domains
      maximum(j) = user(j)%nfpmax
    end do
    allocate (map(n), stat=ierr); if (ierr /= 0) goto900
    do rank = 1, stream%nproc
    do i = 1, geometry%nfprgpnum(rank)
      map(geometry%nfprgpind(i, rank)) = rank
    end do
    end do
    do j = 1, domains
      names(j)%cgg = grid_prefixes(1:5)//experiment(1:4)
      names(j)%cua = grid_prefixes(6:10)//experiment(1:4)
      names(j)%csh = trim(spectral_path)//'ICMSH'//experiment(1:4)
      names(j)%cli = climate_names(j)
    end do
    stream%nfprgpl = geometry%nfprgpl
    stream%nfprgpg = geometry%nfprgpg
    stream%nfprgplx = geometry%nfprgplx
    call move_alloc(maximum, stream%nfpmax)
    call move_alloc(map, stream%numprocfp)
    status = 0; return
900 status = 1
  end function
  !> Release only these two stream owners; geometry metadata remain owned upstream.
  subroutine release_native_fullpos_grib_setup(stream)
    type(native_geometry_stream), intent(inout) :: stream
    if (allocated(stream%nfpmax)) deallocate (stream%nfpmax)
    if (allocated(stream%numprocfp)) deallocate (stream%numprocfp)
  end subroutine
end module
