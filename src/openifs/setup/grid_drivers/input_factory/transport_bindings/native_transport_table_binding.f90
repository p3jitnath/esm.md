!> Bind the actual nineteen interpolation tables without copying their data.
module forecast_native_transport_table_binding
  use iso_fortran_env, only: int32
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_interpolation_coefficient_table_types, only: native_interpolation_coefficient_tables
  use md2asm_departure_interpolation_weights, only: departure_weight_geometry
  implicit none
  private
  public :: bind_transport_table_views
contains
  !> Preserve the storage-index contract of the native LASCAW numerical child.
 !! The original local latitude table is sliced at actual NDGSAH:NDGENH.
 !! Native child array storage begins at1; FIRST_LATITUDE and SPLINE_FIRST_LEVEL
 !! retain the separate physical index origins. This is pointer rebasing only.
 !! Eta is dimensionless, latitude is radians and all coefficients retain
 !! their existing units and rounded values. No weather owner is allocated.
  subroutine bind_transport_table_views(geometry, sl, tables, view, status)
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_interpolation_state), target, intent(in) :: sl
    type(native_interpolation_coefficient_tables), target, intent(in) :: tables
    type(departure_weight_geometry), intent(inout) :: view
    integer(int32), intent(out) :: status
    type(departure_weight_geometry) :: bound
    integer :: first, last, levels
    status = 2
    if (.not. geometry%initialized .or. .not. associated(geometry%vertical)) return
    if (.not. tables%ready) return
    if (sl%naslb1 < 1) return
    levels = geometry%dimensions%nflevg
    if (tables%levels /= levels) return
    first = sl%ndgsah; last = sl%ndgenh
    if (first > last .or. tables%first_halo /= first .or. tables%last_halo /= last) return
    if (.not. allocated(geometry%latitudes%rlati)) return
    if (first < lbound(geometry%latitudes%rlati, 1) .or. last > ubound(geometry%latitudes%rlati, 1)) return
    if (.not. allocated(sl%nsloff) .or. .not. allocated(sl%nslmap)) return
    if (first < lbound(sl%nsloff, 1) .or. last > ubound(sl%nsloff, 1)) return
    if (first < lbound(sl%nslmap, 2) .or. last > ubound(sl%nslmap, 2)) return
    if (.not. allocated(geometry%vertical%vetaf)) return
    if (lbound(geometry%vertical%vetaf, 1) /= 0 .or. ubound(geometry%vertical%vetaf, 1) /= levels + 1) return
    if (.not. allocated(tables%yrhslmer%ripi) .or. .not. allocated(tables%yrhslmer%rsld)) return
    if (.not. allocated(tables%yrhslmer%rsldw) .or. .not. allocated(tables%yrhslmer%r3dtw)) return
    if (lbound(tables%yrhslmer%ripi, 1) /= first .or. ubound(tables%yrhslmer%ripi, 1) /= last) return
    if (.not. allocated(tables%yrvsleta%vcuico) .or. .not. allocated(tables%yrvsleta%vsld)) return
    if (.not. allocated(tables%yrvsleta%vsldw) .or. .not. allocated(tables%yrvsleta%vslvf)) return
    if (.not. allocated(tables%yrvsleta%gamma_weno) .or. .not. allocated(tables%yrvsleta%nvautf)) return
    if (.not. allocated(tables%yrvsplip%pieces)) return
    bound = view
    bound%first_latitude = first
    bound%latitude_offset = sl%nfrstloff
    bound%longitude_first = lbound(sl%nslmap, 1)
    bound%buffer_stride = sl%naslb1
    bound%field_level = geometry%dimensions%nflsa
    bound%spline_first_level = lbound(tables%yrvsplip%pieces, 2)
    bound%latitude_multiplier = geometry%grid%constants%r4jp
    bound%lookup_scale = tables%yrvsleta%vrlevx
    bound%first_buffer(1:) => sl%nsloff(first:last)
    bound%longitude_map(1:, 1:) => sl%nslmap(:, first:last)
    bound%latitude(1:) => geometry%latitudes%rlati(first:last)
    bound%latitude_reciprocals(1:, 1:) => tables%yrhslmer%ripi
    bound%latitude_quadratic(1:, 1:) => tables%yrhslmer%rsld
    bound%latitude_diffusion(1:, 1:, 1:) => tables%yrhslmer%rsldw
    bound%latitude_turbulence(1:, 1:, 1:) => tables%yrhslmer%r3dtw
    bound%eta(1:) => geometry%vertical%vetaf
    bound%vertical_lookup(1:) => tables%yrvsleta%nvautf
    bound%vertical_cubic(1:, 1:) => tables%yrvsleta%vcuico
    bound%vertical_quadratic(1:, 1:) => tables%yrvsleta%vsld
    bound%vertical_diffusion(1:, 1:, 1:) => tables%yrvsleta%vsldw
    bound%vertical_filter(1:, 1:, 1:) => tables%yrvsleta%vslvf
    bound%weno_gamma(1:, 1:) => tables%yrvsleta%gamma_weno
    bound%spline(1:, 1:, 1:) => tables%yrvsplip%pieces
    view = bound
    status = 0
  end subroutine
end module
