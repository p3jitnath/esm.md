!> Complete original EC_PHYS wave-model surface arithmetic.
module md2asm_wave_surface_fields
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: calculate_runtime_wave_surface_fields
  interface
    function public_log(x) bind(C, name="log") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_pow(x, p) bind(C, name="pow") result(y)
      import :: c_double
      real(c_double), value :: x, p
      real(c_double) :: y
    end function
  end interface
contains
!> Calculate selected-column wind, density, gust, ice, lake and currents.
!! Inputs use pressure Pa, temperature K, humidity kg/kg, stress N/m2,
!! heat flux W/m2 and moisture flux kg/m2/s. Returned winds/currents use m/s,
!! density kg/m3 and fractions1; mode2 returns dimensionless wind directions.
!! Every array is a native full-column view; nonunit strides are supported.
!! Only first:last changes. Optional views are consumed only on their source
!! branch. The finite physical domain and disjoint writable owners are caller
!! requirements. Status2 refuses metadata before any public output store.
  subroutine calculate_runtime_wave_surface_fields(physical, columns, first, last, mode, neutral_winds, return_currents, missing, &
 pressure,temperature,humidity,wind_u,wind_v,density,gust,ice,lake,moisture_flux,heat_flux,land_mask,sea_ice,lake_fraction,status, &
                        stress_u, stress_v, neutral_u, neutral_v, input_current_u, input_current_v, roughness, current_u, current_v)
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: columns, first, last, mode
    logical, intent(in) :: neutral_winds, return_currents
    real(real64), intent(in) :: missing, pressure(:), temperature(:), humidity(:)
    real(real64), intent(inout) :: wind_u(:), wind_v(:), density(:), gust(:), ice(:), lake(:)
    real(real64), intent(in) :: moisture_flux(:), heat_flux(:), land_mask(:), sea_ice(:), lake_fraction(:)
 real(real64),intent(in),optional::stress_u(:),stress_v(:),neutral_u(:),neutral_v(:),input_current_u(:),input_current_v(:),roughness(:)
    real(real64), intent(inout), optional :: current_u(:), current_v(:)
    integer(int32), intent(out) :: status
    real(real64) :: rho, inverse_rho, u, v, a, c, speed, profile, buoyancy, value
    real(real64), volatile :: height_gravity
    real(real64), parameter :: minimum_speed = transfer(int(z'3F1A36E2EB1C432D', int64), 0.0_real64)
    real(real64), parameter :: one_third = transfer(int(z'3FD5555555555555', int64), 0.0_real64)
    integer :: j
    status = 2
    if (columns < 1 .or. columns > 128 .or. first < 1 .or. last < first .or. last > columns) return
    if (mode < 1 .or. mode > 3 .or. physical%initialized /= 1) return
 if(min(size(pressure),size(temperature),size(humidity),size(wind_u),size(wind_v),size(density),size(gust),size(ice),size(lake))<columns)return
    if (min(size(moisture_flux), size(heat_flux), size(land_mask), size(sea_ice), size(lake_fraction)) < columns) return
    if (mode /= 3 .or. .not. neutral_winds) then
      if (.not. present(stress_u) .or. .not. present(stress_v)) return
      if (min(size(stress_u), size(stress_v)) < columns) return
    end if
    if (mode == 3 .and. neutral_winds) then
      if (.not. present(neutral_u) .or. .not. present(neutral_v)) return
      if (min(size(neutral_u), size(neutral_v)) < columns) return
    end if
    if (return_currents .or. (mode == 3 .and. neutral_winds)) then
      if (.not. present(input_current_u) .or. .not. present(input_current_v)) return
      if (min(size(input_current_u), size(input_current_v)) < columns) return
    end if
    if (mode == 3 .and. .not. neutral_winds) then
      if (.not. present(roughness)) return
      if (size(roughness) < columns) return
    end if
    if (return_currents) then
      if (.not. present(current_u) .or. .not. present(current_v)) return
      if (min(size(current_u), size(current_v)) < columns) return
    end if
    height_gravity = 10.0_real64*physical%rg
    do j = first, last
      a = physical%rd*temperature(j)
      c = physical%retv*humidity(j); c = 1.0_real64 + c; a = a*c
      rho = pressure(j)/a; inverse_rho = 1.0_real64/rho
      if (mode == 3 .and. neutral_winds) then
        u = neutral_u(j) - input_current_u(j); v = neutral_v(j) - input_current_v(j)
      else
        u = stress_u(j); v = stress_v(j)
        if (mode /= 2) then
          u = u*inverse_rho; v = v*inverse_rho
        end if
        if (mode == 3) then
          a = height_gravity/roughness(j); profile = public_log(a); profile = profile/0.40_real64
        end if
        a = u*u; c = v*v; a = a + c
        if (mode == 2) then
          speed = public_pow(a, 0.5_real64)
        else
          speed = public_pow(a, 0.25_real64)
        end if
        speed = max(minimum_speed, speed)
        u = u/speed; v = v/speed
        if (mode == 3) then
          u = u*profile; v = v*profile
        end if
      end if
      wind_u(j) = u; wind_v(j) = v
      a = -physical%retv; a = a*moisture_flux(j)
      c = heat_flux(j)/physical%rcpd; c = c/temperature(j); a = a - c
      buoyancy = physical%rg*a; buoyancy = buoyancy*inverse_rho
      if (buoyancy > 0.0_real64) then
        a = 1000.0_real64*buoyancy; value = public_pow(a, one_third)
      else
        value = 0.0_real64
      end if
      density(j) = rho; gust(j) = value
      if (land_mask(j) <= 0.5_real64) then
        ice(j) = sea_ice(j)
      else
        ice(j) = missing
      end if
      lake(j) = lake_fraction(j)
      if (return_currents) then
        current_u(j) = input_current_u(j); current_v(j) = input_current_v(j)
      end if
    end do
    status = 0
  end subroutine
end module
