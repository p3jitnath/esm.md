module srfvegevol_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int64_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yos_cst, only: tcst
  use yos_veg, only: tveg
  use yos_ags, only: tags
  use nitro_decline_mod, only: nitro_decline
  implicit none
  private
  public :: srfvegevol, md2asm_srfvegevol_native_calls_get
  integer(int64), save :: native_calls = 0_int64
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Advance leaf and structural biomass in vegetation_evolution.S order.
  !!
  !! PTSPHY is the physics step in seconds and PLAT is latitude in degrees.
  !! Leaf area arrays use m^2/m^2 and biomass arrays use kg/m^2.
  !! PCVT and KVEG have exactly KLON by YDVEG%NVTILES entries.
  !! The other tile arrays have the same shape and retain inactive columns.
  !! A nonempty PDHBIOS has at least five channels and PDHVEGS has two.
  !! Daily structural biomass clipping also applies to inactive columns.
  !! Native TCST, TVEG and TAGS records own their allocated parameter tables.
  subroutine srfvegevol(kidia, kfdia, klon, klevs, kstep, ptsphy, plat, pmu0, &
                        pcvt, pcvl, pcvh, kveg, itvl, itvh, ptskm1m, ptsam1m, panfmvt, pandayvt, &
                        plaivt, plail, plaih, plailc, plaihc, prespbstr, prespbstr2, pbiomass_last, &
                        pbiomasstr_last, pbiomasstr2_last, pblossvt, pbgainvt, plaie1, pbstre1, &
                        pbstr2e1, plai, pbiom, pbloss, pbgain, pbiomstr, pbiomstr2, pdhbios, pdhvegs, &
                        ydcst, ydveg, ydags)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevs, kstep
    real(real64), intent(in) :: ptsphy, plat(:), pmu0(:), pcvl(:), pcvh(:)
    real(real64), intent(in) :: ptskm1m(:), ptsam1m(:, :), plailc(:), plaihc(:)
    integer(int32), intent(in) :: itvl(:), itvh(:)
    integer(int32), intent(inout) :: kveg(:, :)
    real(real64), intent(inout) :: pcvt(:, :), panfmvt(:, :), pandayvt(:, :)
    real(real64), intent(inout) :: plaivt(:, :), plail(:), plaih(:)
    real(real64), intent(inout) :: prespbstr(:, :), prespbstr2(:, :)
    real(real64), intent(inout) :: pbiomass_last(:, :), pbiomasstr_last(:, :), pbiomasstr2_last(:, :)
    real(real64), intent(inout) :: pblossvt(:, :), pbgainvt(:, :), plaie1(:, :), pbstre1(:, :), pbstr2e1(:, :)
    real(real64), intent(inout) :: plai(:), pbiom(:), pbloss(:), pbgain(:), pbiomstr(:), pbiomstr2(:)
    real(real64), intent(inout) :: pdhbios(:, :, :), pdhvegs(:, :, :)
    type(tcst), intent(in) :: ydcst
    type(tveg), intent(in) :: ydveg
    type(tags), intent(in) :: ydags
    real(real64), allocatable :: biomass(:, :), old_leaf(:, :), old_structure(:, :), old_root(:, :)
    real(real64) :: climatology, previous, increment, value, temporary, weight, biomass_coefficient, steps_per_day
    real(real64), parameter :: biomass_floor = transfer(int(z'2AC1EAFF4A98553D', int64), 0.0_real64)
    integer(int32) :: column, tile, kind, tiles, vegetation_period, allocation_status
    logical :: biomass_diagnostics, leaf_diagnostics
    call require_ieee_mode()
    tiles = ydveg%nvtiles
    if (klon < 1 .or. klon > 4096 .or. kidia < 1 .or. kidia > klon + 1) call reject_contract()
    if (kfdia < 0 .or. kfdia > klon .or. kstep < 0) call reject_contract()
    if (tiles < 2 .or. tiles > 10 .or. klevs < 2 .or. klevs > 4) call reject_contract()
    if (.not. (ptsphy >= 1.0_real64 .and. ptsphy <= 86400.0_real64)) call reject_contract()
    if (.not. (ydveg%rlaiint >= 0.0_real64 .and. ydveg%rlaiint <= 1.0_real64)) call reject_contract()
    if (min(size(plat), size(pmu0), size(pcvl), size(pcvh), size(itvl), size(itvh), &
            size(ptskm1m), size(plail), size(plaih), size(plailc), size(plaihc), &
            size(plai), size(pbiom), size(pbloss), size(pbgain), size(pbiomstr), size(pbiomstr2)) < klon) call reject_contract()
    if (size(pcvt, 1) /= klon .or. size(pcvt, 2) /= tiles) call reject_contract()
    if (size(kveg, 1) /= klon .or. size(kveg, 2) /= tiles) call reject_contract()
    if (size(ptsam1m, 1) /= klon .or. size(ptsam1m, 2) < 2) call reject_contract()
    call require_tiles(panfmvt, klon, tiles)
    call require_tiles(pandayvt, klon, tiles)
    call require_tiles(plaivt, klon, tiles)
    call require_tiles(prespbstr, klon, tiles)
    call require_tiles(prespbstr2, klon, tiles)
    call require_tiles(pbiomass_last, klon, tiles)
    call require_tiles(pbiomasstr_last, klon, tiles)
    call require_tiles(pbiomasstr2_last, klon, tiles)
    call require_tiles(pblossvt, klon, tiles)
    call require_tiles(pbgainvt, klon, tiles)
    call require_tiles(plaie1, klon, tiles)
    ! PBSTRE1 can retain inactive columns after the active vegetation tiles.
    if (size(pbstre1, 1) /= klon .or. size(pbstre1, 2) < tiles) call reject_contract()
    call require_tiles(pbstr2e1, klon, tiles)
    biomass_diagnostics = size(pdhbios) > 0
    leaf_diagnostics = size(pdhvegs) > 0
    if (biomass_diagnostics) then
      if (size(pdhbios, 1) /= klon .or. size(pdhbios, 2) /= tiles .or. size(pdhbios, 3) < 5) call reject_contract()
    end if
    if (leaf_diagnostics) then
      if (size(pdhvegs, 1) /= klon .or. size(pdhvegs, 2) /= tiles .or. size(pdhvegs, 3) < 2) call reject_contract()
    end if
    do column = kidia, kfdia
      if (itvl(column) < 0 .or. itvl(column) > 20 .or. itvh(column) < 0 .or. itvh(column) > 20) call reject_contract()
    end do
    if (.not. allocated(ydags%rvbslai_nitro)) call reject_contract()
    if (lbound(ydags%rvbslai_nitro, 1) > 0 .or. ubound(ydags%rvbslai_nitro, 1) < 20) call reject_contract()
    allocate (biomass(klon, tiles), old_leaf(klon, tiles), old_structure(klon, tiles), &
              old_root(klon, tiles), stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    do tile = 1, tiles
      do column = kidia, kfdia
        pcvt(column, tile) = 0.0_real64
        plaivt(column, tile) = 0.0_real64
        kveg(column, tile) = 0_int32
        climatology = 0.0_real64
        if (tile == 1) then
          pcvt(column, tile) = pcvl(column)
          kveg(column, tile) = itvl(column)
          plaivt(column, tile) = plail(column)
          climatology = plailc(column)
        else if (tile == 2) then
          pcvt(column, tile) = pcvh(column)
          kveg(column, tile) = itvh(column)
          plaivt(column, tile) = plaih(column)
          climatology = plaihc(column)
        end if
        kind = kveg(column, tile)
        value = plaivt(column, tile)*ydags%rvbslai_nitro(kind)
        biomass(column, tile) = value
        previous = value*ydveg%rlaiint
        temporary = climatology*ydags%rvbslai_nitro(kind)
        weight = 1.0_real64 - ydveg%rlaiint
        temporary = temporary*weight
        biomass(column, tile) = previous + temporary
        old_leaf(column, tile) = plaivt(column, tile)
        old_structure(column, tile) = pbiomasstr_last(column, tile)
        old_root(column, tile) = pbiomasstr2_last(column, tile)
      end do
    end do
    if (kstep == 0) then
      do tile = 1, tiles
        do column = kidia, kfdia
          prespbstr(column, tile) = 0.0_real64
          prespbstr2(column, tile) = 0.0_real64
          pblossvt(column, tile) = 0.0_real64
          pbgainvt(column, tile) = 0.0_real64
          pbiomass_last(column, tile) = biomass(column, tile)
        end do
      end do
    end if
    if (ydveg%rlaiint > 0.0_real64) then
      steps_per_day = ydcst%rday/ptsphy
      vegetation_period = nint(steps_per_day, int32)
      if (vegetation_period < 1) call reject_contract()
      temporary = ydags%rmco2*ydags%rpcco2
      biomass_coefficient = ydags%rmc/temporary
      do tile = 1, tiles
        call nitro_decline(kidia, kfdia, kveg(:, tile), klon, kstep, ptsphy, pcvt(:, tile), &
                           ptskm1m, ptsam1m(:, 2), plat, plaivt(:, tile), ydcst, ydags, panfmvt(:, tile), &
                           prespbstr(:, tile), prespbstr2(:, tile), pbiomass_last(:, tile), &
                           pbiomasstr_last(:, tile), pbiomasstr2_last(:, tile), biomass(:, tile), pblossvt(:, tile))
        if (mod(kstep, vegetation_period) == 0) then
          do column = kidia, kfdia
            kind = kveg(column, tile)
            if (pcvt(column, tile) > 0.0_real64 .and. kind > 0) then
              value = ydags%rvlaimin(kind)*ydags%rvbslai_nitro(kind)
              value = value - biomass(column, tile)
              temporary = pandayvt(column, tile)*biomass_coefficient
              increment = max(value, temporary)
              increment = max(increment, 0.0_real64)
              biomass(column, tile) = biomass(column, tile) + increment
              plaivt(column, tile) = biomass(column, tile)/ydags%rvbslai_nitro(kind)
              pandayvt(column, tile) = 0.0_real64
              pbgainvt(column, tile) = increment
            else
              pandayvt(column, tile) = 0.0_real64
              plaivt(column, tile) = 0.0_real64
            end if
          end do
        end if
      end do
      do tile = 1, tiles
        do column = 1, klon
          if (pbiomasstr_last(column, tile) < biomass_floor) pbiomasstr_last(column, tile) = 0.0_real64
        end do
      end do
    end if
    do tile = 1, tiles
      do column = kidia, kfdia
        if (leaf_diagnostics) pdhvegs(column, tile, 2) = plaivt(column, tile)
        if (biomass_diagnostics) then
          pdhbios(column, tile, 1) = biomass(column, tile)
          pdhbios(column, tile, 2) = pblossvt(column, tile)
          pdhbios(column, tile, 3) = pbgainvt(column, tile)
          pdhbios(column, tile, 4) = pbiomasstr_last(column, tile)
          pdhbios(column, tile, 5) = pbiomasstr2_last(column, tile)
        end if
      end do
    end do
    do column = kidia, kfdia
      plai(column) = 0.0_real64
      pbiom(column) = 0.0_real64
      pbloss(column) = 0.0_real64
      pbgain(column) = 0.0_real64
      pbiomstr(column) = 0.0_real64
      pbiomstr2(column) = 0.0_real64
    end do
    do tile = 1, tiles
      do column = kidia, kfdia
        value = pcvt(column, tile)*plaivt(column, tile)
        plai(column) = plai(column) + value
        value = pcvt(column, tile)*biomass(column, tile)
        pbiom(column) = pbiom(column) + value
        value = pcvt(column, tile)*pblossvt(column, tile)
        pbloss(column) = pbloss(column) + value
        value = pcvt(column, tile)*pbgainvt(column, tile)
        pbgain(column) = pbgain(column) + value
        value = pcvt(column, tile)*pbiomasstr_last(column, tile)
        pbiomstr(column) = pbiomstr(column) + value
        value = pcvt(column, tile)*pbiomasstr2_last(column, tile)
        pbiomstr2(column) = pbiomstr2(column) + value
      end do
    end do
    do tile = 1, tiles
      do column = kidia, kfdia
        temporary = plaivt(column, tile) - old_leaf(column, tile)
        temporary = temporary/ptsphy
        plaie1(column, tile) = plaie1(column, tile) + temporary
        temporary = pbiomasstr_last(column, tile) - old_structure(column, tile)
        temporary = temporary/ptsphy
        pbstre1(column, tile) = pbstre1(column, tile) + temporary
        temporary = pbiomasstr2_last(column, tile) - old_root(column, tile)
        temporary = temporary/ptsphy
        pbstr2e1(column, tile) = pbstr2e1(column, tile) + temporary
      end do
    end do
    native_calls = native_calls + 1_int64
  end subroutine srfvegevol

  !> Require the exact tile shape used by this native Fortran interface.
  subroutine require_tiles(field, columns, tiles)
    real(real64), intent(in) :: field(:, :)
    integer(int32), intent(in) :: columns, tiles
    if (size(field, 1) /= columns .or. size(field, 2) /= tiles) call reject_contract()
  end subroutine require_tiles

  !> Require nearest rounding and an exact gradual-underflow result.
  subroutine require_ieee_mode()
    type(ieee_round_type) :: rounding
    real(real64), volatile :: normal, half, subnormal
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = normal*half
    if (transfer(subnormal, 0_int64) /= int(z'0008000000000000', int64)) call reject_contract()
  end subroutine require_ieee_mode

  !> Return the number of completed native calls as a C integer.
  function md2asm_srfvegevol_native_calls_get() result(calls) bind(c, name="md2asm_srfvegevol_native_calls_get")
    integer(c_int64_t) :: calls
    calls = native_calls
  end function md2asm_srfvegevol_native_calls_get
end module srfvegevol_mod
