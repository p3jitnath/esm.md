module streaming_spectral_record_placement_port
  !! Place one decoded global record into the uncommitted local owners.
  !! Port: src/openifs/input/streaming_runtime_spectral_record_placement.S.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use initial_field_placement_port, only: spectral_initial_partition
  implicit none
  private
  public :: scatter_streamed_spectral_record
contains
  subroutine scatter_streamed_spectral_record(partition, row, record, spectral, surface)
    !! record is the zero-based source record number. The owning parent has
    !! validated all shapes, maps and field labels before this private call.
    !! row contains (degree+1)*(degree+2) FP64 wave words. spectral has shape
    !! (local_levels,local_coefficients,3); surface has zero or two columns.
    !! Only the selected local cells change. Every assignment copies a bit
    !! pattern without evaluating its physical value or changing its units.
    type(spectral_initial_partition), intent(in) :: partition
    real(real64), intent(in) :: row(:)
    integer(int64), intent(in) :: record
    real(real64), intent(inout) :: spectral(:, :, :), surface(:, :)
    integer :: field, global_level, local_level, wave, m, k, first_local, first_global, length
    logical :: surface_record
    surface_record = record == 0_int64 .or. record == 3_int64*partition%global_levels + 1_int64
    if (surface_record) then
      if (partition%surface_fields == 0) return
      field = 1
      if (record /= 0_int64) field = 2
    else
      if (partition%local_levels == 0) return
      global_level = int((record - 1_int64)/3_int64) + 1
      field = int(mod(record - 1_int64, 3_int64)) + 1
      do local_level = 1, partition%local_levels
        if (partition%levels(local_level) == global_level) exit
        if (partition%levels(local_level) > global_level) return
      end do
      if (local_level > partition%local_levels) return
    end if
    do wave = 1, size(partition%waves)
      m = partition%waves(wave)
      first_local = partition%local_first(m)
      first_global = partition%global_first(m)
      length = 2*(partition%degree + 1 - m)
      do k = 0, length - 1
        if (surface_record) then
          surface(first_local + k, field) = row(first_global + k)
        else
          spectral(local_level, first_local + k, field) = row(first_global + k)
        end if
      end do
    end do
  end subroutine
end module streaming_spectral_record_placement_port
