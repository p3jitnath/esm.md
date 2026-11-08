!> Named portable metadata for the shortwave worker and controller.
!! Bounds and payload shapes come from live ecRad records. No Arm byte offsets,
!! fixed native record sizes or alternative scientific arrays are introduced.
!! FP observation words are supplied by an external observer, never read here.
module forecast_shortwave_team_metadata
  use iso_fortran_env, only: int32, int64, real64
  use radiation_config, only: config_type
  use radiation_single_level, only: single_level_type
  use radiation_cloud, only: cloud_type
  use radiation_flux, only: flux_type
  use md2asm_shortwave_column_team, only: solver_mcica_sw_team
  implicit none
  private
  public :: shortwave_argument_views, shortwave_worker_metadata, shortwave_controller_metadata
  public :: shortwave_counter_metadata, shortwave_parent_metadata, solver_mcica_sw_team, selected_shortwave_workers
  public :: selected_shortwave_columns, selected_shortwave_layers, selected_shortwave_samples, selected_shortwave_bands
  integer(int32), parameter :: selected_shortwave_workers = 8_int32
  integer(int32), parameter :: selected_shortwave_columns = 8, selected_shortwave_layers = 19
  integer(int32), parameter :: selected_shortwave_samples = 112, selected_shortwave_bands = 14
  type shortwave_counter_metadata
    integer(int64) :: fast = 0_int64, wide = 0_int64, exponentials = 0_int64
  end type
  type shortwave_argument_views
    type(config_type), pointer :: configuration => null()
    type(single_level_type), pointer :: single_level => null()
    type(cloud_type), pointer :: cloud => null()
    type(flux_type), pointer :: flux => null()
real(real64), pointer :: optical_depth(:, :, :) => null(), single_scattering_albedo(:, :, :) => null(), asymmetry(:, :, :) => null()
real(real64), pointer :: cloud_optical_depth(:, :, :) => null(), cloud_albedo(:, :, :) => null(), cloud_asymmetry(:, :, :) => null()
    real(real64),pointer::surface_albedo_direct(:,:)=>null(),surface_albedo_diffuse(:,:)=>null(),incoming_solar(:,:)=>null()
    integer(int32) :: levels = 0, first = 1, last = 0
  end type
  type shortwave_worker_metadata
    type(shortwave_counter_metadata) :: counts
    integer(int32) :: first = 1, last = 0, actual_team = 0, thread_index = 0
    integer(int64) :: numerical_flags = 0, entry_control = 0, entry_flags = 0, reserved = 0
    integer(int32) :: final_errno = 0, entry_errno = 0
    integer(int32), pointer :: errno_slot => null()
    logical :: seen = .false.
    real(real64), pointer :: scratch(:) => null()
    type(flux_type), pointer :: flux => null()
    type(shortwave_argument_views), pointer :: arguments => null()
    type(shortwave_controller_metadata), pointer :: controller => null()
  end type
  type shortwave_controller_metadata
    type(shortwave_argument_views) :: arguments
    integer(int32) :: first = 1, last = 0, full_columns = 0, samples = 0, layers = 0
    integer(int64) :: entry_control = 0, entry_flags = 0
    integer(int32), pointer :: errno_slot => null()
    integer(int32) :: entry_errno = 0, actual_team = 0, allocated_workers = 0, required_team = 8
    logical :: bad_team = .false.
    type(shortwave_counter_metadata) :: total
    type(shortwave_worker_metadata), pointer :: workers(:) => null()
  end type
  ! The parent compiler frame is replaced by named automatic metadata.
  type shortwave_parent_metadata
    type(config_type), pointer :: configuration => null()
    type(shortwave_controller_metadata), pointer :: controller => null()
    integer(int64) :: saved_control, saved_flags
    integer(int32) :: saved_errno
    logical :: private_delta
  end type
end module forecast_shortwave_team_metadata
