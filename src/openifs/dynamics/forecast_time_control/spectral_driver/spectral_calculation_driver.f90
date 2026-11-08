!> Own the native spectral driver interface and borrow all physical storage.
!! Spectral coefficients use their source field units. Time is seconds and
!! rotation rate is1/s. Integer maps and scalar switches are dimensionless.
module forecast_spectral_calculation_driver
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08, only: MPI_Comm, MPI_COMM_NULL
  use md2asm_distributed_pressure_stage, only: spectral_pressure_context
  use md2asm_spectral_implicit_update, only: spectral_implicit_controls, spectral_implicit_coefficients
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_transform_profile_policy, only: transform_profile_policy
  use forecast_runtime_spectral_transposes, only: native_runtime_spectral_fields
  use forecast_spectral_horizontal_diffusion, only: native_horizontal_diffusion_switches
  use forecast_spectral_diffusion_setup, only: native_spectral_diffusion_state
  use forecast_runtime_dry_mass_reference, only: native_dry_mass_reference
  implicit none
  private
  public :: native_spectral_calculation_context, native_spectral_calculation_fields
  public :: advance_spectral_calculations, transform_profile_policy

  !> Borrow one real pressure context, mass state, diffusion state and source maps.
  !! Scalar controls are a per-call snapshot from their named canonical producer.
  !! The caller refreshes them and time-dependent coefficients before each visit.
  !! This record allocates no field, map, parameter or replacement model.
  type :: native_spectral_calculation_context
    type(MPI_Comm) :: communicator = MPI_COMM_NULL
    type(spectral_pressure_context), pointer :: pressure => null()
    type(native_dry_mass_reference), pointer :: mass => null()
    type(native_spectral_diffusion_state), pointer :: diffusion => null()
    type(spectral_implicit_controls) :: implicit_control
    type(spectral_implicit_coefficients) :: implicit_coefficients
    type(vertical_operator_matrices) :: vertical_matrices
    type(native_horizontal_diffusion_switches) :: diffusion_switches
    integer(int32), pointer :: myms(:) => null(), nasm0(:) => null(), nvalue(:) => null(), nptrsv(:) => null()
    integer(int32) :: ncurrent_iter = -1, nsiter = -1, zero_wave_horizontal_owner = 0, level_offset = -1
    ! Live NPROMA is the source chunk width for public vertical matrix calls.
    integer(int32) :: vertical_chunk = 0
    integer(int64) :: temporary_bytes_budget = 0_int64, successful_calls = 0_int64
    real(real64), pointer :: rcordit(:) => null()
    logical :: lr3d = .false., limpf = .false., lsidg = .true., lnhdyn = .true., lnhx = .true.
    logical :: lmascor = .false., lgpmascor = .false., lgradsp = .false., lrsiddh = .true.
    logical :: lnhee = .true., lsi_nhee = .false., lnhqe = .true., lnhqe_sihyd = .false.
    logical :: ready = .false.
  end type

  !> Borrow the actual level-form spectral fields and optional filter carriers.
  !! Matrix views retain their native strides and any inactive padded rows.
  !! Only source-active physical coefficients may be changed by the driver.
  type :: native_spectral_calculation_fields
    type(native_runtime_spectral_fields) :: level
    real(real64), pointer :: filtered_vorticity(:, :) => null(), filtered_divergence(:, :) => null()
  end type

  interface
    !> Run source SPCM order through complete owned numerical children.
    !! Context and fields retain their owners throughout the call. Status0
    !! succeeds,1 reports allocation refusal and2 reports unsupported metadata.
    !! Profile is the optional public runtime event policy. No numerical
    !! procedure argument or private assembly descriptor is accepted here.
    module function advance_spectral_calculations(context, fields, configuration, profile) result(status)
      type(native_spectral_calculation_context), intent(inout), target :: context
      type(native_spectral_calculation_fields), intent(inout) :: fields
      character(len=1), intent(in) :: configuration
      type(transform_profile_policy), intent(in), optional :: profile
      integer(int32) :: status
    end function
  end interface
end module forecast_spectral_calculation_driver
