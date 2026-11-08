!> Complete fixed-Gaussian and runtime cloud diagnostics entry families.
!! Fixed tables are exact FP64 source words; they replace selected SIN/ASIN/COS.
!! Runtime entries reuse the unchanged explicit-constant native child.
!! Inputs use Pa, K, radians and kg/kg; overlap lengths use km.
!! Caller establishes nearest-even and gradual underflow; no child mode probe.
module forecast_complete_shared_cloud_diagnostics
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use radiation_config, only: config_type
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yoecld, only: tecld
  use physical_constant_setup_port, only: forecast_physical_constants
  use native_radiation_cloud_diagnostics_without_clock, only: &
    cldpp_runtime => cldpp_without_clock, decorr_runtime => cloud_overlap_decorr_len, cldpp_cumulative
  implicit none
  private
  public :: cldpp_selected, cloud_overlap_decorr_len_selected, cldpp_runtime, decorr_runtime, cldpp_cumulative
  integer(int64), parameter :: latitude_words(2, 32) = reshape([ &
                                                               int(z'3ff7f2e9650529f4', int64), &
                                                               int(z'3fefe995e70409b6', int64), &
                                                               int(z'3ff66a4f3f0a78ff', int64), &
                                                               int(z'3fef8a212714bcdc', int64), &
                                                               int(z'3ff4df6394c3a8dc', int64), &
                                                               int(z'3feedf5518053baa', int64), &
                                                               int(z'3ff353f1d9ef99b5', int64), &
                                                               int(z'3fedeac0259f7f42', int64), &
                                                               int(z'3ff1c84d4f66f7f5', int64), &
                                                               int(z'3fecaea9b4574cb9', int64), &
                                                               int(z'3ff03c903a9fd6d6', int64), &
                                                               int(z'3feb2e04fd686a13', int64), &
                                                               int(z'3fed618af8d6485b', int64), &
                                                               int(z'3fe96c69481c4bc5', int64), &
                                                               int(z'3fea49e4cc01ba6d', int64), &
                                                               int(z'3fe76e0931d693ba', int64), &
                                                               int(z'3fe73233c1c07c3e', int64), &
                                                               int(z'3fe537a89c487f89', int64), &
                                                               int(z'3fe41a7b5283a5a0', int64), &
                                                               int(z'3fe2ce9146962ca5', int64), &
                                                               int(z'3fe102bdb452ba1a', int64), &
                                                               int(z'3fe038862866b29e', int64), &
                                                               int(z'3fdbd5f8c9b823e5', int64), &
                                                               int(z'3fdaf76b57c6f8f1', int64), &
                                                               int(z'3fd5a670e661da05', int64), &
                                                               int(z'3fd53d55ce57bdf7', int64), &
                                                               int(z'3fceedcaa7be5cb2', int64), &
                                                               int(z'3fcea0f7e19c0949', int64), &
                                                               int(z'3fc28eaea3e5e152', int64), &
                                                               int(z'3fc27e0ea717f236', int64), &
                                                               int(z'3fa8be3f640a1669', int64), &
                                                               int(z'3fa8bbc8488cc499', int64), &
                                                               int(z'bfa8be3f640a1669', int64), &
                                                               int(z'bfa8bbc8488cc499', int64), &
                                                               int(z'bfc28eaea3e5e152', int64), &
                                                               int(z'bfc27e0ea717f236', int64), &
                                                               int(z'bfceedcaa7be5cb2', int64), &
                                                               int(z'bfcea0f7e19c0949', int64), &
                                                               int(z'bfd5a670e661da05', int64), &
                                                               int(z'bfd53d55ce57bdf7', int64), &
                                                               int(z'bfdbd5f8c9b823e5', int64), &
                                                               int(z'bfdaf76b57c6f8f1', int64), &
                                                               int(z'bfe102bdb452ba1a', int64), &
                                                               int(z'bfe038862866b29e', int64), &
                                                               int(z'bfe41a7b5283a5a0', int64), &
                                                               int(z'bfe2ce9146962ca5', int64), &
                                                               int(z'bfe73233c1c07c3e', int64), &
                                                               int(z'bfe537a89c487f89', int64), &
                                                               int(z'bfea49e4cc01ba6d', int64), &
                                                               int(z'bfe76e0931d693ba', int64), &
                                                               int(z'bfed618af8d6485b', int64), &
                                                               int(z'bfe96c69481c4bc5', int64), &
                                                               int(z'bff03c903a9fd6d6', int64), &
                                                               int(z'bfeb2e04fd686a13', int64), &
                                                               int(z'bff1c84d4f66f7f5', int64), &
                                                               int(z'bfecaea9b4574cb9', int64), &
                                                               int(z'bff353f1d9ef99b5', int64), &
                                                               int(z'bfedeac0259f7f42', int64), &
                                                               int(z'bff4df6394c3a8dc', int64), &
                                                               int(z'bfeedf5518053baa', int64), &
                                                               int(z'bff66a4f3f0a78ff', int64), &
                                                               int(z'bfef8a212714bcdc', int64), &
                                                               int(z'bff7f2e9650529f4', int64), &
                                                               int(z'bfefe995e70409b6', int64)], [2, 32])
  integer(int64), parameter :: coordinate_words(3, 32) = reshape([ &
                                                                 int(z'3fefe995e70409b6', int64), &
                                                                 int(z'3ff7f2e9650529f4', int64), &
                                                                 int(z'3fb2ecb28e1b54f8', int64), &
                                                                 int(z'3fef8a212714bcdc', int64), &
                                                                 int(z'3ff66a4f3f0a78ff', int64), &
                                                                 int(z'3fc5a2a8d1292e09', int64), &
                                                                 int(z'3feedf5518053baa', int64), &
                                                                 int(z'3ff4df6394c3a8dc', int64), &
                                                                 int(z'3fd0d702773295b3', int64), &
                                                                 int(z'3fedeac0259f7f42', int64), &
                                                                 int(z'3ff353f1d9ef99b5', int64), &
                                                                 int(z'3fd6b69a82ff9e41', int64), &
                                                                 int(z'3fecaea9b4574cb9', int64), &
                                                                 int(z'3ff1c84d4f66f7f5', int64), &
                                                                 int(z'3fdc60c137bd2841', int64), &
                                                                 int(z'3feb2e04fd686a13', int64), &
                                                                 int(z'3ff03c903a9fd6d6', int64), &
                                                                 int(z'3fe0e3c06f55b060', int64), &
                                                                 int(z'3fe96c69481c4bc5', int64), &
                                                                 int(z'3fed618af8d6485b', int64), &
                                                                 int(z'3fe36ee1b06a2a4e', int64), &
                                                                 int(z'3fe76e0931d693ba', int64), &
                                                                 int(z'3fea49e4cc01ba6d', int64), &
                                                                 int(z'3fe5cba4e8c85f68', int64), &
                                                                 int(z'3fe537a89c487f89', int64), &
                                                                 int(z'3fe73233c1c07c3e', int64), &
                                                                 int(z'3fe7f45e7108d59f', int64), &
                                                                 int(z'3fe2ce9146962ca5', int64), &
                                                                 int(z'3fe41a7b5283a5a0', int64), &
                                                                 int(z'3fe9e3e17c5a9c0f', int64), &
                                                                 int(z'3fe038862866b29e', int64), &
                                                                 int(z'3fe102bdb452ba1a', int64), &
                                                                 int(z'3feb958b579e13a9', int64), &
                                                                 int(z'3fdaf76b57c6f8f1', int64), &
                                                                 int(z'3fdbd5f8c9b823e5', int64), &
                                                                 int(z'3fed054defc9ba72', int64), &
                                                                 int(z'3fd53d55ce57bdf7', int64), &
                                                                 int(z'3fd5a670e661da05', int64), &
                                                                 int(z'3fee2fb9377aabfe', int64), &
                                                                 int(z'3fcea0f7e19c0949', int64), &
                                                                 int(z'3fceedcaa7be5cb2', int64), &
                                                                 int(z'3fef120333e73813', int64), &
                                                                 int(z'3fc27e0ea717f236', int64), &
                                                                 int(z'3fc28eaea3e5e152', int64), &
                                                                 int(z'3fefaa0e8ea0d481', int64), &
                                                                 int(z'3fa8bbc8488cc499', int64), &
                                                                 int(z'3fa8be3f640a1669', int64), &
                                                                 int(z'3feff66f94ecbbbb', int64), &
                                                                 int(z'bfa8bbc8488cc499', int64), &
                                                                 int(z'bfa8be3f640a1669', int64), &
                                                                 int(z'3feff66f94ecbbbb', int64), &
                                                                 int(z'bfc27e0ea717f236', int64), &
                                                                 int(z'bfc28eaea3e5e152', int64), &
                                                                 int(z'3fefaa0e8ea0d481', int64), &
                                                                 int(z'bfcea0f7e19c0949', int64), &
                                                                 int(z'bfceedcaa7be5cb2', int64), &
                                                                 int(z'3fef120333e73813', int64), &
                                                                 int(z'bfd53d55ce57bdf7', int64), &
                                                                 int(z'bfd5a670e661da05', int64), &
                                                                 int(z'3fee2fb9377aabfe', int64), &
                                                                 int(z'bfdaf76b57c6f8f1', int64), &
                                                                 int(z'bfdbd5f8c9b823e5', int64), &
                                                                 int(z'3fed054defc9ba72', int64), &
                                                                 int(z'bfe038862866b29e', int64), &
                                                                 int(z'bfe102bdb452ba1a', int64), &
                                                                 int(z'3feb958b579e13a9', int64), &
                                                                 int(z'bfe2ce9146962ca5', int64), &
                                                                 int(z'bfe41a7b5283a5a0', int64), &
                                                                 int(z'3fe9e3e17c5a9c0f', int64), &
                                                                 int(z'bfe537a89c487f89', int64), &
                                                                 int(z'bfe73233c1c07c3e', int64), &
                                                                 int(z'3fe7f45e7108d59f', int64), &
                                                                 int(z'bfe76e0931d693ba', int64), &
                                                                 int(z'bfea49e4cc01ba6d', int64), &
                                                                 int(z'3fe5cba4e8c85f68', int64), &
                                                                 int(z'bfe96c69481c4bc5', int64), &
                                                                 int(z'bfed618af8d6485b', int64), &
                                                                 int(z'3fe36ee1b06a2a4e', int64), &
                                                                 int(z'bfeb2e04fd686a13', int64), &
                                                                 int(z'bff03c903a9fd6d6', int64), &
                                                                 int(z'3fe0e3c06f55b060', int64), &
                                                                 int(z'bfecaea9b4574cb9', int64), &
                                                                 int(z'bff1c84d4f66f7f5', int64), &
                                                                 int(z'3fdc60c137bd2841', int64), &
                                                                 int(z'bfedeac0259f7f42', int64), &
                                                                 int(z'bff353f1d9ef99b5', int64), &
                                                                 int(z'3fd6b69a82ff9e41', int64), &
                                                                 int(z'bfeedf5518053baa', int64), &
                                                                 int(z'bff4df6394c3a8dc', int64), &
                                                                 int(z'3fd0d702773295b3', int64), &
                                                                 int(z'bfef8a212714bcdc', int64), &
                                                                 int(z'bff66a4f3f0a78ff', int64), &
                                                                 int(z'3fc5a2a8d1292e09', int64), &
                                                                 int(z'bfefe995e70409b6', int64), &
                                                                 int(z'bff7f2e9650529f4', int64), &
                                                                 int(z'3fb2ecb28e1b54f8', int64)], [3, 32])
  interface
    function selected_log(value) bind(c, name="log") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function
    function selected_exp(value) bind(c, name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function
    subroutine reject_contract() bind(c, name="abort")
    end subroutine
  end interface
contains
  subroutine cloud_overlap_decorr_len_selected(constants, ydecld, kidia, kfdia, klon, sin_lat, mode, edge_km, water_km, ratio)
    type(forecast_physical_constants), intent(in) :: constants
    type(tecld), intent(in) :: ydecld
    integer(int32), intent(in) :: kidia, kfdia, klon, mode
    real(real64), intent(in) :: sin_lat(klon)
    real(real64), intent(inout) :: edge_km(klon)
    real(real64), optional, intent(inout) :: water_km(klon), ratio
    real(real64) :: coordinates(klon), a, b
    real(real64), volatile :: factor
    integer(int32) :: column, table_index
    integer(int64) :: word
    if (klon < 1_int32 .or. klon > 2048_int32) call reject_contract()
    if (kidia < 1_int32 .or. kidia > klon + 1_int32) call reject_contract()
    if (kfdia < 0_int32 .or. kfdia > klon) call reject_contract()
    if (mode == 0_int32) then
      do column = kidia, kfdia
        edge_km(column) = ydecld%rdecorr_cf
      end do
      if (present(water_km)) then
        do column = kidia, kfdia
          water_km(column) = ydecld%rdecorr_cw
        end do
      end if
      if (present(ratio)) ratio = ydecld%rdecorr_cw/ydecld%rdecorr_cf
      return
    end if
    if (transfer(constants%rpi, word) /= int(z'400921fb54442d18', int64)) call reject_contract()
    factor = 180.0_real64/constants%rpi
    do column = kidia, kfdia
      word = transfer(sin_lat(column), word)
      table_index = 1
      do while (table_index <= 32)
        if (word == coordinate_words(1, table_index)) exit
        table_index = table_index + 1
      end do
      if (table_index > 32) call reject_contract()
      if (mode == 1_int32) then
        coordinates(column) = transfer(coordinate_words(2, table_index), 0.0_real64)
      else
        coordinates(column) = transfer(coordinate_words(3, table_index), 0.0_real64)
      end if
    end do
    do column = kidia, kfdia
      a = coordinates(column)
      if (mode == 1_int32) then
        a = a*factor
        a = abs(a)
        a = 0.02759_real64*a
        a = 2.899_real64 - a
      else
        b = 2.149_real64*a
        a = b*a
        a = 0.75_real64 + a
      end if
      edge_km(column) = a
    end do
    if (present(water_km)) then
      do column = kidia, kfdia
        a = edge_km(column)
        water_km(column) = a*0.5_real64
      end do
    end if
    if (present(ratio)) ratio = 0.5_real64
  end subroutine cloud_overlap_decorr_len_selected

  subroutine cldpp_selected(constants, ydradiation, yderad, yderdi, ydecld, kidia, kfdia, klon, klev, &
                            paphm1, papm1, pa, pl, pi, pt, pgelat, pgelam, ldcldcover, pcc, pch, pcl, pcm, pct, pclc, pqiwp, pqlwp)
    type(forecast_physical_constants), intent(in) :: constants
    type(config_type), intent(inout) :: ydradiation
    type(terad), intent(inout) :: yderad
    type(terdi), intent(inout) :: yderdi
    type(tecld), intent(inout) :: ydecld
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: paphm1(klon, klev + 1), papm1(klon, klev), pa(klon, klev)
    real(real64), intent(in) :: pl(klon, klev), pi(klon, klev), pt(klon, klev), pgelat(klon), pgelam(klon)
    logical, intent(in) :: ldcldcover
    real(real64), intent(inout) :: pcc(klon), pch(klon), pcl(klon), pcm(klon), pct(klon)
    real(real64), intent(inout) :: pclc(klon, klev), pqiwp(klon, klev), pqlwp(klon, klev)
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: sine(:), length_km(:), fractions(:), alpha(:), cumulative(:), pair(:)
    integer(int32) :: table_index, boundaries(2, klon), column, level, middle, low, status, first, count, flag
    integer(int64) :: word
    real(real64) :: cutoff, high_boundary, low_boundary, surface_pressure, a, b, c
    real(real64), volatile :: height_factor
    if (klon < 1_int32 .or. klon > 2048_int32) call reject_contract()
    if (klev < 3_int32 .or. klev > 512_int32) call reject_contract()
    if (kidia < 1_int32 .or. kidia > klon) call reject_contract()
    if (kfdia < 0_int32 .or. kfdia > klon) call reject_contract()
    flag = transfer(ldcldcover, flag)
    if (flag < 0_int32 .or. flag > 1_int32) call reject_contract()
    cutoff = yderdi%repclc
    if (ldcldcover) then
      if (yderad%lusepre2017rad) call reject_contract()
      if (ydradiation%i_overlap_scheme /= 1_int32) call reject_contract()
      high_boundary = ydecld%retahb
      low_boundary = ydecld%retamb
      height_factor = constants%rd/constants%rg
      allocate (workspace(2*klon + 4*klev), stat=status)
      if (status /= 0_int32) call reject_contract()
      workspace = 0.0_real64
      first = 1
      sine => workspace(first:first + klon - 1)
      first = first + klon
      length_km => workspace(first:first + klon - 1)
      first = first + klon
      fractions => workspace(first:first + klev - 1)
      first = first + klev
      alpha => workspace(first:first + klev - 1)
      first = first + klev
      cumulative => workspace(first:first + klev - 1)
      first = first + klev
      pair => workspace(first:first + klev - 1)

      ! Admit every active latitude and cloud class before the first public output write.
      do column = kidia, kfdia
        word = transfer(pgelat(column), word)
        table_index = 1
        do while (table_index <= 32)
          if (word == latitude_words(1, table_index)) exit
          table_index = table_index + 1
        end do
        if (table_index > 32) call reject_contract()
        sine(column) = transfer(latitude_words(2, table_index), 0.0_real64)
        surface_pressure = paphm1(column, klev + 1)
        a = paphm1(column, 1)/surface_pressure
        if (.not. (a < high_boundary)) call reject_contract()
        middle = 1_int32
        do
          a = paphm1(column, middle + 1)/surface_pressure
          if (middle >= klev - 1_int32) exit
          if (a >= high_boundary) exit
          middle = middle + 1_int32
        end do
        if (.not. (a < low_boundary)) call reject_contract()
        boundaries(1, column) = middle
        low = middle + 1_int32
        if (low >= klev) call reject_contract()
        do
          a = paphm1(column, low + 1)/surface_pressure
          if (low >= klev - 1_int32) exit
          if (a >= low_boundary) exit
          low = low + 1_int32
        end do
        if (.not. (a >= low_boundary)) call reject_contract()
        boundaries(2, column) = low
      end do
      call cloud_overlap_decorr_len_selected(constants, ydecld, kidia, kfdia, klon, sine, yderad%ndecolat, length_km)
      do column = kidia, kfdia
        do level = 1, klev
          a = max(pa(column, level), 0.0_real64)
          fractions(level) = min(a, 1.0_real64)
          if (level == klev) cycle
          a = papm1(column, level + 1)/papm1(column, level)
          b = selected_log(a)
          a = pt(column, level) + pt(column, level + 1)
          c = height_factor*0.5_real64
          a = c*a
          a = a*b
          a = a*0.001_real64
          a = -a
          a = a/length_km(column)
          alpha(level) = selected_exp(a)
        end do
        count = klev
        call cldpp_cumulative(count, fractions, alpha, cumulative, pair)
        pct(column) = cumulative(count)
        count = boundaries(1, column)
        call cldpp_cumulative(count, fractions, alpha, cumulative, pair)
        pch(column) = cumulative(count)
        first = boundaries(1, column) + 1_int32
        count = boundaries(2, column) - boundaries(1, column)
        call cldpp_cumulative(count, fractions(first:), alpha(first:), cumulative, pair)
        pcm(column) = cumulative(count)
        first = boundaries(2, column) + 1_int32
        count = klev - boundaries(2, column)
        call cldpp_cumulative(count, fractions(first:), alpha(first:), cumulative, pair)
        pcl(column) = cumulative(count)
      end do
    end if

    if (kidia <= kfdia) then
      b = 1.0_real64 - cutoff
      do level = 1, klev
        do column = kidia, kfdia
          a = max(pa(column, level), cutoff)
          a = min(a, b)
          pclc(column, level) = a
          if (a > cutoff) then
            pqlwp(column, level) = pl(column, level)
            pqiwp(column, level) = pi(column, level)
          else
            pqlwp(column, level) = 0.0_real64
            pqiwp(column, level) = 0.0_real64
          end if
        end do
      end do
    end if
    if (allocated(workspace)) deallocate (workspace)
  end subroutine cldpp_selected
end module forecast_complete_shared_cloud_diagnostics
