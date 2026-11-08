!> Owned shortwave absorption calculations for all fourteen reduced bands.
!! Inputs are explicit native coefficient records and borrowed native layer views.
!! Molecular columns use the source scale of about 1e20 molecules/cm2. Optical
!! depths are dimensionless; selected solar coefficients have units W/m2.
module native_shortwave_band_calculations
  use iso_fortran_env, only: real64, int32, int64
  use native_absorption_records, only: shortwave_absorption_record
  use native_shortwave_gas_inputs
  use yomhook, only: lhook, dr_hook, jphook
  implicit none
  private
  public :: calculate_shortwave_band
  type :: band_coefficient_views
    real(real64), pointer :: lower(:, :) => null(), upper(:, :) => null()
    real(real64), pointer :: self(:, :) => null(), foreign(:, :) => null(), solar(:, :) => null()
    real(real64), pointer :: rayleigh_table(:, :) => null(), extra_lower(:) => null(), extra_upper(:) => null()
    real(real64) :: rayleigh = 0.0_real64, ratio = 0.0_real64, scale = 0.0_real64, given_factor = 0.0_real64
    integer :: reference_layer = 0, lower_mixtures = 0, upper_mixtures = 0, points = 0
  end type
contains
  !> Compute a four-point pressure/temperature interpolation with ordered sums.
  function four_sum(table, row0, row1, stride, g, f00, f10, f01, f11, coefficient_first) result(value)
    real(real64), intent(in) :: table(:, :), f00, f10, f01, f11
    integer, intent(in) :: row0, row1, stride, g
    logical, intent(in) :: coefficient_first
    real(real64) :: value, p
    if (coefficient_first) then
      value = table(row0, g)*f00
      p = table(row0 + stride, g)*f10
      value = value + p
      p = table(row1, g)*f01
      value = value + p
      p = table(row1 + stride, g)*f11
    else
      value = f00*table(row0, g)
      p = f10*table(row0 + stride, g)
      value = value + p
      p = f01*table(row1, g)
      value = value + p
      p = f11*table(row1 + stride, g)
    end if
    value = value + p
  end function
  !> Interpolate one water-continuum coefficient and apply its density factor.
  function continuum(table, index, g, fraction, factor) result(value)
    real(real64), intent(in) :: table(:, :), fraction, factor
    integer, intent(in) :: index, g
    real(real64) :: value
    value = linear_continuum(table, index, g, fraction)
    value = factor*value
  end function
  function linear_continuum(table, index, g, fraction) result(value)
    real(real64), intent(in) :: table(:, :), fraction
    integer, intent(in) :: index, g
    real(real64) :: value
    value = table(index + 1, g) - table(index, g)
    value = fraction*value
    value = table(index, g) + value
  end function
  !> Evaluate a complete source band with lower then upper layer-major passes.
  !! The caller supplies 0..512 active levels within the native layer capacity,
  !! at most 4096 columns, all fourteen produced coefficient tables, and full
  !! sixteen-point output owners. Night columns and unused capacity are retained.
  !! The five gas coordinates are water, CO2, ozone, methane and oxygen.
  subroutine calculate_shortwave_band(band, coefficients, input, solar, taug, taur)
    integer, intent(in) :: band
    type(shortwave_absorption_record), intent(in), target :: coefficients
    type(shortwave_layer_inputs), intent(in) :: input
    real(real64), intent(inout) :: solar(:, :), taug(:, :, :), taur(:, :, :)
    type(band_coefficient_views) :: table
    integer :: columns, region, k, i, g, mixtures, row0, row1, js, integer_fraction
    integer :: jp, jt, jt1, primary, secondary, shared_solar
    integer :: solar_layer(size(input%solar_cosine))
    real(real64) :: mixed, fraction, complement, scaled, ratio, oxygen_continuum
    real(real64) :: f00, f10, f01, f11, p, q, a, b, gas_depth, ray_depth, self_value, foreign_value
    real(real64), parameter :: oxygen_coefficient = transfer(int(z'3f3c8216c0000000', int64), 0.0_real64)
    logical :: mixture, write_solar, lower_pass, shared_selection, return_hook
    real(jphook) :: hook_handle
    return_hook = .false.
    if (band == 21) then
      if (lhook) call dr_hook("SRTM_TAUMOL21", 0, hook_handle)
      return_hook = lhook
    end if
    columns = size(input%solar_cosine)
    if (band == 21) then
      if (columns > 4096 .or. input%levels < 0) error stop "Unsupported band 21 shape"
      if (size(input%fac00, 2) > 512 .or. input%levels > size(input%fac00, 2)) error stop "Unsupported band 21 capacity"
    end if
    if (columns <= 0 .or. input%levels <= 0) then
      if (return_hook) call dr_hook("SRTM_TAUMOL21", 1, hook_handle)
      return
    end if
    call bind_band_coefficients(band, coefficients, table)
    shared_selection = band == 16 .or. band == 17 .or. band == 27 .or. band == 28 .or. band == 29
    solar_layer = input%tropopause
    shared_solar = input%levels
    do region = 1, 2
      lower_pass = region == 1
      do k = 1, input%levels
        do i = 1, columns
          if (input%solar_cosine(i) <= 0.0_real64) cycle
          if (lower_pass) then
            if (k > input%tropopause(i)) cycle
          else
            if (k <= input%tropopause(i)) cycle
          end if
          jp = 0; jt = 0; jt1 = 0
          if (lower_pass) then
            if (associated(table%lower)) then
              jp = input%pressure_index(i, k)
              jt = input%temperature_index(i, k)
              jt1 = input%next_temperature_index(i, k)
            end if
          else
            if (associated(table%upper)) then
              jp = input%pressure_index(i, k)
              jt = input%temperature_index(i, k)
              jt1 = input%next_temperature_index(i, k)
            end if
          end if
          write_solar = .false.
          if (shared_selection) then
            if (.not. lower_pass) then
              if (input%pressure_index(i, k - 1) < table%reference_layer) then
                if (jp >= table%reference_layer) shared_solar = k
              end if
              write_solar = k == shared_solar
            end if
          elseif (lower_pass) then
            if (band /= 26) then
              if (jp < table%reference_layer) then
                if (input%pressure_index(i, k + 1) >= table%reference_layer) &
                  solar_layer(i) = min(k + 1, input%tropopause(i))
              end if
            end if
            write_solar = k == solar_layer(i)
          end if
          f00 = 0.0_real64; f10 = 0.0_real64; f01 = 0.0_real64; f11 = 0.0_real64
          if ((lower_pass .and. associated(table%lower)) .or. (.not. lower_pass .and. associated(table%upper))) then
            f00 = input%fac00(i, k); f10 = input%fac10(i, k)
            f01 = input%fac01(i, k); f11 = input%fac11(i, k)
          end if
          mixture = .false.
          primary = water_column; secondary = carbon_dioxide_column
          if (lower_pass) then
mixture = band == 16 .or. band == 17 .or. band == 18 .or. band == 19 .or. band == 21 .or. band == 22 .or. band == 24 .or. band == 28
          else
            mixture = band == 17 .or. band == 21 .or. band == 28
          end if
          if (band == 16 .or. band == 18) secondary = methane_column
          if (band == 22 .or. band == 24 .or. band == 28) secondary = oxygen_column
          if (band == 28) primary = ozone_column
          fraction = 0.0_real64; complement = 1.0_real64; js = 1
          mixed = 0.0_real64
          if (mixture) then
            ratio = table%ratio
            if (band == 22) ratio = 1.6_real64*ratio
            p = ratio*input%gas(i, k, secondary)
            mixed = input%gas(i, k, primary) + p
            fraction = input%gas(i, k, primary)/mixed
            if (fraction >= input%mixture_cap(i)) fraction = input%mixture_cap(i)
            if (lower_pass) then
              scaled = 8.0_real64*fraction
            else
              scaled = 4.0_real64*fraction
            end if
            integer_fraction = int(scaled, int32)
            js = integer_fraction + 1
            fraction = scaled - real(integer_fraction, real64)
            complement = 1.0_real64 - fraction
          end if
          if (lower_pass) then
            mixtures = table%lower_mixtures
            row0 = ((jp - 1)*5 + jt - 1)*mixtures + js
            row1 = (jp*5 + jt1 - 1)*mixtures + js
          else
            mixtures = table%upper_mixtures
            row0 = ((jp - 13)*5 + jt - 1)*mixtures + js
            row1 = ((jp - 12)*5 + jt1 - 1)*mixtures + js
          end if
          if (associated(table%rayleigh_table)) then
            ray_depth = 0.0_real64
          else
            ray_depth = input%molecules(i, k)*table%rayleigh
          end if
          oxygen_continuum = 0.0_real64
          if (band == 22) then
            oxygen_continuum = oxygen_coefficient*input%gas(i, k, oxygen_column)
            oxygen_continuum = oxygen_continuum/700.0_real64
          end if
          do g = 1, table%points
            if (mixture) then
              if (lower_pass) then
                a = four_sum(table%lower, row0, row1, mixtures, g, f00, f10, f01, f11, .true.)
                b = four_sum(table%lower, row0 + 1, row1 + 1, mixtures, g, f00, f10, f01, f11, .true.)
              else
                a = four_sum(table%upper, row0, row1, mixtures, g, f00, f10, f01, f11, .true.)
                b = four_sum(table%upper, row0 + 1, row1 + 1, mixtures, g, f00, f10, f01, f11, .true.)
              end if
              a = complement*a
              b = fraction*b
              a = a + b
              gas_depth = mixed*a
            else
              a = 0.0_real64
              if (lower_pass) then
                if (associated(table%lower)) a = four_sum(table%lower, row0, row1, 1, g, f00, f10, f01, f11, .false.)
              else
                if (associated(table%upper)) a = four_sum(table%upper, row0, row1, 1, g, f00, f10, f01, f11, .false.)
              end if
              select case (band)
              case (16, 18)
                gas_depth = input%gas(i, k, methane_column)*a
              case (19)
                gas_depth = input%gas(i, k, carbon_dioxide_column)*a
              case (20, 23, 25, 29)
                gas_depth = 0.0_real64
                if (band == 25 .and. lower_pass) gas_depth = input%gas(i, k, water_column)*a
              case (22)
                p = input%gas(i, k, oxygen_column)*1.6_real64
                gas_depth = p*a
              case (24)
                gas_depth = input%gas(i, k, oxygen_column)*a
              case (26)
                gas_depth = 0.0_real64
              case (27)
                gas_depth = input%gas(i, k, ozone_column)*a
              end select
            end if
            self_value = 0.0_real64; foreign_value = 0.0_real64
            if (lower_pass) then
              if (associated(table%self)) self_value = continuum(table%self, input%self_index(i, k), g, &
                                                                 input%self_fraction(i, k), input%self_factor(i, k))
              if (associated(table%foreign)) foreign_value = continuum(table%foreign, input%foreign_index(i, k), g, &
                                                                       input%foreign_fraction(i, k), input%foreign_factor(i, k))
              select case (band)
              case (16, 17, 18, 19, 21, 22)
                p = self_value + foreign_value
                p = input%gas(i, k, water_column)*p
                gas_depth = gas_depth + p
              case (20, 29)
                p = a + self_value
                p = p + foreign_value
                gas_depth = input%gas(i, k, water_column)*p
                if (band == 20) then
                  p = input%gas(i, k, methane_column)*table%extra_lower(g)
                else
                  p = input%gas(i, k, carbon_dioxide_column)*table%extra_lower(g)
                end if
                gas_depth = gas_depth + p
              case (23)
                p = table%given_factor*a
                p = p + self_value
                p = p + foreign_value
                gas_depth = input%gas(i, k, water_column)*p
              case (24)
                p = input%gas(i, k, ozone_column)*table%extra_lower(g)
                gas_depth = gas_depth + p
                p = self_value + foreign_value
                p = input%gas(i, k, water_column)*p
                gas_depth = gas_depth + p
              case (25)
                p = input%gas(i, k, ozone_column)*table%extra_lower(g)
                gas_depth = gas_depth + p
              end select
            else
              if (band == 17 .or. band == 20 .or. band == 21) then
                foreign_value = linear_continuum(table%foreign, input%foreign_index(i, k), g, &
                                                 input%foreign_fraction(i, k))
                if (band == 20) then
                  p = a
                  q = input%foreign_factor(i, k)*foreign_value
                  p = p + q
                  gas_depth = input%gas(i, k, water_column)*p
                  p = input%gas(i, k, methane_column)*table%extra_lower(g)
                  gas_depth = gas_depth + p
                else
                  p = input%gas(i, k, water_column)*input%foreign_factor(i, k)
                  p = p*foreign_value
                  gas_depth = gas_depth + p
                end if
              end if
              if (band == 23) gas_depth = 0.0_real64
              if (band == 24 .or. band == 25) then
                p = input%gas(i, k, ozone_column)*table%extra_upper(g)
                if (band == 24) then
                  gas_depth = gas_depth + p
                else
                  gas_depth = p
                end if
              end if
              if (band == 29) then
                gas_depth = input%gas(i, k, carbon_dioxide_column)*a
                p = input%gas(i, k, water_column)*table%extra_upper(g)
                gas_depth = gas_depth + p
              end if
            end if
            if (band == 22) gas_depth = gas_depth + oxygen_continuum
            if (associated(table%rayleigh_table)) then
              if (band == 24 .and. lower_pass) then
                p = table%rayleigh_table(g, js + 1) - table%rayleigh_table(g, js)
                p = fraction*p
                p = table%rayleigh_table(g, js) + p
              elseif (band == 24) then
                p = coefficients%b24_raylbc(g)
              else
                p = table%rayleigh_table(g, 1)
              end if
              ray_depth = input%molecules(i, k)*p
            end if
            if (band == 26 .and. lower_pass .and. write_solar) solar(i, g) = table%solar(g, 1)
            taug(i, k, g) = gas_depth
            if (band == 20 .or. band == 21) taur(i, k, g) = ray_depth
            if (write_solar .and. band /= 26) then
              if (size(table%solar, 2) > 1) then
                p = table%solar(g, js + 1) - table%solar(g, js)
                p = fraction*p
                p = table%solar(g, js) + p
              else
                p = table%solar(g, 1)
              end if
              if (band == 27) p = table%scale*p
              solar(i, g) = p
            end if
            if (band /= 20 .and. band /= 21) taur(i, k, g) = ray_depth
          end do
        end do
      end do
    end do
    if (return_hook) call dr_hook("SRTM_TAUMOL21", 1, hook_handle)
  end subroutine
  !> Join compiler-native coefficient arrays without copying their payloads.
  subroutine bind_band_coefficients(band, coefficients, view)
    integer, intent(in) :: band
    type(shortwave_absorption_record), intent(in), target :: coefficients
    type(band_coefficient_views), intent(out) :: view
    view%points = coefficients%ng(band)
    view%lower_mixtures = coefficients%nspa(band)
    view%upper_mixtures = coefficients%nspb(band)
    select case (band)
    case (16)
      view%lower(1:585, 1:16) => coefficients%b16_kac
      view%upper(1:235, 1:16) => coefficients%b16_kbc
      view%self(1:10, 1:16) => coefficients%b16_selfrefc
      view%foreign(1:3, 1:16) => coefficients%b16_forrefc
      view%solar(1:16, 1:1) => coefficients%b16_sfluxrefc
      view%rayleigh = coefficients%b16_rayl
      view%ratio = coefficients%b16_strrat1
      view%reference_layer = coefficients%b16_layreffr
    case (17)
      view%lower(1:585, 1:16) => coefficients%b17_kac
      view%upper(1:1175, 1:16) => coefficients%b17_kbc
      view%self(1:10, 1:16) => coefficients%b17_selfrefc
      view%foreign(1:4, 1:16) => coefficients%b17_forrefc
      view%solar(1:16, 1:5) => coefficients%b17_sfluxrefc
      view%rayleigh = coefficients%b17_rayl
      view%ratio = coefficients%b17_strrat
      view%reference_layer = coefficients%b17_layreffr
    case (18)
      view%lower(1:585, 1:16) => coefficients%b18_kac
      view%upper(1:235, 1:16) => coefficients%b18_kbc
      view%self(1:10, 1:16) => coefficients%b18_selfrefc
      view%foreign(1:3, 1:16) => coefficients%b18_forrefc
      view%solar(1:16, 1:9) => coefficients%b18_sfluxrefc
      view%rayleigh = coefficients%b18_rayl
      view%ratio = coefficients%b18_strrat
      view%reference_layer = coefficients%b18_layreffr
    case (19)
      view%lower(1:585, 1:16) => coefficients%b19_kac
      view%upper(1:235, 1:16) => coefficients%b19_kbc
      view%self(1:10, 1:16) => coefficients%b19_selfrefc
      view%foreign(1:3, 1:16) => coefficients%b19_forrefc
      view%solar(1:16, 1:9) => coefficients%b19_sfluxrefc
      view%rayleigh = coefficients%b19_rayl
      view%ratio = coefficients%b19_strrat
      view%reference_layer = coefficients%b19_layreffr
    case (20)
      view%lower(1:65, 1:16) => coefficients%b20_kac
      view%upper(1:235, 1:16) => coefficients%b20_kbc
      view%self(1:10, 1:16) => coefficients%b20_selfrefc
      view%foreign(1:4, 1:16) => coefficients%b20_forrefc
      view%solar(1:16, 1:1) => coefficients%b20_sfluxrefc
      view%extra_lower => coefficients%b20_absch4c
      view%rayleigh = coefficients%b20_rayl
      view%reference_layer = coefficients%b20_layreffr
    case (21)
      view%lower(1:585, 1:16) => coefficients%b21_kac
      view%upper(1:1175, 1:16) => coefficients%b21_kbc
      view%self(1:10, 1:16) => coefficients%b21_selfrefc
      view%foreign(1:4, 1:16) => coefficients%b21_forrefc
      view%solar(1:16, 1:9) => coefficients%b21_sfluxrefc
      view%rayleigh = coefficients%b21_rayl
      view%ratio = coefficients%b21_strrat
      view%reference_layer = coefficients%b21_layreffr
    case (22)
      view%lower(1:585, 1:16) => coefficients%b22_kac
      view%upper(1:235, 1:16) => coefficients%b22_kbc
      view%self(1:10, 1:16) => coefficients%b22_selfrefc
      view%foreign(1:3, 1:16) => coefficients%b22_forrefc
      view%solar(1:16, 1:9) => coefficients%b22_sfluxrefc
      view%rayleigh = coefficients%b22_rayl
      view%ratio = coefficients%b22_strrat
      view%reference_layer = coefficients%b22_layreffr
    case (23)
      view%lower(1:65, 1:16) => coefficients%b23_kac
      view%self(1:10, 1:16) => coefficients%b23_selfrefc
      view%foreign(1:3, 1:16) => coefficients%b23_forrefc
      view%solar(1:16, 1:1) => coefficients%b23_sfluxrefc
      view%rayleigh_table(1:16, 1:1) => coefficients%b23_raylc
      view%given_factor = coefficients%b23_givfac
      view%reference_layer = coefficients%b23_layreffr
    case (24)
      view%lower(1:585, 1:16) => coefficients%b24_kac
      view%upper(1:235, 1:16) => coefficients%b24_kbc
      view%self(1:10, 1:16) => coefficients%b24_selfrefc
      view%foreign(1:3, 1:16) => coefficients%b24_forrefc
      view%solar(1:16, 1:9) => coefficients%b24_sfluxrefc
      view%extra_lower => coefficients%b24_abso3ac
      view%extra_upper => coefficients%b24_abso3bc
      view%rayleigh_table => coefficients%b24_raylac
      view%ratio = coefficients%b24_strrat
      view%reference_layer = coefficients%b24_layreffr
    case (25)
      view%lower(1:65, 1:16) => coefficients%b25_kac
      view%solar(1:16, 1:1) => coefficients%b25_sfluxrefc
      view%extra_lower => coefficients%b25_abso3ac
      view%extra_upper => coefficients%b25_abso3bc
      view%rayleigh_table(1:16, 1:1) => coefficients%b25_raylc
      view%reference_layer = coefficients%b25_layreffr
    case (26)
      view%solar(1:16, 1:1) => coefficients%b26_sfluxrefc
      view%rayleigh_table(1:16, 1:1) => coefficients%b26_raylc
    case (27)
      view%lower(1:65, 1:16) => coefficients%b27_kac
      view%upper(1:235, 1:16) => coefficients%b27_kbc
      view%solar(1:16, 1:1) => coefficients%b27_sfluxrefc
      view%rayleigh_table(1:16, 1:1) => coefficients%b27_raylc
      view%scale = coefficients%b27_scalekur
      view%reference_layer = coefficients%b27_layreffr
    case (28)
      view%lower(1:585, 1:16) => coefficients%b28_kac
      view%upper(1:1175, 1:16) => coefficients%b28_kbc
      view%solar(1:16, 1:5) => coefficients%b28_sfluxrefc
      view%rayleigh = coefficients%b28_rayl
      view%ratio = coefficients%b28_strrat
      view%reference_layer = coefficients%b28_layreffr
    case (29)
      view%lower(1:65, 1:16) => coefficients%b29_kac
      view%upper(1:235, 1:16) => coefficients%b29_kbc
      view%self(1:10, 1:16) => coefficients%b29_selfrefc
      view%foreign(1:4, 1:16) => coefficients%b29_forrefc
      view%solar(1:16, 1:1) => coefficients%b29_sfluxrefc
      view%extra_lower => coefficients%b29_absco2c
      view%extra_upper => coefficients%b29_absh2oc
      view%rayleigh = coefficients%b29_rayl
      view%reference_layer = coefficients%b29_layreffr
    end select
  end subroutine
end module
