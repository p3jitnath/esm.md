!> Source controls for stable upper levels, departure points and an inactive sponge.
module forecast_additional_dynamics_controls
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_stable_level_configuration, initialize_departure_point_controls, initialize_inactive_sponge_controls
contains
  !> Count live half-level pressures at most6000 Pa under the source condition.
  !! The six named outputs are borrowed caller fields, not a second model owner.
  !! HALF_PRESSURE(0:levels) is read only on the active branch. Refusal2 is atomic.
  integer(c_int) function initialize_stable_level_configuration(nconf, lecmwf, lr2d, lr3d, lslag, nstop, levels, &
                                lsettlsvf, rpres_settlsvf, rscale, rscaleoff, lsettlsvf_diff, nflevsf, half_pressure) result(status)
    integer(c_int), intent(in) :: nconf, nstop, levels
    logical, intent(in) :: lecmwf, lr2d, lr3d, lslag
    logical, intent(inout) :: lsettlsvf, lsettlsvf_diff
    real(c_double), intent(inout) :: rpres_settlsvf, rscale, rscaleoff
    integer(c_int), intent(inout) :: nflevsf
    real(c_double), optional, intent(in) :: half_pressure(0:)
    logical :: active
    integer(c_int) :: j, count
    integer(c_int64_t) :: bits
    status = 2
    if (.not. canonical_logical(lecmwf) .or. .not. canonical_logical(lslag)) return
    if (transfer(lr2d, 0_c_int) /= 0 .or. transfer(lr3d, 0_c_int) /= 1) return
    if (levels < 1 .or. levels > 255) return
    active = (nconf == 1 .or. nconf == 131 .or. nconf == 302 .or. nconf == 401 .or. nconf == 501 .or. nconf == 801)
    active = active .and. lecmwf .and. lslag .and. nstop > 0
    count = 0
    if (active) then
      if (.not. present(half_pressure)) return
      if (size(half_pressure) < levels + 1) return
      do j = 1, levels
        bits = transfer(half_pressure(j), bits)
        if (ibits(bits, 52, 11) == 2047_c_int64_t) return
        if (btest(bits, 63) .and. iand(bits, int(z'7fffffffffffffff', c_int64_t)) /= 0) return
      end do
      do j = 1, levels
        if (half_pressure(j) <= 6000.0_c_double) count = count + 1
      end do
      count = min(count, levels)
    end if
    lsettlsvf = active
    rpres_settlsvf = transfer(int(z'40b7700000000000', c_int64_t), 0.0_c_double)
    rscale = transfer(int(z'42d6bcc41e900000', c_int64_t), 0.0_c_double)
    rscaleoff = transfer(int(z'3d06849b86a12b9b', c_int64_t), 0.0_c_double)
    lsettlsvf_diff = .false.; nflevsf = count
    status = 0
  end function
  !> Set the five Cartesian departure controls from live source logical inputs.
  integer(c_int) function initialize_departure_point_controls(nconf, lecmwf, lr2d, lr3d, lsettlst, lsettlsv, &
                                                              nitmp, vetaon, vetaox, lrhs_curv, lfindvsep) result(status)
    integer(c_int), intent(in) :: nconf
    logical, intent(in) :: lecmwf, lr2d, lr3d, lsettlst, lsettlsv
    integer(c_int), intent(inout) :: nitmp
    real(c_double), intent(inout) :: vetaon, vetaox
    logical, intent(inout) :: lrhs_curv, lfindvsep
    status = 2
    if (nconf /= 1 .or. transfer(lecmwf, 0_c_int) /= 1) return
    if (transfer(lr2d, 0_c_int) /= 0 .or. transfer(lr3d, 0_c_int) /= 1) return
    if (.not. canonical_logical(lsettlst) .or. .not. canonical_logical(lsettlsv)) return
    nitmp = 2
    if (lsettlst .or. lsettlsv) nitmp = 3
    lrhs_curv = .false.; vetaon = 1.0_c_double; vetaox = 1.0_c_double; lfindvsep = .false.
    status = 0
  end function
  !> Admit empty NAMSPNG and an absent RSPONGF before disabling the sponge.
  integer(c_int) function initialize_inactive_sponge_controls(text, rspongf, lnsponge) result(status)
    character(*), intent(in) :: text
    real(c_double), allocatable, intent(in) :: rspongf(:)
    logical, intent(inout) :: lnsponge
    status = 2
    if (allocated(rspongf)) return
    if (len(text) < 1 .or. len(text) > 262144) return
    status = require_empty_physics_group(text, 'NAMSPNG')
    if (status /= 0) return
    lnsponge = .false.
  end function
  pure logical function canonical_logical(value) result(valid)
    logical, intent(in) :: value
    integer(c_int) :: bits
    bits = transfer(value, bits)
    valid = bits == 0 .or. bits == 1
  end function
end module forecast_additional_dynamics_controls
