!> Own field-list construction without original allocation or print methods.
module forecast_fullpos_field_construction
  use iso_fortran_env, only: int32, int64, real64
  use type_fpfields, only: tfpfields
  use yomfpc, only: tnamfpl
  use yomvert, only: tvab
  use yom_grib_codes, only: ngrbclbt, ngrbcsbt, ngrbsd, ngrbwsn, ngrbrsn, ngrbtsn
  implicit none
  integer, parameter :: JPRB = real64
  private
  public :: initialize_fullpos_fields, release_fullpos_fields
contains
  !> Construct21 caller-owned field arrays in source order.
 !! Model/snow/satellite counts are dimensionless and byte_limit is bytes.
 !! OUTPUT must have no live allocatable fields. The optional vertical record
 !! stays borrowed and supplies the model-level index bound.
 integer(int32) function initialize_fullpos_fields(namelist,model_levels,snow_levels,satellite_count,larpegef,output,byte_limit,vertical)result(status)
    type(tnamfpl), intent(in) :: namelist
    integer(int32), intent(in) :: model_levels, snow_levels, satellite_count
    logical, intent(in) :: larpegef
    type(tfpfields), intent(inout) :: output
    integer(int64), intent(in) :: byte_limit
    type(tvab), optional, intent(in) :: vertical
    type(tfpfields) :: pending
    integer(int32) :: j, jfld, ifld, jsat, jsnow, allocation_status
    integer(int64) :: needed
    status = 2_int32
    if (model_levels < 1 .or. model_levels > 200 .or. snow_levels < 0 .or. snow_levels > 200) return
    if (satellite_count < 0 .or. satellite_count > 1024 .or. larpegef .or. byte_limit < 1_int64) return
    if (allocated(output%CFP3DF)) return
    if (allocated(output%CFP2DF)) return
    if (allocated(output%CFPPHY)) return
    if (allocated(output%CFPCFU)) return
    if (allocated(output%CFPXFU)) return
    if (allocated(output%MFP3DFS)) return
    if (allocated(output%MFP3DFP)) return
    if (allocated(output%MFP3DFH)) return
    if (allocated(output%MFP3DFT)) return
    if (allocated(output%MFP3DFV)) return
    if (allocated(output%MFP3DFI)) return
    if (allocated(output%MFP3DFF)) return
    if (allocated(output%MFP2DF)) return
    if (allocated(output%MFPPHY)) return
    if (allocated(output%RFP3P)) return
    if (allocated(output%RFP3H)) return
    if (allocated(output%RFP3TH)) return
    if (allocated(output%RFP3PV)) return
    if (allocated(output%RFP3I)) return
    if (allocated(output%RFP3F)) return
    if (allocated(output%NRFP3S)) return
    if (namelist%NFP2DF < 0 .or. namelist%NFP2DF > size(namelist%MFP2DF)) return
    if (namelist%NFPPHY < 0 .or. namelist%NFPPHY > size(namelist%MFPPHY)) return
    if (namelist%NFP3DFS < 0 .or. namelist%NFP3DFS > size(namelist%MFP3DFS)) return
    if (namelist%NFP3DFP < 0 .or. namelist%NFP3DFP > size(namelist%MFP3DFP)) return
    if (namelist%NFP3DFH < 0 .or. namelist%NFP3DFH > size(namelist%MFP3DFH)) return
    if (namelist%NFP3DFT < 0 .or. namelist%NFP3DFT > size(namelist%MFP3DFT)) return
    if (namelist%NFP3DFV < 0 .or. namelist%NFP3DFV > size(namelist%MFP3DFV)) return
    if (namelist%NFP3DFI < 0 .or. namelist%NFP3DFI > size(namelist%MFP3DFI)) return
    if (namelist%NFP3DFF < 0 .or. namelist%NFP3DFF > size(namelist%MFP3DFF)) return
    ASSOCIATE (RFP3P => namelist%RFP3P, RFP3H => namelist%RFP3H, RFP3TH => namelist%RFP3TH, &
     & RFP3PV => namelist%RFP3PV, RFP3I => namelist%RFP3I, RFP3F => namelist%RFP3F, &
     & NRFP3S => namelist%NRFP3S, NFP3DFP => namelist%NFP3DFP, NFP3DFH => namelist%NFP3DFH, &
     & NFP3DFT => namelist%NFP3DFT, NFP3DFV => namelist%NFP3DFV, NFP3DFI => namelist%NFP3DFI, &
     & NFP3DFF => namelist%NFP3DFF, NFP3DFS => namelist%NFP3DFS, MFP3DFP => namelist%MFP3DFP, &
     & MFP3DFH => namelist%MFP3DFH, MFP3DFT => namelist%MFP3DFT, MFP3DFV => namelist%MFP3DFV, &
     & MFP3DFI => namelist%MFP3DFI, MFP3DFF => namelist%MFP3DFF, MFP3DFS => namelist%MFP3DFS, &
     & CFP3DF => namelist%CFP3DF, CFP2DF => namelist%CFP2DF, MFP2DF => namelist%MFP2DF, &
     & NFP2DF => namelist%NFP2DF, CFPCFU => namelist%CFPCFU, CFPXFU => namelist%CFPXFU, &
     & CFPPHY => namelist%CFPPHY, MFPPHY => namelist%MFPPHY, NFPPHY => namelist%NFPPHY)

      IF (larpegef) THEN
        DO J = 1, SIZE(CFP2DF)
          IF (CFP2DF(J) == ' ') EXIT
        END DO
        pending%NFP2DF = J - 1
        DO J = 1, SIZE(CFP3DF)
          IF (CFP3DF(J) == ' ') EXIT
        END DO
        pending%NFP3DF = J - 1
        DO J = 1, SIZE(CFPCFU)
          IF (CFPCFU(J) == ' ') EXIT
        END DO
        pending%NFPCFU = J - 1
        DO J = 1, SIZE(CFPXFU)
          IF (CFPXFU(J) == ' ') EXIT
        END DO
        pending%NFPXFU = J - 1
        DO J = 1, SIZE(CFPPHY)
          IF (CFPPHY(J) == ' ') EXIT
        END DO
        pending%NFPPHY = J - 1
        pending%NFP3DFS = pending%NFP3DF
        pending%NFP3DFP = pending%NFP3DF
        pending%NFP3DFH = pending%NFP3DF
        pending%NFP3DFT = pending%NFP3DF
        pending%NFP3DFV = pending%NFP3DF
        pending%NFP3DFI = pending%NFP3DF
        pending%NFP3DFF = pending%NFP3DF
      ELSE
        pending%NFP2DF = NFP2DF
        pending%NFP3DF = 0
        pending%NFPCFU = 0
        pending%NFPXFU = 0
        pending%NFPPHY = NFPPHY
        pending%NFP3DFS = NFP3DFS
        pending%NFP3DFP = NFP3DFP
        pending%NFP3DFH = NFP3DFH
        pending%NFP3DFT = NFP3DFT
        pending%NFP3DFV = NFP3DFV
        pending%NFP3DFI = NFP3DFI
        pending%NFP3DFF = NFP3DFF
        pending%NFPCFU = 0
        pending%NFPXFU = 0
        IF (satellite_count > 0) THEN
          DO JFLD = 1, NFPPHY
            IF (MFPPHY(JFLD) == NGRBCLBT .OR. MFPPHY(JFLD) == NGRBCSBT) &
             & pending%NFPPHY = pending%NFPPHY + (satellite_count - 1)
          END DO
        END IF
        IF (snow_levels > 0) THEN
          DO JFLD = 1, NFPPHY
            IF (MFPPHY(JFLD) == NGRBSD .OR. MFPPHY(JFLD) == NGRBWSN) THEN
              pending%NFPPHY = pending%NFPPHY + (snow_levels - 1)
            END IF
            IF (MFPPHY(JFLD) == NGRBRSN .OR. MFPPHY(JFLD) == NGRBTSN) THEN
              pending%NFPPHY = pending%NFPPHY + (snow_levels)
            END IF
          END DO
        END IF
      END IF

      DO J = 1, SIZE(RFP3P)
        IF (RFP3P(J) < 0.0_JPRB) EXIT
      END DO
      pending%NFP3P = (J - 1)*MIN(1, pending%NFP3DFP)
      DO J = 1, SIZE(RFP3H)
        IF (RFP3H(J) < 0.0_JPRB) EXIT
      END DO
      pending%NFP3H = (J - 1)*MIN(1, pending%NFP3DFH)
      DO J = 1, SIZE(RFP3TH)
        IF (RFP3TH(J) < 0.0_JPRB) EXIT
      END DO
      pending%NFP3TH = (J - 1)*MIN(1, pending%NFP3DFT)
      DO J = 1, SIZE(RFP3PV)
        IF (RFP3PV(J) >= 100000._JPRB) EXIT
      END DO
      pending%NFP3PV = (J - 1)*MIN(1, pending%NFP3DFV)
      DO J = 1, SIZE(RFP3I)
        IF (RFP3I(J) < -999_JPRB) EXIT
      END DO
      pending%NFP3I = (J - 1)*MIN(1, pending%NFP3DFI)

      IF (NRFP3S(1) == -99) THEN
        pending%NFP3S = model_levels*MIN(1, pending%NFP3DFS)
      ELSE
        DO J = 1, SIZE(NRFP3S)
          IF (NRFP3S(J) < 0) EXIT
        END DO
        pending%NFP3S = (J - 1)*MIN(1, pending%NFP3DFS)
      END IF

      DO J = 1, SIZE(RFP3F)
        IF (RFP3F(J) < 0.0_JPRB) EXIT
      END DO
      pending%NFP3F = (J - 1)*MIN(1, pending%NFP3DFF)

      if (NRFP3S(1) == -99 .and. pending%NFP3DFS == 0) return
      if (present(vertical)) then
        if (.not. allocated(vertical%vbh)) return
        if (pending%nfp3s > ubound(vertical%vbh, 1)) return
        if (NRFP3S(1) == -99) then
          if (model_levels > ubound(vertical%vbh, 1)) return
        else
          do j = 1, pending%nfp3s
            if (NRFP3S(j) < 1 .or. NRFP3S(j) > ubound(vertical%vbh, 1)) return
          end do
        end if
      end if
! Every allocation is staged before the final native ownership transfer.
      needed = 0_int64
      needed = needed + int(pending%NFP3DF, int64)*12_int64
      needed = needed + int(pending%NFP2DF, int64)*16_int64
      needed = needed + int(pending%NFPPHY, int64)*16_int64
      needed = needed + int(pending%NFPCFU, int64)*16_int64
      needed = needed + int(pending%NFPXFU, int64)*16_int64
      needed = needed + int(pending%NFP3DFS, int64)*4_int64
      needed = needed + int(pending%NFP3DFP, int64)*4_int64
      needed = needed + int(pending%NFP3DFH, int64)*4_int64
      needed = needed + int(pending%NFP3DFT, int64)*4_int64
      needed = needed + int(pending%NFP3DFV, int64)*4_int64
      needed = needed + int(pending%NFP3DFI, int64)*4_int64
      needed = needed + int(pending%NFP3DFF, int64)*4_int64
      needed = needed + int(pending%NFP2DF, int64)*4_int64
      needed = needed + int(pending%NFPPHY, int64)*4_int64
      needed = needed + int(pending%NFP3P, int64)*8_int64
      needed = needed + int(pending%NFP3H, int64)*8_int64
      needed = needed + int(pending%NFP3TH, int64)*8_int64
      needed = needed + int(pending%NFP3PV, int64)*8_int64
      needed = needed + int(pending%NFP3I, int64)*8_int64
      needed = needed + int(pending%NFP3F, int64)*8_int64
      needed = needed + int(pending%NFP3S, int64)*4_int64
      if (needed > byte_limit) return
      allocate (pending%CFP3DF(pending%NFP3DF), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%CFP3DF(:) = ' '
      allocate (pending%CFP2DF(pending%NFP2DF), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%CFP2DF(:) = ' '
      allocate (pending%CFPPHY(pending%NFPPHY), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%CFPPHY(:) = ' '
      allocate (pending%CFPCFU(pending%NFPCFU), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%CFPCFU(:) = ' '
      allocate (pending%CFPXFU(pending%NFPXFU), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%CFPXFU(:) = ' '
      allocate (pending%MFP3DFS(pending%NFP3DFS), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFS(:) = huge(1_int32)
      allocate (pending%MFP3DFP(pending%NFP3DFP), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFP(:) = huge(1_int32)
      allocate (pending%MFP3DFH(pending%NFP3DFH), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFH(:) = huge(1_int32)
      allocate (pending%MFP3DFT(pending%NFP3DFT), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFT(:) = huge(1_int32)
      allocate (pending%MFP3DFV(pending%NFP3DFV), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFV(:) = huge(1_int32)
      allocate (pending%MFP3DFI(pending%NFP3DFI), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFI(:) = huge(1_int32)
      allocate (pending%MFP3DFF(pending%NFP3DFF), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP3DFF(:) = huge(1_int32)
      allocate (pending%MFP2DF(pending%NFP2DF), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFP2DF(:) = huge(1_int32)
      allocate (pending%MFPPHY(pending%NFPPHY), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%MFPPHY(:) = huge(1_int32)
      allocate (pending%RFP3P(pending%NFP3P), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%RFP3P(:) = huge(1.0_real64)
      allocate (pending%RFP3H(pending%NFP3H), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%RFP3H(:) = huge(1.0_real64)
      allocate (pending%RFP3TH(pending%NFP3TH), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%RFP3TH(:) = huge(1.0_real64)
      allocate (pending%RFP3PV(pending%NFP3PV), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%RFP3PV(:) = huge(1.0_real64)
      allocate (pending%RFP3I(pending%NFP3I), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%RFP3I(:) = huge(1.0_real64)
      allocate (pending%RFP3F(pending%NFP3F), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%RFP3F(:) = huge(1.0_real64)
      allocate (pending%NRFP3S(pending%NFP3S), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        call release_fullpos_fields(pending)
        return
      end if
      pending%NRFP3S(:) = huge(1_int32)

      pending%RFP3P(:) = RFP3P(1:pending%NFP3P)
      pending%RFP3H(:) = RFP3H(1:pending%NFP3H)
      pending%RFP3TH(:) = RFP3TH(1:pending%NFP3TH)
      pending%RFP3PV(:) = RFP3PV(1:pending%NFP3PV)
      pending%RFP3I(:) = RFP3I(1:pending%NFP3I)
      pending%RFP3F(:) = RFP3F(1:pending%NFP3F)
      IF (NRFP3S(1) == -99) THEN
        DO J = 1, model_levels
          pending%NRFP3S(J) = J
        END DO
      ELSE
        pending%NRFP3S(:) = NRFP3S(1:pending%NFP3S)
      END IF

      IF (larpegef) THEN

        pending%CFP3DF(:) = CFP3DF(1:pending%NFP3DF)
        pending%CFP2DF(:) = CFP2DF(1:pending%NFP2DF)
        pending%CFPPHY(:) = CFPPHY(1:pending%NFPPHY)
        pending%CFPCFU(:) = CFPCFU(1:pending%NFPCFU)
        pending%CFPXFU(:) = CFPXFU(1:pending%NFPXFU)

      ELSE

        pending%MFP3DFS(:) = MFP3DFS(1:pending%NFP3DFS)
        pending%MFP3DFP(:) = MFP3DFP(1:pending%NFP3DFP)
        pending%MFP3DFH(:) = MFP3DFH(1:pending%NFP3DFH)
        pending%MFP3DFT(:) = MFP3DFT(1:pending%NFP3DFT)
        pending%MFP3DFV(:) = MFP3DFV(1:pending%NFP3DFV)
        pending%MFP3DFI(:) = MFP3DFI(1:pending%NFP3DFI)
        pending%MFP3DFF(:) = MFP3DFF(1:pending%NFP3DFF)
        pending%MFP2DF(:) = MFP2DF(1:pending%NFP2DF)
        IFLD = 0
        DO JFLD = 1, NFPPHY
          IFLD = IFLD + 1
          pending%MFPPHY(IFLD) = MFPPHY(JFLD)
          IF (MFPPHY(JFLD) == NGRBCLBT .OR. MFPPHY(JFLD) == NGRBCSBT) THEN
            DO JSAT = 1, satellite_count - 1
              IFLD = IFLD + 1
              pending%MFPPHY(IFLD) = MFPPHY(JFLD)
            END DO
          END IF
          IF (MFPPHY(JFLD) == NGRBSD .OR. MFPPHY(JFLD) == NGRBWSN) THEN
            DO JSNOW = 1, snow_levels - 1
              IFLD = IFLD + 1
              pending%MFPPHY(IFLD) = MFPPHY(JFLD)
            END DO
          END IF
          IF (MFPPHY(JFLD) == NGRBRSN .OR. MFPPHY(JFLD) == NGRBTSN) THEN
            DO JSNOW = 1, snow_levels
              IFLD = IFLD + 1
              pending%MFPPHY(IFLD) = MFPPHY(JFLD)
            END DO
          END IF
        END DO
      END IF

    end associate
    call move_alloc(pending%CFP3DF, output%CFP3DF)
    call move_alloc(pending%CFP2DF, output%CFP2DF)
    call move_alloc(pending%CFPPHY, output%CFPPHY)
    call move_alloc(pending%CFPCFU, output%CFPCFU)
    call move_alloc(pending%CFPXFU, output%CFPXFU)
    call move_alloc(pending%MFP3DFS, output%MFP3DFS)
    call move_alloc(pending%MFP3DFP, output%MFP3DFP)
    call move_alloc(pending%MFP3DFH, output%MFP3DFH)
    call move_alloc(pending%MFP3DFT, output%MFP3DFT)
    call move_alloc(pending%MFP3DFV, output%MFP3DFV)
    call move_alloc(pending%MFP3DFI, output%MFP3DFI)
    call move_alloc(pending%MFP3DFF, output%MFP3DFF)
    call move_alloc(pending%MFP2DF, output%MFP2DF)
    call move_alloc(pending%MFPPHY, output%MFPPHY)
    call move_alloc(pending%RFP3P, output%RFP3P)
    call move_alloc(pending%RFP3H, output%RFP3H)
    call move_alloc(pending%RFP3TH, output%RFP3TH)
    call move_alloc(pending%RFP3PV, output%RFP3PV)
    call move_alloc(pending%RFP3I, output%RFP3I)
    call move_alloc(pending%RFP3F, output%RFP3F)
    call move_alloc(pending%NRFP3S, output%NRFP3S)
    output%NFP3P = pending%NFP3P
    output%NFP3H = pending%NFP3H
    output%NFP3TH = pending%NFP3TH
    output%NFP3PV = pending%NFP3PV
    output%NFP3I = pending%NFP3I
    output%NFP3S = pending%NFP3S
    output%NFP3F = pending%NFP3F
    output%NFP3DFS = pending%NFP3DFS
    output%NFP3DFP = pending%NFP3DFP
    output%NFP3DFH = pending%NFP3DFH
    output%NFP3DFT = pending%NFP3DFT
    output%NFP3DFV = pending%NFP3DFV
    output%NFP3DFI = pending%NFP3DFI
    output%NFP3DFF = pending%NFP3DFF
    output%NFP3DF = pending%NFP3DF
    output%NFP2DF = pending%NFP2DF
    output%NFPPHY = pending%NFPPHY
    output%NFPCFU = pending%NFPCFU
    output%NFPXFU = pending%NFPXFU
    status = 0_int32
  end function
  !> Release only this record's21 native allocatable owners, in source order.
  subroutine release_fullpos_fields(output)
    type(tfpfields), intent(inout) :: output
    if (allocated(output%CFP3DF)) deallocate (output%CFP3DF)
    if (allocated(output%CFP2DF)) deallocate (output%CFP2DF)
    if (allocated(output%CFPPHY)) deallocate (output%CFPPHY)
    if (allocated(output%CFPCFU)) deallocate (output%CFPCFU)
    if (allocated(output%CFPXFU)) deallocate (output%CFPXFU)
    if (allocated(output%MFP3DFS)) deallocate (output%MFP3DFS)
    if (allocated(output%MFP3DFP)) deallocate (output%MFP3DFP)
    if (allocated(output%MFP3DFH)) deallocate (output%MFP3DFH)
    if (allocated(output%MFP3DFT)) deallocate (output%MFP3DFT)
    if (allocated(output%MFP3DFV)) deallocate (output%MFP3DFV)
    if (allocated(output%MFP3DFI)) deallocate (output%MFP3DFI)
    if (allocated(output%MFP3DFF)) deallocate (output%MFP3DFF)
    if (allocated(output%MFP2DF)) deallocate (output%MFP2DF)
    if (allocated(output%MFPPHY)) deallocate (output%MFPPHY)
    if (allocated(output%RFP3P)) deallocate (output%RFP3P)
    if (allocated(output%RFP3H)) deallocate (output%RFP3H)
    if (allocated(output%RFP3TH)) deallocate (output%RFP3TH)
    if (allocated(output%RFP3PV)) deallocate (output%RFP3PV)
    if (allocated(output%RFP3I)) deallocate (output%RFP3I)
    if (allocated(output%RFP3F)) deallocate (output%RFP3F)
    if (allocated(output%NRFP3S)) deallocate (output%NRFP3S)
  end subroutine
end module
