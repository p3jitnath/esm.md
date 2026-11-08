module md2asm_fourier_wind_and_hemisphere
  !! Complete generated LDFOU2 scaling and ASRE1B reconstruction/scatter.
  !! The metric factor uses1/m; reconstruction preserves the field's units.
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: scale_fourier_wind, reconstruct_fourier_hemispheres
contains
  subroutine scale_fourier_wind(wave, wind_pairs, northern_latitudes, active_latitudes, antisymmetric, symmetric, &
                                status, reciprocal_metric)
    !! Each selected real/imaginary row receives one rounded product.
    !! Arrays may be strided; inactive latitude and row padding stay unchanged.
    integer(int32), intent(in) :: wave, wind_pairs, northern_latitudes, active_latitudes(0:)
    real(real64), intent(inout) :: antisymmetric(:, :), symmetric(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: reciprocal_metric(:)
    integer :: first_latitude, count, latitude, row, rows
    status = 2
    if (wave < 0 .or. wave > 1024 .or. wind_pairs < 0 .or. wind_pairs > 1024) return
    if (northern_latitudes < 0 .or. northern_latitudes > 4096) return
    if (ubound(active_latitudes, 1) < wave) return
    count = active_latitudes(wave)
    if (count < 0 .or. count > northern_latitudes) return
    rows = 4*wind_pairs
    status = 0
    if (rows == 0 .or. count == 0) return
    status = 2
    if (size(antisymmetric, 1) < rows .or. size(symmetric, 1) < rows) return
    if (size(antisymmetric, 2) < northern_latitudes .or. size(symmetric, 2) < northern_latitudes) return
    if (.not. present(reciprocal_metric)) return
    if (size(reciprocal_metric) < northern_latitudes) return
    first_latitude = northern_latitudes - count + 1
    do latitude = first_latitude, northern_latitudes
      do row = 1, rows
        antisymmetric(row, latitude) = antisymmetric(row, latitude)*reciprocal_metric(latitude)
        symmetric(row, latitude) = symmetric(row, latitude)*reciprocal_metric(latitude)
      end do
    end do
    status = 0
  end subroutine

  subroutine reconstruct_fourier_hemispheres(field_count, wave, local_wave, northern_latitudes, active_latitudes, &
                                             process_of_latitude, process_offset, wave_offset, antisymmetric, symmetric, &
                                             packed, status)
    !! Native maps replace compiler-specific global object descriptors.
    !! process_offset and wave_offset's first dimension use logical index0.
    !! Every selected packed interval must be disjoint, as in the frozen
    !! caller contract. All map bounds are checked before the first write.
    integer(int32), intent(in) :: field_count, wave, local_wave, northern_latitudes, active_latitudes(0:)
    integer(int32), intent(in) :: process_of_latitude(:), process_offset(0:), wave_offset(0:, :)
    real(real64), intent(in) :: antisymmetric(:, :), symmetric(:, :)
    real(real64), intent(inout) :: packed(:)
    integer(int32), intent(out) :: status
    integer :: count, first_latitude, latitude, south, row, rows
    integer(int64) :: north_offset, south_offset
    status = 2
    if (field_count < 0 .or. field_count > 1024 .or. wave < 0 .or. wave > 1024 .or. local_wave < 0 .or. local_wave > 1024) return
    if (northern_latitudes < 0 .or. northern_latitudes > 4096 .or. ubound(active_latitudes, 1) < wave) return
    count = active_latitudes(wave)
    if (count < 0 .or. count > northern_latitudes) return
    rows = 2*field_count
    status = 0
    if (rows == 0 .or. count == 0) return
    status = 2
    if (size(antisymmetric, 1) < rows .or. size(symmetric, 1) < rows) return
    if (size(antisymmetric, 2) < northern_latitudes .or. size(symmetric, 2) < northern_latitudes) return
    if (size(process_of_latitude) < 2*northern_latitudes) return
    if (ubound(wave_offset, 1) < local_wave .or. size(wave_offset, 2) < 2*northern_latitudes) return
    first_latitude = northern_latitudes - count + 1
    do latitude = first_latitude, northern_latitudes
      south = 2*northern_latitudes + 1 - latitude
      if (.not. destination(latitude, north_offset)) return
      if (.not. destination(south, south_offset)) return
    end do
    do latitude = first_latitude, northern_latitudes
      south = 2*northern_latitudes + 1 - latitude
      if (.not. destination(latitude, north_offset)) return
      if (.not. destination(south, south_offset)) return
      do row = 1, rows
        packed(north_offset + row) = antisymmetric(row, latitude) + symmetric(row, latitude)
        packed(south_offset + row) = symmetric(row, latitude) - antisymmetric(row, latitude)
      end do
    end do
    status = 0
  contains
    logical function destination(latitude, offset)
      integer, intent(in) :: latitude
      integer(int64), intent(out) :: offset
      integer :: process
      integer(int64) :: coefficient
      destination = .false.
      offset = 0
      process = process_of_latitude(latitude)
      if (process < 0 .or. process > ubound(process_offset, 1)) return
      coefficient = int(process_offset(process), int64) + int(wave_offset(local_wave, latitude), int64)
      if (coefficient < 0) return
      offset = coefficient*rows
      if (offset > huge(0_int32)) return
      if (offset + rows > size(packed, kind=int64)) return
      destination = .true.
    end function
  end subroutine
end module md2asm_fourier_wind_and_hemisphere
