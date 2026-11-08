!> Port the complete selected CPTAVE calculations from land_parameter_numerical_children.S.
module cptave_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: cptave
  interface
    function selected_log(value) bind(c, name="log") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_log
    function selected_pow(base, exponent) bind(c, name="pow") result(answer)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: answer
    end function selected_pow
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Set the three coarse, medium and fine soil texture classes.
  !! All six real64 output arrays contain exactly three elements.
  !! PTHESAT, PTHECAP and PTHEPWP are water volume fractions in m3/m3.
  !! PCKSAT is saturated hydraulic conductivity in m/s; PSISAT is water potential in m.
  !! PB is the dimensionless Clapp-Hornberger exponent. All six owners are disjoint.
  !! The selected caller supplies round-to-nearest, gradual underflow and aligned native arrays.
  subroutine cptave(pthesat, pthecap, pthepwp, pcksat, psisat, pb)
    real(real64), intent(out) :: pthesat(:), pthecap(:), pthepwp(:), pcksat(:), psisat(:), pb(:)
    real(real64), volatile :: tables(11, 4), constants(5)
    real(real64) :: a, b, c, factor, psi_wilt, psi_capacity, log_ratio, exponent
    integer(int32) :: texture
    if (size(pthesat) /= 3 .or. size(pthecap) /= 3 .or. size(pthepwp) /= 3) call reject_contract()
    if (size(pcksat) /= 3 .or. size(psisat) /= 3 .or. size(pb) /= 3) call reject_contract()
    tables(:, 1) = [0.395_real64, 0.410_real64, 0.435_real64, 0.485_real64, 0.451_real64, &
                    0.420_real64, 0.477_real64, 0.476_real64, 0.426_real64, 0.492_real64, 0.482_real64]
    tables(:, 2) = [0.093_real64, 0.172_real64, 0.229_real64, 0.341_real64, 0.288_real64, &
                    0.280_real64, 0.345_real64, 0.317_real64, 0.311_real64, 0.338_real64, 0.384_real64]
    tables(:, 3) = [0.033_real64, 0.058_real64, 0.100_real64, 0.153_real64, 0.145_real64, &
                    0.157_real64, 0.201_real64, 0.187_real64, 0.188_real64, 0.207_real64, 0.250_real64]
    tables(:, 4) = [176e-6_real64, 156e-6_real64, 34.7e-6_real64, 7.20e-6_real64, 6.95e-6_real64, &
                    6.30e-6_real64, 1.70e-6_real64, 2.45e-6_real64, 2.16e-6_real64, 1.03e-6_real64, 1.28e-6_real64]
    constants = [1000.0_real64, 100.0_real64, 9.8_real64, -15.0_real64, -0.33_real64]
    call average_classes(tables(:, 1), pthesat)
    call average_classes(tables(:, 2), pthecap)
    call average_classes(tables(:, 3), pthepwp)
    call average_classes(tables(:, 4), pcksat)
    a = constants(1)
    b = a*constants(2)
    a = a*constants(3)
    factor = b/a
    psi_wilt = constants(4)*factor
    psi_capacity = constants(5)*factor
    a = psi_capacity/psi_wilt
    log_ratio = selected_log(a)
    do texture = 1, 3
      a = pthepwp(texture)/pthecap(texture)
      a = selected_log(a)
      exponent = log_ratio/a
      pb(texture) = exponent
      a = pthesat(texture)/pthecap(texture)
      a = selected_pow(a, exponent)
      psisat(texture) = psi_capacity/a
    end do
  end subroutine cptave

  !> Average eleven input texture values into three broad classes in source order.
  subroutine average_classes(table, texture)
    real(real64), intent(in) :: table(:)
    real(real64), intent(out) :: texture(:)
    real(real64), volatile :: a, b
    a = table(1)
    b = table(2)
    a = a + b
    a = a + table(3)
    a = a + table(6)
    texture(1) = a/4.0_real64
    a = table(4)
    b = table(5)
    a = a + b
    a = a + table(7)
    a = a + table(8)
    texture(2) = a/4.0_real64
    a = table(9)
    b = table(10)
    a = a + b
    a = a + table(11)
    texture(3) = a/3.0_real64
  end subroutine average_classes
end module cptave_mod

!> Port the complete selected SRFROOTFR calculations from land_parameter_numerical_children.S.
module srfrootfr_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: srfrootfr
  interface
    function selected_exp(value) bind(c, name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_exp
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Set root fractions for four soil layers and twenty vegetation types.
  !! KLEVS=4 and KVTYPES=20 are the selected source shape.
  !! PSDEPTH has four real64 layer thicknesses in m; PROOTF has shape (4,20).
  !! PROOTF is dimensionless and has a separate complete owner from PSDEPTH.
  !! Types eight, twelve, fourteen, fifteen and twenty finish as [1,0,0,0].
  !! Type eight executes every source exponential calculation before that final override.
  !! The selected caller supplies round-to-nearest, gradual underflow and aligned native arrays.
  subroutine srfrootfr(klevs, kvtypes, psdepth, prootf)
    integer(int32), intent(in) :: klevs, kvtypes
    real(real64), intent(in) :: psdepth(:)
    real(real64), intent(out) :: prootf(:, :)
    real(real64), volatile :: aa(20), bb(20)
    real(real64) :: cumulative_depth(4), a, b, first_rate, second_rate
    integer(int32) :: vegetation, layer, index
    integer(int32), parameter :: override(5) = [8, 12, 14, 15, 20]
    if (klevs /= 4_int32 .or. kvtypes /= 20_int32) call reject_contract()
    if (size(psdepth) /= 4 .or. any(shape(prootf) /= [4, 20])) call reject_contract()
    aa = [5.558_real64, 10.739_real64, 6.706_real64, 7.066_real64, 5.990_real64, &
          7.344_real64, 8.235_real64, 4.372_real64, 8.992_real64, 5.558_real64, &
          4.372_real64, 0.0_real64, 7.344_real64, 0.0_real64, 0.0_real64, &
          6.326_real64, 6.326_real64, 4.453_real64, 4.453_real64, 0.0_real64]
    bb = [2.614_real64, 2.608_real64, 2.175_real64, 1.953_real64, 1.955_real64, &
          1.303_real64, 1.627_real64, 0.978_real64, 8.992_real64, 2.614_real64, &
          0.978_real64, 0.0_real64, 1.303_real64, 0.0_real64, 0.0_real64, &
          1.567_real64, 1.567_real64, 1.631_real64, 1.631_real64, 0.0_real64]
    a = psdepth(1)
    cumulative_depth(1) = a
    do layer = 2, 4
      a = a + psdepth(layer)
      cumulative_depth(layer) = a
    end do
    do vegetation = 1, 20
      first_rate = aa(vegetation)
      second_rate = bb(vegetation)
      if (first_rate <= 0.01_real64) then
        do layer = 1, 4
          prootf(layer, vegetation) = 0.0_real64
        end do
        cycle
      end if
      a = -first_rate
      a = a*cumulative_depth(1)
      b = selected_exp(a)
      a = -second_rate
      a = a*cumulative_depth(1)
      a = selected_exp(a)
      a = b + a
      a = 0.5_real64*a
      a = 1.0_real64 - a
      prootf(1, vegetation) = a
      do layer = 2, 3
        a = -first_rate
        a = a*cumulative_depth(layer - 1)
        b = selected_exp(a)
        a = -second_rate
        a = a*cumulative_depth(layer - 1)
        a = selected_exp(a)
        b = b + a
        a = -first_rate
        a = a*cumulative_depth(layer)
        a = selected_exp(a)
        b = b - a
        a = -second_rate
        a = a*cumulative_depth(layer)
        a = selected_exp(a)
        b = b - a
        a = 0.5_real64*b
        prootf(layer, vegetation) = a
      end do
      a = 0.0_real64
      do layer = 1, 3
        a = a + prootf(layer, vegetation)
      end do
      prootf(4, vegetation) = 1.0_real64 - a
    end do
    do index = 1, 5
      vegetation = override(index)
      prootf(1, vegetation) = 1.0_real64
      prootf(2, vegetation) = 0.0_real64
      prootf(3, vegetation) = 0.0_real64
      prootf(4, vegetation) = 0.0_real64
    end do
  end subroutine srfrootfr
end module srfrootfr_mod
