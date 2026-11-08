!> Return named borrowed views from the actual caller-owned output arrays and records.
!! Every target must remain alive until all consumers release their views.
!! C_PTR carries an address only; no original record offset is read or reconstructed.
module forecast_output_request_views
  use iso_c_binding, only: c_ptr, c_null_ptr, c_loc, c_int64_t
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_request_types, only: type_fprqdyn, trqfp, increment_output_counter
  use forecast_fullpos_state_types, only: native_fullpos_state
  use forecast_grid_motion_types, only: native_grid_motion_state
  use type_fpofn, only: tfpofn
  implicit none
  private
  public :: native_output_field_view, native_output_block_views, native_output_io_views
  public :: native_output_view_counters, output_field_map, output_block_views, output_io_views, output_metadata_count
  type, bind(c) :: native_output_field_view
    integer(c_int64_t) :: level_count, fit, index
    type(c_ptr) :: level_indices
    integer(c_int64_t) :: pitch
  end type
  type, bind(c) :: native_output_block_views
    integer(c_int64_t) :: point_pitch, levels, active_rows
    type(c_ptr) :: temperature, humidity, liquid, ice, rain, snow, surface_pressure
    type(c_ptr) :: orography, map_factor, orography_l, orography_m, surface_pressure_l, surface_pressure_m
    type(c_ptr) :: u, v, vertical_coordinate, vertical_metadata
    integer(c_int64_t) :: reserved_tail(4)
  end type
  type, bind(c) :: native_output_io_views
    type(c_ptr) :: resolution, spectral_words, global_spectral_words, local_grid_points
    type(c_ptr) :: target_grid, point_pitch, geometry, surface, ecmwf_physics, physics
    type(c_ptr) :: physical_request, names, step, time_step, global_output_size, user_geometry
    type(c_ptr) :: extra_field_control, target_grid_again
  end type
  type :: native_output_view_counters
    integer(int64) :: calls(0:2) = 0
  end type
contains
  !> Read one request map; unsupported active codes retain the source109cause.
  integer(int32) function output_field_map(request, code, view, counters) result(status)
    type(type_fprqdyn), target, intent(in) :: request
    integer(int32), intent(in) :: code
    type(native_output_field_view), intent(inout) :: view
    type(native_output_view_counters), intent(inout) :: counters
    call increment_output_counter(counters%calls(0))
    view%level_count = 0
    view%fit = 0
    view%index = 0
    view%level_indices = c_null_ptr
    view%pitch = 0
    status = 116
    if (.not. allocated(request%ll)) return
    if (code < lbound(request%ll, 1) .or. code > ubound(request%ll, 1)) return
    if (.not. request%ll(code)) then
      status = 0
      return
    end if
    status = 109
    if (code /= 5 .and. code /= 6 .and. code /= 454) return
    if (.not. allocated(request%isf) .or. .not. allocated(request%ilev)) return
    if (.not. allocated(request%ilvp) .or. .not. allocated(request%igpx) .or. .not. allocated(request%igt1)) return
    if (request%isf(code) > 1) return
    view%level_count = request%ilev(code)
    view%fit = request%isf(code)
    if (request%isf(code) > 0) then
      view%index = request%igt1(code, 1)
      view%pitch = request%nfpgt1
    else
      view%index = request%igpx(code)
      view%pitch = request%nfpauxb
    end if
    view%level_indices = c_loc(request%ilvp(1, code))
    status = 0
  end function
  !> Return selected24-by19block field addresses from the live motion and constituent owners.
  !! constituent_index order is humidity,liquid,ice,rain,snow; each is a live field index.
  !! Terrain and map-factor arrays are the actual chosen block arrays, with one-based bounds.
  integer(int32) function output_block_views(motion, constituents, constituent_index, orography, orography_l, &
                             orography_m, map_factor, points, levels, total_points, block, vertical_coordinate, vertical_metadata, &
                                             views, counters) result(status)
    type(native_grid_motion_state), target, intent(in) :: motion
    real(real64), target, intent(in) :: constituents(:, :, :, :), orography(:), orography_l(:), orography_m(:), map_factor(:)
    integer(int32), intent(in) :: constituent_index(5), points, levels, total_points, block
    type(c_ptr), intent(in) :: vertical_coordinate, vertical_metadata
    type(native_output_block_views), intent(inout) :: views
    type(native_output_view_counters), intent(inout) :: counters
    integer :: i, motion_index(3), surface_index(3)
    call increment_output_counter(counters%calls(1))
    views%point_pitch = 0
    views%levels = 0
    views%active_rows = 0
    views%temperature = c_null_ptr
    views%humidity = c_null_ptr
    views%liquid = c_null_ptr
    views%ice = c_null_ptr
    views%rain = c_null_ptr
    views%snow = c_null_ptr
    views%surface_pressure = c_null_ptr
    views%orography = c_null_ptr
    views%map_factor = c_null_ptr
    views%orography_l = c_null_ptr
    views%orography_m = c_null_ptr
    views%surface_pressure_l = c_null_ptr
    views%surface_pressure_m = c_null_ptr
    views%u = c_null_ptr
    views%v = c_null_ptr
    views%vertical_coordinate = c_null_ptr
    views%vertical_metadata = c_null_ptr
    views%reserved_tail = 0
    status = 116
    if (points /= 24 .or. levels /= 19 .or. total_points /= 2048 .or. block < 1 .or. block > 86) return
    if (.not. allocated(motion%gmv) .or. .not. allocated(motion%gmvs)) return
    if (size(motion%gmv, 1) /= 24 .or. size(motion%gmv, 2) /= 19 .or. size(motion%gmv, 4) /= 86) return
    if (size(motion%gmvs, 1) /= 24 .or. size(motion%gmvs, 3) /= 86) return
    if (size(constituents, 1) /= 24 .or. size(constituents, 2) /= 19 .or. size(constituents, 4) /= 86) return
    if (.not. is_contiguous(constituents)) return
    if (min(size(orography), size(orography_l), size(orography_m), size(map_factor)) < 1) return
    if (.not. is_contiguous(orography) .or. .not. is_contiguous(orography_l) .or. &
        .not. is_contiguous(orography_m) .or. .not. is_contiguous(map_factor)) return
    motion_index = [motion%yt0%mt, motion%yt0%mu, motion%yt0%mv]
    surface_index = [motion%yt0%msp, motion%yt0%mspl, motion%yt0%mspm]
    if (any(motion_index < 1) .or. any(motion_index > size(motion%gmv, 3))) return
    if (any(surface_index < 1) .or. any(surface_index > size(motion%gmvs, 2))) return
    if (any(constituent_index < 1) .or. any(constituent_index > size(constituents, 3))) return
    views%point_pitch = points
    views%levels = levels
    views%active_rows = min(total_points - (block - 1)*points, points)
    views%temperature = c_loc(motion%gmv(1, 1, motion_index(1), block))
    views%humidity = c_loc(constituents(1, 1, constituent_index(1), block))
    views%liquid = c_loc(constituents(1, 1, constituent_index(2), block))
    views%ice = c_loc(constituents(1, 1, constituent_index(3), block))
    views%rain = c_loc(constituents(1, 1, constituent_index(4), block))
    views%snow = c_loc(constituents(1, 1, constituent_index(5), block))
    views%surface_pressure = c_loc(motion%gmvs(1, surface_index(1), block))
    views%orography = c_loc(orography(1))
    views%map_factor = c_loc(map_factor(1))
    views%orography_l = c_loc(orography_l(1))
    views%orography_m = c_loc(orography_m(1))
    views%surface_pressure_l = c_loc(motion%gmvs(1, surface_index(2), block))
    views%surface_pressure_m = c_loc(motion%gmvs(1, surface_index(3), block))
    views%u = c_loc(motion%gmv(1, 1, motion_index(2), block))
    views%v = c_loc(motion%gmv(1, 1, motion_index(3), block))
    views%vertical_coordinate = vertical_coordinate
    views%vertical_metadata = vertical_metadata
    status = 0
  end function
  !> Return18named native record/scalar addresses with exact repeated-target aliases.
  !! The four opaque owner addresses are supplied from the actual root owners by C_LOC.
  !! Their contents are not read, copied or interpreted by this metadata-only child.
  integer(int32) function output_io_views(fullpos, geometry, surface, ecmwf_physics, physics, physical, names, &
                                          step, time_step, views, counters) result(status)
    type(native_fullpos_state), target, intent(in) :: fullpos
    type(c_ptr), intent(in) :: geometry, surface, ecmwf_physics, physics
    type(trqfp), target, intent(in) :: physical
    type(tfpofn), target, intent(in) :: names
    integer(int32), target, intent(in) :: step
    real(real64), target, intent(in) :: time_step
    type(native_output_io_views), intent(inout) :: views
    type(native_output_view_counters), intent(inout) :: counters
    integer :: first
    call increment_output_counter(counters%calls(2))
    status = 116
    if (.not. allocated(fullpos%yfpgeometry%yfpusergeo)) return
    if (size(fullpos%yfpgeometry%yfpusergeo) < 1) return
    first = lbound(fullpos%yfpgeometry%yfpusergeo, 1)
    views%resolution = c_loc(fullpos%yfpgeometry%yfpusergeo(first)%nfpresol)
    views%spectral_words = c_loc(fullpos%yfpgeometry%yfpusergeo(first)%nspec2)
    views%global_spectral_words = c_loc(fullpos%yfpgeometry%yfpusergeo(first)%nspec2g)
    views%local_grid_points = c_loc(fullpos%yfpgeometry%yfpgeo%nfprgpl)
    views%target_grid = c_loc(fullpos%yfpgeometry%yfpgeo)
    views%point_pitch = c_loc(fullpos%yfpgeometry%yfpgeo%nfproma)
    views%geometry = geometry
    views%surface = surface
    views%ecmwf_physics = ecmwf_physics
    views%physics = physics
    views%physical_request = c_loc(physical)
    views%names = c_loc(names)
    views%step = c_loc(step)
    views%time_step = c_loc(time_step)
    views%global_output_size = c_loc(fullpos%yfpgeometry%yfpusergeo(first)%nfpsizeg)
    views%user_geometry = c_loc(fullpos%yfpgeometry%yfpusergeo(first))
    views%extra_field_control = c_loc(fullpos%yfpioh%ynamfpios%nfpxfld)
    views%target_grid_again = views%target_grid
    status = 0
  end function
  integer(int64) function output_metadata_count(index, counters) result(value)
    integer(int64), intent(in) :: index
    type(native_output_view_counters), intent(in) :: counters
    value = 0
    if (index >= 0 .and. index <= 2) value = counters%calls(index)
  end function
end module forecast_output_request_views
