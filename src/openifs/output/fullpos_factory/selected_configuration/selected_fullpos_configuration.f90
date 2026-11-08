!> Build the selected MODEL Fullpos records from the first live NAMFPC.
!! This sibling keeps the runtime constructor and all existing owners unchanged.
module forecast_selected_fullpos_configuration
  use iso_fortran_env, only: int32, int64, real64
  use yomfpc, only: tnamfpobj, tnamfpsci, tnamfpint, tnamfpl
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use forecast_output_request_preparation, only: native_output_common_metadata
  implicit none
  private
  public :: initialize_selected_native_fullpos_configuration
contains
  !> Parse supported source assignments into private native records, then commit.
  !! Text contains 1:262144 bytes. Controls supply the live source schedules.
  !! NGRIBFILE is a nonnegative count; NVGRIB admits -1:3 or 100:200.
  !! Pressure lists use pascals. All output records are borrowed, fixed-size
  !! canonical types. An absent levels argument retains original mode zero:
  !! the private level record is not returned and its physical prefix is not
  !! checked. No output changes on status 2. Success returns status 0.
  recursive integer(int32) function initialize_selected_native_fullpos_configuration( &
    text, controls, ngribfile, nvgrib, object, science, interpolation, levels, common) result(status)
    character(len=*), intent(in) :: text
    type(native_forecast_control_namespace), intent(in) :: controls
    integer(int32), intent(in) :: ngribfile, nvgrib
    type(tnamfpobj), intent(inout) :: object
    type(tnamfpsci), intent(inout) :: science
    type(tnamfpint), intent(inout) :: interpolation
    type(tnamfpl), optional, intent(inout) :: levels
    type(native_output_common_metadata), intent(inout) :: common
    type(tnamfpobj) :: obj
    type(tnamfpsci) :: sci
    type(tnamfpint) :: ip
    type(tnamfpl) :: lev
    type(native_output_common_metadata) :: cm
    integer :: j
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if (ngribfile < 0) return
    if (nvgrib < -1) return
    if (nvgrib > 3) then
      if (nvgrib < 100 .or. nvgrib > 200) return
    end if
    if (controls%lecmwf /= 1 .or. controls%lelam /= 0 .or. controls%larpegef /= 0) return
    if (controls%nfpos /= 2) return
    call source_defaults(obj, sci, ip, lev, cm)
    obj%nfpgrib = nvgrib
    obj%nfrfpos = controls%nfrpos
    obj%nfposts = controls%nposts
    obj%nfpostsmin = controls%npostsmin
    cm%lfppacking = ngribfile == 0
    if (parse_source_group(text, obj, lev) /= 0) return
    if (obj%cfpfmt /= 'MODEL') return
    if (lev%nfp3dfs < 0 .or. lev%nfp3dfs > size(lev%mfp3dfs)) return
    if (lev%nfp3dfp < 0 .or. lev%nfp3dfp > size(lev%mfp3dfp)) return
    if (lev%nfp2df < 0 .or. lev%nfp2df > size(lev%mfp2df)) return
    if (lev%nfpphy < 0 .or. lev%nfpphy > size(lev%mfpphy)) return
    if (present(levels)) then
      do j = 1, lev%nfpphy
        if (lev%mfpphy(j) < 1) return
      end do
    end if
    object%cfpfmt = obj%cfpfmt
    object%cfpdom = obj%cfpdom
    object%cfpdir = obj%cfpdir
    object%cfpmonipath_in = obj%cfpmonipath_in
    object%cfpmonipath_out = obj%cfpmonipath_out
    object%nfpgrib = obj%nfpgrib
    object%nfposts = obj%nfposts
    object%nfpostsmin = obj%nfpostsmin
    object%nfrfpos = obj%nfrfpos
    science%rfpvcap = sci%rfpvcap
    science%fprhmax = sci%fprhmax
    science%lcritsnowtemp = sci%lcritsnowtemp
    science%lisot_aboveg = sci%lisot_aboveg
    science%lfprh100 = sci%lfprh100
    science%nfpsurfex = sci%nfpsurfex
    science%nfpboyd = sci%nfpboyd
    science%rfpbscal = sci%rfpbscal
    science%lfpcapex = sci%lfpcapex
    science%nfpcli = sci%nfpcli
    science%lclimalbedos = sci%lclimalbedos
    science%lclimaerosol = sci%lclimaerosol
    science%lclimozone = sci%lclimozone
    science%nfplake = sci%nfplake
    science%nfpmask = sci%nfpmask
    science%nfpswi = sci%nfpswi
    science%nfpcape = sci%nfpcape
    science%lfpisopv = sci%lfpisopv
    science%niterpv = sci%niterpv
    science%rentra = sci%rentra
    science%fprhmin = sci%fprhmin
    science%lsaturcap = sci%lsaturcap
    science%lfitbetween = sci%lfitbetween
    science%lfpq = sci%lfpq
    science%lfplosp = sci%lfplosp
    science%lputzs = sci%lputzs
    science%lfpclstogmv = sci%lfpclstogmv
    science%tsreserv1 = sci%tsreserv1
    science%tsreserv2 = sci%tsreserv2
    science%tdelta1 = sci%tdelta1
    science%tdelta2 = sci%tdelta2
    science%rwpitpn = sci%rwpitpn
    science%rwpitpx = sci%rwpitpx
    science%rsnstpn = sci%rsnstpn
    science%rsnstpx = sci%rsnstpx
    science%rsnsmod = sci%rsnsmod
    science%rfpcorr = sci%rfpcorr
    science%rfpcsab = sci%rfpcsab
    science%rfpcd2 = sci%rfpcd2
    science%rstrmmh = sci%rstrmmh
    science%rsrhh = sci%rsrhh
    science%nfitp = sci%nfitp
    science%nfitt = sci%nfitt
    science%nfitv = sci%nfitv
    science%nfiti = sci%nfiti
    science%nfitf = sci%nfitf
    science%nfith = sci%nfith
    science%nfits = sci%nfits
    science%nspfilp = sci%nspfilp
    science%nspfilt = sci%nspfilt
    science%nspfilv = sci%nspfilv
    science%nspfili = sci%nspfili
    science%nspfilf = sci%nspfilf
    science%nspfilh = sci%nspfilh
    science%nspfils = sci%nspfils
    science%nspfil2 = sci%nspfil2
    interpolation%lfpml_std = ip%lfpml_std
    interpolation%lfpml_lan = ip%lfpml_lan
    interpolation%lfpml_sea = ip%lfpml_sea
    interpolation%nfpindyn = ip%nfpindyn
    interpolation%nfpinphy = ip%nfpinphy
    interpolation%nfpsfxint = ip%nfpsfxint
    interpolation%rfpcr_std = ip%rfpcr_std
    interpolation%rfpcr_lan = ip%rfpcr_lan
    interpolation%rfpcr_sea = ip%rfpcr_sea
    if (present(levels)) then
      levels%cfp3df = lev%cfp3df
      levels%cfpphy = lev%cfpphy
      levels%mfp3dfs = lev%mfp3dfs
      levels%mfp3dfp = lev%mfp3dfp
      levels%mfp3dfh = lev%mfp3dfh
      levels%mfp3dft = lev%mfp3dft
      levels%mfp3dfv = lev%mfp3dfv
      levels%mfp3dfi = lev%mfp3dfi
      levels%mfp3dff = lev%mfp3dff
      levels%mfp2df = lev%mfp2df
      levels%rfp3p = lev%rfp3p
      levels%rfp3h = lev%rfp3h
      levels%rfp3th = lev%rfp3th
      levels%rfp3pv = lev%rfp3pv
      levels%rfp3i = lev%rfp3i
      levels%rfp3f = lev%rfp3f
      levels%nrfp3s = lev%nrfp3s
      levels%nfp3dfs = lev%nfp3dfs
      levels%nfp3dfp = lev%nfp3dfp
      levels%nfp3dfh = lev%nfp3dfh
      levels%nfp3dft = lev%nfp3dft
      levels%nfp3dfv = lev%nfp3dfv
      levels%nfp3dfi = lev%nfp3dfi
      levels%nfp3dff = lev%nfp3dff
      levels%nfp2df = lev%nfp2df
      levels%mfpphy = lev%mfpphy
      levels%nfpphy = lev%nfpphy
      levels%cfpcfu = lev%cfpcfu
      levels%cfpxfu = lev%cfpxfu
      levels%cfp2df = lev%cfp2df
    end if
    common%ltracefp = cm%ltracefp
    common%lallofp = cm%lallofp
    common%lfpmois = cm%lfpmois
    common%l_read_model_date = cm%l_read_model_date
    common%lfppacking = cm%lfppacking
    common%locedelay = cm%locedelay
    common%lwider_dom = cm%lwider_dom
    common%nfpchkdat = cm%nfpchkdat
    common%nfpsfxwrt = cm%nfpsfxwrt
    common%rwidom = cm%rwidom
    status = 0
  end function

  !> Set every named declaration and selected literal before reading text.
  !! Representation padding is not copied from the original private records.
  subroutine source_defaults(obj, sci, ip, lev, cm)
    type(tnamfpobj), intent(inout) :: obj
    type(tnamfpsci), intent(inout) :: sci
    type(tnamfpint), intent(inout) :: ip
    type(tnamfpl), intent(inout) :: lev
    type(native_output_common_metadata), intent(inout) :: cm
    obj%cfpdir = ' '
    obj%cfpmonipath_in = ' '
    obj%cfpmonipath_in = '.'
    obj%cfpmonipath_out = ' '
    obj%cfpmonipath_out = '.'
    obj%nfposts = 0
    obj%nfpostsmin = 0
    obj%nfrfpos = 1
    sci%nfpsurfex = 0
    sci%nfpboyd = 0
    sci%rfpbscal = transfer(int(z'4008000000000000', int64), 0.0_real64)
    sci%lfpcapex = .false.
    sci%nfpcli = 0
    sci%lclimalbedos = .true.
    sci%lclimaerosol = .true.
    sci%lclimozone = .true.
    sci%nfplake = 0
    sci%nfpmask = 1
    sci%nfpswi = 0
    sci%nfpcape = 2
    sci%lfpisopv = .true.
    sci%niterpv = 3
    sci%rentra = transfer(int(z'0000000000000000', int64), 0.0_real64)
    sci%fprhmin = transfer(int(z'0000000000000000', int64), 0.0_real64)
    sci%lsaturcap = .false.
    sci%lfitbetween = .false.
    sci%lfpq = .false.
    sci%lfplosp = .false.
    sci%lputzs = .true.
    sci%lfpclstogmv = .false.
    sci%tsreserv1 = transfer(int(z'4071026666666666', int64), 0.0_real64)
    sci%tsreserv2 = transfer(int(z'4070d26666666666', int64), 0.0_real64)
    sci%tdelta1 = transfer(int(z'4008000000000000', int64), 0.0_real64)
    sci%tdelta2 = transfer(int(z'401c000000000000', int64), 0.0_real64)
    sci%rwpitpn = transfer(int(z'4071100000000000', int64), 0.0_real64)
    sci%rwpitpx = transfer(int(z'4071100000000000', int64), 0.0_real64)
    sci%rsnstpn = transfer(int(z'4071000000000000', int64), 0.0_real64)
    sci%rsnstpx = transfer(int(z'4071000000000000', int64), 0.0_real64)
    sci%rsnsmod = transfer(int(z'4054000000000000', int64), 0.0_real64)
    sci%rfpcorr = transfer(int(z'40a6fe0000000000', int64), 0.0_real64)
    sci%rfpcsab = transfer(int(z'3f847ae147ae147b', int64), 0.0_real64)
    sci%rfpcd2 = transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64)
    sci%rstrmmh = transfer(int(z'40b7700000000000', int64), 0.0_real64)
    sci%rsrhh = transfer(int(z'40a7700000000000', int64), 0.0_real64)
    ip%lfpml_std = .false.
    ip%lfpml_lan = .false.
    ip%lfpml_sea = .false.
    ip%nfpindyn = 12
    ip%nfpinphy = 12
    ip%nfpsfxint = 0
    ip%rfpcr_std(1) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ip%rfpcr_std(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ip%rfpcr_lan(1) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ip%rfpcr_lan(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    ip%rfpcr_sea(1) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    ip%rfpcr_sea(2) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    lev%cfp3df = ' '
    lev%cfpphy = ' '
    lev%mfp3dfs = 0
    lev%mfp3dfp = 0
    lev%mfp3dfh = 0
    lev%mfp3dft = 0
    lev%mfp3dfv = 0
    lev%mfp3dfi = 0
    lev%mfp3dff = 0
    lev%mfp2df = 0
    lev%rfp3p = transfer(int(z'c022000000000000', int64), 0.0_real64)
    lev%rfp3h = transfer(int(z'c022000000000000', int64), 0.0_real64)
    lev%rfp3th = transfer(int(z'c022000000000000', int64), 0.0_real64)
    lev%rfp3pv = transfer(int(z'42029fe50e000000', int64), 0.0_real64)
    lev%rfp3i = transfer(int(z'c0c3878000000000', int64), 0.0_real64)
    lev%rfp3f = transfer(int(z'c022000000000000', int64), 0.0_real64)
    lev%nrfp3s = -9
    lev%nfp3dfs = 0
    lev%nfp3dfp = 0
    lev%nfp3dfh = 0
    lev%nfp3dft = 0
    lev%nfp3dfv = 0
    lev%nfp3dfi = 0
    lev%nfp3dff = 0
    lev%nfp2df = 0
    lev%mfpphy = -9999
    lev%nfpphy = 0
    lev%cfpcfu = ' '
    lev%cfpxfu = ' '
    lev%cfp2df = ' '
    obj%cfpfmt = 'GAUSS'
    obj%cfpdom = ' '
    obj%cfpdom(1) = '000'
    sci%rfpvcap = transfer(int(z'40c1620000000000', int64), 0.0_real64)
    sci%fprhmax = transfer(int(z'4000000000000000', int64), 0.0_real64)
    sci%lcritsnowtemp = .false.
    sci%lisot_aboveg = .false.
    sci%lfprh100 = .true.
    sci%nfitp = 2; sci%nfitt = 2; sci%nfitv = 2; sci%nfiti = 2; sci%nfits = 2
    sci%nfith = 0; sci%nfitf = 0
    sci%nspfilp = 1; sci%nspfilt = 1; sci%nspfilv = 1; sci%nspfili = 1
    sci%nspfilf = 1; sci%nspfilh = 1; sci%nspfils = 1; sci%nspfil2 = 1
    cm%ltracefp = .false.; cm%lallofp = .false.; cm%lfpmois = .false.
    cm%l_read_model_date = .false.; cm%lfppacking = .false.; cm%locedelay = .true.
    cm%lwider_dom = .false.; cm%nfpchkdat = 1; cm%nfpsfxwrt = 0
    cm%rwidom = transfer(int(z'7fefffffffffffff', int64), 0.0_real64)
  end subroutine

  !> Apply the eleven actual keys in their source order.
  integer(int32) function parse_source_group(text, obj, lev) result(status)
    character(len=*), intent(in) :: text
    type(tnamfpobj), intent(inout) :: obj
    type(tnamfpl), intent(inout) :: lev
    character(len=16) :: key
    character(len=1) :: quote, ch
    integer :: p, start, finish, k, capacity, index, field, n
    integer(int32) :: value
    real(real64) :: pressure
    logical :: real_value, negative_zero
    status = 2
    n = len(text)
    p = first_group(text)
    if (p == 0) return
    do
      call skip_source_space(text, p)
      if (p > n) return
      if (text(p:p) == ',') then
        p = p + 1
        cycle
      end if
      if (text(p:p) == '/') then
        status = 0
        return
      end if
      start = p
      do while (p <= n)
        if (.not. key_character(text(p:p))) exit
        p = p + 1
      end do
      if (p > n) return
      if (p == start .or. p - start > len(key)) return
      key = ' '
      do k = start, p - 1
        key(k - start + 1:k - start + 1) = upper_ascii(text(k:k))
      end do
      select case (trim(key))
      case ('CFPFMT'); field = 1; capacity = 1
      case ('NFP3DFS'); field = 2; capacity = 1
      case ('MFP3DFS'); field = 3; capacity = size(lev%mfp3dfs)
      case ('NRFP3S'); field = 4; capacity = size(lev%nrfp3s)
      case ('NFP2DF'); field = 5; capacity = 1
      case ('MFP2DF'); field = 6; capacity = size(lev%mfp2df)
      case ('NFP3DFP'); field = 7; capacity = 1
      case ('MFP3DFP'); field = 8; capacity = size(lev%mfp3dfp)
      case ('RFP3P'); field = 9; capacity = size(lev%rfp3p)
      case ('NFPPHY'); field = 10; capacity = 1
      case ('MFPPHY'); field = 11; capacity = size(lev%mfpphy)
      case default
        return
      end select
      call skip_source_space(text, p)
      if (p > n) return
      if (text(p:p) /= '=') return
      p = p + 1
      call skip_source_space(text, p)
      if (p > n) return
      if (field == 1) then
        quote = text(p:p)
        if (quote /= "'" .and. quote /= '"') return
        p = p + 1
        start = p
        do
          if (p > n) return
          ch = text(p:p)
          p = p + 1
          if (ch == quote) exit
          if (ch == achar(10) .or. ch == achar(13)) return
          if (p - start > 5) return
        end do
        obj%cfpfmt = ' '
        finish = p - 2
        if (finish >= start) obj%cfpfmt(1:finish - start + 1) = text(start:finish)
        if (p > n) return
        ch = text(p:p)
        if (ch == '/') then
          status = 0
          return
        end if
        if (.not. white_space(ch) .and. ch /= ',') return
        cycle
      end if
      index = 1
      do
        if (index > capacity) return
        start = p
        do while (p <= n)
          ch = text(p:p)
          if (white_space(ch) .or. ch == ',' .or. ch == '!' .or. ch == '/') exit
          p = p + 1
        end do
        if (p > n) return
        finish = p - 1
        if (finish < start) return
        real_value = field == 9
        if (source_number(text(start:finish), real_value, value, negative_zero) /= 0) return
        select case (field)
        case (2); lev%nfp3dfs = value
        case (3); lev%mfp3dfs(index) = value
        case (4); lev%nrfp3s(index) = value
        case (5); lev%nfp2df = value
        case (6); lev%mfp2df(index) = value
        case (7); lev%nfp3dfp = value
        case (8); lev%mfp3dfp(index) = value
        case (9)
          pressure = real(value, real64)
          if (negative_zero) pressure = transfer(int(z'8000000000000000', int64), 0.0_real64)
          lev%rfp3p(index) = pressure
        case (10); lev%nfpphy = value
        case (11); lev%mfpphy(index) = value
        end select
        index = index + 1
        call skip_source_space(text, p)
        if (p > n) return
        if (text(p:p) == ',') then
          p = p + 1
          call skip_source_space(text, p)
          if (p > n) return
          if (number_start(text(p:p))) cycle
        end if
        if (text(p:p) == '/') then
          status = 0
          return
        end if
        if (.not. letter(text(p:p))) return
        exit
      end do
    end do
  end function

  !> Find the first exact source group marker in columns one through ten.
  integer function first_group(text) result(position)
    character(len=*), intent(in) :: text
    integer :: line, p, n
    position = 0
    n = len(text)
    line = 1
    do while (line <= n)
      p = line
      do while (p <= n)
        if (.not. white_space(text(p:p)) .or. text(p:p) == achar(10)) exit
        p = p + 1
      end do
      if (p <= n) then
        if (p - line < 10 .and. text(p:p) == '&') then
          if (p + 7 <= n) then
            if (text(p + 1:p + 6) == 'NAMFPC') then
              if (white_space(text(p + 7:p + 7)) .or. text(p + 7:p + 7) == '/') then
                position = p + 7
                return
              end if
            end if
          end if
        end if
      end if
      do while (p <= n)
        if (text(p:p) == achar(10)) exit
        p = p + 1
      end do
      line = p + 1
    end do
  end function

  !> Skip source whitespace and exclamation comments without reading past text.
  subroutine skip_source_space(text, p)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: p
    do while (p <= len(text))
      if (white_space(text(p:p))) then
        p = p + 1
      else if (text(p:p) == '!') then
        do while (p <= len(text))
          if (text(p:p) == achar(10)) exit
          p = p + 1
        end do
      else
        return
      end if
    end do
  end subroutine

  !> Retain the bounded signed-decimal route and exact integer real levels.
  integer(int32) function source_number(token, allow_real, value, negative_zero) result(status)
    character(len=*), intent(in) :: token
    logical, intent(in) :: allow_real
    integer(int32), intent(out) :: value
    logical, intent(out) :: negative_zero
    integer :: first, last, p, digit, point
    integer(int64) :: magnitude
    logical :: negative
    status = 2
    negative_zero = .false.
    value = 0
    first = 1
    last = len(token)
    if (last == 0) return
    negative = token(1:1) == '-'
    if (negative .or. token(1:1) == '+') first = 2
    point = 0
    if (allow_real) then
      do p = first, last
        if (token(p:p) == '.') then
          point = p
          exit
        end if
      end do
    end if
    if (point /= 0) then
      do p = point + 1, last
        if (token(p:p) /= '0') return
      end do
      last = point - 1
    end if
    if (first > last) return
    magnitude = 0
    do p = first, last
      digit = iachar(token(p:p)) - iachar('0')
      if (digit < 0 .or. digit > 9) return
      magnitude = magnitude*10_int64 + digit
      if (magnitude > 100000000_int64) return
    end do
    value = int(magnitude, int32)
    if (negative) value = -value
    negative_zero = allow_real .and. negative .and. value == 0
    status = 0
  end function

  pure logical function white_space(ch)
    character(len=1), intent(in) :: ch
    white_space = ch == ' ' .or. ch == achar(9) .or. ch == achar(13) .or. ch == achar(10)
  end function
  pure logical function letter(ch)
    character(len=1), intent(in) :: ch
    integer :: n
    n = iachar(ch)
    letter = (n >= 65 .and. n <= 90) .or. (n >= 97 .and. n <= 122)
  end function
  pure logical function key_character(ch)
    character(len=1), intent(in) :: ch
    integer :: n
    n = iachar(ch)
    key_character = letter(ch) .or. (n >= 48 .and. n <= 57) .or. ch == '_'
  end function
  pure logical function number_start(ch)
    character(len=1), intent(in) :: ch
    integer :: n
    n = iachar(ch)
    number_start = ch == '+' .or. ch == '-' .or. (n >= 48 .and. n <= 57)
  end function
  pure character(len=1) function upper_ascii(ch) result(value)
    character(len=1), intent(in) :: ch
    integer :: n
    n = iachar(ch)
    value = ch
    if (n >= 97 .and. n <= 122) value = achar(n - 32)
  end function
end module forecast_selected_fullpos_configuration
