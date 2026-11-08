!> Complete source-selected cloud, freezing-level and precipitation diagnostics.
!! Physical and thermal constants are readonly canonical records. Arrays remain
!! caller-owned; only active output cells change. Temperature is K, pressure Pa,
!! condensates kg/kg, geopotential m2/s2, heights m and rain/snow rates kg/(m2 s).
module forecast_cloud_weather_diagnostics
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoecumf, only: TECUMF
  use forecast_tropopause_level, only: troplev
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event
  implicit none
  private
  public :: diag_clouds, diag_clouds_phase_sign
  interface diag_clouds_phase_sign
    module procedure diag_clouds
  end interface
  interface
    function public_exp(x) bind(C, name='exp') result(value)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_log(x) bind(C, name='log') result(value)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Diagnose the complete original35 argument roles with explicit constants.
  !! Arrays use columns first, full levels1:L and half levels1:L+1.
  !! PCONVIND and PZTWETB have at least two planes. Outputs are INOUT so
  !! inactive rows, extra planes and extra levels retain their incoming bytes.
  !! The caller supplies valid disjoint owners, nearest-even/gradual mode and
  !! source-admitted physical inputs. Status2 refuses metadata before stores;
  !! status1 reports native scratch allocation failure. Later child refusal
  !! propagates with preceding source stores visible; no rollback is applied.
  subroutine diag_clouds(physical, thermal, YDECUMF, KIDIA, KFDIA, KLON, KLEV, LDIAG_CL, &
                         LDCUM, KCBOT, KCTOP, PAP, PAPH, PGEO, PGEOH, PT, PQ, PL, PI, PA, PFPLCL, PFPLCN, &
                         PFPLSL, PFPLSN, PRAINFRAC_TOPRFZ, P2T, P2D, PCBASE, PCBASEA, PCTOPC, P0DEGL, &
                         PM10DEGL, PCONVIND, PPRECTYPE, PFZRA, PZTWETB, PTROPOTP, status, profile)
    type(forecast_physical_constants), intent(in) :: physical
    type(thermal_parameter_record), intent(in) :: thermal
    type(TECUMF), intent(inout) :: YDECUMF
    integer(int32), intent(in) :: KIDIA, KFDIA, KLON, KLEV
    logical, intent(in) :: LDIAG_CL, LDCUM(:)
    integer(int32), intent(in) :: KCBOT(:), KCTOP(:)
    real(real64), intent(in) :: PAP(:, :), PAPH(:, :), PGEO(:, :), PGEOH(:, :), PT(:, :), PQ(:, :)
    real(real64), intent(in) :: PL(:, :), PI(:, :), PA(:, :), PFPLCL(:, :), PFPLCN(:, :), PFPLSL(:, :), PFPLSN(:, :)
    real(real64), intent(in) :: PRAINFRAC_TOPRFZ(:), P2T(:), P2D(:)
    real(real64), intent(inout) :: PCBASE(:), PCBASEA(:), PCTOPC(:), P0DEGL(:), PM10DEGL(:)
    real(real64), intent(inout) :: PCONVIND(:, :), PPRECTYPE(:), PFZRA(:), PZTWETB(:, :), PTROPOTP(:)
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    logical, allocatable :: LLSTB(:, :)
    integer(int32), allocatable :: IC0L(:), ICM10L(:), ILTROP(:)
    real(real64), allocatable :: ZBASEC(:), ZBASES(:), ZTWETB(:, :)
    real(real64), volatile :: ZRG, ZTM10
    real(real64) :: ZP, ZA, ZTD8, ZTD7, ZDZ, ZQSICE, ZSUBSAT
    real(real64) :: ZRAIN, ZSNOW, ZTOT, ZRAINFRAC_SFC, term, other, numerator, denominator, hook_handle
    integer(int32) :: JL, JK, JKS, allocation_status
    status = 2_int32
    if (KLON < 1 .or. KLON > 4096 .or. KLEV < 3 .or. KLEV > 512) return
    if (KIDIA < 1 .or. KFDIA > KLON .or. KFDIA < KIDIA) return
    if (physical%initialized /= 1) return
    if (.not. is_contiguous(LDCUM)) return
    if (size(LDCUM) < KLON) return
    if (.not. is_contiguous(KCBOT)) return
    if (size(KCBOT) < KLON) return
    if (.not. is_contiguous(KCTOP)) return
    if (size(KCTOP) < KLON) return
    if (.not. is_contiguous(PRAINFRAC_TOPRFZ)) return
    if (size(PRAINFRAC_TOPRFZ) < KLON) return
    if (.not. is_contiguous(P2T)) return
    if (size(P2T) < KLON) return
    if (.not. is_contiguous(P2D)) return
    if (size(P2D) < KLON) return
    if (.not. is_contiguous(PCBASE)) return
    if (size(PCBASE) < KLON) return
    if (.not. is_contiguous(PCBASEA)) return
    if (size(PCBASEA) < KLON) return
    if (.not. is_contiguous(PCTOPC)) return
    if (size(PCTOPC) < KLON) return
    if (.not. is_contiguous(P0DEGL)) return
    if (size(P0DEGL) < KLON) return
    if (.not. is_contiguous(PM10DEGL)) return
    if (size(PM10DEGL) < KLON) return
    if (.not. is_contiguous(PPRECTYPE)) return
    if (size(PPRECTYPE) < KLON) return
    if (.not. is_contiguous(PFZRA)) return
    if (size(PFZRA) < KLON) return
    if (.not. is_contiguous(PTROPOTP)) return
    if (size(PTROPOTP) < KLON) return
    if (.not. is_contiguous(PAP)) return
    if (size(PAP, 1) /= KLON .or. size(PAP, 2) < KLEV) return
    if (.not. is_contiguous(PGEO)) return
    if (size(PGEO, 1) /= KLON .or. size(PGEO, 2) < KLEV) return
    if (.not. is_contiguous(PT)) return
    if (size(PT, 1) /= KLON .or. size(PT, 2) < KLEV) return
    if (.not. is_contiguous(PQ)) return
    if (size(PQ, 1) /= KLON .or. size(PQ, 2) < KLEV) return
    if (.not. is_contiguous(PL)) return
    if (size(PL, 1) /= KLON .or. size(PL, 2) < KLEV) return
    if (.not. is_contiguous(PI)) return
    if (size(PI, 1) /= KLON .or. size(PI, 2) < KLEV) return
    if (.not. is_contiguous(PA)) return
    if (size(PA, 1) /= KLON .or. size(PA, 2) < KLEV) return
    if (.not. is_contiguous(PAPH)) return
    if (size(PAPH, 1) /= KLON .or. size(PAPH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PGEOH)) return
    if (size(PGEOH, 1) /= KLON .or. size(PGEOH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFPLCL)) return
    if (size(PFPLCL, 1) /= KLON .or. size(PFPLCL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFPLCN)) return
    if (size(PFPLCN, 1) /= KLON .or. size(PFPLCN, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFPLSL)) return
    if (size(PFPLSL, 1) /= KLON .or. size(PFPLSL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFPLSN)) return
    if (size(PFPLSN, 1) /= KLON .or. size(PFPLSN, 2) < KLEV + 1) return
    if (.not. is_contiguous(PCONVIND)) return
    if (size(PCONVIND, 1) /= KLON .or. size(PCONVIND, 2) < 2) return
    if (.not. is_contiguous(PZTWETB)) return
    if (size(PZTWETB, 1) /= KLON .or. size(PZTWETB, 2) < 2) return
    if (LDIAG_CL) then
      if (YDECUMF%NJKT2 < 1 .or. YDECUMF%NJKT2 > KLEV) return
      if (YDECUMF%NJKT4 < 1 .or. YDECUMF%NJKT4 > KLEV) return
      if (YDECUMF%NJKT5 < 1 .or. YDECUMF%NJKT5 > KLEV) return
      if (YDECUMF%NJKT6 < 1 .or. YDECUMF%NJKT6 > KLEV) return
      do JL = KIDIA, KFDIA
        if (.not. LDCUM(JL)) cycle
        if (KCBOT(JL) < 1 .or. KCBOT(JL) > KLEV + 1) return
        if (KCTOP(JL) < 1 .or. KCTOP(JL) > KLEV + 1) return
      end do
    end if
    call transform_profile_event('DIAG_CLOUDS', 0_int32, hook_handle, profile)
    allocate (ZBASEC(KLON), ZBASES(KLON), LLSTB(KLON, 2), IC0L(KLON), ICM10L(KLON), &
              ILTROP(KLON), ZTWETB(KLON, KLEV + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if
    ZRG = 1.0_real64/physical%RG
    ZTM10 = physical%RTT - 10.0_real64
    do JL = KIDIA, KFDIA
      PCBASE(JL) = YDECUMF%RBASE0
      PCBASEA(JL) = YDECUMF%RBASE0
      PCTOPC(JL) = YDECUMF%RBASE0
      ZBASEC(JL) = YDECUMF%RBASE0
      ZBASES(JL) = YDECUMF%RBASE0
      P0DEGL(JL) = 0.0_real64
      PM10DEGL(JL) = 0.0_real64
      PPRECTYPE(JL) = 0.0_real64
      PFZRA(JL) = 0.0_real64
      PTROPOTP(JL) = 0.0_real64
      PCONVIND(JL, 1) = 0.0_real64
      PZTWETB(JL, 1) = 0.0_real64
      PCONVIND(JL, 2) = 0.0_real64
      PZTWETB(JL, 2) = 0.0_real64
    end do
    if (LDIAG_CL) then
      do JL = KIDIA, KFDIA
        LLSTB(JL, 1) = .true.
        LLSTB(JL, 2) = .true.
        IC0L(JL) = 0_int32
        ICM10L(JL) = 0_int32
        if (LDCUM(JL)) then
          JK = KCBOT(JL)
          ZBASEC(JL) = PGEOH(JL, JK)*ZRG
          JK = KCTOP(JL)
          PCTOPC(JL) = PGEOH(JL, JK)*ZRG
        end if
      end do
      do JK = KLEV - 1, YDECUMF%NJKT2, -1
        do JL = KIDIA, KFDIA
          if (LLSTB(JL, 1)) then
            if (PA(JL, JK) > 0.01_real64) then
              term = PL(JL, JK) + PI(JL, JK)
              if (term > 0.000001_real64) then
                ZBASES(JL) = PGEO(JL, JK)*ZRG
                LLSTB(JL, 1) = .false.
              end if
            end if
          end if
        end do
        do JL = KIDIA, KFDIA
          if (LLSTB(JL, 2)) then
            if (PA(JL, JK) > 0.5_real64) then
              PCBASEA(JL) = PGEO(JL, JK)*ZRG
              LLSTB(JL, 2) = .false.
            end if
          end if
        end do
        do JL = KIDIA, KFDIA
          if (IC0L(JL) < 2) then
            if (PT(JL, JK + 1) > physical%RTT .and. PT(JL, JK) <= physical%RTT) then
              numerator = physical%RTT - PT(JL, JK + 1)
              term = PGEO(JL, JK) - PGEO(JL, JK + 1)
              numerator = numerator*term
              denominator = PT(JL, JK) - PT(JL, JK + 1)
              denominator = source_minimum(-0.00000001_real64, denominator)
              ZDZ = numerator/denominator
              term = PGEO(JL, JK + 1) + ZDZ
              P0DEGL(JL) = term*ZRG
              IC0L(JL) = IC0L(JL) + 1
            end if
          end if
          if (ICM10L(JL) < 2) then
            if (PT(JL, JK + 1) > ZTM10 .and. PT(JL, JK) <= ZTM10) then
              numerator = ZTM10 - PT(JL, JK + 1)
              term = PGEO(JL, JK) - PGEO(JL, JK + 1)
              numerator = numerator*term
              denominator = PT(JL, JK) - PT(JL, JK + 1)
              denominator = source_minimum(-0.00000001_real64, denominator)
              ZDZ = numerator/denominator
              term = PGEO(JL, JK + 1) + ZDZ
              PM10DEGL(JL) = term*ZRG
              ICM10L(JL) = ICM10L(JL) + 1
            end if
          end if
        end do
      end do
      do JL = KIDIA, KFDIA
        PCBASE(JL) = ZBASES(JL)
        if (ZBASEC(JL) < YDECUMF%RBASE0 .and. ZBASES(JL) < YDECUMF%RBASE0) &
          PCBASE(JL) = source_minimum(ZBASEC(JL), ZBASES(JL))
      end do
      ZP = 1.0_real64/thermal%R2ES
      do JL = KIDIA, KFDIA
        term = source_maximum(0.000000001_real64, PQ(JL, YDECUMF%NJKT4))
        term = term*PAP(JL, YDECUMF%NJKT4)
        term = term*ZP
        ZA = public_log(term)
        numerator = thermal%R4LES*ZA
        other = thermal%R3LES*physical%RTT
        numerator = numerator - other
        denominator = ZA - thermal%R3LES
        ZTD8 = numerator/denominator
        term = PT(JL, YDECUMF%NJKT4) + ZTD8
        other = 2.0_real64*PT(JL, YDECUMF%NJKT5)
        PCONVIND(JL, 1) = term - other
        term = source_maximum(0.000000001_real64, PQ(JL, YDECUMF%NJKT6))
        term = term*PAP(JL, YDECUMF%NJKT6)
        term = term*ZP
        ZA = public_log(term)
        numerator = thermal%R4LES*ZA
        other = thermal%R3LES*physical%RTT
        numerator = numerator - other
        denominator = ZA - thermal%R3LES
        ZTD7 = numerator/denominator
        term = PT(JL, YDECUMF%NJKT4) - PT(JL, YDECUMF%NJKT5)
        term = term + ZTD8
        term = term - PT(JL, YDECUMF%NJKT6)
        term = term + ZTD7
        PCONVIND(JL, 2) = term - physical%RTT
        IC0L(JL) = 0_int32
      end do
      do JK = KLEV, 1, -1
        JKS = min(JK + 1, KLEV)
        do JL = KIDIA, KFDIA
          if (PAP(JL, JK) > 6000.0_real64 .and. IC0L(JL) < 2) then
            ZQSICE = scaled_saturation_pressure(physical, thermal, PT(JL, JK))
            ZQSICE = ZQSICE/PAP(JL, JK)
            ZQSICE = source_minimum(ZQSICE, 0.5_real64)
            term = physical%RETV*ZQSICE
            term = 1.0_real64 - term
            ZQSICE = ZQSICE/term
            ZSUBSAT = ZQSICE - PQ(JL, JK)
            ZSUBSAT = source_maximum(ZSUBSAT, 0.0_real64)
            term = PAP(JL, JK) - 85000.0_real64
            term = 0.0074615_real64*term
            term = 1329.31_real64 + term
            other = PT(JL, JK) - 275.0_real64
            other = 40.637_real64*other
            term = term - other
            term = ZSUBSAT*term
            term = PT(JL, JK) - term
            ZTWETB(JL, JK) = term - physical%RTT
            if (JK < KLEV) then
              if (ZTWETB(JL, JKS) > 0.0_real64 .and. ZTWETB(JL, JK) <= 0.0_real64) then
                numerator = -ZTWETB(JL, JKS)
                term = PGEO(JL, JK) - PGEO(JL, JKS)
                numerator = numerator*term
                denominator = ZTWETB(JL, JK) - ZTWETB(JL, JKS)
                denominator = source_minimum(-0.00000001_real64, denominator)
                ZDZ = numerator/denominator
                term = PGEO(JL, JKS) + ZDZ
                PZTWETB(JL, 1) = term*ZRG
                IC0L(JL) = IC0L(JL) + 1
              end if
              if (ZTWETB(JL, JKS) > 1.0_real64 .and. ZTWETB(JL, JK) <= 1.0_real64) then
                numerator = 1.0_real64 - ZTWETB(JL, JKS)
                term = PGEO(JL, JK) - PGEO(JL, JKS)
                numerator = numerator*term
                denominator = ZTWETB(JL, JK) - ZTWETB(JL, JKS)
                denominator = source_minimum(-0.00000001_real64, denominator)
                ZDZ = numerator/denominator
                term = PGEO(JL, JKS) + ZDZ
                PZTWETB(JL, 2) = term*ZRG
              end if
            end if
          end if
        end do
      end do
      call troplev(KLON, KIDIA, KFDIA, KLEV, .false., PT(:, 1:KLEV), PQ(:, 1:KLEV), &
                   PAP(:, 1:KLEV), ILTROP, physical%RD, physical%RG, physical%RKAPPA, status)
      if (status /= 0_int32) return
      do JL = KIDIA, KFDIA
        if (ILTROP(JL) < 1 .or. ILTROP(JL) > KLEV) then
          status = 2_int32
          return
        end if
        PTROPOTP(JL) = PAP(JL, ILTROP(JL))
      end do
    end if

    do JL = KIDIA, KFDIA
      ZRAIN = PFPLCL(JL, KLEV + 1) + PFPLSL(JL, KLEV + 1)
      ZSNOW = PFPLCN(JL, KLEV + 1) + PFPLSN(JL, KLEV + 1)
      ZTOT = ZRAIN + ZSNOW
      if (ZTOT > 0.0000000001_real64) then
        ZRAINFRAC_SFC = ZRAIN/ZTOT
        if (P2T(JL) > physical%RTT) then
          if (ZRAINFRAC_SFC > 0.8_real64) then
            PPRECTYPE(JL) = 1.0_real64
          else if (ZRAINFRAC_SFC > 0.2_real64) then
            PPRECTYPE(JL) = 7.0_real64
          else
            PPRECTYPE(JL) = 6.0_real64
          end if
        else
          if (PRAINFRAC_TOPRFZ(JL) < 0.01_real64) then
            if (ZRAINFRAC_SFC < 0.01_real64) then
              PPRECTYPE(JL) = 5.0_real64
            else if (ZRAINFRAC_SFC < 0.5_real64) then
              PPRECTYPE(JL) = 5.0_real64
            else
              PPRECTYPE(JL) = 12.0_real64
              PFZRA(JL) = ZRAIN
            end if
          else if (PRAINFRAC_TOPRFZ(JL) < 0.2_real64) then
            if (ZRAINFRAC_SFC < 0.01_real64) then
              PPRECTYPE(JL) = 5.0_real64
            else if (ZRAINFRAC_SFC < 0.5_real64) then
              PPRECTYPE(JL) = 5.0_real64
            else
              PPRECTYPE(JL) = 3.0_real64
              PFZRA(JL) = ZRAIN
            end if
          else if (PRAINFRAC_TOPRFZ(JL) < 0.8_real64) then
            if (ZRAINFRAC_SFC <= 0.5_real64) then
              PPRECTYPE(JL) = 8.0_real64
            else
              PPRECTYPE(JL) = 3.0_real64
              PFZRA(JL) = ZRAIN
            end if
          else
            if (ZRAINFRAC_SFC <= 0.5_real64) then
              PPRECTYPE(JL) = 8.0_real64
            else
              PPRECTYPE(JL) = 3.0_real64
              PFZRA(JL) = ZRAIN
            end if
          end if
        end if
      end if
    end do
    deallocate (ZBASEC, ZBASES, LLSTB, IC0L, ICM10L, ILTROP, ZTWETB)
    call transform_profile_event('DIAG_CLOUDS', 1_int32, hook_handle, profile)
    status = 0_int32
  end subroutine diag_clouds

  !> Retain both model-scaled liquid and ice EXP stages before phase weighting.
  function scaled_saturation_pressure(physical, thermal, temperature) result(value)
    type(forecast_physical_constants), intent(in) :: physical
    type(thermal_parameter_record), intent(in) :: thermal
    real(real64), intent(in) :: temperature
    real(real64) :: value, phase, liquid, ice, numerator, denominator, other
    real(real64), volatile :: liquid_delta, ice_delta
    liquid_delta = temperature - physical%RTT
    phase = 1.0_real64
    if (btest(transfer(liquid_delta, 0_int64), 63)) phase = 0.0_real64
    numerator = thermal%R3LES*liquid_delta
    denominator = temperature - thermal%R4LES
    numerator = numerator/denominator
    liquid = public_exp(numerator)
    liquid = thermal%R2ES*liquid
    ice_delta = temperature - physical%RTT
    numerator = thermal%R3IES*ice_delta
    denominator = temperature - thermal%R4IES
    numerator = numerator/denominator
    ice = public_exp(numerator)
    ice = thermal%R2ES*ice
    other = 1.0_real64 - phase
    other = other*ice
    liquid = phase*liquid
    value = liquid + other
  end function scaled_saturation_pressure

  !> Match source FP MIN/MAX, including signed-zero ties and NaN priority.
  function source_minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    value = source_extreme(a, b, .true.)
  end function source_minimum
  function source_maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    value = source_extreme(a, b, .false.)
  end function source_maximum
  function source_extreme(a, b, minimum) result(value)
    real(real64), intent(in) :: a, b
    logical, intent(in) :: minimum
    real(real64) :: value
    real(real64), volatile :: signalling_value
    integer(int64) :: abits, bbits
    logical :: an, bn
    abits = transfer(a, 0_int64)
    bbits = transfer(b, 0_int64)
    an = iand(abits, int(z'7ff0000000000000', int64)) == int(z'7ff0000000000000', int64) &
         .and. iand(abits, int(z'000fffffffffffff', int64)) /= 0_int64
    bn = iand(bbits, int(z'7ff0000000000000', int64)) == int(z'7ff0000000000000', int64) &
         .and. iand(bbits, int(z'000fffffffffffff', int64)) /= 0_int64
    if (an .and. .not. btest(abits, 51)) then
      signalling_value = a
      value = signalling_value + 0.0_real64
      return
    end if
    if (bn .and. .not. btest(bbits, 51)) then
      signalling_value = b
      value = signalling_value + 0.0_real64
      return
    end if
    if (an) then
      value = a
    else if (bn) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      if (minimum) then
        value = transfer(ior(abits, bbits), 0.0_real64)
      else
        value = transfer(iand(abits, bbits), 0.0_real64)
      end if
    else if (minimum) then
      if (a < b) then
        value = a
      else
        value = b
      end if
    else
      if (a > b) then
        value = a
      else
        value = b
      end if
    end if
  end function source_extreme
end module forecast_cloud_weather_diagnostics
