!> Project real runtime Fullpos configuration into its canonical named records.
!! All arrays use their declared source bounds; pressure levels are in Pa.
!! The caller retains one runtime configuration and stable final output owners.
module forecast_fullpos_configuration
  use iso_fortran_env, only: int32, int64, real64
  use yomfpc, only: tnamfpobj, tnamfpsci, tnamfpint, tnamfpl
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_runtime_output_configuration, only: native_runtime_output_configuration
  use forecast_output_request_preparation, only: native_output_common_metadata
  implicit none
  private
  public :: initialize_native_fullpos_configuration
contains
  !> Fill source defaults and actual parsed requests, without numerical reference calls.
 !! MODEL is readonly. CONFIGURATION is the produced runtime5 owner. Status2
 !! retains all records; success publishes their named values, including fixed tails.
 integer(int32) function initialize_native_fullpos_configuration(text,model,configuration,object,science,interpolation,levels,common,nvgrib) result(status)
    character(*), intent(in) :: text
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_runtime_output_configuration), target, intent(in) :: configuration
    type(tnamfpobj), intent(inout) :: object
    type(tnamfpsci), intent(inout) :: science
    type(tnamfpint), intent(inout) :: interpolation
    type(tnamfpl), intent(inout) :: levels
    type(native_output_common_metadata), intent(inout) :: common
    integer(int32), optional, intent(in) :: nvgrib
    type(tnamfpobj) :: obj
    type(tnamfpsci) :: sci
    type(tnamfpint) :: ip
    type(tnamfpl) :: lev
    type(native_output_common_metadata) :: cm
    integer :: j
    status = 2
    if (.not. present(nvgrib)) return
    if (nvgrib < 0 .or. nvgrib > 2) return
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. associated(model%initial)) return
    if (.not. configuration%ready .or. .not. associated(configuration%metadata)) return
    if (model%initial%controls%namespace%lecmwf /= 1 .or. model%initial%controls%namespace%larpegef /= 0) return
    if (model%initial%controls%namespace%lelam /= 0) return
    if (model%initial%controls%namespace%nfpos /= 2) return
    if (configuration%namfpc%cfpfmt /= 'MODEL') return
    if (any(configuration%namfpc%field_count < 0)) return
    obj%cfpfmt = configuration%namfpc%cfpfmt
    obj%cfpdom = ' '; obj%cfpdom(1) = '000'
    obj%nfpgrib = nvgrib
    obj%nfposts = model%initial%controls%namespace%nposts
    obj%nfpostsmin = model%initial%controls%namespace%npostsmin
    obj%nfrfpos = model%initial%controls%namespace%nfrpos
    cm%ltracefp = configuration%namfpc%ltracefp
    cm%lfppacking = model%initial%prefix%headers%ngribfile == 0
    cm%rwidom = huge(0.0_real64); cm%locedelay = .true.
    cm%lallofp = .false.; cm%lfpmois = .false.
    cm%l_read_model_date = .false.; cm%lwider_dom = .false.
    cm%nfpchkdat = 1; cm%nfpsfxwrt = 0
    sci%nfitp = 2; sci%nfitt = 2; sci%nfitv = 2; sci%nfiti = 2
    sci%nfits = 2; sci%nfith = 0; sci%nfitf = 0
    sci%nspfilp = 1; sci%nspfilt = 1; sci%nspfilv = 1; sci%nspfili = 1
    sci%nspfilf = 1; sci%nspfilh = 1; sci%nspfils = 1; sci%nspfil2 = 1
    sci%lcritsnowtemp = .false.; sci%lfprh100 = .true.
    sci%rfpvcap = 8900.0_real64; sci%fprhmax = 2.0_real64
    sci%lisot_aboveg = .false.
    sci%nfpcli = max(0, min(configuration%namfpc%nfpcli, 3))
    sci%lfpq = configuration%namfpc%lfpq; sci%rfpcorr = configuration%namfpc%rfpcorr
    lev%nfp3dfs = configuration%namfpc%field_count(1)
    lev%nfp3dfp = configuration%namfpc%field_count(2)
    lev%nfp3dfh = configuration%namfpc%field_count(3)
    lev%nfp3dft = configuration%namfpc%field_count(4)
    lev%nfp3dfv = configuration%namfpc%field_count(5)
    lev%nfp3dfi = configuration%namfpc%field_count(6)
    lev%nfp3dff = configuration%namfpc%field_count(7)
    lev%nfp2df = configuration%namfpc%field_count(8)
    lev%nfpphy = configuration%namfpc%field_count(9)
    if (lev%nfp3dfs > size(lev%mfp3dfs) .or. lev%nfp3dfp > size(lev%mfp3dfp)) return
    if (lev%nfp3dfh > size(lev%mfp3dfh) .or. lev%nfp3dft > size(lev%mfp3dft)) return
    if (lev%nfp3dfv > size(lev%mfp3dfv) .or. lev%nfp3dfi > size(lev%mfp3dfi)) return
    if (lev%nfp3dff > size(lev%mfp3dff) .or. lev%nfp2df > size(lev%mfp2df)) return
    if (lev%nfpphy > size(lev%mfpphy)) return
    lev%mfp3dfs(1:min(size(lev%mfp3dfs), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dfs), 256), 1)
    lev%mfp3dfp(1:min(size(lev%mfp3dfp), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dfp), 256), 2)
    lev%mfp3dfh(1:min(size(lev%mfp3dfh), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dfh), 256), 3)
    lev%mfp3dft(1:min(size(lev%mfp3dft), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dft), 256), 4)
    lev%mfp3dfv(1:min(size(lev%mfp3dfv), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dfv), 256), 5)
    lev%mfp3dfi(1:min(size(lev%mfp3dfi), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dfi), 256), 6)
    lev%mfp3dff(1:min(size(lev%mfp3dff), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp3dff), 256), 7)
    lev%mfp2df(1:min(size(lev%mfp2df), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfp2df), 256), 8)
    lev%mfpphy(1:min(size(lev%mfpphy), 256)) = configuration%namfpc%field_code(1:min(size(lev%mfpphy), 256), 9)
    lev%nrfp3s = configuration%namfpc%nrfp3s(1:size(lev%nrfp3s))
    lev%rfp3p = configuration%namfpc%levels(1:size(lev%rfp3p), 1)
    lev%rfp3h = configuration%namfpc%levels(1:size(lev%rfp3h), 2)
    lev%rfp3th = configuration%namfpc%levels(1:size(lev%rfp3th), 3)
    lev%rfp3pv = configuration%namfpc%levels(1:size(lev%rfp3pv), 4)
    lev%rfp3i = configuration%namfpc%levels(1:size(lev%rfp3i), 5)
    lev%rfp3f = configuration%namfpc%levels(1:size(lev%rfp3f), 6)
    object = obj; science = sci; interpolation = ip; levels = lev; common = cm
    status = 0
  end function
end module
