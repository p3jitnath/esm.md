module srfwinc_mod
  use iso_fortran_env, only: int32, real64
  use yos_soil, only: tsoil
  use yos_thf, only: rhoh2o
  implicit none
  private
  public :: srfwinc
contains
  !> Recover soil water and its fluxes in the order of soil_water_increment.S.
  !! Water is in m3/m3, time is in s, and fluxes are in kg/m2/s.
  !! Incoming gravity flux and bottom drainage remain inputs to the update.
  !! Array sections retain their own strides; inactive cells retain their bytes.
  subroutine srfwinc(kidia, kfdia, klevs, ptmst, pwsam1m, pwsadif, psawgfl, pcfw, &
                     ydsoil, pwsa, pwfsd, ldland, pdhwls)
    integer(int32), intent(in) :: kidia, kfdia, klevs
    real(real64), intent(in) :: ptmst, pwsam1m(:, :), pwsadif(:, :), pcfw(:, :)
    type(tsoil), intent(in) :: ydsoil
    real(real64), intent(inout) :: psawgfl(:, :), pwsa(:, :), pwfsd(:), pdhwls(:, :, :)
    logical, intent(in) :: ldland(:)
    integer(int32) :: column, layer
    real(real64) :: old_weight, flux_weight, a, b, c

    old_weight = 1.0_real64/ydsoil%rsimp
    old_weight = old_weight - 1.0_real64
    flux_weight = rhoh2o/ptmst
    if (kidia > kfdia) return
    do layer = 1, klevs
      do column = kidia, kfdia
        if (ldland(column)) then
          a = pwsam1m(column, layer)
          a = old_weight*a
          b = pwsadif(column, layer)
          c = b - a
          pwsa(column, layer) = c
          if (layer < klevs) then
            b = pwsadif(column, layer)
            c = pwsadif(column, layer + 1)
            c = b - c
            a = pcfw(column, layer)
            a = flux_weight*a
            a = a*c
            b = psawgfl(column, layer)
            a = b + a
            psawgfl(column, layer) = a
          end if
        else
          pwsa(column, layer) = pwsam1m(column, layer)
          psawgfl(column, layer) = 0.0_real64
        end if
      end do
    end do
    do column = kidia, kfdia
      pwfsd(column) = psawgfl(column, 1)
    end do
    if (size(pdhwls) == 0) return
    do layer = 1, klevs
      do column = kidia, kfdia
        pdhwls(column, layer, 8) = psawgfl(column, layer)
      end do
    end do
    do column = kidia, kfdia
      a = psawgfl(column, klevs)
      b = pdhwls(column, klevs, 6)
      a = b - a
      pdhwls(column, klevs, 6) = a
    end do
  end subroutine srfwinc
end module srfwinc_mod
