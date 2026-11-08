!> Build the source auxiliary physical request using named native metadata.
!! This count-zero runtime extension retains the original SUFPTR2 field order.
module forecast_runtime_output_auxiliary_requests
  use iso_fortran_env, only: int32
  use forecast_fullpos_state_types, only: native_fullpos_state
  use forecast_output_request_types, only: trqfp, trqfpdyn
  use forecast_output_request_status
  use yomafn, only: tafn
  implicit none
  private
  public :: initialize_runtime_auxiliary_requests
contains
  !> Add source preparatory fields without removing repeated codes.
  !! The input records are readonly. auxiliary owns its eight output arrays.
  !! No weather calculation or original method is called. Status2 is refusal;
  !! status1 retains the allocated output prefix for the caller to release.
  integer(int32) function initialize_runtime_auxiliary_requests(YDRQPHY, YDRQAUX, KFPINPHY, fullpos, &
                                                                LDPHYS, LDHPOS, LDFPOSHOR, YDRQDYN) result(status)
    type(trqfp), intent(in) :: YDRQPHY
    type(trqfp), intent(inout) :: YDRQAUX
    integer(int32), intent(in) :: KFPINPHY
    type(native_fullpos_state), intent(in) :: fullpos
    logical, intent(in) :: LDPHYS, LDHPOS, LDFPOSHOR
    type(trqfpdyn), intent(in), optional :: YDRQDYN
    integer :: JFLD, IPTR, IFPDOM, IFPVT0(1639)
    logical :: LLUPPERAIR, LLDYPP, LLTS, LLTCLS, LLRHCLS, LLRHSRF, LLORO, LLPBL, LLCAPE, LLDY2D, LLFPSX1
    status = 2
    if (YDRQPHY%nfieldg < 0 .or. YDRQPHY%nfieldg > 1639) return
    if (YDRQPHY%nfieldg > 0) then
      if (.not. allocated(YDRQPHY%icod)) return
      if (size(YDRQPHY%icod) < YDRQPHY%nfieldg) return
    end if
    if (allocated(YDRQAUX%icod) .or. allocated(YDRQAUX%igrib) .or. allocated(YDRQAUX%llsurf)) return
    if (allocated(YDRQAUX%clname) .or. allocated(YDRQAUX%clpref) .or. allocated(YDRQAUX%ivec)) return
    if (allocated(YDRQAUX%idom) .or. allocated(YDRQAUX%idmp)) return
    if (present(YDRQDYN)) then
      if (YDRQDYN%y2d%nppfieldg < 0 .or. YDRQDYN%y2d%nppfieldg > 256) return
      if (YDRQDYN%y2d%nppfieldg > 0) then
        if (.not. allocated(YDRQDYN%y2d%icod)) return
        if (size(YDRQDYN%y2d%icod) < YDRQDYN%y2d%nppfieldg) return
      end if
      if (.not. valid_levels(YDRQDYN%yho%nppfieldg, YDRQDYN%yho%npplevg)) return
      if (.not. valid_levels(YDRQDYN%yit%nppfieldg, YDRQDYN%yit%npplevg)) return
      if (.not. valid_levels(YDRQDYN%yfl%nppfieldg, YDRQDYN%yfl%npplevg)) return
      if (.not. valid_levels(YDRQDYN%yes%nppfieldg, YDRQDYN%yes%npplevg)) return
    end if
ASSOCIATE(NFPLAKE=>fullpos%ynamfpsci%NFPLAKE, NFPCLI=>fullpos%ynamfpsci%NFPCLI, NFPSURFEX=>fullpos%ynamfpsci%NFPSURFEX, LFPCAPEX=>fullpos%ynamfpsci%LFPCAPEX, &
 & LFPCLSTOGMV=>fullpos%ynamfpsci%LFPCLSTOGMV, NFPMASK=>fullpos%ynamfpsci%NFPMASK, TFP=>fullpos%yafn%TFP, GFP=>fullpos%yafn%GFP, GFP_PHYDS=>fullpos%yafn%GFP_PHYDS)

!*       2.  COMPUTE MAIN LOGICAL KEYS
!            -------------------------

      LLCAPE = .FALSE.
      IF (PRESENT(YDRQDYN)) THEN
        DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
          IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%CAPE%ICOD .OR. &
           &  YDRQDYN%Y2D%ICOD(JFLD) == TFP%CIEN%ICOD .OR. &
           &  YDRQDYN%Y2D%ICOD(JFLD) == TFP%TCVS%ICOD) THEN
            LLCAPE = .TRUE.
            EXIT
          END IF
        END DO
      END IF

      LLPBL = LLCAPE .AND. (.NOT. LFPCAPEX)
      IF (PRESENT(YDRQDYN)) THEN
        DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
          IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%UCLS%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%VCLS%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%TCLS%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%QCLS%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%RCLS%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%TX%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%TN%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%HUX%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%HUN%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%UGST%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%VGST%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%FGST%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%FCLS%ICOD) THEN
            IF (LDPHYS) THEN
              IF (.NOT. LDHPOS .OR. NFPCLI >= 3) THEN
                LLPBL = .TRUE.
                EXIT
              ELSE
                RETURN
              END IF
            ELSE
              RETURN
            END IF
          END IF
        END DO
      END IF

      LLDY2D = .FALSE.
      IF (PRESENT(YDRQDYN)) THEN
        DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
          IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%SP%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%LNSP%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%WWS%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%UJET%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%VJET%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%PJET%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%TCAO%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%PCAO%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%HTPW%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%HTPW1%ICOD .OR.&
             & YDRQDYN%Y2D%ICOD(JFLD) == TFP%HTPW2%ICOD) THEN
            LLDY2D = .TRUE.
            EXIT
          END IF
        END DO
      END IF

      LLUPPERAIR = .FALSE.
      IF (PRESENT(YDRQDYN)) THEN
        IF (YDRQDYN%YHO%NPPFIELDG > 0) THEN
          LLUPPERAIR = LLUPPERAIR .OR. (MAXVAL(YDRQDYN%YHO%NPPLEVG(:)) > 0)
        END IF
        IF (YDRQDYN%YIT%NPPFIELDG > 0) THEN
          LLUPPERAIR = LLUPPERAIR .OR. (MAXVAL(YDRQDYN%YIT%NPPLEVG(:)) > 0)
        END IF
        IF (YDRQDYN%YFL%NPPFIELDG > 0) THEN
          LLUPPERAIR = LLUPPERAIR .OR. (MAXVAL(YDRQDYN%YFL%NPPLEVG(:)) > 0)
        END IF
        IF (YDRQDYN%YES%NPPFIELDG > 0) THEN
          LLUPPERAIR = LLUPPERAIR .OR. (MAXVAL(YDRQDYN%YES%NPPLEVG(:)) > 0)
        END IF
      END IF
      LLDYPP = LDHPOS .AND. (LLUPPERAIR .OR. LLDY2D .OR. LLPBL .OR. LLCAPE)

      LLFPSX1 = (NFPSURFEX == 1)

!*       2.  COMPUTE POINTERS, DESCRIPTORS & AND RESULTING DIMENSION
!            -------------------------------------------------------

      IPTR = 0

!        2.1 Orography

! Interpolated orography needed for surface-dependent vertical post-processing
      IF (LLDYPP) THEN
        CALL SET_NEXT(GFP%SFIS%ICOD)
      ELSEIF (LLFPSX1) THEN
        IF (NFPCLI == 0) THEN
          ! Or for Surfex if no climatology dataset present:
          CALL SET_NEXT(GFP%SFIS%ICOD)
        ELSE
          ! Output orography put as well in auxilary buffer for Surfex : makes an easy redirection
          CALL SET_NEXT(GFP%GFIS%ICOD)
        END IF
      END IF

!        2.2 Surface physical fields

      IF (LDPHYS) THEN

!        2.2.1 Climatology fields

! Interpolated land-sea mask needed for any correction on surface fields
! except surface geopotential, O3 profiles and aerosols
        IF (NFPCLI == 0 .AND. LDFPOSHOR) THEN
          DO JFLD = 1, YDRQPHY%NFIELDG
            IF (YDRQPHY%ICOD(JFLD) /= GFP%SFIS%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%GFIS%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%O3A%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%O3B%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%O3C%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%ASEA%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%ALAN%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%ASOO%ICOD .AND. &
             & YDRQPHY%ICOD(JFLD) /= GFP%ADES%ICOD) THEN
              CALL SET_NEXT(GFP%LSM%ICOD)
              EXIT
            END IF
          END DO
        END IF

! if no climatology, anisotropy and direction of topography are computed
! from the vector "anisotropy"
        IF (IFPSEARCH(YDRQPHY, GFP%DPAT%ICOD) /= 0 .OR. IFPSEARCH(YDRQPHY, GFP%ACOT%ICOD) /= 0) THEN
          IF (NFPCLI <= 1 .AND. LDFPOSHOR) THEN
            CALL SET_NEXT(GFP%SDOG%ICOD)
            CALL SET_NEXT(GFP%PADOU%ICOD)
            CALL SET_NEXT(GFP%PADOV%ICOD)
          END IF
        END IF

! if no climatology and actual interpolations, Leaf area index is needed for Interception content
        IF (NFPCLI <= 1 .AND. LDFPOSHOR) THEN
          IF (IFPSEARCH(YDRQPHY, GFP%IC%ICOD) /= 0) THEN
            CALL SET_NEXT(GFP%LAI%ICOD)
          END IF
        END IF

!        2.2.1 Pronostic fields

! Interpolated surface temperature is needed for surface-dependent
! vertical interpolations or a lake option
        IF (LLDYPP .OR. (NFPLAKE == -1)) THEN
          CALL SET_NEXT(GFP%RDST%ICOD)
!   Supplementary fields if 2 masks:
          IF (NFPMASK >= 2) THEN
            CALL SET_NEXT(GFP%LAN%ICOD)
          END IF
        END IF

! SST :
        IF (((LLDYPP .OR. NFPLAKE == -1) .AND. NFPMASK >= 2) .OR. LLFPSX1) THEN
          CALL SET_NEXT(GFP%SST%ICOD)
        END IF

! Cls temperature needed for XFU extreme temperatures, gmv-to-cls option and sometimes CAPE
        LLTCLS = (LLCAPE .AND. LFPCAPEX) .OR. LFPCLSTOGMV
        IF (NFPCLI > 0 .OR. LDFPOSHOR) THEN
          IF (IFPSEARCH(YDRQPHY, GFP%XX2T%ICOD) /= 0 .OR. IFPSEARCH(YDRQPHY, GFP%XN2T%ICOD) /= 0) THEN
            LLTCLS = .TRUE.
          END IF
        END IF
        IF (LLTCLS) THEN
          CALL SET_NEXT(GFP%X2T%ICOD)
        END IF

! Cls relative moisture needed for XFU extreme moistures, gmv-to-cls option, and CAPE sometimes
        LLRHCLS = (LLCAPE .AND. LFPCAPEX) .OR. LFPCLSTOGMV
        IF (NFPCLI > 0 .OR. LDFPOSHOR) THEN
          IF (IFPSEARCH(YDRQPHY, GFP%XX2HU%ICOD) /= 0 .OR. IFPSEARCH(YDRQPHY, GFP%XN2HU%ICOD) /= 0) THEN
            LLRHCLS = .TRUE.
          END IF
        END IF
        IF (LLRHCLS) THEN
          CALL SET_NEXT(GFP%X2RH%ICOD)
        END IF

! Output surface temperature is needed for surface-dependent vertical interpolations, Tcls, snow depth, Tp and Surfex :
        LLTS = LLDYPP .OR. LLTCLS .OR. LLFPSX1
        IF (NFPCLI > 0 .OR. LDFPOSHOR) THEN
          IF (IFPSEARCH(YDRQPHY, GFP%SD%ICOD) /= 0 .OR. IFPSEARCH(YDRQPHY, GFP%DST%ICOD) /= 0 &
           & .OR. IFPSEARCH(YDRQPHY, GFP%X2T%ICOD) /= 0) THEN
            LLTS = .TRUE.
          END IF
        END IF
        IF (LLTS) THEN
          CALL SET_NEXT(GFP%ST%ICOD)
        END IF

! Interpolated orography may be needed for surface temperature :
        LLORO = .FALSE.
        IF (.NOT. LLDYPP .AND. (NFPCLI > 0 .OR. NFPLAKE == -1)) THEN
          IF (LLTS .OR. IFPSEARCH(YDRQPHY, GFP%ST%ICOD) /= 0) THEN
            LLORO = .TRUE.
          END IF
        END IF
        IF (LLORO) THEN
          CALL SET_NEXT(GFP%SFIS%ICOD)
        END IF

! Cls wind intensity is computed from the Cls wind components
        IF (IFPSEARCH(YDRQPHY, GFP%X10FF%ICOD) /= 0) THEN
          CALL SET_NEXT(GFP%X10U%ICOD)
          CALL SET_NEXT(GFP%X10V%ICOD)
        END IF

! Gusts intensity is computed from the Gust components
        IF (IFPSEARCH(YDRQPHY, GFP%XGUST%ICOD) /= 0) THEN
          CALL SET_NEXT(GFP%XUGST%ICOD)
          CALL SET_NEXT(GFP%XVGST%ICOD)
        END IF

! Surface relative moisture needed for cls relative moisture
        LLRHSRF = LLRHCLS
        IF (NFPCLI > 0 .OR. LDFPOSHOR) THEN
          IF (IFPSEARCH(YDRQPHY, GFP%X2RH%ICOD) /= 0) THEN
            LLRHSRF = (GFP%X2RH%IANO /= 0)
          END IF
        END IF
        IF (LLRHSRF) THEN
          CALL SET_NEXT(GFP%PSRHU%ICOD)
        END IF

! Advanced PBL post-processing or Surfex :
        IF (LLPBL .OR. LLFPSX1) THEN
!   Model snow depth :
          CALL SET_NEXT(GFP%SD%ICOD)
!   Model surface water content :
          CALL SET_NEXT(GFP%SSW%ICOD)
!   surface frost :
          CALL SET_NEXT(GFP%FSSW%ICOD)
        END IF

! Advanced PBL post-processing for U,V,T,Q & HU :
        IF (LLPBL) THEN
!   Interpolated dynamic surface roughness length :
          CALL SET_NEXT(GFP%IDZ0%ICOD)
!   Resistance to evapotranspiration :
          CALL SET_NEXT(GFP%HV%ICOD)
!   Interpolated thermal surface roughness length :
          CALL SET_NEXT(GFP%ITZ0%ICOD)
        END IF
        IF (PRESENT(YDRQDYN)) THEN
          DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
            IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%TX%ICOD) THEN
              ! Increment to maxi temperature :
              CALL SET_NEXT(GFP%INCTX%ICOD)
              EXIT
            END IF
          END DO
        END IF
        IF (PRESENT(YDRQDYN)) THEN
          DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
            IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%TN%ICOD) THEN
              ! Increment to mini temperature :
              CALL SET_NEXT(GFP%INCTN%ICOD)
              EXIT
            END IF
          END DO
        END IF
        IF (PRESENT(YDRQDYN)) THEN
          DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
            IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%HUX%ICOD) THEN
              ! Increment to maxi relative moisture :
              CALL SET_NEXT(GFP%INCHX%ICOD)
              EXIT
            END IF
          END DO
        END IF
        IF (PRESENT(YDRQDYN)) THEN
          DO JFLD = 1, YDRQDYN%Y2D%NPPFIELDG
            IF (YDRQDYN%Y2D%ICOD(JFLD) == TFP%HUN%ICOD) THEN
              ! Increment to mini temperature :
              CALL SET_NEXT(GFP%INCHN%ICOD)
              EXIT
            END IF
          END DO
        END IF

! Preparatory fields CAPE under certain conditions (no interpolations) :
        IF (LLCAPE .AND. KFPINPHY == 0 .AND. NFPCLI == 0) THEN
          CALL SET_NEXT(GFP%IVEG%ICOD)
        END IF
! if no climatology, vegetation is needed for Interception content
        IF (NFPCLI <= 1 .AND. LDFPOSHOR) THEN
          IF (IFPSEARCH(YDRQPHY, GFP%IC%ICOD) /= 0 .OR. (LLCAPE .AND. KFPINPHY == 0 .AND. NFPCLI == 0)) THEN
            CALL SET_NEXT(GFP%VEG%ICOD)
          END IF
        END IF

! Other preparatory fields for Surfex or CAPE under certain conditions (no interpolations) :
        IF (LLFPSX1 .OR. (LLCAPE .AND. KFPINPHY == 0 .AND. NFPCLI == 0)) THEN
          CALL SET_NEXT(GFP%LSM%ICOD)
          CALL SET_NEXT(GFP%ARG%ICOD)
          CALL SET_NEXT(GFP%SAB%ICOD)
          CALL SET_NEXT(GFP%D2%ICOD)
        END IF

! Other preparatory fields for Surfex :
        IF (LLFPSX1) THEN
          CALL SET_NEXT(GFP%DST%ICOD)
          CALL SET_NEXT(GFP%DSW%ICOD)
          CALL SET_NEXT(GFP%FDSW%ICOD)
        END IF

      END IF

      IF (IPTR > 0) THEN
        IFPDOM = 1
        status = allocate_auxiliary_physical_request(fullpos%yafn, IFPVT0(1:IPTR), YDRQAUX)
        if (status /= 0) return
      END IF

    END ASSOCIATE
    status = 0
  contains
    subroutine SET_NEXT(code)
      integer(int32), intent(in) :: code
      IPTR = IPTR + 1
      IFPVT0(IPTR) = code
    end subroutine
  end function

  logical function valid_levels(count, levels)
    integer(int32), intent(in) :: count
    integer(int32), allocatable, intent(in) :: levels(:)
    valid_levels = .false.
    if (count < 0 .or. count > 256) return
    if (count > 0) then
      if (.not. allocated(levels)) return
      if (size(levels) < count) return
    end if
    valid_levels = .true.
  end function

  integer function IFPSEARCH(request, code) result(position)
    type(trqfp), intent(in) :: request
    integer(int32), intent(in) :: code
    integer :: i
    position = 0
    do i = 1, request%nfieldg
      if (request%icod(i) /= code) cycle
      position = i
      return
    end do
  end function

  !> Allocate in the original eight-owner order, then set descriptor metadata.
  integer(int32) function allocate_auxiliary_physical_request(afn, codes, request) result(status)
    type(tafn), intent(in) :: afn
    integer, intent(in) :: codes(:)
    type(trqfp), intent(inout) :: request
    integer :: count, i, j, k, u, v, ierr
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    status = 2
    count = size(codes)
    if (count < 1 .or. count > 1639) return
    if (any(codes < 1) .or. any(codes > size(afn%gfp_phyds))) return
    call save_output_status(saved, error_slot, error_before)
    request%nfieldg = count
    allocate (request%icod(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%igrib(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%llsurf(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%clname(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%clpref(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%ivec(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%idom(count), stat=ierr)
    if (ierr /= 0) goto700
    allocate (request%idmp(1, count), stat=ierr)
    if (ierr /= 0) goto700
    do k = 1, count
      i = codes(k)
      request%icod(k) = i
      request%clpref(k) = afn%gfp_phyds(i)%clname(1:4)
      request%clname(k) = afn%gfp_phyds(i)%clname(5:)
      request%igrib(k) = afn%gfp_phyds(i)%igrib
      request%llsurf(k) = afn%gfp_phyds(i)%llsrf
      request%ivec(k) = 0
    end do
    do v = 1, count
      i = request%icod(v)
      if (afn%gfp_phyds(i)%iordr >= 0) cycle
      do u = 1, count
        j = request%icod(u)
        if (afn%gfp_phyds(j)%iordr <= 0) cycle
        if (afn%gfp_phyds(j)%clpair /= afn%gfp_phyds(i)%clpair) cycle
        request%ivec(u) = 1
        request%ivec(v) = -u
      end do
    end do
    request%idom = 1
    request%idmp = 1
    status = 0
    goto900
700 status = 1
900 call restore_output_status(saved, error_slot, error_before)
  end function
end module
