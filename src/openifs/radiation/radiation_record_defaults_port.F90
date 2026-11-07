!> Apply the selected named declaration defaults without resetting records.
!! The source is radiation_record_defaults.S. The caller owns all records
!! and calls this leaf once at record admission. Only the 89 source-declared
!! fields change. All unrelated values, descriptors, pointers and padding
!! retain their incoming bits. No original constructor or numerical body runs.
module radiation_record_defaults_mod
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: terad
  use yoecmip, only: tecmip
  use yoeozoc, only: teozoc
  use eint_mod, only: sl_struct
  implicit none
  private
  public :: initialize_radiation_record_defaults

contains

  !> Set the selected native radiation, climate, ozone and interpolation defaults.
  !! All five arguments have intent INOUT. RADIATION, CMIP, OZONE and the two
  !! SL_STRUCT interpolation records remain caller owned. Ozone missing-value
  !! sentinels retain their exact source FP64 bits. Dates and interpolation
  !! indices are int32. Existing allocated owners are neither read nor changed.
  subroutine initialize_radiation_record_defaults( &
      radiation,cmip,ozone,interpolation_in,interpolation_out)
    type(terad), intent(inout) :: radiation
    type(tecmip), intent(inout) :: cmip
    type(teozoc), intent(inout) :: ozone
    type(sl_struct), intent(inout) :: interpolation_in,interpolation_out
    radiation%cghgclimfile = ''
    radiation%cghgtimeseriesfile = ''
    radiation%csolarirradiancefile = ''
    cmip%ncurryr = int(z'ffffffff',int32)
    ozone%cozqc = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    ozone%cozqs = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    ozone%cozhc = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    ozone%cozhs = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    ozone%rsinc = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    ozone%rozt = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    ozone%rproc = transfer(int(z'ffefffffffffffff',int64),0.0_real64)
    call initialize_interpolation_defaults(interpolation_in)
    call initialize_interpolation_defaults(interpolation_out)
  end subroutine initialize_radiation_record_defaults

  !> Set the source-declared SL_STRUCT scalars while keeping all owners.
  !! INTERPOLATION is INOUT. DISTUNUSEDHALO is a distance diagnostic in the
  !! original source units. Its 999999 sentinel and the character version
  !! mark retain their exact source values; no array descriptor is touched.
  subroutine initialize_interpolation_defaults(interpolation)
    type(sl_struct), intent(inout) :: interpolation
    interpolation%cver = 'XX'
    interpolation%nslgroup = int(z'00000000',int32)
    interpolation%naslb1 = int(z'00000000',int32)
    interpolation%naslb1_true = int(z'00000000',int32)
    interpolation%nslpad = int(z'00000000',int32)
    interpolation%lslt_arrays_init = .false.
    interpolation%lslondem = .false.
    interpolation%lslondem_active = .false.
    interpolation%nunusedhalo = int(z'000f423f',int32)
    interpolation%distunusedhalo = transfer(int(z'412e847e00000000',int64),0.0_real64)
    interpolation%nslprocs = int(z'00000000',int32)
    interpolation%nslrpt = int(z'00000000',int32)
    interpolation%nslspt = int(z'00000000',int32)
    interpolation%nslwiden = int(z'00000000',int32)
    interpolation%nslwides = int(z'00000000',int32)
    interpolation%nslwidee = int(z'00000000',int32)
    interpolation%nslwidew = int(z'00000000',int32)
    interpolation%nslwide = int(z'00000000',int32)
    interpolation%ndglg = int(z'00000000',int32)
    interpolation%ndlon = int(z'00000000',int32)
    interpolation%ndgsag = int(z'00000000',int32)
    interpolation%ndgeng = int(z'00000000',int32)
    interpolation%ndgsal = int(z'00000000',int32)
    interpolation%ndgenl = int(z'00000000',int32)
    interpolation%ndgsah = int(z'00000000',int32)
    interpolation%ndgenh = int(z'00000000',int32)
    interpolation%ngptot = int(z'00000000',int32)
    interpolation%ndguxl = int(z'00000000',int32)
    interpolation%ndlung = int(z'00000000',int32)
    interpolation%ndluxg = int(z'00000000',int32)
    interpolation%ndgung = int(z'00000000',int32)
    interpolation%ndguxg = int(z'00000000',int32)
    interpolation%ndsur1 = int(z'00000000',int32)
    interpolation%ndlsur = int(z'00000000',int32)
    interpolation%ndgsur = int(z'00000000',int32)
    interpolation%nptrfloff = int(z'00000000',int32)
    interpolation%nfrstloff = int(z'00000000',int32)
    interpolation%myfrstactlat = int(z'00000000',int32)
    interpolation%mylstactlat = int(z'00000000',int32)
  end subroutine initialize_interpolation_defaults

end module radiation_record_defaults_mod
