!> Solve the coupled surface heat and water balance for each active column.
!! The caller supplies initialized native surface records and nearest-even
!! FP64 arithmetic with gradual underflow. No original model globals are read.
module forecast_native_surface_energy_balance
  use iso_fortran_env, only: int32, real64
  use yos_cst, only: tcst
  use yos_exc, only: texc
  use yos_veg, only: tveg
  use yos_flake, only: tflake
  use yos_soil, only: tsoil
  use yos_urb, only: turb
  use yos_surf, only: tsurf
  implicit none
  private
  public :: surfseb_ctl, surfseb
contains
  !> Form tile fluxes and solve the two equations for the lowest air layer.
  !! Integer controls are int32. Every real argument is FP64. Input and output
  !! tile arrays have shape at least (KLON,KTILES); vectors have at least KLON
  !! elements. Only KIDIA:KFDIA and tiles 1:KTILES change. Owners must be
  !! disjoint; positive strided views and unchanged trailing values are allowed.
  !! PSSKM1M/PSSK and PSL are J/kg; temperatures are K; PQSKM1M/PQL are kg/kg.
  !! PDQSDT is 1/K, transfer coefficients are kg/(m2 s), tile fractions and
  !! emissivity are dimensionless, PLAMSK is W/(m2 K), and heat fluxes are W/m2.
  !! PJQ is kg/(m2 s). The remaining coefficient units follow their named
  !! surface equations in the local contract. RVTMP2 is the source heat
  !! capacity moisture coefficient, supplied as RVTMP2 without recomputation.
  !! PTMST (s), vegetation indices, snow and ice inputs, and SOIL/URB records
  !! retain the source interface; the frozen calculation does not consume them.
  !! Status 0 means success; 2 means an unsupported bound or incomplete owner.
  !! A refusal occurs before any output changes. Finite physical inputs and
  !! finite, nonzero coupled denominators are caller requirements.
  subroutine surfseb_ctl(rvtmp2, kidia, kfdia, klon, ktiles, ktvl, ktvh, &
                         ptmst, psskm1m, ptskm1m, pqskm1m, pdqsdt, prhochu, prhocqu, &
                         palphal, palphas, pssrfl, pfrti, ptsrf, plamsk, psnm, prsn, phlice, &
                         pslrfl, ptskrad, pemis, pasl, pbsl, paql, pbql, pthkice, psntice, &
                         ydcst, ydexc, ydveg, ydflake, ydsoil, ydurb, &
                         pjs, pjq, pssk, ptsk, pssh, pslh, pstr, pg0, psl, pql, lnemolimthk, status)
    real(real64), intent(in) :: rvtmp2, ptmst
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, ktvl(:), ktvh(:)
    real(real64), intent(in) :: psskm1m(:, :), ptskm1m(:, :), pqskm1m(:, :), pdqsdt(:, :)
    real(real64), intent(in) :: prhochu(:, :), prhocqu(:, :), palphal(:, :), palphas(:, :)
    real(real64), intent(in) :: pssrfl(:, :), pfrti(:, :), ptsrf(:, :), plamsk(:, :)
    real(real64), intent(in) :: psnm(:), prsn(:), phlice(:), pslrfl(:), ptskrad(:), pemis(:)
    real(real64), intent(in) :: pasl(:), pbsl(:), paql(:), pbql(:), pthkice(:), psntice(:)
    type(tcst), intent(in) :: ydcst
    type(texc), intent(in) :: ydexc
    type(tveg), intent(in) :: ydveg
    type(tflake), intent(in) :: ydflake
    type(tsoil), intent(in) :: ydsoil
    type(turb), intent(in) :: ydurb
    real(real64), intent(inout) :: pjs(:, :), pjq(:, :), pssk(:, :), ptsk(:, :)
    real(real64), intent(inout) :: pssh(:, :), pslh(:, :), pstr(:, :), pg0(:, :), psl(:), pql(:)
    logical, intent(in) :: lnemolimthk
    integer(int32), intent(out) :: status
    real(real64) :: dss1(10), dss2(10), dss4(10), djs1(10), djs2(10), djs4(10)
    real(real64) :: djq1(10), djq2(10), djq4(10), inverse_cp(10), conductance(10)
    real(real64) :: dlw, work, work2, cjs1, cjs3, cjq2, cjq3, cjq4, latent, coefficient
    real(real64) :: denominator, reciprocal, transmission, fraction
    real(real64) :: ejs1, ejs2, ejs4, ejq1, ejq2, ejq4
    real(real64) :: zz1, zz2, zz3, zy1, zy2, zy3, js, jq, sl, ql
    real(real64) :: static_energy, energy_flux, water_flux, temperature, mean_temperature
    logical :: lake_ice
    integer :: j, t, needed_vegetation_index

    status = 2_int32
    if (klon < 1 .or. klon > 4096 .or. ktiles < 1 .or. ktiles > 10) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (size(ktvl) < klon .or. size(ktvh) < klon) return
    if (.not. tile_owner(psskm1m, klon, ktiles)) return
    if (.not. tile_owner(ptskm1m, klon, ktiles)) return
    if (.not. tile_owner(pqskm1m, klon, ktiles)) return
    if (.not. tile_owner(pdqsdt, klon, ktiles)) return
    if (.not. tile_owner(prhochu, klon, ktiles)) return
    if (.not. tile_owner(prhocqu, klon, ktiles)) return
    if (.not. tile_owner(palphal, klon, ktiles)) return
    if (.not. tile_owner(palphas, klon, ktiles)) return
    if (.not. tile_owner(pssrfl, klon, ktiles)) return
    if (.not. tile_owner(pfrti, klon, ktiles)) return
    if (.not. tile_owner(ptsrf, klon, ktiles)) return
    if (.not. tile_owner(plamsk, klon, ktiles)) return
    if (size(psnm) < klon .or. size(prsn) < klon .or. size(phlice) < klon) return
    if (size(pslrfl) < klon .or. size(ptskrad) < klon .or. size(pemis) < klon) return
    if (size(pasl) < klon .or. size(pbsl) < klon .or. size(paql) < klon .or. size(pbql) < klon) return
    if (size(pthkice) < klon .or. size(psntice) < klon) return
    if (.not. tile_owner(pjs, klon, ktiles)) return
    if (.not. tile_owner(pjq, klon, ktiles)) return
    if (.not. tile_owner(pssk, klon, ktiles)) return
    if (.not. tile_owner(ptsk, klon, ktiles)) return
    if (.not. tile_owner(pssh, klon, ktiles)) return
    if (.not. tile_owner(pslh, klon, ktiles)) return
    if (.not. tile_owner(pstr, klon, ktiles)) return
    if (.not. tile_owner(pg0, klon, ktiles)) return
    if (size(psl) < klon .or. size(pql) < klon) return
    if (kidia > kfdia) then
      status = 0_int32
      return
    end if
    needed_vegetation_index = 0
    if (ktiles >= 3) needed_vegetation_index = 1
    if (ktiles >= 6) needed_vegetation_index = 3
    if (needed_vegetation_index > 0) then
      if (.not. allocated(ydveg%rvtrsr)) return
      if (lbound(ydveg%rvtrsr, 1) > 1 .or. ubound(ydveg%rvtrsr, 1) < needed_vegetation_index) return
    end if

    do j = kidia, kfdia
      lake_ice = phlice(j) > ydflake%rh_ice_min_flk
      if (ydexc%lelwdd) then
        work = -4.0_real64*pemis(j)
        work = work*ydcst%rsigma
        work2 = ptskrad(j)*ptskrad(j)
        work2 = work2*ptskrad(j)
        dlw = work*work2
      else
        work = pslrfl(j)/ptskrad(j)
        dlw = 4.0_real64*work
      end if
      ejs1 = 0.0_real64
      ejs2 = 0.0_real64
      ejs4 = 0.0_real64
      ejq1 = 0.0_real64
      ejq2 = 0.0_real64
      ejq4 = 0.0_real64
      do t = 1, ktiles
        inverse_cp(t) = ptskm1m(j, t)/psskm1m(j, t)
        cjs1 = prhochu(j, t)
        cjs3 = -cjs1
        cjq2 = prhocqu(j, t)*palphal(j, t)
        cjq3 = -prhocqu(j, t)
        cjq3 = cjq3*palphas(j, t)
        cjq3 = cjq3*pdqsdt(j, t)
        cjq3 = cjq3*inverse_cp(t)
        cjq4 = -prhocqu(j, t)
        cjq4 = cjq4*palphas(j, t)
        work = pdqsdt(j, t)*ptskm1m(j, t)
        work = pqskm1m(j, t) - work
        cjq4 = cjq4*work
        latent = ydcst%rlvtt
        if (t == 2 .or. t == 5 .or. (t == 9 .and. lake_ice)) latent = ydcst%rlstt
        work = ydcst%rcpd*ptskm1m(j, t)
        work = work*rvtmp2
        coefficient = latent - work
        conductance(t) = plamsk(j, t)
        denominator = dlw - conductance(t)
        denominator = denominator*inverse_cp(t)
        denominator = denominator + cjs3
        work = coefficient*cjq3
        denominator = denominator + work
        reciprocal = 1.0_real64/denominator
        dss1(t) = -cjs1
        dss1(t) = dss1(t)*reciprocal
        dss2(t) = -coefficient
        dss2(t) = dss2(t)*cjq2
        dss2(t) = dss2(t)*reciprocal
        transmission = 1.0_real64
        if (t == 3 .or. t == 4) transmission = 1.0_real64 - ydveg%rvtrsr(1)
        if (t == 6 .or. t == 7) transmission = 1.0_real64 - ydveg%rvtrsr(3)
        work = -pssrfl(j, t)
        work = work*transmission
        work = work - pslrfl(j)
        work2 = dlw*ptskrad(j)
        work = work + work2
        work2 = coefficient*cjq4
        work = work - work2
        work2 = conductance(t)*ptsrf(j, t)
        work = work - work2
        dss4(t) = work*reciprocal
        work = cjs3*dss1(t)
        djs1(t) = cjs1 + work
        djs2(t) = cjs3*dss2(t)
        djs4(t) = cjs3*dss4(t)
        djq1(t) = cjq3*dss1(t)
        work = cjq3*dss2(t)
        djq2(t) = cjq2 + work
        work = cjq3*dss4(t)
        djq4(t) = work + cjq4
        fraction = pfrti(j, t)
        work = fraction*djs1(t)
        ejs1 = ejs1 + work
        work = fraction*djs2(t)
        ejs2 = ejs2 + work
        work = fraction*djs4(t)
        ejs4 = ejs4 + work
        work = fraction*djq1(t)
        ejq1 = ejq1 + work
        work = fraction*djq2(t)
        ejq2 = ejq2 + work
        work = fraction*djq4(t)
        ejq4 = ejq4 + work
      end do

      work = pasl(j)*ejs1
      zz1 = 1.0_real64 - work
      zz2 = paql(j)*ejs2
      zz3 = pbsl(j)*ejs1
      work = pbql(j)*ejs2
      zz3 = zz3 + work
      zz3 = zz3 + ejs4
      work = paql(j)*ejq2
      zy1 = 1.0_real64 - work
      zy2 = pasl(j)*ejq1
      zy3 = pbsl(j)*ejq1
      work = pbql(j)*ejq2
      zy3 = zy3 + work
      zy3 = zy3 + ejq4
      denominator = zz1*zy1
      work = zz2*zy2
      denominator = denominator - work
      reciprocal = 1.0_real64/denominator
      jq = zz3*zy2
      work = zz1*zy3
      jq = jq + work
      jq = jq*reciprocal
      js = zz2*zy3
      work = zz3*zy1
      js = js + work
      js = js*reciprocal
      sl = pasl(j)*js
      sl = sl + pbsl(j)
      ql = paql(j)*jq
      ql = ql + pbql(j)
      psl(j) = sl
      pql(j) = ql

      mean_temperature = 0.0_real64
      do t = 1, ktiles
        static_energy = dss1(t)*sl
        work = dss2(t)*ql
        static_energy = static_energy + work
        static_energy = static_energy + dss4(t)
        energy_flux = djs1(t)*sl
        work = djs2(t)*ql
        energy_flux = energy_flux + work
        energy_flux = energy_flux + djs4(t)
        water_flux = djq1(t)*sl
        work = djq2(t)*ql
        water_flux = water_flux + work
        water_flux = water_flux + djq4(t)
        pssk(j, t) = static_energy
        pjs(j, t) = energy_flux
        pjq(j, t) = water_flux
        temperature = static_energy*inverse_cp(t)
        ptsk(j, t) = temperature
        work = ydcst%rcpd*ptskm1m(j, t)
        work = work*rvtmp2
        work = work*water_flux
        pssh(j, t) = energy_flux - work
        latent = ydcst%rlvtt
        if (t == 2 .or. t == 5 .or. (t == 9 .and. lake_ice)) latent = ydcst%rlstt
        pslh(j, t) = latent*water_flux
        work = temperature - ptskrad(j)
        work = dlw*work
        pstr(j, t) = pslrfl(j) + work
        work = temperature - ptsrf(j, t)
        pg0(j, t) = conductance(t)*work
        work = pfrti(j, t)*temperature
        mean_temperature = mean_temperature + work
      end do
      if (ydexc%lelwtl) then
        work = -4.0_real64*pemis(j)
        work = work*ydcst%rsigma
        work2 = mean_temperature*mean_temperature
        work2 = work2*mean_temperature
        dlw = work*work2
        do t = 1, ktiles
          work = ptsk(j, t) - mean_temperature
          work = dlw*work
          pstr(j, t) = pslrfl(j) + work
        end do
      end if
    end do
    status = 0_int32
  end subroutine surfseb_ctl

  !> Select the six parameter records from their canonical owned TSURF.
  !! This count-zero wrapper borrows YDSURF and forwards the same numerical
  !! arguments and mutations as SURFSEB_CTL. It makes no handle or registry call.
  subroutine surfseb(ydsurf, rvtmp2, kidia, kfdia, klon, ktiles, ktvl, ktvh, &
                     ptmst, psskm1m, ptskm1m, pqskm1m, pdqsdt, prhochu, prhocqu, &
                     palphal, palphas, pssrfl, pfrti, ptsrf, plamsk, psnm, prsn, phlice, &
                     pslrfl, ptskrad, pemis, pasl, pbsl, paql, pbql, pthkice, psntice, &
                     pjs, pjq, pssk, ptsk, pssh, pslh, pstr, pg0, psl, pql, lnemolimthk, status)
    type(tsurf), intent(in) :: ydsurf
    real(real64), intent(in) :: rvtmp2, ptmst
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, ktvl(:), ktvh(:)
    real(real64), intent(in) :: psskm1m(:, :), ptskm1m(:, :), pqskm1m(:, :), pdqsdt(:, :)
    real(real64), intent(in) :: prhochu(:, :), prhocqu(:, :), palphal(:, :), palphas(:, :)
    real(real64), intent(in) :: pssrfl(:, :), pfrti(:, :), ptsrf(:, :), plamsk(:, :)
    real(real64), intent(in) :: psnm(:), prsn(:), phlice(:), pslrfl(:), ptskrad(:), pemis(:)
    real(real64), intent(in) :: pasl(:), pbsl(:), paql(:), pbql(:), pthkice(:), psntice(:)
    real(real64), intent(inout) :: pjs(:, :), pjq(:, :), pssk(:, :), ptsk(:, :)
    real(real64), intent(inout) :: pssh(:, :), pslh(:, :), pstr(:, :), pg0(:, :), psl(:), pql(:)
    logical, intent(in) :: lnemolimthk
    integer(int32), intent(out) :: status
    call surfseb_ctl(rvtmp2, kidia, kfdia, klon, ktiles, ktvl, ktvh, &
                     ptmst, psskm1m, ptskm1m, pqskm1m, pdqsdt, prhochu, prhocqu, &
                     palphal, palphas, pssrfl, pfrti, ptsrf, plamsk, psnm, prsn, phlice, &
                     pslrfl, ptskrad, pemis, pasl, pbsl, paql, pbql, pthkice, psntice, &
                     ydsurf%ycst, ydsurf%yexc, ydsurf%yveg, ydsurf%yflake, ydsurf%ysoil, ydsurf%yurb, &
                     pjs, pjq, pssk, ptsk, pssh, pslh, pstr, pg0, psl, pql, lnemolimthk, status)
  end subroutine surfseb

  !> Check the declared two-dimensional owner without reading any field value.
  pure logical function tile_owner(owner, columns, tiles)
    real(real64), intent(in) :: owner(:, :)
    integer(int32), intent(in) :: columns, tiles
    tile_owner = size(owner, 1) >= columns .and. size(owner, 2) >= tiles
  end function tile_owner
end module forecast_native_surface_energy_balance
