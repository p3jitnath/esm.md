!> Preserve source CPVPOSPR tensor classification, dimensions and field order.
!! The actual producer supplies both wave and vertical process groups.
module forecast_runtime_output_derivative_requests
  use iso_fortran_env, only: int32, real64
  use yomhook, only: lhook, dr_hook
  use yomafn, only: tafn
  use forecast_output_request_types, only: type_fprqdyn
  implicit none
  private
  public :: classify_runtime_output_derivatives
contains
  !> Update named request metadata using the produced AFN descriptors.
 !! KFPCONF is0:2, arrays retain the686field catalogue and1:512levels.
 !! All live owner descriptors stay compiler-owned; no output payload changes.
  integer(int32) function classify_runtime_output_derivatives(kfpconf, ydafn, ydqtype, nprtrv, mysetv) result(status)
    integer(int32), intent(in) :: kfpconf, nprtrv, mysetv
    type(tafn), intent(in) :: ydafn
    type(type_fprqdyn), intent(inout) :: ydqtype
    integer, parameter :: jposdyn = 686
    integer :: ivptr(max(1, min(32, nprtrv))), ivcount(max(1, min(32, nprtrv))), iloc(1)
    integer :: j, inc, ij, jl, ispread, ivset, isdir, isinv, imomdir, imomdirg, imominv, imominvg, i, jj
    integer :: iptrgpx, ivor, idiv, isca1, iumom, ivmom, isca0
    real(real64) :: zhook_handle
    status = 2
    if (nprtrv < 1 .or. nprtrv > 32 .or. mysetv < 1 .or. mysetv > nprtrv .or. kfpconf < 0 .or. kfpconf > 2) return
    if (.not. allocated(ydqtype%nfptrdyn)) return
    if (.not. allocated(ydqtype%ll)) return
    if (.not. allocated(ydqtype%isf)) return
    if (.not. allocated(ydqtype%iskp)) return
    if (.not. allocated(ydqtype%iled)) return
    if (.not. allocated(ydqtype%ilev)) return
    if (.not. allocated(ydqtype%ilvp)) return
    if (.not. allocated(ydqtype%idom)) return
    if (.not. allocated(ydqtype%idmp)) return
    if (.not. allocated(ydqtype%iset)) return
    if (.not. allocated(ydqtype%iloc)) return
    if (.not. allocated(ydqtype%ispd)) return
    if (.not. allocated(ydqtype%igpx)) return
    if (.not. allocated(ydqtype%igt1)) return
    if (size(ydqtype%ll) /= 686 .or. size(ydqtype%isf) /= 686 .or. size(ydqtype%iskp) /= 686) return
    if (size(ydqtype%iled) /= 686 .or. size(ydqtype%ilev) /= 686 .or. size(ydqtype%nfptrdyn) /= 686) return
    if (any(shape(ydqtype%igt1) /= [686, 3]) .or. lbound(ydqtype%igt1, 2) /= 0) return
    if (size(ydqtype%ilvp, 2) /= 686 .or. size(ydqtype%ilvp, 1) < 1 .or. size(ydqtype%ilvp, 1) > 512) return
    if (any(shape(ydqtype%idom) /= shape(ydqtype%ilvp)) .or. any(shape(ydqtype%iset) /= shape(ydqtype%ilvp))) return
    if (any(shape(ydqtype%iloc) /= shape(ydqtype%ilvp)) .or. any(shape(ydqtype%ispd) /= shape(ydqtype%ilvp))) return
    if (size(ydqtype%igpx) /= 686 .or. ydqtype%nfposdyn < 0 .or. ydqtype%nfposdyn > 686) return
    if (any(ydqtype%ilev < 0) .or. any(ydqtype%ilev > size(ydqtype%ilvp, 1))) return
    if (any(ydqtype%isf < 0) .or. any(ydqtype%isf > 3)) return
    if (any([ydafn%tfp%abs%icod, ydafn%tfp%vor%icod, ydafn%tfp%div%icod, ydafn%tfp%khi%icod, &
             ydafn%tfp%psi%icod, ydafn%tfp%smc%icod, ydafn%tfp%asmc%icod, ydafn%tfp%vsmc%icod] < 1)) return
    if (any([ydafn%tfp%abs%icod, ydafn%tfp%vor%icod, ydafn%tfp%div%icod, ydafn%tfp%khi%icod, &
             ydafn%tfp%psi%icod, ydafn%tfp%smc%icod, ydafn%tfp%asmc%icod, ydafn%tfp%vsmc%icod] > 686)) return
    do j = 1, ydqtype%nfposdyn
      ij = ydqtype%nfptrdyn(j)
      if (ij < 1 .or. ij > 686) return
      if (.not. ydqtype%ll(ij)) return
      if (j > 1) then
        if (any(ydqtype%nfptrdyn(1:j - 1) == ij)) return
      end if
    end do
    if (lhook) call dr_hook('CPVPOSPR', 0, zhook_handle)
    ASSOCIATE (TFP => YDAFN%TFP, TFP_DYNDS => YDAFN%TFP_DYNDS)

!*       3.    CONTROL REQUESTS
!              ----------------

!        3.1 Tensor aspects

      YDQTYPE%ILED(:) = 0
! Vorticities, divergence :
      YDQTYPE%ILED(TFP%ABS%ICOD) = 2
      YDQTYPE%ILED(TFP%VOR%ICOD) = 2
      YDQTYPE%ILED(TFP%DIV%ICOD) = 3
! Psi and Khi are computed from U and V in spectral space :
      YDQTYPE%ILED(TFP%KHI%ICOD) = 1
      YDQTYPE%ILED(TFP%PSI%ICOD) = -TFP%KHI%ICOD
! Surface Moisture Convergence is computed as DIV(q.Ucls,q.Vcls) ;
      YDQTYPE%ILED(TFP%SMC%ICOD) = 3
      YDQTYPE%ILED(TFP%ASMC%ICOD) = 3
      YDQTYPE%ILED(TFP%VSMC%ICOD) = 3

! Vectors :
      DO J = 1, JPOSDYN
        IF (TFP_DYNDS(J)%IORDR < 0) THEN
          ! V => find U :
          DO JJ = 1, JPOSDYN
            IF (TFP_DYNDS(JJ)%CLPAIR == TFP_DYNDS(J)%CLPAIR .AND. JJ /= J) THEN
              YDQTYPE%ILED(JJ) = 1
              YDQTYPE%ILED(J) = -JJ
              EXIT
            END IF
          END DO
        END IF
      END DO

      IF (KFPCONF /= 1) THEN
        ! Vectors will be considered as individual "scalars" if spectrally fitted because nothing else follows
        DO J = 1, JPOSDYN
          IF (ABS(TFP_DYNDS(J)%IORDR) == 1) THEN
            YDQTYPE%ILED(J) = YDQTYPE%ILED(J)*(1 - MIN(YDQTYPE%ISF(J), 1))
          END IF
        END DO
      END IF

!        3.3   Number of fields needed in gridpoint space :

      YDQTYPE%ISKP(:) = 1

      YDQTYPE%ISKP(TFP%ABS%ICOD) = 1 + MIN(YDQTYPE%ISF(TFP%ABS%ICOD), 1)
      YDQTYPE%ISKP(TFP%VOR%ICOD) = 1 + MIN(YDQTYPE%ISF(TFP%VOR%ICOD), 1)
      YDQTYPE%ISKP(TFP%DIV%ICOD) = 1 + MIN(YDQTYPE%ISF(TFP%DIV%ICOD), 1)

! Surface Moisture Convergence is computed as DIV(q.Ucls,q.Vcls) ;
      YDQTYPE%ISKP(TFP%SMC%ICOD) = 2
      YDQTYPE%ISKP(TFP%ASMC%ICOD) = 2
      YDQTYPE%ISKP(TFP%VSMC%ICOD) = 2

!*       2. COMPUTE DIMENSIONS

      DO J = 1, JPOSDYN
        IF (.NOT. YDQTYPE%LL(J)) THEN
          ! Nullify dimensions for non-requested fields and count requested ones
          YDQTYPE%ISF(J) = 0
          YDQTYPE%ISKP(J) = 0
          YDQTYPE%ILED(J) = 0
          YDQTYPE%ILEV(J) = 0
        END IF
      END DO

!        2.1 Global dimensions for fitted/non-fitted fields in gp space

      YDQTYPE%NFPDYNB = 0
      YDQTYPE%NFPAUXB = 0
      DO J = 1, YDQTYPE%NFPOSDYN
        IJ = YDQTYPE%NFPTRDYN(J)
        YDQTYPE%NFPDYNB = YDQTYPE%NFPDYNB + YDQTYPE%ILEV(IJ)
        YDQTYPE%NFPAUXB = YDQTYPE%NFPAUXB + (1 - MIN(YDQTYPE%ISF(IJ), 1))*YDQTYPE%ILEV(IJ)
      END DO

!        3.7 "B-level" distribution (balanced here for direct transforms)

      YDQTYPE%ISET(:, :) = 1
      IF (NPRTRV > 1) THEN
        IVCOUNT(:) = 0
! Make 2 scans to improve balance : first those which have more that 1 field :
        DO J = 1, YDQTYPE%NFPOSDYN
          IJ = YDQTYPE%NFPTRDYN(J)
          IF (YDQTYPE%ISF(IJ) >= 1 .AND. YDQTYPE%ISKP(IJ) > 1) THEN
            DO JL = 1, YDQTYPE%ILEV(IJ)
              IF (YDQTYPE%ILED(IJ) /= 1) THEN
!         Any field but U-vector momenta in direct transforms :
                ILOC = MINLOC(IVCOUNT)
                IVSET = ILOC(1)
                YDQTYPE%ISET(JL, IJ) = IVSET
                IVCOUNT(IVSET) = IVCOUNT(IVSET) + YDQTYPE%ISKP(IJ)
                IF (YDQTYPE%ILED(IJ) < 0) THEN
!           V-vector momenta => put counterpart U on the same set
                  I = -YDQTYPE%ILED(IJ)
                  YDQTYPE%ISET(JL, I) = IVSET
                  IVCOUNT(IVSET) = IVCOUNT(IVSET) + YDQTYPE%ISKP(I)
                END IF
              END IF
            END DO
          END IF
        END DO
        DO J = 1, YDQTYPE%NFPOSDYN
          IJ = YDQTYPE%NFPTRDYN(J)
          IF (YDQTYPE%ISF(IJ) >= 1 .AND. YDQTYPE%ISKP(IJ) == 1) THEN
            DO JL = 1, YDQTYPE%ILEV(IJ)
              IF (YDQTYPE%ILED(IJ) /= 1) THEN
!         Any field but U-vector momenta in direct transforms :
                ILOC = MINLOC(IVCOUNT)
                IVSET = ILOC(1)
                YDQTYPE%ISET(JL, IJ) = IVSET
                IVCOUNT(IVSET) = IVCOUNT(IVSET) + YDQTYPE%ISKP(IJ)
                IF (YDQTYPE%ILED(IJ) < 0) THEN
!           V-vector momenta => put counterpart U on the same set
                  I = -YDQTYPE%ILED(IJ)
                  YDQTYPE%ISET(JL, I) = IVSET
                  IVCOUNT(IVSET) = IVCOUNT(IVSET) + YDQTYPE%ISKP(I)
                END IF
              END IF
            END DO
          END IF
        END DO
      END IF

!        2.2 Global/Local dimensions

      YDQTYPE%NFPGT1 = 0
      YDQTYPE%NFPGT0B = 0
      YDQTYPE%NFPSCAG = 0
      IMOMDIRG = 0
      YDQTYPE%NFPISCAG = 0
      IMOMINVG = 0
      YDQTYPE%NFPSPD = 0
      YDQTYPE%NFPSPB = 0
      YDQTYPE%NFPSCA = 0
      IMOMDIR = 0
      YDQTYPE%NFPISCA = 0
      IMOMINV = 0
      YDQTYPE%NFPUVMN = 0
      YDQTYPE%ILOC(:, :) = 0
      IVPTR(:) = 0
      YDQTYPE%ISPD(:, :) = 0
      DO J = 1, YDQTYPE%NFPOSDYN
        IJ = YDQTYPE%NFPTRDYN(J)
        ! YDQTYPE%ISPD : Count how many arrays fields are spread over
        ISPREAD = MAX(0, YDQTYPE%ISF(IJ) - 2)
        DO JL = 1, YDQTYPE%ILEV(IJ)
          YDQTYPE%ISPD(JL, IJ) = ISPREAD*(YDQTYPE%IDOM(JL, IJ)) + (1 - ISPREAD)
        END DO
        IF (YDQTYPE%ISF(IJ) >= 1) THEN
          ISDIR = MAX(0, (1 - ABS(YDQTYPE%ILED(IJ))))
          IF (YDQTYPE%ILED(IJ) == 1 .OR. YDQTYPE%ILED(IJ) < 0) THEN
            ISINV = 0
          ELSE
            ISINV = 1
          END IF
          DO JL = 1, YDQTYPE%ILEV(IJ)
            INC = YDQTYPE%ISPD(JL, IJ)
            YDQTYPE%NFPGT1 = YDQTYPE%NFPGT1 + YDQTYPE%ISKP(IJ)
            YDQTYPE%NFPSCAG = YDQTYPE%NFPSCAG + YDQTYPE%ISKP(IJ)*ISDIR
            IMOMDIRG = IMOMDIRG + YDQTYPE%ISKP(IJ)*(1 - ISDIR)
            IF (YDQTYPE%IFIT /= 2) YDQTYPE%NFPGT0B = YDQTYPE%NFPGT0B + INC
            YDQTYPE%NFPISCAG = YDQTYPE%NFPISCAG + INC*ISINV
            IMOMINVG = IMOMINVG + INC*(1 - ISINV)
            IVSET = YDQTYPE%ISET(JL, IJ)
            IVPTR(IVSET) = IVPTR(IVSET) + 1
            YDQTYPE%ILOC(JL, IJ) = IVPTR(IVSET)
            IF (IVSET == MYSETV) THEN
              ! V-set local dimensions
              YDQTYPE%NFPSPD = YDQTYPE%NFPSPD + MAX(0, YDQTYPE%ISF(IJ) - 2)
              YDQTYPE%NFPSCA = YDQTYPE%NFPSCA + YDQTYPE%ISKP(IJ)*ISDIR
              IMOMDIR = IMOMDIR + YDQTYPE%ISKP(IJ)*(1 - ISDIR)
              YDQTYPE%NFPSPB = YDQTYPE%NFPSPB + INC
              YDQTYPE%NFPISCA = YDQTYPE%NFPISCA + INC*ISINV
              IMOMINV = IMOMINV + INC*(1 - ISINV)
              YDQTYPE%NFPUVMN = YDQTYPE%NFPUVMN + INC*MAX(0, -SIGN(1, YDQTYPE%ILED(IJ)))
            END IF
          END DO
        END IF
      END DO
      IF (MOD(IMOMDIRG, 2) /= 0) THEN
        status = 2; return
      ELSEIF (MOD(IMOMINVG, 2) /= 0) THEN
        status = 2; return
      ELSE
        YDQTYPE%NFPVECG = IMOMDIRG/2
        YDQTYPE%NFPIVECG = IMOMINVG/2
      END IF
      IF (MOD(IMOMDIR, 2) /= 0) THEN
        status = 2; return
      ELSEIF (MOD(IMOMINV, 2) /= 0) THEN
        status = 2; return
      ELSE
        YDQTYPE%NFPVEC = IMOMDIR/2
        YDQTYPE%NFPIVEC = IMOMINV/2
      END IF

!*       3.    COMPUTE POINTERS
!              ----------------

! Compute pointers for GT1/GAUX (splitting the flow gp data against spectrally fitted data)

      IVOR = 1
      IDIV = YDQTYPE%NFPVECG + 1
      ISCA1 = 2*YDQTYPE%NFPVECG + 1
      IUMOM = 1
      IVMOM = YDQTYPE%NFPIVECG + 1
      ISCA0 = 2*YDQTYPE%NFPIVECG + 1
      YDQTYPE%IGT1(:, :) = 0
      IPTRGPX = 1
      YDQTYPE%IGPX(:) = 0
      DO J = 1, YDQTYPE%NFPOSDYN
        IJ = YDQTYPE%NFPTRDYN(J)
        IF (YDQTYPE%ISF(IJ) >= 1) THEN
          ! Pointers % transforms :
          INC = YDQTYPE%ILEV(IJ)
          ISPREAD = 0
          IF (YDQTYPE%IFIT /= 2) THEN
            ! No "stretching effect" on the target grids
            DO JL = 1, INC
              ISPREAD = ISPREAD + YDQTYPE%ISPD(JL, IJ)
            END DO
          END IF
          SELECT CASE (YDQTYPE%ILED(IJ))
          CASE (0)
            ! Scalar
            YDQTYPE%IGT1(IJ, 1) = ISCA1
            ISCA1 = ISCA1 + INC
            YDQTYPE%IGT1(IJ, 0) = ISCA0
            ISCA0 = ISCA0 + ISPREAD
          CASE (:-1)
            ! V from (U,V)<=>(Vor,Div) : set Vor then Div for direct transforms
            YDQTYPE%IGT1(-YDQTYPE%ILED(IJ), 1) = IVOR
            IVOR = IVOR + INC
            YDQTYPE%IGT1(IJ, 1) = IDIV
            IDIV = IDIV + INC
            ! set U then V for inverse transforms
            YDQTYPE%IGT1(-YDQTYPE%ILED(IJ), 0) = IUMOM
            IUMOM = IUMOM + ISPREAD
            YDQTYPE%IGT1(IJ, 0) = IVMOM
            IVMOM = IVMOM + ISPREAD
          CASE (2, 3)
            !  (U,V) for individual Vor or Div : set Vor then Div
            YDQTYPE%IGT1(IJ, 1) = IVOR
            IVOR = IVOR + INC
            YDQTYPE%IGT1(IJ, 2) = IDIV
            IDIV = IDIV + INC
            ! set as scalar in inverse transforms because only 1 field selected
            YDQTYPE%IGT1(IJ, 0) = ISCA0
            ISCA0 = ISCA0 + ISPREAD
          END SELECT
        ELSE
          YDQTYPE%IGPX(IJ) = IPTRGPX
          IPTRGPX = IPTRGPX + YDQTYPE%ILEV(IJ)
        END IF
      END DO

!     ------------------------------------------------------------------
    END ASSOCIATE
    if (lhook) call dr_hook('CPVPOSPR', 1, zhook_handle)
    status = 0
  end function
end module
