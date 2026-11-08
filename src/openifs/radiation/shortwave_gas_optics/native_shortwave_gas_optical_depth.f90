!> Complete owned shortwave band caller with one native workspace owner.
!! Each band is an owned numerical child. Coefficient tables remain readonly.
module native_shortwave_gas_optical_depth
  use iso_fortran_env, only: real64, int32, int64
  use native_absorption_records, only: shortwave_absorption_record
  use native_shortwave_gas_inputs, only: shortwave_layer_inputs
  use native_srtm_taumol16, only: srtm_taumol16
  use native_srtm_taumol17, only: srtm_taumol17
  use native_srtm_taumol18, only: srtm_taumol18
  use native_srtm_taumol19, only: srtm_taumol19
  use native_srtm_taumol20, only: srtm_taumol20
  use native_srtm_taumol21, only: srtm_taumol21
  use native_srtm_taumol22, only: srtm_taumol22
  use native_srtm_taumol23, only: srtm_taumol23
  use native_srtm_taumol24, only: srtm_taumol24
  use native_srtm_taumol25, only: srtm_taumol25
  use native_srtm_taumol26, only: srtm_taumol26
  use native_srtm_taumol27, only: srtm_taumol27
  use native_srtm_taumol28, only: srtm_taumol28
  use native_srtm_taumol29, only: srtm_taumol29
  implicit none
  private
  public :: srtm_gas_optical_depth
  interface
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
  !> Produce total gas/Rayleigh depth, scattering fraction and incoming solar.
  !! Optical arrays are (columns,layer_capacity,spectral_capacity), dimensionless.
  !! Solar is (columns,spectral_capacity), W/m2. Only daylight active cells in
  !! the sum of the fourteen produced band counts change. Other cells retain
  !! their incoming values. The caller proves every consumed solar cell is set.
  subroutine srtm_gas_optical_depth(coefficients, input, incoming_solar, optical_depth, scattering_fraction)
    type(shortwave_absorption_record), intent(in), target :: coefficients
    type(shortwave_layer_inputs), intent(in) :: input
    real(real64), intent(inout) :: incoming_solar(:, :), optical_depth(:, :, :), scattering_fraction(:, :, :)
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: gas(:, :, :), rayleigh(:, :, :), solar(:, :)
    integer(int64) :: plane_cells, solar_cells, workspace_cells
    integer :: columns, levels, band, point, i, k, offset, allocation_status
    real(real64) :: total
    logical :: has_daylight
    columns = size(input%solar_cosine); levels = input%levels
    if (columns <= 0) return
    has_daylight = .false.
    do i = 1, columns
      if (input%solar_cosine(i) > 0.0_real64) then
        has_daylight = .true.
        exit
      end if
    end do
    if (.not. has_daylight) return
    plane_cells = int(columns, int64)*int(levels, int64)*16_int64
    solar_cells = int(columns, int64)*16_int64
    workspace_cells = plane_cells*2_int64 + solar_cells
    allocate (workspace(workspace_cells), stat=allocation_status)
    if (allocation_status /= 0) call public_abort()
    gas(1:columns, 1:levels, 1:16) => workspace(1:plane_cells)
    rayleigh(1:columns, 1:levels, 1:16) => workspace(plane_cells + 1:plane_cells*2)
    solar(1:columns, 1:16) => workspace(plane_cells*2 + 1:workspace_cells)
    offset = 0
    do band = 16, 29
      select case (band)
      case (16)
        call srtm_taumol16(coefficients, input, solar, gas, rayleigh)
      case (17)
        call srtm_taumol17(coefficients, input, solar, gas, rayleigh)
      case (18)
        call srtm_taumol18(coefficients, input, solar, gas, rayleigh)
      case (19)
        call srtm_taumol19(coefficients, input, solar, gas, rayleigh)
      case (20)
        call srtm_taumol20(coefficients, input, solar, gas, rayleigh)
      case (21)
        call srtm_taumol21(coefficients, input, solar, gas, rayleigh)
      case (22)
        call srtm_taumol22(coefficients, input, solar, gas, rayleigh)
      case (23)
        call srtm_taumol23(coefficients, input, solar, gas, rayleigh)
      case (24)
        call srtm_taumol24(coefficients, input, solar, gas, rayleigh)
      case (25)
        call srtm_taumol25(coefficients, input, solar, gas, rayleigh)
      case (26)
        call srtm_taumol26(coefficients, input, solar, gas, rayleigh)
      case (27)
        call srtm_taumol27(coefficients, input, solar, gas, rayleigh)
      case (28)
        call srtm_taumol28(coefficients, input, solar, gas, rayleigh)
      case (29)
        call srtm_taumol29(coefficients, input, solar, gas, rayleigh)
      end select
      do point = 1, coefficients%ng(band)
        do i = 1, columns
          if (input%solar_cosine(i) > 0.0_real64) incoming_solar(i, offset + point) = solar(i, point)
        end do
        do k = 1, levels
          do i = 1, columns
            if (input%solar_cosine(i) <= 0.0_real64) cycle
            total = rayleigh(i, k, point) + gas(i, k, point)
            optical_depth(i, k, offset + point) = total
            scattering_fraction(i, k, offset + point) = rayleigh(i, k, point)/total
          end do
        end do
      end do
      offset = offset + coefficients%ng(band)
    end do
    nullify (gas, rayleigh, solar)
    deallocate (workspace)
  end subroutine
end module
