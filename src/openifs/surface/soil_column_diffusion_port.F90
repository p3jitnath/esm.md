module srfwdif_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int
  use yos_soil, only: tsoil
  implicit none
  private
  public :: srfwdif
contains
  !> Solve one soil column in the operation order of soil_column_diffusion.S.
  !! Arguments retain the original module interface and array sections.
  !! Water state is in m3/m3; diffusion factors and layer capacities are inputs.
  !! Only active land output cells change. Supported layer counts are 2 to 512.
  subroutine srfwdif(kidia, kfdia, klon, klevs, pwsam1m, pcfw, prhsw, pcdz, ydsoil, pwsadif, ldland)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevs
    real(real64), intent(in) :: pwsam1m(:, :), pcfw(:, :), prhsw(:, :), pcdz(:, :)
    type(tsoil), intent(in) :: ydsoil
    real(real64), intent(inout) :: pwsadif(:, :)
    logical, intent(in) :: ldland(:)
    integer(int32) :: column, layer
    real(real64) :: elimination(512), inverse_implicit, previous_factor
    real(real64) :: a, b, c, d, e, q
    interface
      subroutine reject_unsupported_layers(code) bind(c, name="_exit")
        import c_int
        integer(c_int), value :: code
      end subroutine reject_unsupported_layers
    end interface

    if (klevs < 2_int32 .or. klevs > 512_int32) call reject_unsupported_layers(119_c_int)
    inverse_implicit = 1.0_real64/ydsoil%rsimp
    do column = kidia, kfdia
      if (.not. ldland(column)) cycle
      do layer = 1, klevs
        a = inverse_implicit*pwsam1m(column, layer)
        a = a + prhsw(column, layer)
        pwsadif(column, layer) = a
      end do

      previous_factor = pcfw(column, 1)
      q = 1.0_real64/pcdz(column, 1)
      c = previous_factor*q
      d = 1.0_real64 + c
      d = 1.0_real64/d
      e = d*c
      elimination(1) = e
      a = pwsadif(column, 1)
      a = d*a
      pwsadif(column, 1) = a

      do layer = 2, klevs
        a = pcdz(column, layer)
        q = 1.0_real64/a
        a = previous_factor*q
        b = elimination(layer - 1)
        c = 1.0_real64 - b
        c = a*c
        c = 1.0_real64 + c
        previous_factor = pcfw(column, layer)
        e = previous_factor*q
        c = c + e
        d = 1.0_real64/c
        if (layer < klevs) then
          c = d*e
          elimination(layer) = c
        end if
        b = pwsadif(column, layer)
        c = pwsadif(column, layer - 1)
        c = a*c
        b = b + c
        b = d*b
        pwsadif(column, layer) = b
      end do

      do layer = klevs - 1, 1, -1
        a = pwsadif(column, layer)
        b = pwsadif(column, layer + 1)
        c = elimination(layer)
        b = c*b
        a = a + b
        pwsadif(column, layer) = a
      end do
    end do
  end subroutine srfwdif
end module srfwdif_mod
