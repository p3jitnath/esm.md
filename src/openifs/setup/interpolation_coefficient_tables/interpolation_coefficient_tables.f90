!> Construct the original SUINTERPOLATOR tables from actual forecast owners.
module forecast_interpolation_coefficient_tables
  use iso_fortran_env, only: int32, int64, real64
  use forecast_interpolation_coefficient_table_types, only: native_interpolation_coefficient_tables
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use vertical_spline_interpolation_port, only: initialize_vertical_spline_interpolation, release_vertical_spline_interpolation
  use forecast_vertical_interpolation_coefficients, only: native_vertical_interpolation_controls, &
                                         initialize_vertical_interpolation_coefficients, release_vertical_interpolation_coefficients
  use forecast_meridional_interpolation, only: initialize_meridional_interpolation, release_meridional_interpolation
  implicit none
  private
  public :: native_interpolation_coefficient_tables
  public :: initialize_interpolation_coefficient_tables, release_interpolation_coefficient_tables
contains
  !> Admit an owner only when all nineteen original arrays are absent.
  logical function table_owners_fresh(state) result(fresh)
    type(native_interpolation_coefficient_tables), intent(in) :: state
    fresh = .false.
    if (state%ready) return
    if (allocated(state%yrvsplip%tridiagonal) .or. allocated(state%yrvsplip%constants) .or. allocated(state%yrvsplip%pieces)) return
    if (allocated(state%yrvsleta%vcuico) .or. allocated(state%yrvsleta%vsld)) return
    if (allocated(state%yrvsleta%vsldw) .or. allocated(state%yrvsleta%vslvf)) return
    if (allocated(state%yrvsleta%vcuicoh) .or. allocated(state%yrvsleta%vsldh)) return
    if (allocated(state%yrvsleta%vsldwh) .or. allocated(state%yrvsleta%vslvfh)) return
    if (allocated(state%yrvsleta%gamma_weno) .or. allocated(state%yrvsleta%vrdetar)) return
    if (allocated(state%yrvsleta%nvautf) .or. allocated(state%yrvsleta%nvauth)) return
    if (allocated(state%yrhslmer%ripi) .or. allocated(state%yrhslmer%rsld)) return
    if (allocated(state%yrhslmer%rsldw) .or. allocated(state%yrhslmer%r3dtw)) return
    fresh = .true.
  end function

  !> Calculate SUVSPLIP, SUVSLETA and SUHSLMER in their actual source order.
 !!
 !! OUTPUT owns the existing three native table records at one stable address.
 !! MODEL is the same completed canonical model used by the forecast; its one
 !! initial context supplies actual vertical coordinates, standard pressure,
 !! latitude and partition. Its produced interpolation state supplies the
 !! exact NDGSAH:NDGENH halo rows. The routine creates no replacement model,
 !! pressure, clock, grid, field map or coefficient values.
 !!
 !! This entry admits the existing global irregular-latitude child routes:
 !! LRPLANE=false, L=4:255, rows=2:4096, stencil>=2, and the source vertical
 !! scheme flags admitted by the unchanged SUVSLETA child. Current L137 and
 !! world32 are derived from the same live model. No fixed rank or shape is
 !! inserted. The caller establishes nearest-even and gradual underflow.
 !!
 !! Return0 marks complete setup,1 is a child allocation failure and2 is a
 !! refused input. A child failure keeps earlier source-completed arrays for
 !! release. Optional CHILD_STATUS has three int32 entries in call order;
 !! uncalled entries are -1. FAILED_STAGE is0 or the first failing stage1:3.
  integer(int32) function initialize_interpolation_coefficient_tables(output, model, child_status, failed_stage) result(status)
    type(native_interpolation_coefficient_tables), intent(inout) :: output
    type(native_operational_model_configuration), target, intent(in) :: model
    integer(int32), optional, intent(out) :: child_status(3), failed_stage
    type(native_geometry_state), pointer :: geometry
    type(native_vertical_interpolation_controls) :: controls
    integer(int32) :: levels, first, last, offset, stage, child
    status = 2
    if (present(child_status)) child_status = -1
    if (present(failed_stage)) failed_stage = 0
    if (.not. table_owners_fresh(output)) return
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (.not. allocated(model%initial%geometry)) return
    geometry => model%initial%geometry
    if (.not. geometry%initialized .or. .not. associated(geometry%vertical)) return
    if (.not. associated(model%partition)) return
    if (.not. associated(model%partition, geometry%partition)) return
    if (geometry%partition%phase /= 7) return
    if (model%initial%controls%namespace%lrplane /= 0) return
    levels = geometry%dimensions%nflevg
    if (levels < 4 .or. levels > 255) return
    if (geometry%vertical%levels /= levels) return
    if (.not. allocated(geometry%vertical%vetaf) .or. .not. allocated(geometry%vertical%vetah)) return
    if (lbound(geometry%vertical%vetaf, 1) /= 0 .or. ubound(geometry%vertical%vetaf, 1) /= levels + 1) return
    if (lbound(geometry%vertical%vetah, 1) /= 0 .or. ubound(geometry%vertical%vetah, 1) /= levels) return
    if (geometry%vertical%configuration%lregeta < 0 .or. geometry%vertical%configuration%lregeta > 1) return
    if (.not. allocated(geometry%vertical%vbh)) return
    if (lbound(geometry%vertical%vbh, 1) /= 0 .or. ubound(geometry%vertical%vbh, 1) /= levels) return
    if (.not. allocated(geometry%atmosphere%full_pressure) .or. .not. allocated(geometry%atmosphere%half_pressure)) return
    if (size(geometry%atmosphere%full_pressure) /= levels) return
    if (lbound(geometry%atmosphere%half_pressure, 1) /= 0 .or. ubound(geometry%atmosphere%half_pressure, 1) /= levels) return
    if (geometry%dimensions%ndglg < 2 .or. geometry%dimensions%ndglg > 4096) return
    if (geometry%dimensions%ndgsur < 2) return
    if (.not. allocated(geometry%latitudes%rlatig)) return
    if (model%interpolation%ndglg /= geometry%dimensions%ndglg) return
    if (model%interpolation%ndgsur /= geometry%dimensions%ndgsur) return
    if (model%interpolation%nfrstloff /= geometry%partition%nfrstloff) return
    if (model%interpolation%ndgsal /= geometry%partition%ndgsal) return
    if (model%interpolation%ndgenl /= geometry%partition%ndgenl) return
    first = model%interpolation%ndgsah
    last = model%interpolation%ndgenh
    offset = model%interpolation%nfrstloff
    if (first > last) return
    if (int(last, int64) - int(first, int64) + 1_int64 > 16384_int64) return
    if (first > geometry%partition%ndgsal .or. last < geometry%partition%ndgenl) return
    controls%lslhd = model%dynamics%lslhd
    controls%lslhdquad = model%dynamics%lslhdquad
    controls%lhoislt = model%dynamics%lhoislt
    controls%lrhsvweno = model%dynamics%lrhsvweno
    controls%lsltvweno = model%dynamics%lsltvweno
    controls%lslvf = model%dynamics%lslvf
    controls%slvfeps = model%dynamics%slvfeps
    controls%p_slvf_bot = model%dynamics%p_slvf_bot
    controls%slvfmin = model%dynamics%slvfmin
    controls%slvftr = model%dynamics%slvftr
    controls%p_slvf_tr = model%dynamics%p_slvf_tr
    ! Original TVSLETA declaration defaults precede its scientific writer.
    output%yrvsleta%nrlevx = 1
    output%yrvsleta%vrlevx = 1.0_real64
    stage = 1
    child = initialize_vertical_spline_interpolation(levels, geometry%vertical%vetaf, geometry%vertical%vetah, output%yrvsplip)
    if (present(child_status)) child_status(stage) = child
    if (child /= 0) goto900
    stage = 2
    child = initialize_vertical_interpolation_coefficients(output%yrvsleta, controls, levels, &
                                   geometry%vertical%vetaf, geometry%vertical%vetah, geometry%vertical%configuration%lregeta == 1, &
                                        geometry%vertical%vbh, geometry%atmosphere%full_pressure, geometry%atmosphere%half_pressure)
    if (present(child_status)) child_status(stage) = child
    if (child /= 0) goto900
    stage = 3
    child = initialize_meridional_interpolation(output%yrhslmer, geometry%dimensions%ndglg, first, last, &
                        offset, geometry%dimensions%nstencilwide, lbound(geometry%latitudes%rlatig, 1), geometry%latitudes%rlatig, &
                                                model%dynamics%slhdepsh, .false.)
    if (present(child_status)) child_status(stage) = child
    if (child /= 0) goto900
    output%levels = levels
    output%first_halo = first
    output%last_halo = last
    output%ready = .true.
    status = 0
    return
900 continue
    status = child
    if (present(failed_stage)) failed_stage = stage
  end function

  !> Retire this owner only, in reverse construction order.
 !! Repeated release is safe. Geometry, model, controls and all input arrays
 !! remain unchanged. Numerical arrays are never copied to a second owner.
  integer(int32) function release_interpolation_coefficient_tables(output) result(status)
    type(native_interpolation_coefficient_tables), intent(inout) :: output
    integer(int32) :: child
    child = release_meridional_interpolation(output%yrhslmer)
    call release_vertical_interpolation_coefficients(output%yrvsleta)
    call release_vertical_spline_interpolation(output%yrvsplip)
    output%ready = .false.
    output%levels = 0
    output%first_halo = 0
    output%last_halo = -1
    status = child
  end function
end module
