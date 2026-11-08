!> Own ozone and greenhouse profile interpolation with explicit native records.
!! Pressure is Pa, latitude is its dimensionless sine and outputs use kg/kg
!! for gases or pressure-weighted ozone amounts as declared by the source.
!! Scientific equations and interface attribution: ECMWF RADOZC and RADGHG.
module native_radiation_climatology_profiles
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int32, real64
  use yoeozoc, only: TEOZOC
  use yoerad, only: TERAD
  use yoeradghg, only: TRADGHG
  use native_radiation_gas_preparation, only: interp_gas
  implicit none
  private
  public :: radozc, radghg
  interface
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains

!> Integrate the latitude-interpolated ozone profile over model layers.
!! PAPRS has shape (columns,levels+1), in Pa. PGEMU has columns entries.
!! The native TEOZOC input owns its canonical latitude, pressure and ratio arrays.
!! Selected source columns advance by spacing; destination starts at shift+1.
!! Only selected rows change. The caller supplies positive, increasing pressure
!! and the retained normal/aquaplanet domains. Empty work writes no values.
  subroutine radozc(reference, aquaplanet, first, last, columns, levels, spacing, output_columns, shift, pressure, latitude, output)
    type(TEOZOC), intent(in) :: reference
    logical, intent(in) :: aquaplanet
    integer(int32), intent(in) :: first, last, columns, levels, spacing, output_columns, shift
    real(real64), intent(in) :: pressure(columns, levels + 1), latitude(columns)
    real(real64), intent(inout) :: output(output_columns, levels)
    real(real64) :: profile(0:60), slope(0:59), sine, weight, p, q, left, right, previous, current, thickness
    integer :: low, j, k, c, d, maximum
    logical :: blend
    if (first > last .or. levels == 0) return
    if (spacing <= 0) call public_abort()
    sine = latitude(first); low = 0; weight = -9999.0_real64
    if (aquaplanet) then
      if (sine <= reference%RSINC(1)) then
        low = 1; blend = .false.
      elseif (sine >= reference%RSINC(64)) then
        low = 64; blend = .false.
      else
        do j = 63, 1, -1
          if (sine <= reference%RSINC(j + 1) .and. sine >= reference%RSINC(j)) low = j
        end do
        weight = (sine - reference%RSINC(low))/(reference%RSINC(low + 1) - reference%RSINC(low))
        blend = .true.
      end if
    else
      do j = 18, 1, -1
        if (sine <= reference%RSINC(j + 1) .and. sine >= reference%RSINC(j)) low = j
      end do
    end if
    if (low == 0) call public_abort()
    if (aquaplanet) then
      maximum = 60
      if (.not. blend) then
        do j = 0, maximum
          profile(j) = reference%ROZT(low, j)
        end do
      else
        do j = 0, maximum
          q = reference%ROZT(low + 1, j) - reference%ROZT(low, j)
          q = weight*q
          profile(j) = reference%ROZT(low, j) + q
        end do
      end if
    else
      maximum = 35
      weight = (sine - reference%RSINC(low))/(reference%RSINC(low + 1) - reference%RSINC(low))
      if (low == 18 .or. low == 1) then
        do j = 0, maximum
          profile(j) = reference%ROZT(low, j)
        end do
      else
        do j = 0, maximum
          q = reference%ROZT(low + 1, j) - reference%ROZT(low, j)
          q = weight*q
          profile(j) = reference%ROZT(low, j) + q
        end do
      end if
    end if
    do j = 0, maximum - 1
      q = reference%RPROC(j) - reference%RPROC(j + 1)
      q = 1.0_real64/q
      p = profile(j) - profile(j + 1)
      slope(j) = q*p
    end do
    d = shift
    do c = first, last, spacing
      d = d + 1
      previous = ozone_face(pressure(c, 1))
      do k = 1, levels
        current = ozone_face(pressure(c, k + 1))
        thickness = pressure(c, k + 1) - pressure(c, k)
        p = previous + current
        p = thickness*p
        output(d, k) = p*0.5_real64
        previous = current
      end do
    end do
  contains
    function ozone_face(face_pressure) result(value)
      real(real64), intent(in) :: face_pressure
      real(real64) :: value, difference, product
      integer :: i
      if (face_pressure >= reference%RPROC(maximum)) then
        value = profile(maximum)
        return
      end if
      do i = 0, maximum - 1
        if (face_pressure >= reference%RPROC(i) .and. face_pressure < reference%RPROC(i + 1)) then
          difference = face_pressure - reference%RPROC(i + 1)
          product = difference*slope(i)
          value = profile(i + 1) + product
          return
        end if
      end do
      call public_abort()
      value = 0.0_real64
    end function
  end subroutine

!> Interpolate each configured gas in original species order.
!! Native TRADGHG owns readonly climatology arrays. No global namespace is read.
SUBROUTINE RADGHG ( YDERAD,owned_ghg,KIDIA, KFDIA, KLON, KLEV, KDLON, PPRESSURE_HL, PGEMU, PCO2 , PCH4 , PN2O , PNO2 , PCFC11 , PCFC12, PO3, PHCFC22, PCCL4 )
    type(TRADGHG), intent(in) :: owned_ghg
    TYPE(TERAD), INTENT(INOUT) :: YDERAD
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KDLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    REAL(KIND=JPRB), INTENT(IN) :: PPRESSURE_HL(KLON, 0:KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PGEMU(KLON)
REAL(KIND=JPRB)   ,INTENT(INOUT)   :: PCO2(KLON,KLEV), PCH4(KLON,KLEV), PN2O(KLON,KLEV), PNO2(KLON,KLEV), PCFC11(KLON,KLEV), PCFC12(KLON,KLEV), PO3(KLON,KLEV), PHCFC22(KLON,KLEV), PCCL4(KLON,KLEV)
    REAL(KIND=JPRB) :: ZLATWEIGHT(KLON)
    INTEGER(KIND=JPIM) :: ILAT(KLON), JI, JL
    REAL(KIND=JPRB) :: ZINT, ZSINLAT
    DO JI = KIDIA, KFDIA
      ZSINLAT = PGEMU(JI)
      IF (ZSINLAT > owned_ghg%SINLAT(owned_ghg%NLATITUDE)) THEN
        ILAT(JI) = owned_ghg%NLATITUDE - 1
        ZLATWEIGHT(JI) = 1.0_JPRB
      ELSEIF (ZSINLAT < owned_ghg%SINLAT(1)) THEN
        ILAT(JI) = 1
        ZLATWEIGHT(JI) = 0.0_JPRB
      ELSE
        ILAT(JI) = 0
        DO JL = owned_ghg%NLATITUDE - 1, 1, -1
        IF (ZSINLAT <= owned_ghg%SINLAT(JL + 1) .AND. ZSINLAT >= owned_ghg%SINLAT(JL)) THEN
          ILAT(JI) = JL
          EXIT
        END IF
        END DO
        IF (ILAT(JI) == 0) THEN
          call public_abort()
        END IF
        ZLATWEIGHT(JI) = (ZSINLAT - owned_ghg%SINLAT(ILAT(JI)))/(owned_ghg%SINLAT(ILAT(JI) + 1) - owned_ghg%SINLAT(ILAT(JI)))
      END IF
    END DO
    IF (YDERAD%NGHGRAD == 1 .OR. YDERAD%NGHGRAD >= 10) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_CO2, PPRESSURE_HL, PCO2)
    END IF
    IF (YDERAD%NGHGRAD == 2 .OR. YDERAD%NGHGRAD >= 11) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_CH4, PPRESSURE_HL, PCH4)
    END IF
    IF (YDERAD%NGHGRAD == 3 .OR. YDERAD%NGHGRAD >= 12) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_N2O, PPRESSURE_HL, PN2O)
    END IF
    IF (YDERAD%NGHGRAD == 4 .OR. YDERAD%NGHGRAD >= 20) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_NO2, PPRESSURE_HL, PNO2)
    END IF
    IF (YDERAD%NGHGRAD == 5 .OR. YDERAD%NGHGRAD >= 15) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_CFC11, PPRESSURE_HL, PCFC11)
    END IF
    IF (YDERAD%NGHGRAD == 6 .OR. YDERAD%NGHGRAD >= 16) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_CFC12, PPRESSURE_HL, PCFC12)
    END IF
    IF (YDERAD%NGHGRAD == 7 .OR. YDERAD%NGHGRAD == 17 .OR. YDERAD%NGHGRAD >= 21) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_O3, PPRESSURE_HL, PO3)
    END IF
    IF (YDERAD%NGHGRAD == 8 .OR. YDERAD%NGHGRAD >= 18) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_HCFC22, PPRESSURE_HL, PHCFC22)
    END IF
    IF (YDERAD%NGHGRAD == 9 .OR. YDERAD%NGHGRAD >= 19) THEN
      call interp_gas(KIDIA, KFDIA, ILAT, ZLATWEIGHT, owned_ghg%PRESSURE_HL, owned_ghg%MASS_CCL4, PPRESSURE_HL, PCCL4)
    END IF
  end subroutine radghg
end module
