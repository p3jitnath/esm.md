! (C) Copyright 1989- ECMWF.
! Licensed under the Apache Licence, Version 2.0.
!> Compute the local water source from methane oxidation and photolysis.
!! The source calculations come from the complete selected physics/methox.S.
!! The caller supplies nearest-even rounding, gradual underflow and the
!! physical domain recorded in the methane solver contract. Providers are
!! readonly native records produced by the separate startup routines.
module forecast_native_methane_oxidation
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_ptr, c_intptr_t, c_loc
  use physical_constant_setup_port, only: forecast_physical_constants
  use ecmwf_physics_tail_fields_mod, only: methane_oxidation_parameter_record
  implicit none
  private
  public :: methox, methox_raw
  interface methox_raw
    module procedure methox
  end interface
  interface
    function public_log(x) bind(c, name='log') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_exp(x) bind(c, name='exp') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_pow(x, power) bind(c, name='pow') result(y)
      import c_double
      real(c_double), value :: x, power
      real(c_double) :: y
    end function
    function public_cos(x) bind(c, name='cos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Write humidity tendency in kg/(kg s) on the selected columns.
  !! Physical/parameters are readonly caller-owned records. PQ is humidity
  !! in kg/kg, PAP is pressure in Pa, and PTENQ is the INOUT tendency owner.
  !! All three arrays have shape (KLON,KLEV), with contiguous native storage.
  !! Only KIDIA:KFDIA is written; inactive cells keep their incoming bytes.
  !! The caller may alias the two readonly inputs. PTENQ must be disjoint
  !! from them, from both provider records and from the four scalar counts.
  !! KLON is 0:4096, KLEV is 0:512, KIDIA is 1:KLON+1 and KFDIA is 0:KLON.
  !! Return status 2 for unsupported metadata and 0 after completion. Empty
  !! selections perform no floating-point arithmetic and write no array.
  !! The source physical preconditions apply only to consumed branches:
  !! finite pressure 0:200000 Pa and finite humidity 0:0.1 kg/kg, with a
  !! finite negative temporary humidity allowed when both rates are inactive.
  subroutine methox(physical, parameters, kidia, kfdia, klon, klev, pq, ptenq, pap, status)
    type(forecast_physical_constants), target, intent(in) :: physical
    type(methane_oxidation_parameter_record), target, intent(in) :: parameters
    integer(int32), target, intent(in) :: kidia, kfdia, klon, klev
    real(real64), target, intent(in) :: pq(:, :), pap(:, :)
    real(real64), target, intent(inout) :: ptenq(:, :)
    integer(int32), intent(out) :: status
    integer(int32) :: column, level
    integer(int64) :: bytes
    integer(c_intptr_t) :: output_first, input_first
    real(real64) :: pressure, humidity, tendency, time_days, a, b
    real(real64), volatile :: power_four

    status = 2_int32
    if (klon < 0 .or. klon > 4096 .or. klev < 0 .or. klev > 512) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (any(shape(pq) /= [klon, klev]) .or. any(shape(pap) /= [klon, klev])) return
    if (any(shape(ptenq) /= [klon, klev])) return
    if (.not. is_contiguous(pq) .or. .not. is_contiguous(pap) .or. .not. is_contiguous(ptenq)) return
    if (kidia > kfdia .or. klev == 0) then
      status = 0_int32
      return
    end if
    bytes = 8_int64*int(klon, int64)*int(klev, int64)
    output_first = transfer(c_loc(ptenq(1, 1)), output_first)
    if (.not. valid_span(output_first, bytes)) return
    input_first = transfer(c_loc(pq(1, 1)), input_first)
    if (.not. disjoint(output_first, bytes, input_first, bytes)) return
    input_first = transfer(c_loc(pap(1, 1)), input_first)
    if (.not. disjoint(output_first, bytes, input_first, bytes)) return
    if (.not. disjoint(output_first, bytes, transfer(c_loc(physical), input_first), storage_size(physical, kind=int64)/8)) return
   if (.not. disjoint(output_first, bytes, transfer(c_loc(parameters), input_first), storage_size(parameters, kind=int64)/8)) return
    if (.not. disjoint(output_first, bytes, transfer(c_loc(kidia), input_first), storage_size(kidia, kind=int64)/8)) return
    if (.not. disjoint(output_first, bytes, transfer(c_loc(kfdia), input_first), storage_size(kfdia, kind=int64)/8)) return
    if (.not. disjoint(output_first, bytes, transfer(c_loc(klon), input_first), storage_size(klon, kind=int64)/8)) return
    if (.not. disjoint(output_first, bytes, transfer(c_loc(klev), input_first), storage_size(klev, kind=int64)/8)) return

    power_four = 4.0_real64
    do level = 1, klev
      do column = kidia, kfdia
        pressure = pap(column, level)
        humidity = pq(column, level)
        tendency = 0.0_real64
        if (pressure < parameters%rpbotox .and. humidity < parameters%rqlim) then
          if (pressure > parameters%rptopox) then
            a = pressure/parameters%rptopox
            a = public_log(a)
            a = public_pow(a, power_four)
            b = parameters%rpbotox/pressure
            b = public_log(b)
            a = a/b
            a = parameters%ralpha1*a
            a = 1.0_real64 + a
            time_days = 100.0_real64*a
          else
            time_days = 100.0_real64
          end if
          time_days = physical%rdayi*time_days
          a = parameters%rqlim - humidity
          a = a/time_days
          tendency = tendency + a
        end if
        if (pressure < parameters%rpbotph) then
          if (pressure > parameters%rptopph) then
            a = pressure/parameters%rpbotph
            a = public_log(a)
            a = physical%rpi*a
            a = a/parameters%rlogpph
            a = public_cos(a)
            a = 1.0_real64 + a
            a = parameters%ralpha3*a
            a = parameters%ralpha2 - a
            a = public_exp(a)
            a = a - 0.01_real64
            time_days = 1.0_real64/a
          else
            time_days = 3.0_real64
          end if
          time_days = physical%rdayi*time_days
          a = humidity/time_days
          tendency = tendency - a
        end if
        ptenq(column, level) = tendency
      end do
    end do
    status = 0_int32
  end subroutine methox

  !> Check a half-open address span with representable integer endpoints.
  logical function valid_span(first, bytes) result(valid)
    integer(c_intptr_t), intent(in) :: first
    integer(int64), intent(in) :: bytes
    valid = .false.
    if (bytes < 0_int64 .or. first <= 0_c_intptr_t) return
    if (first > huge(first) - bytes) return
    valid = .true.
  end function

  !> Reject any shared byte between a writable and readonly owner.
  logical function disjoint(first, nfirst, second, nsecond) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: nfirst, nsecond
    separate = .false.
    if (.not. valid_span(first, nfirst) .or. .not. valid_span(second, nsecond)) return
    separate = first + nfirst <= second .or. second + nsecond <= first
  end function
end module forecast_native_methane_oxidation
