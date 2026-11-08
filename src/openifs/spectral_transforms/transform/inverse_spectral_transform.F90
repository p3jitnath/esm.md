!> Own all selected LTINV preparation, work arrays, numerical calls and scatter.
module md2asm_inverse_spectral_transform
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_transform_types, only: transform_spectral_tables, transform_fourier_layout, transform_environment_ready
  use md2asm_spectral_latitude_operators, only: vorticity_divergence_to_wind, spectral_north_south_derivative
  use md2asm_legendre_matrix_transforms, only: reconstruct_legendre_wave
  use md2asm_fourier_wind_and_hemisphere, only: reconstruct_fourier_hemispheres
  implicit none
  private
  public :: inverse_spectral_preparation, reconstruct_spectral_order
  type :: inverse_spectral_preparation
    integer(int32), pointer :: epsilon_start(:) => null(), spectral_start(:) => null()
    real(real64), pointer :: epsilon_values(:) => null()
    logical :: keep_vorticity = .false., keep_divergence = .false.
  end type
contains
!> Reconstruct one selected T21 order into owned Fourier buffer intervals.
!! Spectral arrays have shape(field,506), with optional rank-three scalar planes.
!! Native preparation and table owners remain read-only; all work is private.
  subroutine reconstruct_spectral_order(t, l, p, wave, local_wave, output_fields, wind_fields, scalar_fields, derivative_fields, &
                                internal_columns, output_leading, packed, status, vorticity, divergence, scalars, scalar3a, scalar2)
    type(transform_spectral_tables), intent(in) :: t
    type(transform_fourier_layout), intent(in) :: l
    type(inverse_spectral_preparation), intent(in) :: p
    integer(int32), intent(in) :: wave, local_wave, output_fields, wind_fields, scalar_fields, derivative_fields
    integer(int32), intent(in) :: internal_columns, output_leading
    real(real64), intent(inout) :: packed(:)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: vorticity(:, :), divergence(:, :), scalars(:, :), scalar3a(:, :, :), scalar2(:, :)
    real(real64), allocatable :: work(:, :), anti(:, :), sym(:, :), epsilon(:)
    integer(int32), allocatable :: active(:), process_offset(:), wave_offset(:, :)
    integer :: count, base, last_column, first_column, c, j, k, at, rows, alloc_status, nsc2, nsc3, start_coefficient
    integer :: source_wave_lower, source_process_lower
    status = 2
    if (t%maximum_degree /= 21 .or. t%total_degree /= 21 .or. t%butterfly .or. t%latitude_longitude) return
    if (wave < 0 .or. wave > 21 .or. local_wave /= wave + 1) return
    if (l%northern_latitudes /= 16 .or. l%total_latitudes /= 32) return
    if(wind_fields<0.or.wind_fields>19.or.scalar_fields<0.or.scalar_fields>20.or.derivative_fields<0.or.derivative_fields>20)return
    if (output_leading < 1 .or. output_leading > 256 .or. internal_columns < 1 .or. internal_columns > 232) return
    if (internal_columns /= 8*wind_fields + 2*scalar_fields + 2*derivative_fields) return
    if (derivative_fields /= 0 .and. derivative_fields /= scalar_fields) return
   if(output_fields/=(2+merge(1,0,p%keep_vorticity)+merge(1,0,p%keep_divergence))*wind_fields+scalar_fields+derivative_fields)return
    if (output_leading < 2*output_fields) return
    if (.not. any(2*output_fields == [2, 4, 38, 76, 194, 232])) return
    if (.not. associated(p%epsilon_start) .or. .not. associated(p%spectral_start) .or. .not. associated(p%epsilon_values)) return
    if (wave < lbound(p%epsilon_start, 1) .or. wave > ubound(p%epsilon_start, 1)) return
    if (wave < lbound(p%spectral_start, 1) .or. wave > ubound(p%spectral_start, 1)) return
    count = 22 - wave; base = p%spectral_start(wave)
    if (base < 1 .or. base + 2*count - 1 > 506) return
    start_coefficient = p%epsilon_start(wave) + local_wave - wave
    if (start_coefficient + wave < lbound(p%epsilon_values, 1) .or. start_coefficient + 23 > ubound(p%epsilon_values, 1)) return
    if (wind_fields > 0) then
      if (.not. present(vorticity) .or. .not. present(divergence)) return
      if (size(vorticity, 1) /= wind_fields .or. size(divergence, 1) /= wind_fields) return
      if (size(vorticity, 2) /= 506 .or. size(divergence, 2) /= 506) return
    end if
    nsc2 = 0; nsc3 = 0
    if (scalar_fields > 0) then
      if (present(scalars)) then
        if (size(scalars, 1) /= scalar_fields .or. size(scalars, 2) /= 506) return
      else
        if (present(scalar2)) then
          nsc2 = size(scalar2, 1)
          if (size(scalar2, 2) /= 506) return
        end if
        if (present(scalar3a)) then
          nsc3 = size(scalar3a, 1)*size(scalar3a, 3)
          if (size(scalar3a, 2) /= 506) return
        end if
        if (nsc2 + nsc3 /= scalar_fields) return
      end if
    end if
    if (.not. associated(l%active_latitudes) .or. .not. associated(l%process_of_latitude)) return
    if (.not. associated(l%output_block_offset) .or. .not. associated(l%inverse_wave_latitude_offset)) return
    if (lbound(l%active_latitudes, 1) > 0 .or. ubound(l%active_latitudes, 1) < 21) return
    if (l%active_latitudes(wave) /= 16) return
    if (size(l%process_of_latitude) < 32 .or. lbound(l%process_of_latitude, 1) /= 1) return
    if (lbound(l%output_block_offset, 1) < 0 .or. ubound(l%output_block_offset, 1) > 65536) return
    if (lbound(l%inverse_wave_latitude_offset, 1) < 0 .or. ubound(l%inverse_wave_latitude_offset, 1) > 4096) return
    if (lbound(l%inverse_wave_latitude_offset, 2) /= 1 .or. size(l%inverse_wave_latitude_offset, 2) < 32) return
    if (.not. transform_environment_ready()) return
    rows = t%maximum_degree + 4
    allocate (work(rows, internal_columns), epsilon(0:23), anti(output_leading, 16), sym(output_leading, 16), &
              active(0:21), process_offset(0:ubound(l%output_block_offset, 1)), &
              wave_offset(0:ubound(l%inverse_wave_latitude_offset, 1), 32), stat=alloc_status)
    if (alloc_status /= 0) then
      status = 1; return
    end if
    work = 0.0_real64; anti = 0.0_real64; sym = 0.0_real64
    active = l%active_latitudes(0:21)
    process_offset = 0
    source_process_lower = lbound(l%output_block_offset, 1)
    process_offset(source_process_lower:) = l%output_block_offset
    wave_offset = 0
    source_wave_lower = lbound(l%inverse_wave_latitude_offset, 1)
    wave_offset(source_wave_lower:, :) = l%inverse_wave_latitude_offset(:, 1:32)
    do j = 0, wave - 1
      epsilon(j) = 0.0_real64
    end do
    do j = wave, 23
      epsilon(j) = p%epsilon_values(start_coefficient + j)
    end do
    if (wind_fields > 0) then
      call pack_fields(vorticity, wind_fields, work(:, 1:2*wind_fields))
      call pack_fields(divergence, wind_fields, work(:, 2*wind_fields + 1:4*wind_fields))
      call vorticity_divergence_to_wind(t, wave, wind_fields, epsilon, work(:, 1:2*wind_fields), &
                                        work(:, 2*wind_fields + 1:4*wind_fields), work(:, 4*wind_fields + 1:6*wind_fields), &
                                        work(:, 6*wind_fields + 1:8*wind_fields), status)
      if (status /= 0) return
    end if
    first_column = 8*wind_fields + 1
    if (scalar_fields > 0) then
      if (present(scalars)) then
        call pack_fields(scalars, scalar_fields, work(:, first_column:first_column + 2*scalar_fields - 1))
      else
        if (nsc2 > 0) then
          call pack_fields(scalar2, nsc2, work(:, first_column:first_column + 2*nsc2 - 1))
          first_column = first_column + 2*nsc2
        end if
        if (nsc3 > 0) then
          do k = 1, size(scalar3a, 3)
            c = size(scalar3a, 1)
            call pack_fields(scalar3a(:, :, k), c, work(:, first_column:first_column + 2*c - 1))
            first_column = first_column + 2*c
          end do
        end if
      end if
    end if
    if (derivative_fields > 0) then
      first_column = 8*wind_fields + 1
      last_column = first_column + 2*scalar_fields - 1
      call spectral_north_south_derivative(t, wave, scalar_fields, epsilon, work(:, first_column:last_column), &
                                           work(:, last_column + 1:last_column + 2*derivative_fields), status)
      if (status /= 0) return
    end if
    first_column = 1
    if (.not. p%keep_vorticity) first_column = first_column + 2*wind_fields
    if (.not. p%keep_divergence) first_column = first_column + 2*wind_fields
    last_column = first_column + 2*output_fields - 1
    c = 2*output_fields; if (wave == 0) c = c/2
    call reconstruct_legendre_wave(t, wave, local_wave, 2*output_fields, c, output_fields, 1_int32, 16_int32, &
                                   work(:, first_column:last_column), anti, sym, status)
    if (status /= 0) return
    call reconstruct_fourier_hemispheres(output_fields, wave, local_wave, 16_int32, active, l%process_of_latitude, &
                                         process_offset, wave_offset, anti, sym, packed, status)
  contains
    !> Copy raw field pairs in descending degree order and set source boundary rows.
    subroutine pack_fields(input, fields, output)
      real(real64), intent(in) :: input(:, :)
      integer, intent(in) :: fields
      real(real64), intent(inout) :: output(:, :)
      integer :: f, n, column
      do f = 1, fields
        output(1, 2*f - 1) = 0.0_real64; output(2, 2*f - 1) = 0.0_real64
        output(1, 2*f) = 0.0_real64; output(2, 2*f) = 0.0_real64
        output(count + 3, 2*f - 1) = 0.0_real64; output(count + 3, 2*f) = 0.0_real64
        do n = 1, count
          column = base + 2*(count - n)
          output(n + 2, 2*f - 1) = input(f, column)
          output(n + 2, 2*f) = input(f, column + 1)
        end do
      end do
    end subroutine
  end subroutine
end module
