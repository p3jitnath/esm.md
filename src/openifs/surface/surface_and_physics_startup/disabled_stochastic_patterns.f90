!> Own the disabled SPPT grids and source-defined SPP configuration.
module forecast_disabled_stochastic_patterns
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use yomspsdt, only: tsppt_config
  use spp_mod, only: tspp_config
  use spectral_arp_mod, only: spectral_arp
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_stochastic_gridpoint_field, native_sppt_data
  public :: initialize_disabled_sppt_setup, initialize_disabled_spp_setup, release_disabled_sppt_setup
  !> All counts are dimensionless. The four owners have source zero
  !! constituent extents. The other pointers borrow these same owners.
  type :: native_stochastic_gridpoint_field
    real(real64), pointer :: gp3d(:, :, :, :) => null(), gp2d(:, :, :) => null()
    integer(int32) :: ng3d, ng2d, nproma, ngpblks, nflevg, ngptot, ngptotg
    integer(int32), pointer :: ngrib(:) => null(), ngrib2(:) => null(), ngrib3(:) => null()
    integer(int32), pointer :: nparamid(:) => null(), nparamid2(:) => null(), nparamid3(:) => null()
    real(real64), pointer :: div(:, :, :) => null(), vor(:, :, :) => null(), u(:, :, :) => null(), v(:, :, :) => null()
    real(real64), pointer :: t(:, :, :) => null(), q(:, :, :) => null(), o3(:, :, :) => null(), spr(:, :) => null()
    real(real64), pointer :: wind(:, :, :, :) => null(), scal(:, :, :, :) => null()
  end type
  !> The spectral pattern pointer remains absent on this disabled route.
  type :: native_sppt_data
    integer(int32) :: mpsdt(6), n2d
    integer(int32), pointer :: nseed_sdt(:) => null()
    type(spectral_arp), pointer :: yspsdt_ar1(:) => null()
    type(native_stochastic_gridpoint_field), pointer :: ygpsdt(:) => null(), ygpsdt0(:) => null(), ygpsdt1(:) => null()
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> P is block width1:1024; L is global levels1:256; Q and G are local
  !! and global physical point counts. B must equal ceil(Q/P). TEXT owns
  !! an empty first NAMSPSDT group. CONFIG and DATA are caller-owned.
  !! The constructor publishes three separate grids, with four owners each,
  !! and retains the reached configuration stores after allocation failure.
  integer(int32) function initialize_disabled_sppt_setup(config, data, p, l, b, q, g, text) result(status)
    type(tsppt_config), intent(inout) :: config
    type(native_sppt_data), intent(inout) :: data
    integer(int32), intent(in) :: p, l, b, q, g
    character(*), intent(in) :: text
    integer(int32), allocatable :: temporary(:)
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: error, j
    status = 2
    if (p < 1 .or. p > 1024 .or. l < 1 .or. l > 256 .or. q < 1 .or. g < q .or. b < 1) return
    if (int(b, int64) /= (int(q, int64) - 1_int64)/p + 1_int64) return
    if (associated(data%nseed_sdt) .or. associated(data%yspsdt_ar1)) return
    if (associated(data%ygpsdt) .or. associated(data%ygpsdt0) .or. associated(data%ygpsdt1)) return
    if (associated(config%lactiveq_sdt) .or. associated(config%lactiveo_sdt)) return
    if (associated(config%cipatinit_sdt) .or. associated(config%copattrun_sdt)) return
    if (associated(config%copatsp_sdt) .or. associated(config%copatgp_sdt)) return
    status = require_empty_physics_group(text, 'NAMSPSDT')
    if (status /= 0) return
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    call set_sppt_configuration(config, data)
    allocate (temporary(0), stat=error)
    if (error /= 0) goto900
    allocate (data%ygpsdt(1), stat=error)
    if (error /= 0) goto900
    allocate (data%ygpsdt0(1), stat=error)
    if (error /= 0) goto900
    allocate (data%ygpsdt1(1), stat=error)
    if (error /= 0) goto900
    status = initialize_empty_grid(data%ygpsdt(1), p, l, b, q, g)
    if (status /= 0) goto900
    status = initialize_empty_grid(data%ygpsdt0(1), p, l, b, q, g)
    if (status /= 0) goto900
    status = initialize_empty_grid(data%ygpsdt1(1), p, l, b, q, g)
    if (status /= 0) goto900
    deallocate (temporary)
    error_number = saved_errno
    status = 0
    return
900 continue
    call release_grids(data)
    if (allocated(temporary)) deallocate (temporary)
    error_number = saved_errno
    status = 1
  end function
  !> Retain source-only scalar and literal stores; do not initialize the
  !! source-unwritten taper coefficients, spectral scales or N2D.
  subroutine set_sppt_configuration(config, data)
    type(tsppt_config), intent(inout) :: config
    type(native_sppt_data), intent(inout) :: data
    integer :: j
    real(real64), parameter :: sd(5) = [ &
                               transfer(int(z'3FDAE147AE147AE1', int64), 0.0_real64), &
                               transfer(int(z'3FC1EB851EB851EC', int64), 0.0_real64), &
                               transfer(int(z'3FA89374BC6A7EFA', int64), 0.0_real64), &
                               transfer(int(z'3FA999999999999A', int64), 0.0_real64), &
                               transfer(int(z'3F9999999999999A', int64), 0.0_real64)]
    config%lspsdt = .false.
    config%lsppt1 = .false.
    config%lradclr_sdt = .false.
    config%lsatadj_sdt = .false.
    config%lspptgfix = .false.
    do j = 1, 6
      config%sdev_sdt(:, j) = sd
    end do
    config%tau_sdt = [21600.0_real64, 259200.0_real64, 2592000.0_real64, 7776000.0_real64, 31536000.0_real64]
    config%xlcor_sdt = [500000.0_real64, 1000000.0_real64, 2000000.0_real64, 2000000.0_real64, 2000000.0_real64]
    config%nscales_sdt = 1
    config%cspec_shape_sdt = 'WeaverCourtier'
    config%lclip_spec_sdt = .true.
    config%lclip_grid_sdt = .true.
    config%nclip_kind_sdt = 1
    config%xclip_ratio_sdt = transfer(int(z'3FFCCCCCCCCCCCCD', int64), 0.0_real64)
    config%xclipm_sdt = 1.0_real64
    config%lqpertlimit2 = .true.
    config%nqsat_sdt = 3
    config%xmeanred_thickness_sdt = 20000.0_real64
    config%ltaper_bl0 = .true.
    config%ltaper_bli = .true.
    config%xsigmatop = transfer(int(z'3FEE666666666666', int64), 0.0_real64)
    config%xsigmabot = 1.0_real64
    config%ltaper_st0 = .false.
    config%ltaper_sti = .true.
    config%xpresstop_st0 = 5000.0_real64
    config%xpressbot_st0 = 10000.0_real64
    config%lusesetran_sdt = .true.
    config%lresetseed_sdt = .false.
    config%resetseedfrq_sdt = 1
    config%labstimseed_sdt = .false.
    config%npatfr = 1
    config%lwrite_arp = .false.
    config%lrdpatinit_sdt = .false.
    config%lwrpattrun_sdt = .false.
    config%nhour_pattrun = -1000
    config%nstep_pattrun = -1000
    config%nwrpattrun_sdt = 1
    config%nwav_testspec_sdt = 1
    config%nwn_testspec_sdt = 20
    config%xspptgfixrlx = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    data%mpsdt = 1
    config%lqpertlimit2 = .false.
  end subroutine
  integer(int32) function initialize_empty_grid(grid, p, l, b, q, g) result(status)
    type(native_stochastic_gridpoint_field), intent(inout) :: grid
    integer(int32), intent(in) :: p, l, b, q, g
    integer :: error
    grid%ng3d = 0; grid%ng2d = 0
    grid%nproma = p; grid%ngpblks = b; grid%nflevg = l; grid%ngptot = q; grid%ngptotg = g
    allocate (grid%ngrib(0), stat=error)
    if (error /= 0) goto900
    allocate (grid%nparamid(0), stat=error)
    if (error /= 0) goto900
    grid%ngrib3 => grid%ngrib; grid%ngrib2 => grid%ngrib
    grid%nparamid3 => grid%nparamid; grid%nparamid2 => grid%nparamid
    allocate (grid%gp3d(p, l, 0, b), stat=error)
    if (error /= 0) goto900
    allocate (grid%gp2d(p, 0, b), stat=error)
    if (error /= 0) goto900
    grid%scal => grid%gp3d
    status = 0
    return
900 status = 1
  end function
  !> Release the three source grids only, preserving unrelated pattern data.
  integer(int32) function release_disabled_sppt_setup(config, data) result(status)
    type(tsppt_config), intent(in) :: config
    type(native_sppt_data), intent(inout) :: data
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    status = 2
    if (config%lspsdt) return
    if (associated(data%nseed_sdt) .or. associated(data%yspsdt_ar1)) return
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    call release_grids(data)
    error_number = saved_errno
    status = 0
  end function
  subroutine release_grids(data)
    type(native_sppt_data), intent(inout) :: data
    if (associated(data%ygpsdt)) then
      call release_empty_grid(data%ygpsdt(1))
      deallocate (data%ygpsdt)
    end if
    if (associated(data%ygpsdt0)) then
      call release_empty_grid(data%ygpsdt0(1))
      deallocate (data%ygpsdt0)
    end if
    if (associated(data%ygpsdt1)) then
      call release_empty_grid(data%ygpsdt1(1))
      deallocate (data%ygpsdt1)
    end if
    nullify (data%ygpsdt, data%ygpsdt0, data%ygpsdt1)
  end subroutine
  subroutine release_empty_grid(grid)
    type(native_stochastic_gridpoint_field), intent(inout) :: grid
    if (associated(grid%ngrib)) deallocate (grid%ngrib)
    if (associated(grid%nparamid)) deallocate (grid%nparamid)
    if (associated(grid%gp3d)) deallocate (grid%gp3d)
    if (associated(grid%gp2d)) deallocate (grid%gp2d)
    nullify (grid%ngrib, grid%ngrib2, grid%ngrib3, grid%gp3d, grid%gp2d)
    nullify (grid%nparamid, grid%nparamid2, grid%nparamid3, grid%scal)
  end subroutine
  !> Set the complete inactive GET_SPP_CONF outputs. All five SM arrays
  !! must be absent; the source-unwritten model name and table tails survive.
  integer(int32) function initialize_disabled_spp_setup(config, text) result(status)
    type(tspp_config), intent(inout) :: config
    character(*), intent(in) :: text
    status = 2
    if (allocated(config%sm%defined_perts) .or. allocated(config%sm%active_perts)) return
    if (allocated(config%sm%nseed_off) .or. allocated(config%sm%pndef) .or. allocated(config%sm%pn)) return
    status = require_empty_physics_group(text, 'NAMSPP')
    if (status /= 0) return
    config%sm%ndef = 0
    config%sm%nrftotal = 0
    config%sm%nrftotal_radgrid = 0
    config%pptr%cfm = -1
    config%pptr%cfm1 = -1
    config%pptr%cfm2 = -1
    config%pptr%cfm3 = -1
    config%pptr%rkap = -1
    config%pptr%rkap1 = -1
    config%pptr%rkap2 = -1
    config%pptr%rkap3 = -1
    config%pptr%tofdc = -1
    config%pptr%hsdt = -1
    config%pptr%vdexc = -1
    config%pptr%entrorg = -1
    config%pptr%entshalp = -1
    config%pptr%entstpc1 = -1
    config%pptr%detrpen = -1
    config%pptr%rprcon = -1
    config%pptr%rtau = -1
    config%pptr%cududv = -1
    config%pptr%cududvs = -1
    config%pptr%ramid = -1
    config%pptr%rcldiff = -1
    config%pptr%rclcrit = -1
    config%pptr%rlcritsnow = -1
    config%pptr%rainevap = -1
    config%pptr%snowsublim = -1
    config%pptr%cloudinhom = -1
    config%pptr%qsatvervel = -1
    config%pptr%zdecorr = -1
    config%pptr%zsigqcw = -1
    config%pptr%zradeffl = -1
    config%pptr%zradeffi = -1
    config%pptr%phr = -1
    config%pptr%zhs_vdaero = -1
    config%pptr%delta_aero = -1
    config%lspp = .false.
    config%lramidlimit1 = .false.
    config%luse_setran = .true.
    config%lnseed_offs0 = .false.
    config%iseedfac = 10000
    config%npatfr = 1
    config%shiftseed = 0
    config%lrdpatinit = .false.
    config%lwrpattrun = .false.
    config%lresetseed = .false.
    config%labstimseed = .false.
    config%nhour_pattrun(1) = -1000
    config%nstep_pattrun(1) = -1000
    config%nwrpattrun = 1
    config%resetseedfrq = 1
    config%spp_rdpatinit = 'spp_pattern_0'
    config%spp_wrpattrun = 'spp_pattern_out'
    config%xpress_phr_st = 10000.0_real64
    status = 0
  end function
end module
