!> Extend the empty/default scalar producer to the actual initialized partition.
!! The selected source entry and artifacts remain unchanged. This native domain extension
!! owns no array and imports no original numerical stage or hidden module scalar.
module forecast_runtime_scalar_data
  use iso_fortran_env, only: int32, int64
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use forecast_native_loop_data, only: native_loop_data
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_public_transform, only: native_transform_control
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_runtime_forecast_scalar_data
contains
!> Produce named scalar defaults from admitted controls and the live public region map.
!! TEXT is the exact configuration text. CONTROLS, LOOP, PARTITION and TRANSFORM are
!! read-only produced owners. CPLNG_ACTIVE is the actual TMCC switch. STATE is the
!! single caller-owned scalar record. GRADIENT_SPECTRAL is the actual canonical\n!! TDYNA LGRADSP value. The loop producer must have returned0; mask0 and mask15\n!! describe its two literal allocation routes, not readiness. Status2 refuses\n!! before mutation; status0 assigns
!! every named scalar. MY_REGION_EW comes from the partition's actual public inquiry.
integer(int32)function initialize_runtime_forecast_scalar_data(text,controls,loop,cplng_active,partition,transform,state,gradient_spectral)result(status)
  character(*), intent(in) :: text
  type(native_forecast_control_namespace), intent(in) :: controls
  type(native_loop_data), intent(in) :: loop
  logical, intent(in) :: cplng_active
  type(native_distributed_partition), intent(in) :: partition
  type(native_transform_control), intent(in) :: transform
  type(native_forecast_scalar_data), intent(inout) :: state
  logical, intent(in) :: gradient_spectral
  integer(int32) :: ns, ew
  integer(int64) :: word
  status = 2
  if (len(text) < 1 .or. len(text) > 262144) return
  if (controls%nconf /= 1 .or. controls%larpegef /= 0 .or. controls%lelam /= 0 .or. controls%lecmwf /= 1) return
  if (controls%loldpp < 0 .or. controls%loldpp > 1 .or. controls%lfdbop /= 0) return
  if (loop%nouttype /= 1 .or. cplng_active) return
! Source scalar production is independent of conditional filter allocation.
  if (loop%nfrres < 1 .or. loop%restart /= '0') return
  word = transfer(loop%vp00, 0_int64)
  if (word <= 0_int64 .or. word > int(z'41cdcd6500000000', int64)) return
  if (loop%mysetv /= transform%mysetv .or. loop%nprtrv /= transform%nprtrv) return
  if (loop%nprtrn /= transform%nprtrv .or. loop%npromatr /= transform%npromatr) return
  if (gradient_spectral) then
    if (loop%owned_mask /= 15_int64) return
    if (.not. allocated(loop%spvor_flt) .or. .not. allocated(loop%spdiv_flt)) return
    if (.not. allocated(loop%spub_flt) .or. .not. allocated(loop%spvb_flt)) return
    if (size(loop%spvor_flt, 1) /= partition%nflsur .or. size(loop%spvor_flt, 2) /= partition%nspec2) return
    if (size(loop%spdiv_flt, 1) /= partition%nflsur .or. size(loop%spdiv_flt, 2) /= partition%nspec2) return
    if (size(loop%spub_flt) /= partition%nflevl .or. size(loop%spvb_flt) /= partition%nflevl) return
  else
    if (loop%owned_mask /= 0_int64) return
    if (allocated(loop%spvor_flt) .or. allocated(loop%spdiv_flt)) return
    if (allocated(loop%spub_flt) .or. allocated(loop%spvb_flt)) return
  end if
  if (.not. transform%message_ready .or. .not. transform%environment_ready) return
  if (transform%nproc < 1 .or. transform%nproc > 32 .or. transform%myproc < 1 .or. transform%myproc > transform%nproc) return
  if (partition%phase /= 7 .or. partition%borrowed_resolution == 0) return
  if (.not. allocated(transform%n_regions) .or. .not. allocated(transform%ngpset2pe)) return
  ns = partition%my_region_ns; ew = partition%my_region_ew
  if (ns < 1 .or. ns > transform%regions_ns) return
  if (lbound(transform%n_regions, 1) > 1 .or. ubound(transform%n_regions, 1) < transform%regions_ns) return
  if (ew < 1 .or. ew > transform%n_regions(ns)) return
  if (lbound(transform%ngpset2pe, 1) > ew .or. ubound(transform%ngpset2pe, 1) < ew) return
  if (lbound(transform%ngpset2pe, 2) > ns .or. ubound(transform%ngpset2pe, 2) < ns) return
  if (transform%ngpset2pe(ew, ns) /= transform%myproc) return
  status = require_empty_physics_group(text, 'NAMPPVI')
  if (status /= 0) return
  state%cpl_nemo_lim = 0; state%nimp = 0; state%nout = 0
  state%rmdi = 0.0; state%lsldebug = .false.; state%lsplitout = .false.
  state%my_region_ew = ew; state%lnots_t = .false.; state%lrppuv_callitpq = controls%loldpp /= 0
  state%lrppuv_cstext = .false.
  state%ltrajsave = .false.; state%ltrajslag = .false.
  state%ltrajsave_oops = .false.; state%ltrajslag_oops = .false.
  state%ltwgra = .false.; state%ltwinc = .false.; state%ltwbgv = .false.; state%ltwcgl = .false.
  state%lsfcflx = .false.; state%rextlhf = 0.0; state%rextshf = 0.0
  state%n_vmass = -1
  status = 0
  end function
end module
