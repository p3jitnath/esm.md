!> Keep the generated WRPLFP source order with typed output owners.
!! This module writes pressure, potential-vorticity and theta-level fields.
!! Numerical selection, gathering and encoding use the accepted child ports.
module runtime_fullpos_level_writer_port
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_size_t
  use runtime_grib_template_port, only: grib_geometry_metadata, grib_template_metadata
  use runtime_grib_field_encoding_port, only: grib_field_metadata
  use runtime_grib_writer_state_port, only: grib_writer_state
  use runtime_output_field_gather_port, only: output_distribution, agree_output_status
  use runtime_synchronous_grib_file_backend_port, only: output_file_plan
  use runtime_selected_output_family_port, only: output_selection_request, write_runtime_selected_output_family
  implicit none
  private
  public :: fullpos_level_output_controls, write_fullpos_level_fields
  type :: fullpos_level_output_controls
    integer(int32) :: truncation = 0, block_width = 0, local_coefficients = 0, clock_step = 0
    real(real64) :: time_step = 0.0_real64
    character :: coordinate = 'p'
    logical :: initial_state = .false., profiling_enabled = .false.
  end type fullpos_level_output_controls
contains
  !> Write spectral fields first, followed by their upper-grid fields.
  !! spectrum has (local_field_count,local_coefficients) elements.
  !! blocked has (block_width,field_capacity,block_count) elements.
  !! The six names contain 256 characters each. Only names 1 and 4 are read.
  !! The caller retains each input owner through the last synchronous write.
  subroutine write_fullpos_level_fields(spectral_request, grid_request, geometry, template_metadata, &
                                      field_defaults, distribution, controls, filenames, output_directory, gravity, water_density, &
                                        cloud_cover_precision, cloud_water_precision, writer, status, spectrum, blocked)
    type(output_selection_request), intent(in) :: spectral_request, grid_request
    type(grib_geometry_metadata), intent(in) :: geometry
    type(grib_template_metadata), intent(in) :: template_metadata
    type(grib_field_metadata), intent(in) :: field_defaults
    type(output_distribution), intent(in) :: distribution
    type(fullpos_level_output_controls), intent(in) :: controls
    character(256), intent(in) :: filenames(6)
    character(*), intent(in) :: output_directory
    real(real64), intent(in) :: gravity, water_density, cloud_cover_precision, cloud_water_precision
    type(grib_writer_state), intent(inout) :: writer
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: spectrum(:, :), blocked(:, :, :)
    type(grib_template_metadata) :: reduced_template
    type(grib_field_metadata) :: reduced_fields
    type(output_file_plan) :: plan
    integer(int32) :: local_status
    integer(int64) :: global_coefficients, budget, time_word
    integer :: spectral_count, grid_count

    spectral_count = 0
    grid_count = 0
    if (allocated(spectral_request%parameters)) spectral_count = size(spectral_request%parameters)
    if (allocated(grid_request%parameters)) grid_count = size(grid_request%parameters)
    local_status = 2_int32
    if (controls%truncation >= 1 .and. controls%truncation <= 4096 .and. &
        controls%block_width >= 1 .and. controls%block_width <= 1024 .and. controls%clock_step >= 0 .and. &
        distribution%maps_ready .and. distribution%world >= 1 .and. distribution%world <= 65536 .and. &
        distribution%process_one_based >= 1 .and. distribution%process_one_based <= distribution%world .and. &
        distribution%local_grid_points >= 1 .and. distribution%global_grid_points >= 1 .and. &
        distribution%resolution >= 0 .and. spectral_count <= 65536 .and. grid_count <= 65536 .and. &
        writer%initialized .and. .not. writer%io_server .and. .not. controls%profiling_enabled) then
      global_coefficients = int(controls%truncation + 1, int64)*int(controls%truncation + 2, int64)
      budget = int(field_defaults%workspace_limit_bytes, int64)
      time_word = transfer(controls%time_step, time_word)
      if (controls%local_coefficients >= 0 .and. controls%local_coefficients <= global_coefficients .and. &
          index('pvt', controls%coordinate) > 0 .and. budget >= 640_int64 .and. budget <= 68719476736_int64 .and. &
          time_word > 0_int64 .and. iand(time_word, int(z'7ff0000000000000', int64)) /= int(z'7ff0000000000000', int64)) then
        local_status = 0_int32
        if (spectral_count > 0 .and. .not. present(spectrum)) local_status = 2_int32
        if (grid_count > 0 .and. .not. present(blocked)) local_status = 2_int32
        if (present(blocked)) then
          if (grid_count > 0 .and. size(blocked, 1) /= controls%block_width) local_status = 2_int32
        end if
      end if
    end if
    call agree_output_status(distribution, local_status, status)
    if (status /= 0) return

    reduced_fields = field_defaults
    reduced_template = template_metadata
    reduced_fields%workspace_limit_bytes = int(budget - 640_int64, c_size_t)
    reduced_template%workspace_limit_bytes = reduced_fields%workspace_limit_bytes
    plan%level_kind = controls%coordinate
    plan%nstep = controls%clock_step
    plan%truncation = controls%truncation
    plan%time_step = controls%time_step
    if (spectral_count > 0) then
      plan%spectral = .true.
      plan%append = .true.
      plan%local_value_count = controls%local_coefficients
      plan%global_value_count = int(global_coefficients, int32)
      call write_runtime_selected_output_family(0_int32, spectral_request, geometry, reduced_template, &
                                       reduced_fields, distribution, plan, filenames(1), output_directory, gravity, water_density, &
                                                cloud_cover_precision, cloud_water_precision, writer, status, spectrum=spectrum)
      if (status /= 0) return
    end if
    if (grid_count > 0) then
      ! Retain the source mode-agreement point before the upper-grid call.
      call agree_output_status(distribution, 0_int32, status)
      if (status /= 0) return
      plan%spectral = .false.
      plan%append = .not. controls%initial_state
      plan%local_value_count = distribution%local_grid_points
      plan%global_value_count = distribution%global_grid_points
      call write_runtime_selected_output_family(2_int32, grid_request, geometry, reduced_template, &
                                       reduced_fields, distribution, plan, filenames(4), output_directory, gravity, water_density, &
                                                cloud_cover_precision, cloud_water_precision, writer, status, blocked=blocked)
      return
    end if
    status = 0_int32
  end subroutine write_fullpos_level_fields
end module runtime_fullpos_level_writer_port
