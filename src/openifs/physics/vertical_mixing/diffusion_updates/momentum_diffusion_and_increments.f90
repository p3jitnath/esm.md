!> Ordered implicit momentum diffusion and tendency increments.
!! Arrays use native Fortran column order. The caller establishes nearest-even
!! rounding, gradual underflow, finite admitted physical inputs and finite
!! intermediates. Inputs may share storage. Complete output owners are disjoint
!! from every input and from one another. No allocation or model global is used.
module forecast_momentum_diffusion
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  implicit none
  private
  public :: vdfdifm, vdfincr
contains
  !> Solve both horizontal winds and return six drag tendencies.
  !! Layer inputs and outputs have shape (KLON,KLEV); face pressure, mass flux
  !! and plume winds have shape (KLON,0:KLEV). Currents have shape (KLON).
  !! PTMST is seconds, RG is m/s**2, winds are m/s and pressure is Pa.
  !! KTOP is1:KLEV-1; KLEV is2:1024 and KLON is0:4096.
  !! Return0 after success,2 before mutation for unsupported shapes or bounds.
  integer(int32) function vdfdifm(kidia,kfdia,klon,klev,ktop,ptmst,pum1,pvm1,paphm1,pcfm,ptodc,psoteu,psotev,psoc,pvom,pvol,pucurr,pvcurr,pmflx,puuh,pvuh,pudif,pvdif,pdtutofd,pdtvtofd,pdtuso,pdtvso,pdtuvdf,pdtvvdf,rg) result(status)
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, ktop
    real(real64), intent(in) :: ptmst, rg
    real(real64),intent(in),target :: pum1(:,:),pvm1(:,:),pcfm(:,:),ptodc(:,:),psoteu(:,:),psotev(:,:),psoc(:,:),pvom(:,:),pvol(:,:)
    real(real64), intent(in), target :: paphm1(:, 0:), pmflx(:, 0:), puuh(:, 0:), pvuh(:, 0:)
    real(real64), intent(in), target :: pucurr(:), pvcurr(:)
    real(real64),intent(inout),target :: pudif(:,:),pvdif(:,:),pdtutofd(:,:),pdtvtofd(:,:),pdtuso(:,:),pdtvso(:,:),pdtuvdf(:,:),pdtvvdf(:,:)
    real(real64) :: gamma(max(1, min(klev, 1024)))
    real(real64) :: pressure_scale, inverse_step, ratio, lower, diagonal, upper
    real(real64) :: beta, previous_upper, forcing_u, forcing_v, mass_now, mass_before
    real(real64) :: flux_now_u, flux_now_v, flux_before_u, flux_before_v, drag, temporary
    real(real64) :: total_u, total_v, negative_drag
    real(real64), volatile :: convective_multiplier
    integer :: j, k
    status = 2_int32
    if (klon < 0 .or. klon > 4096 .or. klev < 2 .or. klev > 1024) return
    if (ktop < 1 .or. ktop >= klev .or. kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. is_contiguous(pum1)) return
    if (size(pum1, 1) < klon .or. size(pum1, 2) < klev) return
    if (.not. is_contiguous(pvm1)) return
    if (size(pvm1, 1) < klon .or. size(pvm1, 2) < klev) return
    if (.not. is_contiguous(pcfm)) return
    if (size(pcfm, 1) < klon .or. size(pcfm, 2) < klev) return
    if (.not. is_contiguous(ptodc)) return
    if (size(ptodc, 1) < klon .or. size(ptodc, 2) < klev) return
    if (.not. is_contiguous(psoteu)) return
    if (size(psoteu, 1) < klon .or. size(psoteu, 2) < klev) return
    if (.not. is_contiguous(psotev)) return
    if (size(psotev, 1) < klon .or. size(psotev, 2) < klev) return
    if (.not. is_contiguous(psoc)) return
    if (size(psoc, 1) < klon .or. size(psoc, 2) < klev) return
    if (.not. is_contiguous(pvom)) return
    if (size(pvom, 1) < klon .or. size(pvom, 2) < klev) return
    if (.not. is_contiguous(pvol)) return
    if (size(pvol, 1) < klon .or. size(pvol, 2) < klev) return
    if (.not. is_contiguous(pudif)) return
    if (size(pudif, 1) < klon .or. size(pudif, 2) < klev) return
    if (.not. is_contiguous(pvdif)) return
    if (size(pvdif, 1) < klon .or. size(pvdif, 2) < klev) return
    if (.not. is_contiguous(pdtutofd)) return
    if (size(pdtutofd, 1) < klon .or. size(pdtutofd, 2) < klev) return
    if (.not. is_contiguous(pdtvtofd)) return
    if (size(pdtvtofd, 1) < klon .or. size(pdtvtofd, 2) < klev) return
    if (.not. is_contiguous(pdtuso)) return
    if (size(pdtuso, 1) < klon .or. size(pdtuso, 2) < klev) return
    if (.not. is_contiguous(pdtvso)) return
    if (size(pdtvso, 1) < klon .or. size(pdtvso, 2) < klev) return
    if (.not. is_contiguous(pdtuvdf)) return
    if (size(pdtuvdf, 1) < klon .or. size(pdtuvdf, 2) < klev) return
    if (.not. is_contiguous(pdtvvdf)) return
    if (size(pdtvvdf, 1) < klon .or. size(pdtvvdf, 2) < klev) return
    if (.not. is_contiguous(paphm1)) return
    if (size(paphm1, 1) < klon .or. size(paphm1, 2) < klev + 1) return
    if (.not. is_contiguous(pmflx)) return
    if (size(pmflx, 1) < klon .or. size(pmflx, 2) < klev + 1) return
    if (.not. is_contiguous(puuh)) return
    if (size(puuh, 1) < klon .or. size(puuh, 2) < klev + 1) return
    if (.not. is_contiguous(pvuh)) return
    if (size(pvuh, 1) < klon .or. size(pvuh, 2) < klev + 1) return
    if (.not. is_contiguous(pucurr)) return
    if (size(pucurr) < klon) return
    if (.not. is_contiguous(pvcurr)) return
    if (size(pvcurr) < klon) return
    ! The source calculates these scalars even for an empty selected range.
    pressure_scale = rg*ptmst
    inverse_step = 1.0_real64/ptmst
    convective_multiplier = 0.0_real64
    do j = kidia, kfdia
      beta = 0.0_real64
      previous_upper = 0.0_real64
      do k = ktop, klev
        ratio = paphm1(j, k) - paphm1(j, k - 1)
        ratio = pressure_scale/ratio
        upper = -pcfm(j, k)
        upper = upper*ratio
        drag = ptodc(j, k) + psoc(j, k)
        drag = drag*ptmst
        mass_now = pmflx(j, k)*convective_multiplier
        mass_before = pmflx(j, k - 1)*convective_multiplier
        if (k == ktop) then
          lower = 0.0_real64
          temporary = pcfm(j, k) + mass_now
        else
          lower = -pcfm(j, k - 1)
          lower = lower - mass_before
          lower = lower*ratio
          temporary = pcfm(j, k - 1) + pcfm(j, k)
          if (k /= klev) temporary = temporary + mass_now
        end if
        temporary = temporary*ratio
        diagonal = 1.0_real64 + temporary
        diagonal = diagonal + drag
        if (k == klev) upper = 0.0_real64
        forcing_u = pvom(j, k) + psoteu(j, k)
        forcing_u = ptmst*forcing_u
        forcing_u = pum1(j, k) + forcing_u
        forcing_v = pvol(j, k) + psotev(j, k)
        forcing_v = ptmst*forcing_v
        forcing_v = pvm1(j, k) + forcing_v
        if (k == ktop) then
          flux_now_u = mass_now*puuh(j, k)
          flux_now_v = mass_now*pvuh(j, k)
          temporary = flux_now_u*ratio
          forcing_u = forcing_u + temporary
          temporary = flux_now_v*ratio
          forcing_v = forcing_v + temporary
        else if (k == klev) then
          flux_before_u = mass_before*puuh(j, k - 1)
          flux_before_v = mass_before*pvuh(j, k - 1)
          temporary = flux_before_u*ratio
          forcing_u = forcing_u - temporary
          temporary = flux_before_v*ratio
          forcing_v = forcing_v - temporary
        else
          flux_now_u = mass_now*puuh(j, k)
          flux_now_v = mass_now*pvuh(j, k)
          flux_before_u = mass_before*puuh(j, k - 1)
          flux_before_v = mass_before*pvuh(j, k - 1)
          temporary = flux_now_u - flux_before_u
          temporary = temporary*ratio
          forcing_u = forcing_u + temporary
          temporary = flux_now_v - flux_before_v
          temporary = temporary*ratio
          forcing_v = forcing_v + temporary
        end if
        if (k == ktop) then
          beta = 1.0_real64/diagonal
        else
          gamma(k) = previous_upper*beta
          temporary = lower*gamma(k)
          temporary = diagonal - temporary
          beta = 1.0_real64/temporary
          temporary = lower*pudif(j, k - 1)
          forcing_u = forcing_u - temporary
          temporary = lower*pvdif(j, k - 1)
          forcing_v = forcing_v - temporary
          if (k == klev) then
            temporary = pcfm(j, k)*ratio
            forcing_u = forcing_u + temporary*pucurr(j)
            forcing_v = forcing_v + temporary*pvcurr(j)
          end if
        end if
        pudif(j, k) = forcing_u*beta
        pvdif(j, k) = forcing_v*beta
        previous_upper = upper
      end do
      do k = klev - 1, ktop, -1
        temporary = gamma(k + 1)*pudif(j, k + 1)
        pudif(j, k) = pudif(j, k) - temporary
        temporary = gamma(k + 1)*pvdif(j, k + 1)
        pvdif(j, k) = pvdif(j, k) - temporary
      end do
      do k = 1, ktop - 1
        pdtutofd(j, k) = 0.0_real64
        pdtvtofd(j, k) = 0.0_real64
        pdtuso(j, k) = 0.0_real64
        pdtvso(j, k) = 0.0_real64
        pdtuvdf(j, k) = 0.0_real64
        pdtvvdf(j, k) = 0.0_real64
      end do
      do k = ktop, klev
        total_u = pudif(j, k) - pum1(j, k)
        total_u = total_u*inverse_step
        total_v = pvdif(j, k) - pvm1(j, k)
        total_v = total_v*inverse_step
        negative_drag = -ptodc(j, k)
        pdtutofd(j, k) = pudif(j, k)*negative_drag
        pdtvtofd(j, k) = pvdif(j, k)*negative_drag
        negative_drag = -psoc(j, k)
        temporary = pudif(j, k)*negative_drag
        pdtuso(j, k) = temporary + psoteu(j, k)
        temporary = pvdif(j, k)*negative_drag
        pdtvso(j, k) = temporary + psotev(j, k)
        temporary = total_u - pvom(j, k)
        pdtuvdf(j, k) = temporary - pdtuso(j, k)
        temporary = total_v - pvol(j, k)
        pdtvvdf(j, k) = temporary - pdtvso(j, k)
      end do
    end do
    status = 0_int32
  end function vdfdifm

  !> Update tendencies, pressure-weighted momentum flux and energy losses.
  !! Layer arrays have shape (KLON,KLEV), fluxes and pressure (KLON,0:KLEV),
  !! and integral/bottom-flux vectors (KLON). PTMST is seconds, RG is m/s**2.
  !! Pressure is Pa. Winds are m/s; PDISGW3D is J/kg. The old thermodynamic
  !! inputs and KTOP remain unread. KLON0:4096 and KLEV0:1024 are supported.
  !! Complete owners are INOUT so unselected cells retain incoming bytes.
  integer(int32) function vdfincr(kidia,kfdia,klon,klev,ktop,ptmst,pum1,pvm1,pslgm1,ptm1,pqtm1,paphm1,pdtutofd,pdtvtofd,pdtuso,pdtvso,pdtuvdf,pdtvvdf,pvom,pvol,pslge,pqte,pslgevdf,pqtevdf,pslgewodis,pvdis,pvdisg,pstrtu,pstrtv,pstrsou,pstrsov,pstrtofdu,pstrtofdv,ptofdu,ptofdv,pdisgw3d,rg) result(status)
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, ktop
    real(real64), intent(in) :: ptmst, rg
    real(real64),intent(in),target :: pum1(:,:),pvm1(:,:),pslgm1(:,:),ptm1(:,:),pqtm1(:,:),pdtutofd(:,:),pdtvtofd(:,:),pdtuso(:,:),pdtvso(:,:),pdtuvdf(:,:),pdtvvdf(:,:),pslgevdf(:,:),pqtevdf(:,:)
    real(real64), intent(in), target :: paphm1(:, 0:)
    real(real64), intent(inout), target :: pvom(:, :), pvol(:, :), pslge(:, :), pqte(:, :), pslgewodis(:, :), pdisgw3d(:, :)
    real(real64),intent(inout),target :: pstrtu(:,0:),pstrtv(:,0:),pstrsou(:,0:),pstrsov(:,0:),pstrtofdu(:,0:),pstrtofdv(:,0:)
    real(real64), intent(inout), target :: pvdis(:), pvdisg(:), ptofdu(:), ptofdv(:)
    real(real64) :: inverse_step, inverse_mass_step, inverse_gravity, pressure_difference, mass
    real(real64) :: u1, u2, u3, v1, v2, v3, loss_vdf, loss_so, first, second, temporary
    integer :: j, k
    status = 2_int32
    if (klon < 0 .or. klon > 4096 .or. klev < 0 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. is_contiguous(pum1)) return
    if (size(pum1, 1) < klon .or. size(pum1, 2) < klev) return
    if (.not. is_contiguous(pvm1)) return
    if (size(pvm1, 1) < klon .or. size(pvm1, 2) < klev) return
    if (.not. is_contiguous(pslgm1)) return
    if (size(pslgm1, 1) < klon .or. size(pslgm1, 2) < klev) return
    if (.not. is_contiguous(ptm1)) return
    if (size(ptm1, 1) < klon .or. size(ptm1, 2) < klev) return
    if (.not. is_contiguous(pqtm1)) return
    if (size(pqtm1, 1) < klon .or. size(pqtm1, 2) < klev) return
    if (.not. is_contiguous(pdtutofd)) return
    if (size(pdtutofd, 1) < klon .or. size(pdtutofd, 2) < klev) return
    if (.not. is_contiguous(pdtvtofd)) return
    if (size(pdtvtofd, 1) < klon .or. size(pdtvtofd, 2) < klev) return
    if (.not. is_contiguous(pdtuso)) return
    if (size(pdtuso, 1) < klon .or. size(pdtuso, 2) < klev) return
    if (.not. is_contiguous(pdtvso)) return
    if (size(pdtvso, 1) < klon .or. size(pdtvso, 2) < klev) return
    if (.not. is_contiguous(pdtuvdf)) return
    if (size(pdtuvdf, 1) < klon .or. size(pdtuvdf, 2) < klev) return
    if (.not. is_contiguous(pdtvvdf)) return
    if (size(pdtvvdf, 1) < klon .or. size(pdtvvdf, 2) < klev) return
    if (.not. is_contiguous(pslgevdf)) return
    if (size(pslgevdf, 1) < klon .or. size(pslgevdf, 2) < klev) return
    if (.not. is_contiguous(pqtevdf)) return
    if (size(pqtevdf, 1) < klon .or. size(pqtevdf, 2) < klev) return
    if (.not. is_contiguous(pvom)) return
    if (size(pvom, 1) < klon .or. size(pvom, 2) < klev) return
    if (.not. is_contiguous(pvol)) return
    if (size(pvol, 1) < klon .or. size(pvol, 2) < klev) return
    if (.not. is_contiguous(pslge)) return
    if (size(pslge, 1) < klon .or. size(pslge, 2) < klev) return
    if (.not. is_contiguous(pqte)) return
    if (size(pqte, 1) < klon .or. size(pqte, 2) < klev) return
    if (.not. is_contiguous(pslgewodis)) return
    if (size(pslgewodis, 1) < klon .or. size(pslgewodis, 2) < klev) return
    if (.not. is_contiguous(pdisgw3d)) return
    if (size(pdisgw3d, 1) < klon .or. size(pdisgw3d, 2) < klev) return
    if (.not. is_contiguous(paphm1)) return
    if (size(paphm1, 1) < klon .or. size(paphm1, 2) < klev + 1) return
    if (.not. is_contiguous(pstrtu)) return
    if (size(pstrtu, 1) < klon .or. size(pstrtu, 2) < klev + 1) return
    if (.not. is_contiguous(pstrtv)) return
    if (size(pstrtv, 1) < klon .or. size(pstrtv, 2) < klev + 1) return
    if (.not. is_contiguous(pstrsou)) return
    if (size(pstrsou, 1) < klon .or. size(pstrsou, 2) < klev + 1) return
    if (.not. is_contiguous(pstrsov)) return
    if (size(pstrsov, 1) < klon .or. size(pstrsov, 2) < klev + 1) return
    if (.not. is_contiguous(pstrtofdu)) return
    if (size(pstrtofdu, 1) < klon .or. size(pstrtofdu, 2) < klev + 1) return
    if (.not. is_contiguous(pstrtofdv)) return
    if (size(pstrtofdv, 1) < klon .or. size(pstrtofdv, 2) < klev + 1) return
    if (.not. is_contiguous(pvdis)) return
    if (size(pvdis) < klon) return
    if (.not. is_contiguous(pvdisg)) return
    if (size(pvdisg) < klon) return
    if (.not. is_contiguous(ptofdu)) return
    if (size(ptofdu) < klon) return
    if (.not. is_contiguous(ptofdv)) return
    if (size(ptofdv) < klon) return
    inverse_step = 1.0_real64/ptmst
    temporary = rg*ptmst
    inverse_mass_step = 1.0_real64/temporary
    inverse_gravity = 1.0_real64/rg
    do j = kidia, kfdia
      pvdis(j) = 0.0_real64
      pvdisg(j) = 0.0_real64
      pstrtu(j, 0) = 0.0_real64
      pstrtv(j, 0) = 0.0_real64
      pstrsou(j, 0) = 0.0_real64
      pstrsov(j, 0) = 0.0_real64
      pstrtofdu(j, 0) = 0.0_real64
      pstrtofdv(j, 0) = 0.0_real64
      ptofdu(j) = 0.0_real64
      ptofdv(j) = 0.0_real64
    end do
    do k = 1, klev
      do j = kidia, kfdia
        pressure_difference = paphm1(j, k) - paphm1(j, k - 1)
        mass = -pressure_difference
        mass = mass*inverse_gravity
        temporary = pvom(j, k)*ptmst
        u1 = pum1(j, k) + temporary
        temporary = pvol(j, k)*ptmst
        v1 = pvm1(j, k) + temporary
        temporary = pdtuvdf(j, k)*ptmst
        u2 = u1 + temporary
        temporary = pdtvvdf(j, k)*ptmst
        v2 = v1 + temporary
        temporary = pdtuso(j, k)*ptmst
        u3 = u2 + temporary
        temporary = pdtvso(j, k)*ptmst
        v3 = v2 + temporary
        first = u1 - u2
        first = 0.5_real64*first
        temporary = u1 + u2
        first = first*temporary
        second = v1 - v2
        second = 0.5_real64*second
        temporary = v1 + v2
        second = second*temporary
        loss_vdf = first + second
        first = u2 - u3
        first = 0.5_real64*first
        temporary = u2 + u3
        first = first*temporary
        second = v2 - v3
        second = 0.5_real64*second
        temporary = v2 + v3
        second = second*temporary
        loss_so = first + second
        pdisgw3d(j, k) = loss_so
        temporary = pdtuvdf(j, k)*mass
        pstrtu(j, k) = temporary + pstrtu(j, k - 1)
        temporary = pdtvvdf(j, k)*mass
        pstrtv(j, k) = temporary + pstrtv(j, k - 1)
        temporary = pdtuso(j, k)*mass
        pstrsou(j, k) = temporary + pstrsou(j, k - 1)
        temporary = pdtvso(j, k)*mass
        pstrsov(j, k) = temporary + pstrsov(j, k - 1)
        temporary = pdtutofd(j, k)*mass
        pstrtofdu(j, k) = temporary + pstrtofdu(j, k - 1)
        temporary = pdtvtofd(j, k)*mass
        pstrtofdv(j, k) = temporary + pstrtofdv(j, k - 1)
        temporary = pvom(j, k) + pdtuvdf(j, k)
        pvom(j, k) = temporary + pdtuso(j, k)
        temporary = pvol(j, k) + pdtvvdf(j, k)
        pvol(j, k) = temporary + pdtvso(j, k)
        temporary = loss_vdf*pressure_difference
        pvdis(j) = pvdis(j) + temporary
        temporary = loss_so*pressure_difference
        pvdisg(j) = pvdisg(j) + temporary
        pqte(j, k) = pqte(j, k) + pqtevdf(j, k)
        first = pslge(j, k) + pslgevdf(j, k)
        pslgewodis(j, k) = first
        temporary = loss_vdf + loss_so
        temporary = temporary*inverse_step
        pslge(j, k) = first + temporary
      end do
    end do
    do j = kidia, kfdia
      ptofdu(j) = pstrtofdu(j, klev)
      ptofdv(j) = pstrtofdv(j, klev)
      pvdis(j) = pvdis(j)*inverse_mass_step
      pvdisg(j) = pvdisg(j)*inverse_mass_step
    end do
    status = 0_int32
  end function vdfincr
end module forecast_momentum_diffusion
