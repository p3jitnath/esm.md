!> Pack spectral pressure output before grid pressure output.
module forecast_pressure_output_controller
  use iso_fortran_env, only: int32, real64
  use forecast_output_request_types, only: trqfp
  use forecast_output_field_packing, only: native_spectral_field_metadata, native_grid_field_metadata, &
                                           pack_spectral_output, pack_grid_output
  use forecast_grib_field_writers, only: native_grib_writer_context, native_grib_writer_inputs, &
                                         native_grib_writer_policy, write_spectral_grib_fields, write_grid_grib_fields
  use yomhook, only: dr_hook
  implicit none
  private
  public :: write_pressure_output
contains
  !> Preserve WRPLFP's two temporary-owner lifetimes and child order.
  !! spectral_input is (source fields,spectral words); grid_input is
  !! (block width,source fields,blocks). Spectral words1:506, points1:2048
  !! and width1:24 retain the selected source limits. Both requests contain
  !! at most39fields. The GRIB child retains its stricter admitted field set.
  !! Filenames are the actual names prepared by the own output metadata
  !! stage. Scalar io_service must be0; live vertical set must be1.
  !! A returned failure releases current temporary arrays. Earlier records
  !! remain visible. Hook calls use the public FIAT profiling interface.
  integer(int32) function write_pressure_output(spectral_request, grid_request, spectral_input, &
                              grid_input, spectral_words, points, width, spectral_filename, grid_filename, writer, inputs, policy, &
                                                io_service, split_output, hook_enabled, level_type) result(status)
    type(trqfp), intent(in) :: spectral_request, grid_request
    real(real64), intent(in) :: spectral_input(:, :), grid_input(:, :, :)
    integer(int32), intent(in) :: spectral_words, points, width, io_service
    character(*), intent(in) :: spectral_filename, grid_filename
    type(native_grib_writer_context), intent(inout) :: writer
    type(native_grib_writer_inputs), intent(in) :: inputs
    type(native_grib_writer_policy), intent(in) :: policy
    logical, intent(in) :: split_output, hook_enabled
    character(1), intent(in) :: level_type
    real(real64), allocatable :: packed(:, :)
    type(native_spectral_field_metadata) :: spectral_metadata(39)
    type(native_grid_field_metadata) :: grid_metadata(39)
    integer(int32) :: packed_count
    integer :: allocation_status, fields
    real(real64) :: hook_handle
    character(1) :: mode
    status = 2
    if (policy%nproc /= 1 .or. io_service /= 0) return
    if (.not. associated(inputs%geometry)) return
    if (inputs%geometry%transform_control%mysetv /= 1) return
    if (level_type /= 'p') return
    if (spectral_request%nfieldg < 0 .or. spectral_request%nfieldg > 39) return
    if (hook_enabled) call dr_hook('WRPLFP', 0, hook_handle)
    fields = spectral_request%nfieldg
    if (fields /= 0) then
      if (spectral_words < 1 .or. spectral_words > 506) goto 900
      if (size(spectral_input, 2) /= spectral_words) goto 900
      allocate (packed(spectral_words, fields), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        goto 900
      end if
      status = pack_spectral_output(spectral_request, spectral_input, 1_int32, packed, &
                                    spectral_metadata(:fields), spectral_words, 1_int32, packed_count)
      if (status /= 0) goto 900
      if (packed_count /= fields) then
        status = 2
        goto 900
      end if
      status = write_spectral_grib_fields(writer, inputs, policy, packed, spectral_metadata(:fields), &
                                          level_type, spectral_filename)
      if (status /= 0) goto 900
      deallocate (packed)
    end if
    fields = grid_request%nfieldg
    status = 2
    if (fields < 0 .or. fields > 39) goto 900
    if (fields /= 0) then
      if (points < 1 .or. points > 2048 .or. width < 1 .or. width > 24) goto 900
      if (size(grid_input, 1) < width .or. size(grid_input, 2) < fields) goto 900
      if (size(grid_input, 3) < (points + width - 1)/width) goto 900
      allocate (packed(points, fields), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        goto 900
      end if
      status = pack_grid_output(grid_request, grid_input, packed, grid_metadata(:fields), points, width, 1_int32, packed_count)
      if (status /= 0) goto 900
      if (packed_count /= 0) then
        mode = 'a'
        if (split_output) mode = 'w'
        status = write_grid_grib_fields(writer, inputs, policy, packed(:, :packed_count), &
                                        grid_metadata(:packed_count), level_type, mode, grid_filename)
        if (status /= 0) goto 900
      end if
      deallocate (packed)
    end if
    status = 0
900 if (allocated(packed)) deallocate (packed)
    if (hook_enabled) call dr_hook('WRPLFP', 1, hook_handle)
  end function
end module
