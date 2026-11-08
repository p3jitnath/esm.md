!> Preserve the source filter setup order on the global ECMWF route.
module forecast_fullpos_filter_parent
  use iso_fortran_env, only: int32, int64, real64
  use yomfpc, only: tnamfpobj, tnamfpsci, tnamfpint, tnamfpl
  use yomfpf, only: tnamfpf
  use yomfpfilters, only: tfpfilters
  use type_fpfields, only: tfpfields
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_runtime_output_configuration, only: native_runtime_output_configuration
  use forecast_output_request_preparation, only: native_output_common_metadata
  use forecast_fullpos_configuration, only: initialize_native_fullpos_configuration
  use forecast_fullpos_field_construction, only: initialize_fullpos_fields, release_fullpos_fields
  implicit none
  private
  public :: initialize_fullpos_filters, release_fullpos_filters
contains
  !> Construct one inactive filter after the source private field-list lifetime.
 !! Counts are dimensionless, stretch is dimensionless and budget is bytes.
 !! Common and output are changed only after all allocations succeed.
 integer(int32) function initialize_fullpos_filters(text,model,configuration,filter_controls,model_levels,snow_levels,satellite_count,truncation,stretch,common,output,budget,nvgrib)result(status)
    character(*), intent(in) :: text
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_runtime_output_configuration), target, intent(in) :: configuration
    type(tnamfpf), intent(in) :: filter_controls
    integer(int32), intent(in) :: model_levels, snow_levels, satellite_count, truncation
    real(real64), intent(in) :: stretch
    type(native_output_common_metadata), intent(inout) :: common
    type(tfpfilters), intent(inout) :: output
    integer(int64), intent(in) :: budget
    integer(int32), optional, intent(in) :: nvgrib
    type(tnamfpobj) :: object
    type(tnamfpsci) :: science
    type(tnamfpint) :: interpolation
    type(tnamfpl) :: levels
    type(native_output_common_metadata) :: pending_common
    type(tfpfields) :: fields
    logical, allocatable :: active(:)
    logical :: matrix
    integer :: ierr, maximum_degree
    real(real64), volatile :: scaled_degree
    status = 2
    if (allocated(output%lfpfil) .or. allocated(output%rfpfil) .or. allocated(output%rfpmat)) return
    if (truncation < 1 .or. truncation > 4095 .or. stretch /= 1.0_real64 .or. budget < 4_int64) return
    if (filter_controls%nfpcmax /= 0 .or. filter_controls%nfpreadall /= 1) return
    if (any(filter_controls%nfmax /= 0)) return
    pending_common = common
  status=initialize_native_fullpos_configuration(text,model,configuration,object,science,interpolation,levels,pending_common,nvgrib)
    if (status /= 0) return
    status = initialize_fullpos_fields(levels, model_levels, snow_levels, satellite_count, .false., fields, budget - 4_int64)
    if (status /= 0) return
    allocate (active(1), stat=ierr)
    if (ierr /= 0) then
      call release_fullpos_fields(fields); status = 1; return
    end if
    scaled_degree = real(truncation, real64)*stretch
    maximum_degree = max(filter_controls%nfpcmax, nint(scaled_degree))
    matrix = maximum_degree > truncation
    ! Configuration zero has no dilated spectral domain, so its filter is inactive.
    active(1) = .false.
    call release_fullpos_fields(fields)
    call move_alloc(active, output%lfpfil)
    output%lfpmat = matrix
    common = pending_common
    status = 0
  end function
  !> Release the sole written filter owner; other absent components stay absent.
  subroutine release_fullpos_filters(output)
    type(tfpfilters), intent(inout) :: output
    if (allocated(output%lfpfil)) deallocate (output%lfpfil)
  end subroutine
end module
