!> Write the complete source-ordered radiation setup as a named native stream.
!! This versioned diagnostic records field values, declared bounds and presence.
!! It contains no compiler descriptor, object padding or numerical pointer image.
!! Physical arrays retain their stored bits. The compiler locates every field.
module forecast_radiation_setup_stream
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_null_ptr, c_associated
  use forecast_runtime_radiation_prefix_types, only: native_runtime_radiation_prefix_context
  use forecast_radiation_stream_encoding, only: native_radiation_stream_writer, open_radiation_stream, close_radiation_stream, &
                                                put_stream_tag, put_stream_metadata, put_stream_value, set_stream_failure
  use yomcompo, only: borrowed_composition => tcompo
  use yomphy, only: borrowed_phy => tphy
  use yomparar, only: borrowed_parar => tparar
  use yoephli, only: borrowed_linear_physics => tephli
  use yophnc, only: borrowed_nonlinear_physics => tphnc

  implicit none
  private
  public :: write_radiation_setup_stream
contains
!> Write a completed setup; return0, I/O failure1 or unsupported context2.
!! CONTEXT borrows the one actual produced setup, grid, maps and shape owners.
!! The five further readonly records are the complete actual caller records;
!! no reduced flag clone or default record supplies their unconsumed members.
!! PATH has1:4095 characters and no NUL. This diagnostic replaces the old raw
!! record encoding, not the forecast weather-file format. Ownership is unchanged.
integer(int32)function write_radiation_setup_stream(context,composition,phy,parar,linear_physics,nonlinear_physics,path)result(status)
  type(native_runtime_radiation_prefix_context), intent(in) :: context
  type(borrowed_composition), intent(in) :: composition
  type(borrowed_phy), intent(in) :: phy
  type(borrowed_parar), intent(in) :: parar
  type(borrowed_linear_physics), intent(in) :: linear_physics
  type(borrowed_nonlinear_physics), intent(in) :: nonlinear_physics
  character(len=*), intent(in) :: path
  type(native_radiation_stream_writer) :: w
  status = 2_int32
  if (.not. associated(context%setup)) return
  if (.not. context%setup%setup_complete) return
  if (.not. allocated(context%setup%climate)) return
  if (.not. associated(context%longwave)) return
  if (.not. associated(context%cmip)) return
  if (.not. associated(context%physics)) return
  if (.not. associated(context%grid)) return
  if (.not. associated(context%storage)) return
  if (.not. associated(context%shape)) return
  if (.not. associated(context%ri)) return
  if (.not. associated(context%ro)) return
  if (.not. allocated(context%shape%nrgri)) return
  if (.not. allocated(context%shape%nloeng)) return
  call open_radiation_stream(w, path)
  if (w%status /= 0_int32) then
    status = w%status
    return
  end if
  call put_stream_tag(w, 0_int32, 'NATIVE_RADIATION_SETUP_STREAM')
  call put_stream_value(w, 1_int32)
  call put_stream_value(w, 29_int32)
  call put_stream_value(w, 4_int32)
  call put_stream_value(w, 145_int32)
  call put_stream_value(w, 9_int32)
  call write_section_001(w)
  call write_section_002(w)
  call write_section_003(w)
  call write_section_004(w)
  call write_section_005(w)
  call write_section_006(w)
  call write_section_007(w)
  call write_section_008(w)
  call write_section_009(w)
  call write_section_010(w)
  call write_section_011(w)
  call write_section_012(w)
  call write_section_013(w)
  call write_section_014(w)
  call write_section_015(w)
  call write_section_016(w)
  call write_section_017(w)
  call write_section_018(w)
  call write_section_019(w)
  call write_section_020(w)
  call write_section_021(w)
  call write_section_022(w)
  call write_section_023(w)
  call write_section_024(w)
  call write_section_025(w)
  call write_section_026(w)
  call write_section_027(w)
  call write_section_028(w)
  call write_section_029(w)
  call write_section_030(w)
  call write_section_031(w)
  call write_section_032(w)
  call write_section_033(w)
  call write_section_034(w)
  call write_section_035(w)
  call write_section_036(w)
  call write_section_037(w)
  call write_section_038(w)
  call write_section_039(w)
  call write_section_040(w)
  call write_section_041(w)
  call write_section_042(w)
  call write_section_043(w)
  call write_section_044(w)
  call write_section_045(w)
  call write_section_046(w)
  call write_section_047(w)
  call write_section_048(w)
  call write_section_049(w)
  call write_section_050(w)
  call write_section_051(w)
  call write_section_052(w)
  call write_section_053(w)
  call write_section_054(w)
  call write_section_055(w)
  call write_section_056(w)
  call write_section_057(w)
  call write_section_058(w)
  call write_section_059(w)
  call write_section_060(w)
  call write_section_061(w)
  call write_section_062(w)
  call write_section_063(w)
  call write_section_064(w)
  call write_section_065(w)
  call write_section_066(w)
  call write_section_067(w)
  call write_section_068(w)
  call write_section_069(w)
  call write_section_070(w)
  call write_section_071(w)
  call write_section_072(w)
  call write_section_073(w)
  call write_section_074(w)
  call write_section_075(w)
  call write_section_076(w)
  call write_section_077(w)
  call write_section_078(w)
  call write_section_079(w)
  call write_section_080(w)
  call write_section_081(w)
  call write_section_082(w)
  call write_section_083(w)
  call write_section_084(w)
  call write_section_085(w)
  call write_section_086(w)
  call write_section_087(w)
  call write_section_088(w)
  call write_section_089(w)
  call write_section_090(w)
  call write_section_091(w)
  call write_section_092(w)
  call write_section_093(w)
  call write_section_094(w)
  call write_section_095(w)
  call write_section_096(w)
  call write_section_097(w)
  call write_section_098(w)
  call write_section_099(w)
  call write_section_100(w)
  call write_section_101(w)
  call write_section_102(w)
  call write_section_103(w)
  call write_section_104(w)
  call write_section_105(w)
  call write_section_106(w)
  call write_section_107(w)
  call write_section_108(w)
  call write_section_109(w)
  call write_section_110(w)
  call write_section_111(w)
  call write_section_112(w)
  call write_section_113(w)
  call write_section_114(w)
  call write_section_115(w)
  call write_section_116(w)
  call write_section_117(w)
  call write_section_118(w)
  call write_section_119(w)
  call write_section_120(w)
  call write_section_121(w)
  call write_section_122(w)
  call write_section_123(w)
  call write_section_124(w)
  call write_section_125(w)
  call write_section_126(w)
  call write_section_127(w)
  call write_section_128(w)
  call write_section_129(w)
  call write_section_130(w)
  call write_section_131(w)
  call write_section_132(w)
  call write_section_133(w)
  call write_section_134(w)
  call write_section_135(w)
  call write_section_136(w)
  call write_section_137(w)
  call write_section_138(w)
  call write_section_139(w)
  call write_section_140(w)
  call write_section_141(w)
  call write_section_142(w)
  call write_section_143(w)
  call write_section_144(w)
  call write_section_145(w)
  call write_section_146(w)
  call write_section_147(w)
  call write_section_148(w)
  call write_section_149(w)
  call write_section_150(w)
  call write_section_151(w)
  call write_section_152(w)
  call write_section_153(w)
  call write_section_154(w)
  call write_section_155(w)
  call write_section_156(w)
  call write_section_157(w)
  call write_section_158(w)
  call write_section_159(w)
  call write_section_160(w)
  call write_section_161(w)
  call write_section_162(w)
  call write_section_163(w)
  call write_section_164(w)
  call write_section_165(w)
  call write_section_166(w)
  call write_section_167(w)
  call write_section_168(w)
  call write_section_169(w)
  call write_section_170(w)
  call write_section_171(w)
  call write_section_172(w)
  call write_section_173(w)
  call write_section_174(w)
  call write_section_175(w)
  call write_section_176(w)
  call write_section_177(w)
  call write_section_178(w)
  call write_section_179(w)
  call write_section_180(w)
  call write_section_181(w)
  call write_section_182(w)
  call write_section_183(w)
  call write_section_184(w)
  call write_section_185(w)
  call write_section_186(w)
  call write_section_187(w)
  call write_section_188(w)
  call write_section_189(w)
  call write_section_190(w)
  call write_section_191(w)
  call write_section_192(w)
  call put_stream_tag(w, 4_int32, 'native_live_owners.NRGRI')
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(context%shape%nrgri,kind=int64),ubound(context%shape%nrgri,kind=int64))
  call put_stream_value(w, context%shape%nrgri)
  call put_stream_tag(w, 4_int32, 'native_live_owners.NLOENG')
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(context%shape%nloeng,kind=int64),ubound(context%shape%nloeng,kind=int64))
  call put_stream_value(w, context%shape%nloeng)
  call put_stream_tag(w, 4_int32, 'native_resource_state')
  call put_stream_value(w, context%setup%context_ready)
  call put_stream_value(w, context%setup%storage_ready)
  call put_stream_value(w, context%setup%setup_complete)
  call put_stream_value(w, context%setup%last_stage)
  call put_stream_value(w, context%setup%last_status)
  call put_stream_value(w, context%storage%state)
  call put_stream_tag(w, 4_int32, 'native_live_owners.storage.nsta')
  if (allocated(context%storage%nsta)) then
call put_stream_metadata(w,1_int32,4_int32,2_int32,1_int32,lbound(context%storage%nsta,kind=int64),ubound(context%storage%nsta,kind=int64))
    call put_stream_value(w, context%storage%nsta)
  else
    call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
  end if
  call put_stream_tag(w, 4_int32, 'native_live_owners.storage.nonl')
  if (allocated(context%storage%nonl)) then
call put_stream_metadata(w,1_int32,4_int32,2_int32,1_int32,lbound(context%storage%nonl,kind=int64),ubound(context%storage%nonl,kind=int64))
    call put_stream_value(w, context%storage%nonl)
  else
    call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
  end if
  call put_stream_tag(w, 4_int32, 'native_live_owners.storage.nptrfrstlat')
  if (allocated(context%storage%nptrfrstlat)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(context%storage%nptrfrstlat,kind=int64),ubound(context%storage%nptrfrstlat,kind=int64))
    call put_stream_value(w, context%storage%nptrfrstlat)
  else
    call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
  end if
  call put_stream_tag(w, 4_int32, 'native_live_owners.storage.nfrstlat')
  if (allocated(context%storage%nfrstlat)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(context%storage%nfrstlat,kind=int64),ubound(context%storage%nfrstlat,kind=int64))
    call put_stream_value(w, context%storage%nfrstlat)
  else
    call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
  end if
  call put_stream_tag(w, 4_int32, 'native_live_owners.storage.nlstlat')
  if (allocated(context%storage%nlstlat)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(context%storage%nlstlat,kind=int64),ubound(context%storage%nlstlat,kind=int64))
    call put_stream_value(w, context%storage%nlstlat)
  else
    call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
  end if
  call put_stream_tag(w, 4_int32, 'native_live_owners.storage.zmu')
  if (allocated(context%storage%zmu)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(context%storage%zmu,kind=int64),ubound(context%storage%zmu,kind=int64))
    call put_stream_value(w, context%storage%zmu)
  else
    call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
  end if
  call put_stream_tag(w, 9_int32, 'END_NATIVE_RADIATION_SETUP_STREAM')
  call close_radiation_stream(w)
  status = w%status
contains
  subroutine write_section_001(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TERAD')
      call put_stream_tag(w, 2_int32, 'TERAD.naer')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nmode')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmode)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nozocl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nozocl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradpfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradpfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradpla')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradpla)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradint')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradint)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradres')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradres)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradnfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradnfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradsfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradsfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nrade1h')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrade1h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nrade3h')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrade3h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradelg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradelg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.novlp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%novlp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nrproma')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrproma)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nsw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nswnl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswnl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nswtl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswtl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlwemiss')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwemiss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlwout')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwout)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ntsw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntsw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nuv')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nuv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ncsradf')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ncsradf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.niceopt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%niceopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nliqopt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nliqopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nswiceopt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswiceopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nswliqopt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswliqopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlwiceopt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwiceopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlwliqopt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwliqopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradip')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradip)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nradlp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nradlp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ninhom')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ninhom)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlayinh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlayinh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlngr1h')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlngr1h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.npertaer')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npertaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.npertoz')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npertoz)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nscen')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nscen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nhincsol')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nhincsol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nmcica')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmcica)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nghgrad')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nghgrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ndecolat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndecolat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nminice')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nminice)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nvolcvert')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nvolcvert)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nredglw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nredglw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nredgsw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nredgsw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.naermacc')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naermacc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nmclat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmclat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nmclon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmclon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nmclev')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmclev)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nmcvar')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmcvar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nspmapl')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nspmapl, kind=int64), ubound(v%nspmapl, kind=int64))
      call put_stream_value(w, v%nspmapl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nspmaps')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nspmaps, kind=int64), ubound(v%nspmaps, kind=int64))
      call put_stream_value(w, v%nspmaps)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlwscattering')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwscattering)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nswsolver')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswsolver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nlwsolver')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwsolver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.kmodts')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%kmodts)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nsolarspectrum')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsolarspectrum)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.nswwvcontinuum')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswwvcontinuum)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ndumpbadinputs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndumpbadinputs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ndumpinputs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndumpinputs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ncloudoverlap')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ncloudoverlap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rcloud_frac_std')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcloud_frac_std)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rcloud_separation_scale_toa')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcloud_separation_scale_toa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rcloud_separation_scale_surf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcloud_separation_scale_surf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lfu_lw_ice_optics_bug')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfu_lw_ice_optics_bug)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.linterpincloudmean')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%linterpincloudmean)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lerad1h')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lerad1h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lepo3ra')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lepo3ra)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lonewsw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lonewsw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lecsrad')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecsrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lrrtm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrrtm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lsrtm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsrtm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ldiffc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldiffc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lhvolca')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lhvolca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lnewaer')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnewaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lnotroaer')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnotroaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lrayl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.loptrproma')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%loptrproma)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.leco2var')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leco2var)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lhghg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lhghg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.leso4his')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leso4his)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.letracgms')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%letracgms)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.laerclim')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerclim)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.laervisi')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laervisi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.laer3d')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laer3d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lvolcspec')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvolcspec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lvolcdamp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvolcdamp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ldiagforcing')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldiagforcing)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.laeradcli')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laeradcli)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.laeradjdu')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laeradjdu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lapproxlwupdate')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lapproxlwupdate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lapproxswupdate')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lapproxswupdate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lmannersswupdate')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lmannersswupdate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lcentredtimesza')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcentredtimesza)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.laveragesza')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laveragesza)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lecompgrid')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecompgrid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lusepre2017rad')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lusepre2017rad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lduseason')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lduseason)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lccnl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lccnl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lccno')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lccno)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.lperpet')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lperpet)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.raovlp')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raovlp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rbovlp')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rbovlp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rccnlnd')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rccnlnd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rccnsea')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rccnsea)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.ledbug')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledbug)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rpertoz')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rpertoz)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rre2de')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rre2de)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rlwinhf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlwinhf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rswinhf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rswinhf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rminice')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rminice)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rvolcspec')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rvolcspec, kind=int64), ubound(v%rvolcspec, kind=int64))
      call put_stream_value(w, v%rvolcspec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rns')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rns)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.rsigair')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsigair)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.raeshss')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raeshss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.raeshdu')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raeshdu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.raeshom')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raeshom)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.raeshbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raeshbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.raeshsu')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raeshsu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.trbkg')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%trbkg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.stbkg')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%stbkg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cghgclimfile')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cghgclimfile), int64))
      call put_stream_value(w, v%cghgclimfile)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cghgtimeseriesfile')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cghgtimeseriesfile), int64))
      call put_stream_value(w, v%cghgtimeseriesfile)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.csolarirradiancefile')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csolarirradiancefile), int64))
      call put_stream_value(w, v%csolarirradiancefile)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cvdaess')
      if (allocated(v%cvdaess)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaess, kind=int64), ubound(v%cvdaess, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cvdaedu')
      if (allocated(v%cvdaedu)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaedu, kind=int64), ubound(v%cvdaedu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cvdaeom')
      if (allocated(v%cvdaeom)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaeom, kind=int64), ubound(v%cvdaeom, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cvdaebc')
      if (allocated(v%cvdaebc)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaebc, kind=int64), ubound(v%cvdaebc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.cvdaesu')
      if (allocated(v%cvdaesu)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaesu, kind=int64), ubound(v%cvdaesu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.nintervals')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yspectplanck%nintervals)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.ntemps')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yspectplanck%ntemps)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.temp1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yspectplanck%temp1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.dtemp')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yspectplanck%dtemp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.planck_lut')
      if (allocated(v%yspectplanck%planck_lut)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%yspectplanck%planck_lut,kind=int64),ubound(v%yspectplanck%planck_lut,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.wavlen_bound')
      if (allocated(v%yspectplanck%wavlen_bound)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%yspectplanck%wavlen_bound,kind=int64),ubound(v%yspectplanck%wavlen_bound,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERAD.yspectplanck.interval_map')
      if (allocated(v%yspectplanck%interval_map)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%yspectplanck%interval_map,kind=int64),ubound(v%yspectplanck%interval_map,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_001

  subroutine write_section_002(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%gases)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TERDI')
      call put_stream_tag(w, 2_int32, 'TERDI.rrae')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rrae)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rsundur')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsundur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcardi')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcardi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rch4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rch4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rn2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rno2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rno2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.ro3')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ro3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rccl4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rccl4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcfc11')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcfc11)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcfc12')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcfc12)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcfc22')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcfc22)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.repclc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repclc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.reph2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%reph2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcco2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcch4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcch4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcn2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcno2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcno2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rccfc11')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rccfc11)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rccfc12')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rccfc12)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rccfc22')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rccfc22)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rcccl4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcccl4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TERDI.rsolinc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsolinc)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_002

  subroutine write_section_003(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ultraviolet)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEUVRAD')
      call put_stream_tag(w, 2_int32, 'TEUVRAD.nraduv')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nraduv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.nuvtim')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nuvtim)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.ipuv')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ipuv, kind=int64), ubound(v%ipuv, kind=int64))
      call put_stream_value(w, v%ipuv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.jcop')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%jcop, kind=int64), ubound(v%jcop, kind=int64))
      call put_stream_value(w, v%jcop)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.juvlam')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%juvlam, kind=int64), ubound(v%juvlam, kind=int64))
      call put_stream_value(w, v%juvlam)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.luvproc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%luvproc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.luvtdep')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%luvtdep)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.luvdbg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%luvdbg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.luvaerp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%luvaerp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.lo3_chem_uv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3_chem_uv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rk250')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rk250, kind=int64), ubound(v%rk250, kind=int64))
      call put_stream_value(w, v%rk250)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rtuv1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rtuv1, kind=int64), ubound(v%rtuv1, kind=int64))
      call put_stream_value(w, v%rtuv1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rtuv2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rtuv2, kind=int64), ubound(v%rtuv2, kind=int64))
      call put_stream_value(w, v%rtuv2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rsuvb0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsuvb0, kind=int64), ubound(v%rsuvb0, kind=int64))
      call put_stream_value(w, v%rsuvb0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rayuvb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rayuvb, kind=int64), ubound(v%rayuvb, kind=int64))
      call put_stream_value(w, v%rayuvb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rasa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rasa, kind=int64), ubound(v%rasa, kind=int64))
      call put_stream_value(w, v%rasa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rasb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rasb, kind=int64), ubound(v%rasb, kind=int64))
      call put_stream_value(w, v%rasb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rasc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rasc, kind=int64), ubound(v%rasc, kind=int64))
      call put_stream_value(w, v%rasc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rasd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rasd, kind=int64), ubound(v%rasd, kind=int64))
      call put_stream_value(w, v%rasd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rase')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rase, kind=int64), ubound(v%rase, kind=int64))
      call put_stream_value(w, v%rase)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rasf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rasf, kind=int64), ubound(v%rasf, kind=int64))
      call put_stream_value(w, v%rasf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfa0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfa0, kind=int64), ubound(v%rfa0, kind=int64))
      call put_stream_value(w, v%rfa0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfa1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfa1, kind=int64), ubound(v%rfa1, kind=int64))
      call put_stream_value(w, v%rfa1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfb0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfb0, kind=int64), ubound(v%rfb0, kind=int64))
      call put_stream_value(w, v%rfb0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfb1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfb1, kind=int64), ubound(v%rfb1, kind=int64))
      call put_stream_value(w, v%rfb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfb2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfb2, kind=int64), ubound(v%rfb2, kind=int64))
      call put_stream_value(w, v%rfb2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfb3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfb3, kind=int64), ubound(v%rfb3, kind=int64))
      call put_stream_value(w, v%rfb3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfc0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfc0, kind=int64), ubound(v%rfc0, kind=int64))
      call put_stream_value(w, v%rfc0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfc1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfc1, kind=int64), ubound(v%rfc1, kind=int64))
      call put_stream_value(w, v%rfc1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfc2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfc2, kind=int64), ubound(v%rfc2, kind=int64))
      call put_stream_value(w, v%rfc2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfc3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfc3, kind=int64), ubound(v%rfc3, kind=int64))
      call put_stream_value(w, v%rfc3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfd0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfd0, kind=int64), ubound(v%rfd0, kind=int64))
      call put_stream_value(w, v%rfd0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfd1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfd1, kind=int64), ubound(v%rfd1, kind=int64))
      call put_stream_value(w, v%rfd1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfd2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfd2, kind=int64), ubound(v%rfd2, kind=int64))
      call put_stream_value(w, v%rfd2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfd3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfd3, kind=int64), ubound(v%rfd3, kind=int64))
      call put_stream_value(w, v%rfd3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rtauva')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtauva, kind=int64), ubound(v%rtauva, kind=int64))
      call put_stream_value(w, v%rtauva)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rpiuva')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rpiuva, kind=int64), ubound(v%rpiuva, kind=int64))
      call put_stream_value(w, v%rpiuva)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rcguva')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rcguva, kind=int64), ubound(v%rcguva, kind=int64))
      call put_stream_value(w, v%rcguva)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rxpo')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rxpo, kind=int64), ubound(v%rxpo, kind=int64))
      call put_stream_value(w, v%rxpo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rxpl')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rxpl, kind=int64), ubound(v%rxpl, kind=int64))
      call put_stream_value(w, v%rxpl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rcieas')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rcieas, kind=int64), ubound(v%rcieas, kind=int64))
      call put_stream_value(w, v%rcieas)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rsuvb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsuvb, kind=int64), ubound(v%rsuvb, kind=int64))
      call put_stream_value(w, v%rsuvb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.ruvlam')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ruvlam, kind=int64), ubound(v%ruvlam, kind=int64))
      call put_stream_value(w, v%ruvlam)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rfcaer')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rfcaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEUVRAD.rmuzuv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rmuzuv)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_003

  subroutine write_section_004(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%longwave)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TELWRAD')
      call put_stream_tag(w, 2_int32, 'TELWRAD.nlevlwc')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlevlwc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.nlwfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlwfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.nlooplw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlooplw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.nlooplwo')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlooplwo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.npromalw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npromalw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.nlastlw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlastlw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.loptlwpr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%loptlwpr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TELWRAD.lwlclhr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lwlclhr)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_004

  subroutine write_section_005(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TESWRT')
      call put_stream_tag(w, 2_int32, 'TESWRT.apad')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%apad, kind=int64), ubound(v%apad, kind=int64))
      call put_stream_value(w, v%apad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.bpad')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%bpad, kind=int64), ubound(v%bpad, kind=int64))
      call put_stream_value(w, v%bpad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rray')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rray, kind=int64), ubound(v%rray, kind=int64))
      call put_stream_value(w, v%rray)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rsun')
      if (allocated(v%rsun)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsun, kind=int64), ubound(v%rsun, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rsun2')
      if (allocated(v%rsun2)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsun2, kind=int64), ubound(v%rsun2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rpdh1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rpdh1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rpdu1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rpdu1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rpnh')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rpnh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rpnu')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rpnu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rswce')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rswce, kind=int64), ubound(v%rswce, kind=int64))
      call put_stream_value(w, v%rswce)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rswcp')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rswcp, kind=int64), ubound(v%rswcp, kind=int64))
      call put_stream_value(w, v%rswcp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rtdh2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rtdh2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rtdumg')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rtdumg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rth2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rth2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rtumg')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rtumg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.d')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%d, kind=int64), ubound(v%d, kind=int64))
      call put_stream_value(w, v%d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rexpo3')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rexpo3, kind=int64), ubound(v%rexpo3, kind=int64))
      call put_stream_value(w, v%rexpo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.nexpo3')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nexpo3, kind=int64), ubound(v%nexpo3, kind=int64))
      call put_stream_value(w, v%nexpo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ryfwca')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryfwca, kind=int64), ubound(v%ryfwca, kind=int64))
      call put_stream_value(w, v%ryfwca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ryfwcb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryfwcb, kind=int64), ubound(v%ryfwcb, kind=int64))
      call put_stream_value(w, v%ryfwcb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ryfwcc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryfwcc, kind=int64), ubound(v%ryfwcc, kind=int64))
      call put_stream_value(w, v%ryfwcc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ryfwcd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryfwcd, kind=int64), ubound(v%ryfwcd, kind=int64))
      call put_stream_value(w, v%ryfwcd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ryfwce')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryfwce, kind=int64), ubound(v%ryfwce, kind=int64))
      call put_stream_value(w, v%ryfwce)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ryfwcf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryfwcf, kind=int64), ubound(v%ryfwcf, kind=int64))
      call put_stream_value(w, v%ryfwcf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcua')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcua, kind=int64), ubound(v%rebcua, kind=int64))
      call put_stream_value(w, v%rebcua)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcub')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcub, kind=int64), ubound(v%rebcub, kind=int64))
      call put_stream_value(w, v%rebcub)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcuc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcuc, kind=int64), ubound(v%rebcuc, kind=int64))
      call put_stream_value(w, v%rebcuc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcud')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcud, kind=int64), ubound(v%rebcud, kind=int64))
      call put_stream_value(w, v%rebcud)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcue')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcue, kind=int64), ubound(v%rebcue, kind=int64))
      call put_stream_value(w, v%rebcue)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcuf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcuf, kind=int64), ubound(v%rebcuf, kind=int64))
      call put_stream_value(w, v%rebcuf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcug')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcug, kind=int64), ubound(v%rebcug, kind=int64))
      call put_stream_value(w, v%rebcug)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcuh')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcuh, kind=int64), ubound(v%rebcuh, kind=int64))
      call put_stream_value(w, v%rebcuh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcui')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcui, kind=int64), ubound(v%rebcui, kind=int64))
      call put_stream_value(w, v%rebcui)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rebcuj')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rebcuj, kind=int64), ubound(v%rebcuj, kind=int64))
      call put_stream_value(w, v%rebcuj)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raswca')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raswca, kind=int64), ubound(v%raswca, kind=int64))
      call put_stream_value(w, v%raswca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raswcb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raswcb, kind=int64), ubound(v%raswcb, kind=int64))
      call put_stream_value(w, v%raswcb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raswcc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raswcc, kind=int64), ubound(v%raswcc, kind=int64))
      call put_stream_value(w, v%raswcc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raswcd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raswcd, kind=int64), ubound(v%raswcd, kind=int64))
      call put_stream_value(w, v%raswcd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raswce')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raswce, kind=int64), ubound(v%raswce, kind=int64))
      call put_stream_value(w, v%raswce)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raswcf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raswcf, kind=int64), ubound(v%raswcf, kind=int64))
      call put_stream_value(w, v%raswcf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwca')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwca, kind=int64), ubound(v%rkpnwca, kind=int64))
      call put_stream_value(w, v%rkpnwca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwcb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwcb, kind=int64), ubound(v%rkpnwcb, kind=int64))
      call put_stream_value(w, v%rkpnwcb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwcc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwcc, kind=int64), ubound(v%rkpnwcc, kind=int64))
      call put_stream_value(w, v%rkpnwcc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwcd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwcd, kind=int64), ubound(v%rkpnwcd, kind=int64))
      call put_stream_value(w, v%rkpnwcd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwce')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwce, kind=int64), ubound(v%rkpnwce, kind=int64))
      call put_stream_value(w, v%rkpnwce)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwcf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwcf, kind=int64), ubound(v%rkpnwcf, kind=int64))
      call put_stream_value(w, v%rkpnwcf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwcg')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwcg, kind=int64), ubound(v%rkpnwcg, kind=int64))
      call put_stream_value(w, v%rkpnwcg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rkpnwch')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rkpnwch, kind=int64), ubound(v%rkpnwch, kind=int64))
      call put_stream_value(w, v%rkpnwch)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfueta')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rfueta, kind=int64), ubound(v%rfueta, kind=int64))
      call put_stream_value(w, v%rfueta)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfuetb')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rfuetb, kind=int64), ubound(v%rfuetb, kind=int64))
      call put_stream_value(w, v%rfuetb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfuetc')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rfuetc, kind=int64), ubound(v%rfuetc, kind=int64))
      call put_stream_value(w, v%rfuetc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfulio')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rfulio, kind=int64), ubound(v%rfulio, kind=int64))
      call put_stream_value(w, v%rfulio)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rhsavi')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rhsavi, kind=int64), ubound(v%rhsavi, kind=int64))
      call put_stream_value(w, v%rhsavi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rlilia')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rlilia, kind=int64), ubound(v%rlilia, kind=int64))
      call put_stream_value(w, v%rlilia)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rlilib')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rlilib, kind=int64), ubound(v%rlilib, kind=int64))
      call put_stream_value(w, v%rlilib)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflaa0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflaa0, kind=int64), ubound(v%rflaa0, kind=int64))
      call put_stream_value(w, v%rflaa0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflaa1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflaa1, kind=int64), ubound(v%rflaa1, kind=int64))
      call put_stream_value(w, v%rflaa1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflbb0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflbb0, kind=int64), ubound(v%rflbb0, kind=int64))
      call put_stream_value(w, v%rflbb0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflbb1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflbb1, kind=int64), ubound(v%rflbb1, kind=int64))
      call put_stream_value(w, v%rflbb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflbb2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflbb2, kind=int64), ubound(v%rflbb2, kind=int64))
      call put_stream_value(w, v%rflbb2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflbb3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflbb3, kind=int64), ubound(v%rflbb3, kind=int64))
      call put_stream_value(w, v%rflbb3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflcc0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflcc0, kind=int64), ubound(v%rflcc0, kind=int64))
      call put_stream_value(w, v%rflcc0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflcc1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflcc1, kind=int64), ubound(v%rflcc1, kind=int64))
      call put_stream_value(w, v%rflcc1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflcc2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflcc2, kind=int64), ubound(v%rflcc2, kind=int64))
      call put_stream_value(w, v%rflcc2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rflcc3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rflcc3, kind=int64), ubound(v%rflcc3, kind=int64))
      call put_stream_value(w, v%rflcc3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfuaa0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfuaa0, kind=int64), ubound(v%rfuaa0, kind=int64))
      call put_stream_value(w, v%rfuaa0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfuaa1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfuaa1, kind=int64), ubound(v%rfuaa1, kind=int64))
      call put_stream_value(w, v%rfuaa1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfubb0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfubb0, kind=int64), ubound(v%rfubb0, kind=int64))
      call put_stream_value(w, v%rfubb0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfubb1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfubb1, kind=int64), ubound(v%rfubb1, kind=int64))
      call put_stream_value(w, v%rfubb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfubb2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfubb2, kind=int64), ubound(v%rfubb2, kind=int64))
      call put_stream_value(w, v%rfubb2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfubb3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfubb3, kind=int64), ubound(v%rfubb3, kind=int64))
      call put_stream_value(w, v%rfubb3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfucc0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfucc0, kind=int64), ubound(v%rfucc0, kind=int64))
      call put_stream_value(w, v%rfucc0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfucc1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfucc1, kind=int64), ubound(v%rfucc1, kind=int64))
      call put_stream_value(w, v%rfucc1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfucc2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfucc2, kind=int64), ubound(v%rfucc2, kind=int64))
      call put_stream_value(w, v%rfucc2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfucc3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfucc3, kind=int64), ubound(v%rfucc3, kind=int64))
      call put_stream_value(w, v%rfucc3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfldd0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfldd0, kind=int64), ubound(v%rfldd0, kind=int64))
      call put_stream_value(w, v%rfldd0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfldd1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfldd1, kind=int64), ubound(v%rfldd1, kind=int64))
      call put_stream_value(w, v%rfldd1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfldd2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfldd2, kind=int64), ubound(v%rfldd2, kind=int64))
      call put_stream_value(w, v%rfldd2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rfldd3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfldd3, kind=int64), ubound(v%rfldd3, kind=int64))
      call put_stream_value(w, v%rfldd3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.reffia')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%reffia)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rtaua')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtaua, kind=int64), ubound(v%rtaua, kind=int64))
      call put_stream_value(w, v%rtaua)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rpiza')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rpiza, kind=int64), ubound(v%rpiza, kind=int64))
      call put_stream_value(w, v%rpiza)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.rcga')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rcga, kind=int64), ubound(v%rcga, kind=int64))
      call put_stream_value(w, v%rcga)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.raer')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%raer, kind=int64), ubound(v%raer, kind=int64))
      call put_stream_value(w, v%raer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.nmpsrtm')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nmpsrtm, kind=int64), ubound(v%nmpsrtm, kind=int64))
      call put_stream_value(w, v%nmpsrtm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.ntyps')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntyps)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TESWRT.radjust')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%radjust)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_005

  subroutine write_section_006(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_distribution)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERD')
      call put_stream_tag(w, 2_int32, 'TEAERD.cvdaes')
      if (allocated(v%cvdaes)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaes, kind=int64), ubound(v%cvdaes, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.cvdael')
      if (allocated(v%cvdael)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdael, kind=int64), ubound(v%cvdael, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.cvdaeu')
      if (allocated(v%cvdaeu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaeu, kind=int64), ubound(v%cvdaeu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.cvdaed')
      if (allocated(v%cvdaed)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaed, kind=int64), ubound(v%cvdaed, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raesc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raesc, kind=int64), ubound(v%raesc, kind=int64))
      call put_stream_value(w, v%raesc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raess')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raess, kind=int64), ubound(v%raess, kind=int64))
      call put_stream_value(w, v%raess)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raelc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raelc, kind=int64), ubound(v%raelc, kind=int64))
      call put_stream_value(w, v%raelc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raels')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raels, kind=int64), ubound(v%raels, kind=int64))
      call put_stream_value(w, v%raels)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raeuc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raeuc, kind=int64), ubound(v%raeuc, kind=int64))
      call put_stream_value(w, v%raeuc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raeus')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raeus, kind=int64), ubound(v%raeus, kind=int64))
      call put_stream_value(w, v%raeus)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raedc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raedc, kind=int64), ubound(v%raedc, kind=int64))
      call put_stream_value(w, v%raedc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.raeds')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raeds, kind=int64), ubound(v%raeds, kind=int64))
      call put_stream_value(w, v%raeds)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeops')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcaeops)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeopl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcaeopl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeopu')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcaeopu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeopd')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcaeopd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rctrbga')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rctrbga)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcvobga')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcvobga)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcstbga')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcstbga)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rctrpt')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rctrpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeadk')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rcaeadk, kind=int64), ubound(v%rcaeadk, kind=int64))
      call put_stream_value(w, v%rcaeadk)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeadm')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcaeadm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERD.rcaeros')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcaeros)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_006

  subroutine write_section_007(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_atmosphere)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERATM')
      call put_stream_tag(w, 2_int32, 'TEAERATM.naerconf')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naerconf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.niniday')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%niniday)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nxt3daer')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nxt3daer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.ndd1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndd1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nss1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nss1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nbcoptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nbcoptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nddoptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nddoptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nomoptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nomoptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nssoptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nssoptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nsuoptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsuoptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.nviswl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nviswl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.ntaer')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.ntypaer')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ntypaer, kind=int64), ubound(v%ntypaer, kind=int64))
      call put_stream_value(w, v%ntypaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.naer_blnucl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naer_blnucl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.naerscav')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naerscav)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rgrate')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rgrate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.repscaer')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repscaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerclimg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerclimg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerclimz')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerclimz)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerclist')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerclist)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerdrydp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerdrydp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerhygro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerhygro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerlisi')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerlisi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerngat')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerngat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laersedim')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laersedim)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laersurf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laersurf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerelvs')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerelvs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laer6sdia')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laer6sdia)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laersedimss')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laersedimss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laergtop')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laergtop)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerrad')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerccn')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerccn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laeropt')
      call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%laeropt, kind=int64), ubound(v%laeropt, kind=int64))
      call put_stream_value(w, v%laeropt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerinit')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerinit)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laervol')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laervol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laercstr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laercstr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerdiag1')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerdiag1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerdiag2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerdiag2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerrrtm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerrrtm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laeruvp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laeruvp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerextr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerextr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laergbud')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laergbud)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerprnt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerprnt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laernitrate')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laernitrate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.lseasalt_rh80')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lseasalt_rh80)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerdustsource')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerdustsource)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerdustsizevar')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerdustsizevar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.laerdust_newbin')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerdust_newbin)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rss_dry_diafac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rss_dry_diafac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rss_dry_densfac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rss_dry_densfac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rss_dry_massfac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rss_dry_massfac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rss_rh80_diafac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rss_rh80_diafac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rss_rh80_densfac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rss_rh80_densfac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.rss_rh80_massfac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rss_rh80_massfac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.raerdust_rebound')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raerdust_rebound)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERATM.yaero_desc')
      if (associated(v%yaero_desc)) then
 call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 1_int32, lbound(v%yaero_desc, kind=int64), ubound(v%yaero_desc, kind=int64))
      else
        call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_007

  subroutine write_section_008(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cloud_overlap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEOVLP')
      call put_stream_tag(w, 2_int32, 'TEOVLP.ra1ovlp')
      if (allocated(v%ra1ovlp)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ra1ovlp, kind=int64), ubound(v%ra1ovlp, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_008

  subroutine write_section_009(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TRADF')
      call put_stream_tag(w, 2_int32, 'TRADF.emtd')
      if (allocated(v%emtd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%emtd, kind=int64), ubound(v%emtd, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.trsw')
      if (allocated(v%trsw)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%trsw, kind=int64), ubound(v%trsw, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.emtc')
      if (allocated(v%emtc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%emtc, kind=int64), ubound(v%emtc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.trsc')
      if (allocated(v%trsc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%trsc, kind=int64), ubound(v%trsc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.emtu')
      if (allocated(v%emtu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%emtu, kind=int64), ubound(v%emtu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.tauaer')
      if (allocated(v%tauaer)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%tauaer, kind=int64), ubound(v%tauaer, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswd')
      if (allocated(v%srswd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswd, kind=int64), ubound(v%srswd, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srlwdc')
      if (allocated(v%srlwdc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srlwdc, kind=int64), ubound(v%srlwdc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srlwd')
      if (allocated(v%srlwd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%srlwd, kind=int64), ubound(v%srlwd, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswdc')
      if (allocated(v%srswdc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswdc, kind=int64), ubound(v%srswdc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswdcs')
      if (allocated(v%srswdcs)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswdcs, kind=int64), ubound(v%srswdcs, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srlwdcs')
      if (allocated(v%srlwdcs)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srlwdcs, kind=int64), ubound(v%srlwdcs, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswdv')
      if (allocated(v%srswdv)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswdv, kind=int64), ubound(v%srswdv, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswduv')
      if (allocated(v%srswduv)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswduv, kind=int64), ubound(v%srswduv, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.edro')
      if (allocated(v%edro)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%edro, kind=int64), ubound(v%edro, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswpar')
      if (allocated(v%srswpar)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswpar, kind=int64), ubound(v%srswpar, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswuvb')
      if (allocated(v%srswuvb)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswuvb, kind=int64), ubound(v%srswuvb, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswparc')
      if (allocated(v%srswparc)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswparc, kind=int64), ubound(v%srswparc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srswtinc')
      if (allocated(v%srswtinc)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswtinc, kind=int64), ubound(v%srswtinc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srfdir')
      if (allocated(v%srfdir)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srfdir, kind=int64), ubound(v%srfdir, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.srcdir')
      if (allocated(v%srcdir)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srcdir, kind=int64), ubound(v%srcdir, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.rmoon')
      if (allocated(v%rmoon)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmoon, kind=int64), ubound(v%rmoon, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADF.derivativelw')
      if (associated(v%derivativelw)) then
     call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%derivativelw,kind=int64),ubound(v%derivativelw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_009

  subroutine write_section_010(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TRADIATION')
      call put_stream_tag(w, 2_int32, 'TRADIATION.config')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_spectral_solar_scaling')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_spectral_solar_scaling)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.directory_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%directory_name), int64))
      call put_stream_value(w, v%config%directory_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_fraction_threshold')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%cloud_fraction_threshold)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_mixing_ratio_threshold')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%cloud_mixing_ratio_threshold)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_overlap_scheme')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_overlap_scheme)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_beta_overlap')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_beta_overlap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_cloud_pdf_shape')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_cloud_pdf_shape)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_inhom_decorr_scaling')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%cloud_inhom_decorr_scaling)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.clear_to_thick_fraction')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%clear_to_thick_fraction)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.overhead_sun_factor')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%overhead_sun_factor)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.min_gas_od_lw')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%min_gas_od_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.min_gas_od_sw')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%min_gas_od_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.max_gas_od_3d')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%max_gas_od_3d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.max_cloud_od')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%max_cloud_od)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_lw_cloud_scattering')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_lw_cloud_scattering)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_lw_aerosol_scattering')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_lw_aerosol_scattering)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.nregions')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%nregions)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_solver_sw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_solver_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_solver_lw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_solver_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_sw_delta_scaling_with_gases')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_sw_delta_scaling_with_gases)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_gas_model')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_gas_model)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_lw_wavelength')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_lw_wavelength)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_lw_total_od')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_lw_total_od)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_sw_total_od')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_sw_total_od)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_sw_single_scattering_albedo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_sw_single_scattering_albedo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_sw_asymmetry_factor')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_sw_asymmetry_factor)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_lw_single_scattering_albedo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_lw_single_scattering_albedo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.mono_lw_asymmetry_factor')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%mono_lw_asymmetry_factor)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_liq_model')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_liq_model)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_ice_model')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_ice_model)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_psrad_cloud_optics')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_psrad_cloud_optics)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_nearest_spectral_sw_albedo')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_nearest_spectral_sw_albedo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_nearest_spectral_lw_emiss')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_nearest_spectral_lw_emiss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.sw_albedo_wavelength_bound')
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%sw_albedo_wavelength_bound,kind=int64),ubound(v%config%sw_albedo_wavelength_bound,kind=int64))
      call put_stream_value(w, v%config%sw_albedo_wavelength_bound)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.lw_emiss_wavelength_bound')
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%lw_emiss_wavelength_bound,kind=int64),ubound(v%config%lw_emiss_wavelength_bound,kind=int64))
      call put_stream_value(w, v%config%lw_emiss_wavelength_bound)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_sw_albedo_index')
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_sw_albedo_index,kind=int64),ubound(v%config%i_sw_albedo_index,kind=int64))
      call put_stream_value(w, v%config%i_sw_albedo_index)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_lw_emiss_index')
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_lw_emiss_index,kind=int64),ubound(v%config%i_lw_emiss_index,kind=int64))
      call put_stream_value(w, v%config%i_lw_emiss_index)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_lw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_sw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_clear')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_clear)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_sw_direct')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_sw_direct)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_3d_effects')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_3d_effects)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_3d_sw_entrapment')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%i_3d_sw_entrapment)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_3d_lw_multilayer_effects')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_3d_lw_multilayer_effects)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_lw_side_emissivity')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_lw_side_emissivity)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.max_3d_transfer_rate')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%max_3d_transfer_rate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.min_cloud_effective_size')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%min_cloud_effective_size)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.overhang_factor')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%overhang_factor)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_expm_everywhere')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_expm_everywhere)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_aerosols')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_aerosols)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_aerosol_types')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_aerosol_types)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_aerosol_type_map')
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_aerosol_type_map,kind=int64),ubound(v%config%i_aerosol_type_map,kind=int64))
      call put_stream_value(w, v%config%i_aerosol_type_map)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_save_radiative_properties')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_save_radiative_properties)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_save_spectral_flux')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_save_spectral_flux)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_surface_sw_spectral_flux')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_surface_sw_spectral_flux)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_lw_derivatives')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_lw_derivatives)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_save_gpoint_flux')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_save_gpoint_flux)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_setup_ifsrrtm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_setup_ifsrrtm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_fu_lw_ice_optics_bug')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_fu_lw_ice_optics_bug)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.iverbosesetup')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%iverbosesetup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.iverbose')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%iverbose)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_canopy_fluxes_sw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_canopy_fluxes_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_canopy_fluxes_lw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_canopy_fluxes_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_canopy_full_spectrum_sw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_canopy_full_spectrum_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.use_canopy_full_spectrum_lw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%use_canopy_full_spectrum_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_canopy_gases_sw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_canopy_gases_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_canopy_gases_lw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_canopy_gases_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.ice_optics_override_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%ice_optics_override_file_name), int64))
      call put_stream_value(w, v%config%ice_optics_override_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.liq_optics_override_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%liq_optics_override_file_name), int64))
      call put_stream_value(w, v%config%liq_optics_override_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics_override_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%aerosol_optics_override_file_name), int64))
      call put_stream_value(w, v%config%aerosol_optics_override_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_pdf_override_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%cloud_pdf_override_file_name), int64))
      call put_stream_value(w, v%config%cloud_pdf_override_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.is_consolidated')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%is_consolidated)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber1_sw')
      if (allocated(v%config%wavenumber1_sw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber1_sw,kind=int64),ubound(v%config%wavenumber1_sw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber2_sw')
      if (allocated(v%config%wavenumber2_sw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber2_sw,kind=int64),ubound(v%config%wavenumber2_sw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber1_lw')
      if (allocated(v%config%wavenumber1_lw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber1_lw,kind=int64),ubound(v%config%wavenumber1_lw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber2_lw')
      if (allocated(v%config%wavenumber2_lw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber2_lw,kind=int64),ubound(v%config%wavenumber2_lw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_albedo_from_band_sw')
      if (allocated(v%config%i_albedo_from_band_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_albedo_from_band_sw,kind=int64),ubound(v%config%i_albedo_from_band_sw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_emiss_from_band_lw')
      if (allocated(v%config%i_emiss_from_band_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_emiss_from_band_lw,kind=int64),ubound(v%config%i_emiss_from_band_lw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.sw_albedo_weights')
      if (allocated(v%config%sw_albedo_weights)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%sw_albedo_weights,kind=int64),ubound(v%config%sw_albedo_weights,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.lw_emiss_weights')
      if (allocated(v%config%lw_emiss_weights)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%lw_emiss_weights,kind=int64),ubound(v%config%lw_emiss_weights,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_g_lw')
      if (allocated(v%config%i_band_from_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_g_lw,kind=int64),ubound(v%config%i_band_from_g_lw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_g_sw')
      if (allocated(v%config%i_band_from_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_g_sw,kind=int64),ubound(v%config%i_band_from_g_sw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_g_from_reordered_g_lw')
      if (allocated(v%config%i_g_from_reordered_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_g_from_reordered_g_lw,kind=int64),ubound(v%config%i_g_from_reordered_g_lw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_g_from_reordered_g_sw')
      if (allocated(v%config%i_g_from_reordered_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_g_from_reordered_g_sw,kind=int64),ubound(v%config%i_g_from_reordered_g_sw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_reordered_g_lw')
      if (allocated(v%config%i_band_from_reordered_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_reordered_g_lw,kind=int64),ubound(v%config%i_band_from_reordered_g_lw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_reordered_g_sw')
      if (allocated(v%config%i_band_from_reordered_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_reordered_g_sw,kind=int64),ubound(v%config%i_band_from_reordered_g_sw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_spec_from_reordered_g_lw')
      if (associated(v%config%i_spec_from_reordered_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_spec_from_reordered_g_lw,kind=int64),ubound(v%config%i_spec_from_reordered_g_lw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_spec_from_reordered_g_sw')
      if (associated(v%config%i_spec_from_reordered_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_spec_from_reordered_g_sw,kind=int64),ubound(v%config%i_spec_from_reordered_g_sw,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_canopy_bands_sw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_canopy_bands_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_canopy_bands_lw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_canopy_bands_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.liq_coeff_lw')
      if (allocated(v%config%cloud_optics%liq_coeff_lw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%liq_coeff_lw,kind=int64),ubound(v%config%cloud_optics%liq_coeff_lw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.liq_coeff_sw')
      if (allocated(v%config%cloud_optics%liq_coeff_sw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%liq_coeff_sw,kind=int64),ubound(v%config%cloud_optics%liq_coeff_sw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.ice_coeff_lw')
      if (allocated(v%config%cloud_optics%ice_coeff_lw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%ice_coeff_lw,kind=int64),ubound(v%config%cloud_optics%ice_coeff_lw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.ice_coeff_sw')
      if (allocated(v%config%cloud_optics%ice_coeff_sw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%ice_coeff_sw,kind=int64),ubound(v%config%cloud_optics%ice_coeff_sw,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.liq_coeff_gen')
      if (allocated(v%config%cloud_optics%liq_coeff_gen)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%cloud_optics%liq_coeff_gen,kind=int64),ubound(v%config%cloud_optics%liq_coeff_gen,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.ice_coeff_gen')
      if (allocated(v%config%cloud_optics%ice_coeff_gen)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%cloud_optics%ice_coeff_gen,kind=int64),ubound(v%config%cloud_optics%ice_coeff_gen,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.iclass')
      if (allocated(v%config%aerosol_optics%iclass)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%aerosol_optics%iclass,kind=int64),ubound(v%config%aerosol_optics%iclass,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.itype')
      if (allocated(v%config%aerosol_optics%itype)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%aerosol_optics%itype,kind=int64),ubound(v%config%aerosol_optics%itype,kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_sw_phobic')
      if (allocated(v%config%aerosol_optics%mass_ext_sw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_sw_phobic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_sw_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_sw_phobic')
      if (allocated(v%config%aerosol_optics%ssa_sw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%ssa_sw_phobic,kind=int64),ubound(v%config%aerosol_optics%ssa_sw_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_sw_phobic')
      if (allocated(v%config%aerosol_optics%g_sw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%g_sw_phobic,kind=int64),ubound(v%config%aerosol_optics%g_sw_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_lw_phobic')
      if (allocated(v%config%aerosol_optics%mass_ext_lw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_lw_phobic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_lw_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_lw_phobic')
      if (allocated(v%config%aerosol_optics%ssa_lw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%ssa_lw_phobic,kind=int64),ubound(v%config%aerosol_optics%ssa_lw_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_lw_phobic')
      if (allocated(v%config%aerosol_optics%g_lw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%g_lw_phobic,kind=int64),ubound(v%config%aerosol_optics%g_lw_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_sw_philic')
      if (allocated(v%config%aerosol_optics%mass_ext_sw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_sw_philic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_sw_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_sw_philic')
      if (allocated(v%config%aerosol_optics%ssa_sw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%ssa_sw_philic,kind=int64),ubound(v%config%aerosol_optics%ssa_sw_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_sw_philic')
      if (allocated(v%config%aerosol_optics%g_sw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%g_sw_philic,kind=int64),ubound(v%config%aerosol_optics%g_sw_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_lw_philic')
      if (allocated(v%config%aerosol_optics%mass_ext_lw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_lw_philic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_lw_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_lw_philic')
      if (allocated(v%config%aerosol_optics%ssa_lw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%ssa_lw_philic,kind=int64),ubound(v%config%aerosol_optics%ssa_lw_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_lw_philic')
      if (allocated(v%config%aerosol_optics%g_lw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%g_lw_philic,kind=int64),ubound(v%config%aerosol_optics%g_lw_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_mono_phobic')
      if (allocated(v%config%aerosol_optics%mass_ext_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_mono_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_mono_phobic')
      if (allocated(v%config%aerosol_optics%ssa_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%ssa_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%ssa_mono_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_mono_phobic')
      if (allocated(v%config%aerosol_optics%g_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%g_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%g_mono_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.lidar_ratio_mono_phobic')
      if (allocated(v%config%aerosol_optics%lidar_ratio_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%lidar_ratio_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%lidar_ratio_mono_phobic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_mono_philic')
      if (allocated(v%config%aerosol_optics%mass_ext_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_mono_philic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_mono_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_mono_philic')
      if (allocated(v%config%aerosol_optics%ssa_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%ssa_mono_philic,kind=int64),ubound(v%config%aerosol_optics%ssa_mono_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_mono_philic')
      if (allocated(v%config%aerosol_optics%g_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%g_mono_philic,kind=int64),ubound(v%config%aerosol_optics%g_mono_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.lidar_ratio_mono_philic')
      if (allocated(v%config%aerosol_optics%lidar_ratio_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%lidar_ratio_mono_philic,kind=int64),ubound(v%config%aerosol_optics%lidar_ratio_mono_philic,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.rh_lower')
      if (allocated(v%config%aerosol_optics%rh_lower)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%aerosol_optics%rh_lower,kind=int64),ubound(v%config%aerosol_optics%rh_lower,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.description_phobic_str')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%aerosol_optics%description_phobic_str), int64))
      call put_stream_value(w, v%config%aerosol_optics%description_phobic_str)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.description_philic_str')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%aerosol_optics%description_philic_str), int64))
      call put_stream_value(w, v%config%aerosol_optics%description_philic_str)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ntype')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%ntype)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.n_type_phobic')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%n_type_phobic)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.n_type_philic')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%n_type_philic)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.nrh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%nrh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.n_bands_lw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%n_bands_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.n_bands_sw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%n_bands_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.n_mono_wl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%n_mono_wl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.use_hydrophilic')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%use_hydrophilic)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.use_monochromatic')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%aerosol_optics%use_monochromatic)
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler.ncdf')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%pdf_sampler%ncdf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler.nfsd')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%pdf_sampler%nfsd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler.fsd1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%pdf_sampler%fsd1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler.inv_fsd_interval')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%pdf_sampler%inv_fsd_interval)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler.val')
      if (allocated(v%config%pdf_sampler%val)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%pdf_sampler%val,kind=int64),ubound(v%config%pdf_sampler%val,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.ice_optics_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%ice_optics_file_name), int64))
      call put_stream_value(w, v%config%ice_optics_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.liq_optics_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%liq_optics_file_name), int64))
      call put_stream_value(w, v%config%liq_optics_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%aerosol_optics_file_name), int64))
      call put_stream_value(w, v%config%aerosol_optics_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_pdf_file_name')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%config%cloud_pdf_file_name), int64))
      call put_stream_value(w, v%config%cloud_pdf_file_name)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_g_sw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_g_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_g_lw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_g_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_bands_sw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_bands_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_bands_lw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_bands_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_spec_sw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_spec_sw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_spec_lw')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_spec_lw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_g_lw_if_scattering')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_g_lw_if_scattering)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.n_bands_lw_if_scattering')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%n_bands_lw_if_scattering)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.is_homogeneous')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%is_homogeneous)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.do_clouds')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%config%do_clouds)
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.nweight_uv')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nweight_uv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.iband_uv')
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%iband_uv, kind=int64), ubound(v%iband_uv, kind=int64))
      call put_stream_value(w, v%iband_uv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.weight_uv')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%weight_uv, kind=int64), ubound(v%weight_uv, kind=int64))
      call put_stream_value(w, v%weight_uv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.nweight_par')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nweight_par)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.iband_par')
   call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%iband_par, kind=int64), ubound(v%iband_par, kind=int64))
      call put_stream_value(w, v%iband_par)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.weight_par')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%weight_par, kind=int64), ubound(v%weight_par, kind=int64))
      call put_stream_value(w, v%weight_par)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.trop_bg_aer_mass_ext')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%trop_bg_aer_mass_ext)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TRADIATION.strat_bg_aer_mass_ext')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%strat_bg_aer_mass_ext)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_010

  subroutine write_section_011(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%cmip)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TECMIP')
      call put_stream_tag(w, 2_int32, 'TECMIP.nrcp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrcp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.no3cmip')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%no3cmip)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.nghgcmip')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nghgcmip)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.ncmipfixyr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ncmipfixyr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.ncurryr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ncurryr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.ghgdatadir')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%ghgdatadir), int64))
      call put_stream_value(w, v%ghgdatadir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.csolardata')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csolardata), int64))
      call put_stream_value(w, v%csolardata)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.co3datadir')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%co3datadir), int64))
      call put_stream_value(w, v%co3datadir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.co3datafil')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%co3datafil), int64))
      call put_stream_value(w, v%co3datafil)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.zozcl')
      if (allocated(v%zozcl)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%zozcl, kind=int64), ubound(v%zozcl, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.rsinc1')
      if (allocated(v%rsinc1)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsinc1, kind=int64), ubound(v%rsinc1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.rproc1')
      if (allocated(v%rproc1)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rproc1, kind=int64), ubound(v%rproc1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.rlatcli')
      if (allocated(v%rlatcli)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlatcli, kind=int64), ubound(v%rlatcli, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.rloncli')
      if (allocated(v%rloncli)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rloncli, kind=int64), ubound(v%rloncli, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TECMIP.rozt1')
      if (allocated(v%rozt1)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rozt1, kind=int64), ubound(v%rozt1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_011

  subroutine write_section_012(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ozone)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEOZOC')
      call put_stream_tag(w, 2_int32, 'TEOZOC.zozcl')
      if (allocated(v%zozcl)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%zozcl, kind=int64), ubound(v%zozcl, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.zozclaqua')
      if (allocated(v%zozclaqua)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%zozclaqua, kind=int64), ubound(v%zozclaqua, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.cozqc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cozqc, kind=int64), ubound(v%cozqc, kind=int64))
      call put_stream_value(w, v%cozqc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.cozqs')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cozqs, kind=int64), ubound(v%cozqs, kind=int64))
      call put_stream_value(w, v%cozqs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.cozhc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cozhc, kind=int64), ubound(v%cozhc, kind=int64))
      call put_stream_value(w, v%cozhc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.cozhs')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cozhs, kind=int64), ubound(v%cozhs, kind=int64))
      call put_stream_value(w, v%cozhs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.rsinc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsinc, kind=int64), ubound(v%rsinc, kind=int64))
      call put_stream_value(w, v%rsinc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.rozt')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rozt, kind=int64), ubound(v%rozt, kind=int64))
      call put_stream_value(w, v%rozt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEOZOC.rproc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rproc, kind=int64), ubound(v%rproc, kind=int64))
      call put_stream_value(w, v%rproc)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_012

  subroutine write_section_013(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEGEN')
      call put_stream_tag(w, 2_int32, 'TEGEN.repaer')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.raerbc')
      if (associated(v%raerbc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raerbc, kind=int64), ubound(v%raerbc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.raeror')
      if (associated(v%raeror)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raeror, kind=int64), ubound(v%raeror, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.raersd')
      if (associated(v%raersd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raersd, kind=int64), ubound(v%raersd, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.raerss')
      if (associated(v%raerss)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raerss, kind=int64), ubound(v%raerss, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.raersu')
      if (associated(v%raersu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raersu, kind=int64), ubound(v%raersu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.raerv')
      if (associated(v%raerv)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raerv, kind=int64), ubound(v%raerv, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rlatv')
      if (associated(v%rlatv)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlatv, kind=int64), ubound(v%rlatv, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rtaebc')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtaebc, kind=int64), ubound(v%rtaebc, kind=int64))
      call put_stream_value(w, v%rtaebc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rtaeor')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtaeor, kind=int64), ubound(v%rtaeor, kind=int64))
      call put_stream_value(w, v%rtaeor)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rtaesd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtaesd, kind=int64), ubound(v%rtaesd, kind=int64))
      call put_stream_value(w, v%rtaesd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rtaess')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtaess, kind=int64), ubound(v%rtaess, kind=int64))
      call put_stream_value(w, v%rtaess)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rtaesu')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rtaesu, kind=int64), ubound(v%rtaesu, kind=int64))
      call put_stream_value(w, v%rtaesu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.rtaevo')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rtaevo, kind=int64), ubound(v%rtaevo, kind=int64))
      call put_stream_value(w, v%rtaevo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.isyear')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%isyear)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.ieyear')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ieyear)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEGEN.is_initialised')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%is_initialised)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_013

  subroutine write_section_014(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'CAMS')
      call put_stream_tag(w, 2_int32, 'CAMS.rmacbc')
      if (allocated(v%rmacbc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacbc, kind=int64), ubound(v%rmacbc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacor')
      if (allocated(v%rmacor)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacor, kind=int64), ubound(v%rmacor, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd')
      if (allocated(v%rmacsd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd, kind=int64), ubound(v%rmacsd, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss')
      if (allocated(v%rmacss)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss, kind=int64), ubound(v%rmacss, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsu')
      if (allocated(v%rmacsu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsu, kind=int64), ubound(v%rmacsu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaebc')
      if (allocated(v%rmaebc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaebc, kind=int64), ubound(v%rmaebc, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaeor')
      if (allocated(v%rmaeor)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaeor, kind=int64), ubound(v%rmaeor, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd')
      if (allocated(v%rmaesd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd, kind=int64), ubound(v%rmaesd, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess')
      if (allocated(v%rmaess)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess, kind=int64), ubound(v%rmaess, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesu')
      if (allocated(v%rmaesu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesu, kind=int64), ubound(v%rmaesu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacbc1')
      if (allocated(v%rmacbc1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacbc1, kind=int64), ubound(v%rmacbc1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacbc2')
      if (allocated(v%rmacbc2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacbc2, kind=int64), ubound(v%rmacbc2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaebc1')
      if (allocated(v%rmaebc1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaebc1, kind=int64), ubound(v%rmaebc1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaebc2')
      if (allocated(v%rmaebc2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaebc2, kind=int64), ubound(v%rmaebc2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacor1')
      if (allocated(v%rmacor1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacor1, kind=int64), ubound(v%rmacor1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacor2')
      if (allocated(v%rmacor2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacor2, kind=int64), ubound(v%rmacor2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaeor1')
      if (allocated(v%rmaeor1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaeor1, kind=int64), ubound(v%rmaeor1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaeor2')
      if (allocated(v%rmaeor2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaeor2, kind=int64), ubound(v%rmaeor2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd1')
      if (allocated(v%rmacsd1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd1, kind=int64), ubound(v%rmacsd1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd2')
      if (allocated(v%rmacsd2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd2, kind=int64), ubound(v%rmacsd2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd3')
      if (allocated(v%rmacsd3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd3, kind=int64), ubound(v%rmacsd3, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd1')
      if (allocated(v%rmaesd1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd1, kind=int64), ubound(v%rmaesd1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd2')
      if (allocated(v%rmaesd2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd2, kind=int64), ubound(v%rmaesd2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd3')
      if (allocated(v%rmaesd3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd3, kind=int64), ubound(v%rmaesd3, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss1')
      if (allocated(v%rmacss1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss1, kind=int64), ubound(v%rmacss1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss2')
      if (allocated(v%rmacss2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss2, kind=int64), ubound(v%rmacss2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss3')
      if (allocated(v%rmacss3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss3, kind=int64), ubound(v%rmacss3, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess1')
      if (allocated(v%rmaess1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess1, kind=int64), ubound(v%rmaess1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess2')
      if (allocated(v%rmaess2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess2, kind=int64), ubound(v%rmaess2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess3')
      if (allocated(v%rmaess3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess3, kind=int64), ubound(v%rmaess3, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsu1')
      if (allocated(v%rmacsu1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsu1, kind=int64), ubound(v%rmacsu1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesu1')
      if (allocated(v%rmaesu1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesu1, kind=int64), ubound(v%rmaesu1, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacbc13d')
      if (associated(v%rmacbc13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacbc13d, kind=int64), ubound(v%rmacbc13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacbc23d')
      if (associated(v%rmacbc23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacbc23d, kind=int64), ubound(v%rmacbc23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacor13d')
      if (associated(v%rmacor13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacor13d, kind=int64), ubound(v%rmacor13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacor23d')
      if (associated(v%rmacor23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacor23d, kind=int64), ubound(v%rmacor23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd13d')
      if (associated(v%rmacsd13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacsd13d, kind=int64), ubound(v%rmacsd13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd23d')
      if (associated(v%rmacsd23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacsd23d, kind=int64), ubound(v%rmacsd23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsd33d')
      if (associated(v%rmacsd33d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacsd33d, kind=int64), ubound(v%rmacsd33d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss13d')
      if (associated(v%rmacss13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacss13d, kind=int64), ubound(v%rmacss13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss23d')
      if (associated(v%rmacss23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacss23d, kind=int64), ubound(v%rmacss23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacss33d')
      if (associated(v%rmacss33d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacss33d, kind=int64), ubound(v%rmacss33d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmacsu13d')
      if (associated(v%rmacsu13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%rmacsu13d, kind=int64), ubound(v%rmacsu13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.ref_mon_aer_prs')
      if (associated(v%ref_mon_aer_prs)) then
call put_stream_metadata(w,2_int32,8_int32,4_int32,1_int32,lbound(v%ref_mon_aer_prs,kind=int64),ubound(v%ref_mon_aer_prs,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.ref_mon_aer_dprs')
      if (associated(v%ref_mon_aer_dprs)) then
call put_stream_metadata(w,2_int32,8_int32,4_int32,1_int32,lbound(v%ref_mon_aer_dprs,kind=int64),ubound(v%ref_mon_aer_dprs,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaebc13d')
      if (allocated(v%rmaebc13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaebc13d, kind=int64), ubound(v%rmaebc13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaebc23d')
      if (allocated(v%rmaebc23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaebc23d, kind=int64), ubound(v%rmaebc23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaeor13d')
      if (allocated(v%rmaeor13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaeor13d, kind=int64), ubound(v%rmaeor13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaeor23d')
      if (allocated(v%rmaeor23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaeor23d, kind=int64), ubound(v%rmaeor23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd13d')
      if (allocated(v%rmaesd13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaesd13d, kind=int64), ubound(v%rmaesd13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd23d')
      if (allocated(v%rmaesd23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaesd23d, kind=int64), ubound(v%rmaesd23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesd33d')
      if (allocated(v%rmaesd33d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaesd33d, kind=int64), ubound(v%rmaesd33d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess13d')
      if (allocated(v%rmaess13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaess13d, kind=int64), ubound(v%rmaess13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess23d')
      if (allocated(v%rmaess23d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaess23d, kind=int64), ubound(v%rmaess23d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaess33d')
      if (allocated(v%rmaess33d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaess33d, kind=int64), ubound(v%rmaess33d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.rmaesu13d')
      if (allocated(v%rmaesu13d)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmaesu13d, kind=int64), ubound(v%rmaesu13d, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.ref_aer_prs')
      if (allocated(v%ref_aer_prs)) then
       call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%ref_aer_prs,kind=int64),ubound(v%ref_aer_prs,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.ref_aer_dprs')
      if (allocated(v%ref_aer_dprs)) then
     call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%ref_aer_dprs,kind=int64),ubound(v%ref_aer_dprs,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'CAMS.is_initialised')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%is_initialised)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_014

  subroutine write_section_015(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%physics)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEPHY')
      call put_stream_tag(w, 2_int32, 'TEPHY.lephys')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lephys)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lecond')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecond)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lecumf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecumf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.ledcld')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledcld)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leevap')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leevap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.legwdg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%legwdg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.legwwms')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%legwwms)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leozoc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leozoc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leqngt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leqngt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leradi')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leradimpl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradimpl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lerads')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lerads)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesice')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesice)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesurf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesurf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.levdif')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levdif)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.levdifsl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levdifsl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lagphy')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lagphy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lepcld')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lepcld)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leo3ch')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leo3ch)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lo3ch_safe')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3ch_safe)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lo3ch_oldver')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3ch_oldver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lo3ch_bms')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3ch_bms)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lo3ch_hlo')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3ch_hlo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.co3chem')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%co3chem), int64))
      call put_stream_value(w, v%co3chem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lneeonline')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lneeonline)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lwetonline')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lwetonline)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lbud23')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lbud23)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lpptiles')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lpptiles)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lbudcycle')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lbudcycle)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lextratend')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lextratend)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lemethox')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lemethox)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lecurr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecurr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesurftraj')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesurftraj)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lvdftrac')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvdftrac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lvdfnewtrac')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvdfnewtrac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lmftrac')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lmftrac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lmfscav')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lmfscav)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lerain')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lerain)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lemwave')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lemwave)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.legbrad')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%legbrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leraingg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leraingg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesmos')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesmos)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesmap')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesmap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leocwa')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leocwa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leocco')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leocco)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leocsa')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leocsa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leocla')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leocla)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.levgen')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levgen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lessro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lessro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leflake')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leflake)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leocml')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leocml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leobc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leobc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leobcmax')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leobcmax)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.reobcmax')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%reobcmax)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leobcice')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leobcice)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leoclake')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leoclake)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leolakesst')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leolakesst)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.locmltke')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%locmltke)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leclipqt0')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leclipqt0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leclipcldt0')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leclipcldt0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lductdia')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lductdia)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.ldiagturb_ec')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldiagturb_ec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.ldiagturbgrad_ec')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldiagturbgrad_ec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lslphy')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslphy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesn09')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesn09)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lelaiv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lelaiv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lectessel')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lectessel)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leags')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leags)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lefarquhar')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lefarquhar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leoptsurf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leoptsurf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lec4map')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lec4map)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leairco2coup')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leairco2coup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lelight')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lelight)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lvextrdynacc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvextrdynacc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.rthrfrti')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rthrfrti)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.rcimin')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcimin)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.rlaiint')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlaiint)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.npraccl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npraccl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nlimode')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlimode)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leclim10d')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leclim10d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lesnml')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesnml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.leurban')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leurban)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nsnmlws')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsnmlws)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lbfasco2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lbfasco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nco2climyy1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nco2climyy1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nco2climyy2')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nco2climyy2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nco2climn1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nco2climn1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nco2climn2')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nco2climn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nco2climfrq')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nco2climfrq)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nalbedoscheme')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nalbedoscheme)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.nemissscheme')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nemissscheme)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.ralfminpsn')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ralfminpsn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.rnorthml')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rnorthml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.rsouthml')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsouthml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.rwestml')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rwestml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.reastml')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%reastml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.invml')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%invml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lfpos_ec_phys')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfpos_ec_phys)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lfpos_acc_reset')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfpos_acc_reset)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHY.lrad_cloud_inhomog')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrad_cloud_inhomog)
      if (w%status /= 0_int32) return
      if (storage_size(v%ysurf) /= storage_size(c_null_ptr)) then
        call set_stream_failure(w, 2_int32)
        return
      end if
      call put_stream_tag(w, 6_int32, 'TEPHY.ysurf')
call put_stream_metadata(w,6_int32,0_int32,0_int32,merge(1_int32,0_int32,c_associated(transfer(v%ysurf,c_null_ptr))),[integer(int64)::],[integer(int64)::])
    end associate
  end subroutine write_section_015

  subroutine write_section_016(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_lidar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERLID')
      call put_stream_tag(w, 2_int32, 'TEAERLID.naelid')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naelid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.nwlid')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nwlid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.naerlisi')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naerlisi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.jwlid')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%jwlid, kind=int64), ubound(v%jwlid, kind=int64))
      call put_stream_value(w, v%jwlid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rwlid')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rwlid, kind=int64), ubound(v%rwlid, kind=int64))
      call put_stream_value(w, v%rwlid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlico2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlico2, kind=int64), ubound(v%rlico2, kind=int64))
      call put_stream_value(w, v%rlico2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlio2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlio2, kind=int64), ubound(v%rlio2, kind=int64))
      call put_stream_value(w, v%rlio2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlino2')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rlino2, kind=int64), ubound(v%rlino2, kind=int64))
      call put_stream_value(w, v%rlino2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlio3')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rlio3, kind=int64), ubound(v%rlio3, kind=int64))
      call put_stream_value(w, v%rlio3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlicls')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlicls)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlidelt')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlidelt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlins')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlins)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlipref')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlipref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlitref')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlitref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rlit0')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlit0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERLID.rliddz')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rliddz)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_016

  subroutine write_section_017(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_mapping)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERMAP')
      call put_stream_tag(w, 2_int32, 'TEAERMAP.ndusrcp')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ndusrcp, kind=int64), ubound(v%ndusrcp, kind=int64))
      call put_stream_value(w, v%ndusrcp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERMAP.rdduaer')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rdduaer, kind=int64), ubound(v%rdduaer, kind=int64))
      call put_stream_value(w, v%rdduaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERMAP.rdusrcp')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rdusrcp, kind=int64), ubound(v%rdusrcp, kind=int64))
      call put_stream_value(w, v%rdusrcp)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_017

  subroutine write_section_018(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_sinks)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERSNK')
      call put_stream_tag(w, 2_int32, 'TEAERSNK.ndrydepvel_dyn')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndrydepvel_dyn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.ndrydep')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndrydep)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.r_r')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%r_r)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.r_s')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%r_s)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.raerts')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%raerts, kind=int64), ubound(v%raerts, kind=int64))
      call put_stream_value(w, v%raerts)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rfraer')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rfraer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rrhtab')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rrhtab, kind=int64), ubound(v%rrhtab, kind=int64))
      call put_stream_value(w, v%rrhtab)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rssgrowth_rhtab')
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%rssgrowth_rhtab,kind=int64),ubound(v%rssgrowth_rhtab,kind=int64))
      call put_stream_value(w, v%rssgrowth_rhtab)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rssdens_rhtab')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%rssdens_rhtab,kind=int64),ubound(v%rssdens_rhtab,kind=int64))
      call put_stream_value(w, v%rssdens_rhtab)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rmmd_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rmmd_dd, kind=int64), ubound(v%rmmd_dd, kind=int64))
      call put_stream_value(w, v%rmmd_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rrho_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rrho_dd, kind=int64), ubound(v%rrho_dd, kind=int64))
      call put_stream_value(w, v%rrho_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rmmd_ni')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rmmd_ni, kind=int64), ubound(v%rmmd_ni, kind=int64))
      call put_stream_value(w, v%rmmd_ni)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rrho_ni')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rrho_ni, kind=int64), ubound(v%rrho_ni, kind=int64))
      call put_stream_value(w, v%rrho_ni)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rmmd_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rmmd_ss, kind=int64), ubound(v%rmmd_ss, kind=int64))
      call put_stream_value(w, v%rmmd_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rrho_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rrho_ss, kind=int64), ubound(v%rrho_ss, kind=int64))
      call put_stream_value(w, v%rrho_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rho_wat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rho_wat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rho_ice')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rho_ice)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rhamaker')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rhamaker)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rso2cv1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rso2cv1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rso2cv2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rso2cv2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rsucv1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsucv1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rsucv2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsucv2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rvso2cv1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvso2cv1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSNK.rvso2cv2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvso2cv2)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_018

  subroutine write_section_019(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_sources)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERSRC')
      call put_stream_tag(w, 2_int32, 'TEAERSRC.nddust')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nddust)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.nssalt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nssalt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.naerwnd')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naerwnd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.ndmso')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndmso)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.npist')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npist)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.nso4scheme')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nso4scheme)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.lepaero')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lepaero)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.laeromin')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laeromin)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.locndms')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%locndms)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rgelav')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rgelav)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rgemuv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rgemuv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rdglav')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rdglav)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rdgmuv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rdgmuv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rclonv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rclonv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rslonv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rslonv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rdclonv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rdclonv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rdslonv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rdslonv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rlatvol')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlatvol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rlonvol')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlonvol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rfctdu')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rfctdu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rfctss')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rfctss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rfctdur')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rfctdur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rfctssr')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rfctssr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.raerdub')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%raerdub)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rdmsmin')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rdmsmin)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rcodeca')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcodeca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rsideca')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsideca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rcovsra')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcovsra)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rsivsra')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsivsra)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rssflx')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rssflx, kind=int64), ubound(v%rssflx, kind=int64))
      call put_stream_value(w, v%rssflx)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERSRC.rddusrc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rddusrc, kind=int64), ubound(v%rddusrc, kind=int64))
      call put_stream_value(w, v%rddusrc)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_019

  subroutine write_section_020(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_volume)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEAERVOL')
      call put_stream_tag(w, 2_int32, 'TEAERVOL.naervolc')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naervolc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.naervole')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naervole)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.ninterpt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ninterpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.ntvolc')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntvolc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.nvolerup')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nvolerup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.nvolhomo')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nvolhomo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.nvoloptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nvoloptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.nvoleruz')
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nvoleruz, kind=int64), ubound(v%nvoleruz, kind=int64))
      call put_stream_value(w, v%nvoleruz)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.nvoldats')
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nvoldats, kind=int64), ubound(v%nvoldats, kind=int64))
      call put_stream_value(w, v%nvoldats)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.nvoldate')
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nvoldate, kind=int64), ubound(v%nvoldate, kind=int64))
      call put_stream_value(w, v%nvoldate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.raervolc')
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%raervolc, kind=int64), ubound(v%raervolc, kind=int64))
      call put_stream_value(w, v%raervolc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.raervole')
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%raervole, kind=int64), ubound(v%raervole, kind=int64))
      call put_stream_value(w, v%raervole)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.rvoleruz')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rvoleruz, kind=int64), ubound(v%rvoleruz, kind=int64))
      call put_stream_value(w, v%rvoleruz)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.rvsedvol')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvsedvol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.rvdepvol')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvdepvol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEAERVOL.rwdepvol')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rwdepvol)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_020

  subroutine write_section_021(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_debug)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEDBUG')
      call put_stream_tag(w, 2_int32, 'TEDBUG.kstpdbg')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%kstpdbg, kind=int64), ubound(v%kstpdbg, kind=int64))
      call put_stream_value(w, v%kstpdbg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEDBUG.nstpdbg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nstpdbg)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_021

  subroutine write_section_022(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => composition)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TCOMPO')
      call put_stream_tag(w, 2_int32, 'TCOMPO.lchem_dia')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lchem_dia)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.rchem_dia_period')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rchem_dia_period)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.lchem_ddflx')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lchem_ddflx)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.lcompo_ddflx_dir')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcompo_ddflx_dir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.lchem_tropo')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lchem_tropo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laereqsam4clim')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laereqsam4clim)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laerosfc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerosfc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.lcompo_dcdd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcompo_dcdd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laernitrate')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laernitrate)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laerresuspension')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerresuspension)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laersoa')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laersoa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laersoa_coupled')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laersoa_coupled)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.kghg_chemtend_ch4')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%kghg_chemtend_ch4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.laernucl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laernucl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.aero_scheme')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%aero_scheme), int64))
      call put_stream_value(w, v%aero_scheme)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.nemis2d_desc')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nemis2d_desc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.yemis2d_desc')
      if (allocated(v%yemis2d_desc)) then
     call put_stream_metadata(w,5_int32,0_int32,1_int32,1_int32,lbound(v%yemis2d_desc,kind=int64),ubound(v%yemis2d_desc,kind=int64))
      else
        call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.nemis3d_desc')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nemis3d_desc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.yemis3d_desc')
      if (allocated(v%yemis3d_desc)) then
     call put_stream_metadata(w,5_int32,0_int32,1_int32,1_int32,lbound(v%yemis3d_desc,kind=int64),ubound(v%yemis3d_desc,kind=int64))
      else
        call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TCOMPO.yemis2daux_desc')
      if (allocated(v%yemis2daux_desc)) then
call put_stream_metadata(w,5_int32,0_int32,1_int32,1_int32,lbound(v%yemis2daux_desc,kind=int64),ubound(v%yemis2daux_desc,kind=int64))
      else
        call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_022

  subroutine write_section_023(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => phy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TPHY')
      call put_stream_tag(w, 2_int32, 'TPHY.nbiter')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nbiter)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.niterfl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%niterfl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ndpsfi')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndpsfi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lmphys')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lmphys)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lreasur')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lreasur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcape')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcape)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvgqd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvgqd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvgqm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvgqm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvgqp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvgqp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcondwt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcondwt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvdd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvdd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvpgy')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvpgy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvpp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvpp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldifcexp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldifcexp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldifcons')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldifcons)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldifql')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldifql)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldistur')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldistur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lneige')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lneige)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrnumx')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrnumx)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrnuexp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrnuexp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrtruebbc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrtruebbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrtruedir')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrtruedir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lacpanmx')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lacpanmx)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lclsatur')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lclsatur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lvoigt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvoigt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lglaciers')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lglaciers)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lvfull')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvfull)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lslc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lraylu')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lraylu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrews')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrews)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrprox')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrprox)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrmix')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrmix)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrstab')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrstab)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrstaer')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrstaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrtpp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrtpp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrtdl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrtdl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lraypl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lraypl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrrgust')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrrgust)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lo3abc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3abc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lo3fl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lo3fl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lecshal')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecshal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lecdeep')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecdeep)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebnxr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebnxr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lneb_fp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lneb_fp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lqxrtgh')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lqxrtgh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lhucn')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lhucn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lfpcor')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfpcor)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnoias')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnoias)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lglt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lglt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnewd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnewd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lprocld')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lprocld)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.levapp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levapp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcollec')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcollec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ladjcld')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ladjcld)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsedsta')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsedsta)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsedlag')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsedlag)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsedcl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsedcl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lfsvar')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfsvar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lfsfix')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfsfix)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.la0mps')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%la0mps)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.larpmps')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%larpmps)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.l3mt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%l3mt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lgpcmt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lgpcmt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lentch')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lentch)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcddevpro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcddevpro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.laerosea')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerosea)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.laerolan')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerolan)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.laerosoo')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerosoo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.laerodes')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerodes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.laerovol')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerovol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.laerosul')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%laerosul)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrelaxt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrelaxt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrelaxw')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrelaxw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lssd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lssd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lpble')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lpble)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lblvar')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lblvar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lz0hsrel')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lz0hsrel)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lmlh')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lmlh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnodifqc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnodifqc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lncvpgy')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lncvpgy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsqrml')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsqrml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lab12')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lab12)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvshcu')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvshcu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvgq')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvgq)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lpec')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lpec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ludevol')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ludevol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcddcsd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcddcsd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nclomix')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nclomix)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nfsig')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfsig)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lhlradupd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lhlradupd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ndprecperiod')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndprecperiod)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ndprecperiod2')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndprecperiod2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldprecips')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldprecips)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldprecips2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldprecips2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.hdprecips')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%hdprecips)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.hdclwc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%hdclwc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdhail1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdhail1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdhail2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdhail2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdseuil1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdseuil1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdseuil2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdseuil2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdseuil3')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdseuil3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdseuil4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdseuil4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdseuil5')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdseuil5)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rdclwc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rdclwc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rprecseuil')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rprecseuil)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rhtop')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rhtop)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rtpw')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rtpw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.rawarm')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%rawarm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.racold')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%racold)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.ndtprec')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%ndtprec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.ndtprec2')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%ndtprec2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.ndtpreccur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%ndtpreccur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdprecips.ndtpreccur2')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdprecips%ndtpreccur2)
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.hvisi')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%hvisi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_cm1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_cm1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_cm2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_cm2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_cm3')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_cm3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_cm4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_cm4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_rm1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_rm1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_rm2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_rm2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_im1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_im1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_im2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_im2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_sm1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_sm1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_sm2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_sm2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_gm1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_gm1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.yrdvisi.coef_gm2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%yrdvisi%coef_gm2)
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.cgmixlen')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cgmixlen), int64))
      call put_stream_value(w, v%cgmixlen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.cgturs')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cgturs), int64))
      call put_stream_value(w, v%cgturs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.cgtrg')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cgtrg), int64))
      call put_stream_value(w, v%cgtrg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lprgml')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lprgml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvra')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvra)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ldayd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldayd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvpro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvpro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lgrapro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lgrapro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcddpro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcddpro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvcsd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvcsd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lusl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lusl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnsdo')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnsdo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lect')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lect)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lefb')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lfluso')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfluso)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lectq1')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lectq1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lectrep')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lectrep)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lptke')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lptke)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefktke')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefktke)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefksurf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefksurf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_msc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_msc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_f1')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_f1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_toms')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_toms)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_ths1')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_ths1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_ris')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_ris)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_rih')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_rih)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_pl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_pl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_ml')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_ml)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_ptte')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_ptte)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_flx')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_flx)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcoefk_scq')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcoefk_scq)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lafgd_a')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lafgd_a)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lgwd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lgwd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lgwdc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lgwdc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnorgwd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnorgwd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lhmto')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lhmto)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebco')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebco)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebn')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lptopc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lptopc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lozone')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lozone)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lray')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lray)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrayfm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrayfm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrmu0m')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrmu0m)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrayfm15')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrayfm15)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrrmes')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrrmes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsfhyd')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsfhyd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsnv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsnv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsolv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsolv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lfgel')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfgel)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lstra')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lstra)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lstras')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lstras)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lstrapro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lstrapro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnewstat')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnewstat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lthermo')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lthermo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lvdif')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvdif)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvlis')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvlis)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvcas')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvcas)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lscmf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lscmf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lvgsn')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvgsn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lphcdpi')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lphcdpi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebgr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebgr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebgy')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebgy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvrav3')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvrav3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvppkf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvppkf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvturb')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvturb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebric')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebric)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ledkf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledkf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ledmfi')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledmfi)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ledmfs')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledmfs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lectfl')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lectfl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lectfl0')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lectfl0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nphyrep')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nphyrep)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.noir')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%noir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcamod')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcamod)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcomod')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcomod)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lphspsh')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lphspsh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsmnimbt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsmnimbt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsmtps')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsmtps)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsmgcdev')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsmgcdev)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lxrcdev')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lxrcdev)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrkcdev')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrkcdev)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsmith_cdev')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsmith_cdev)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lrcvott')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lrcvott)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebcv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebcv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebins')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebins)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ndiffneb')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndiffneb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nimelit')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nimelit)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nray')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nray)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nsorayfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsorayfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nthrayfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nthrayfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nrautoev')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrautoev)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nsmtbot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsmtbot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nsmdneb')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsmdneb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nprac')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nprac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nprri')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nprri)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nphy')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nphy)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ncallrad')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ncallrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.nlend')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlend)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lnebect')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnebect)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lcvgqkf')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcvgqkf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lacdifus')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lacdifus)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.l2micro')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%l2micro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lajucv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lajucv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lsmoothmelt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsmoothmelt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.lgcheckmv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lgcheckmv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHY.ledr')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledr)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_023

  subroutine write_section_024(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => parar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TPARAR')
      call put_stream_tag(w, 2_int32, 'TPARAR.cmicro')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cmicro), int64))
      call put_stream_value(w, v%cmicro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.csedim')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csedim), int64))
      call put_stream_value(w, v%csedim)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nsplitr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsplitr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nsplitg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsplitg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nrr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nrrl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrrl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nrri')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrri)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nsv')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nswb_mnh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nswb_mnh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.ngpar')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngpar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.minprr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%minprr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.macprr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%macprr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.minprs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%minprs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.macprs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%macprs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.minprg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%minprg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.macprg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%macprg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.malbdir')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%malbdir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.malbsca')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%malbsca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mrain')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mrain)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.msnow')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%msnow)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mgz0')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mgz0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mgz0h')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mgz0h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mvqs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mvqs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mvts')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mvts)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mvemis')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mvemis)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mswdir')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mswdir)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mswdif')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mswdif)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mfrthds')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mfrthds)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mlsm')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mlsm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.mcd')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mcd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xsw_bands')
      if (allocated(v%xsw_bands)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%xsw_bands, kind=int64), ubound(v%xsw_bands, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.losubg_cond')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%losubg_cond)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.losedic')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%losedic)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lowarm')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lowarm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.losigmas')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%losigmas)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lolsmc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lolsmc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lotownc')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lotownc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.locnd2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%locnd2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lgrsn')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lgrsn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.radgr')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%radgr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.radsn')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%radsn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.vsigqsat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%vsigqsat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.cmf_updraft')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cmf_updraft), int64))
      call put_stream_value(w, v%cmf_updraft)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.cmf_cloud')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cmf_cloud), int64))
      call put_stream_value(w, v%cmf_cloud)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lmixuv')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lmixuv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.llcrit')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%llcrit)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.ltotprec')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ltotprec)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xalp_pert')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xalp_pert)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xabuo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xabuo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xbentr')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xbentr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xbdetr')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xbdetr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xcmf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xcmf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xentr_mf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xentr_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xcrad_mf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xcrad_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xentr_dry')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xentr_dry)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xdetr_dry')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xdetr_dry)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xdetr_lup')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xdetr_lup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xkcf_mf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xkcf_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xkrc_mf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xkrc_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xtausigmf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xtausigmf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xpres_uv')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xpres_uv)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xfrac_up_max')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xfrac_up_max)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xalpha_mf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xalpha_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xsigma_mf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xsigma_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xa1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xa1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xb')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xbeta1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xbeta1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xr')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xlambda')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xlambda)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lthetas')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lthetas)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lsquall')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsquall)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nrefroi1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrefroi1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nrefroi2')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nrefroi2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.vsquall')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%vsquall)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nptp')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nptp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nprintfr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nprintfr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.ldiagwmax')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ldiagwmax)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.ndiagwmax')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndiagwmax)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.ndtchem')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndtchem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.larobu_enable')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%larobu_enable)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xlini')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xlini)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lharatu')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lharatu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.csubg_aucv_rc')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csubg_aucv_rc), int64))
      call put_stream_value(w, v%csubg_aucv_rc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.csubg_rc_rr_accr')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csubg_rc_rr_accr), int64))
      call put_stream_value(w, v%csubg_rc_rr_accr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.csubg_rr_evap')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csubg_rr_evap), int64))
      call put_stream_value(w, v%csubg_rr_evap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.csubg_pr_pdf')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csubg_pr_pdf), int64))
      call put_stream_value(w, v%csubg_pr_pdf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.rcriauti')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcriauti)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.rcriautc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcriautc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.rt0criauti')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rt0criauti)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lcriauti')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcriauti)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xtstep_ts')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xtstep_ts)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xmrstep')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xmrstep)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.nmaxiter_micro')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nmaxiter_micro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.csnowriming')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%csnowriming), int64))
      call put_stream_value(w, v%csnowriming)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xfracm90')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xfracm90)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lnullwetg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnullwetg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lwetgpost')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lwetgpost)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lnullweth')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lnullweth)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lwethpost')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lwethpost)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lfeedbackt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfeedbackt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.levlimit')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levlimit)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lconvhg')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lconvhg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lcrflimit')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lcrflimit)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.cfrac_ice_adjust')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cfrac_ice_adjust), int64))
      call put_stream_value(w, v%cfrac_ice_adjust)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.cfrac_ice_shallow_mf')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cfrac_ice_shallow_mf), int64))
      call put_stream_value(w, v%cfrac_ice_shallow_mf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lsedim_after')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lsedim_after)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xsplit_maxcfl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xsplit_maxcfl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lfprec3d')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lfprec3d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.xcqvr')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%xcqvr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.gqvplim')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%gqvplim)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.gqvtop')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%gqvtop)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPARAR.lqvtop')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lqvtop)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_024

  subroutine write_section_025(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => linear_physics)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TEPHLI')
      call put_stream_tag(w, 2_int32, 'TEPHLI.ltlevol')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ltlevol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.lphylin')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lphylin)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.lphysfclin')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lphysfclin)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.lenopert')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lenopert)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.leppcfls')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leppcfls)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.lraisanen')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lraisanen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.lopptwins')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lopptwins)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlptrc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlptrc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpal1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpal1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpal2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpal2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpbb')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpbb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpcc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpcc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpdd')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpdd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpmixl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpmixl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpbeta')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpbeta)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpdrag')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpdrag)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpevap')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpevap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TEPHLI.rlpp00')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rlpp00)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_025

  subroutine write_section_026(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => nonlinear_physics)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'TPHNC')
      call put_stream_tag(w, 2_int32, 'TPHNC.letrajp')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%letrajp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.letrajpt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%letrajpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.leradi2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradi2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lerads2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lerads2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.leradsw2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradsw2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.leradn2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.leradfl2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradfl2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.leradlw2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leradlw2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lh2oco2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lh2oco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lwlopt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lwlopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lwsopt')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lwsopt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.ledcld2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ledcld2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lepcld2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lepcld2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lencld2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lencld2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.levapls2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levapls2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.levdif2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%levdif2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.legwdg2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%legwdg2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lecumf2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecumf2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lecond2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lecond2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.legwwms2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%legwwms2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.leqngt2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%leqngt2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lesurf2')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lesurf2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lekpert')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lekpert)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.lekperts')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lekperts)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'TPHNC.ltraclnph')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ltraclnph)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_026

  subroutine write_section_027(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%ri)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'RI')
      call put_stream_tag(w, 2_int32, 'RI.cver')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cver), int64))
      call put_stream_value(w, v%cver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslgroup')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslgroup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslsta')
      if (allocated(v%nslsta)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsta, kind=int64), ubound(v%nslsta, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslonl')
      if (allocated(v%nslonl)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslonl, kind=int64), ubound(v%nslonl, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nsloff')
      if (allocated(v%nsloff)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nsloff, kind=int64), ubound(v%nsloff, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslptswest')
      if (allocated(v%nslptswest)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptswest, kind=int64), ubound(v%nslptswest, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslptseast')
      if (allocated(v%nslptseast)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptseast, kind=int64), ubound(v%nslptseast, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslext')
      if (allocated(v%nslext)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslext, kind=int64), ubound(v%nslext, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.lcomplat')
      if (allocated(v%lcomplat)) then
     call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lcomplat, kind=int64), ubound(v%lcomplat, kind=int64))
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nlatglo')
      if (allocated(v%nlatglo)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nlatglo, kind=int64), ubound(v%nlatglo, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.dist1gp')
      if (allocated(v%dist1gp)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%dist1gp, kind=int64), ubound(v%dist1gp, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslsendpos')
      if (allocated(v%nslsendpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendpos, kind=int64), ubound(v%nslsendpos, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslrecvpos')
      if (allocated(v%nslrecvpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvpos, kind=int64), ubound(v%nslrecvpos, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslsendptr')
      if (allocated(v%nslsendptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendptr, kind=int64), ubound(v%nslsendptr, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslrecvptr')
      if (allocated(v%nslrecvptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvptr, kind=int64), ubound(v%nslrecvptr, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslcomm')
      if (allocated(v%nslcomm)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcomm, kind=int64), ubound(v%nslcomm, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.lslcomm')
      if (allocated(v%lslcomm)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 1_int32, lbound(v%lslcomm, kind=int64), ubound(v%lslcomm, kind=int64))
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.naslb1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.naslb1_true')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1_true)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslpad')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslpad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.lslt_arrays_init')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslt_arrays_init)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.lslondem')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.lslondem_active')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem_active)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nunusedhalo')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.distunusedhalo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%distunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.mask_sl1')
      if (allocated(v%mask_sl1)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl1, kind=int64), ubound(v%mask_sl1, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.mask_sl2')
      if (allocated(v%mask_sl2)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl2, kind=int64), ubound(v%mask_sl2, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.mask_sl2t')
      if (allocated(v%mask_sl2t)) then
   call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%mask_sl2t, kind=int64), ubound(v%mask_sl2t, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.mask_sld')
      if (allocated(v%mask_sld)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sld, kind=int64), ubound(v%mask_sld, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslprocs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslprocs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslrpt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslrpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslspt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslspt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslwiden')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwiden)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslwides')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwides)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslwidee')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidee)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslwidew')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidew)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslwide')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwide)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslmap')
      if (allocated(v%nslmap)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslmap, kind=int64), ubound(v%nslmap, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nslcore')
      if (allocated(v%nslcore)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcore, kind=int64), ubound(v%nslcore, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.lslcore')
      if (allocated(v%lslcore)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lslcore, kind=int64), ubound(v%lslcore, kind=int64))
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.mask_sltot')
      if (allocated(v%mask_sltot)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sltot, kind=int64), ubound(v%mask_sltot, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndglg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndglg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndlon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgsag')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsag)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgeng')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgeng)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgsal')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgenl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgsah')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsah)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgenh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndguxl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndlung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndluxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndluxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndguxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndsur1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndsur1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndlsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.ndgsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nptrfloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nptrfloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nfrstloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfrstloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.myfrstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%myfrstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.mylstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mylstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RI.nloeng')
      if (allocated(v%nloeng)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nloeng, kind=int64), ubound(v%nloeng, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_027

  subroutine write_section_028(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%ro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'RO')
      call put_stream_tag(w, 2_int32, 'RO.cver')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cver), int64))
      call put_stream_value(w, v%cver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslgroup')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslgroup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslsta')
      if (allocated(v%nslsta)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsta, kind=int64), ubound(v%nslsta, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslonl')
      if (allocated(v%nslonl)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslonl, kind=int64), ubound(v%nslonl, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nsloff')
      if (allocated(v%nsloff)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nsloff, kind=int64), ubound(v%nsloff, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslptswest')
      if (allocated(v%nslptswest)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptswest, kind=int64), ubound(v%nslptswest, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslptseast')
      if (allocated(v%nslptseast)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptseast, kind=int64), ubound(v%nslptseast, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslext')
      if (allocated(v%nslext)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslext, kind=int64), ubound(v%nslext, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.lcomplat')
      if (allocated(v%lcomplat)) then
     call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lcomplat, kind=int64), ubound(v%lcomplat, kind=int64))
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nlatglo')
      if (allocated(v%nlatglo)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nlatglo, kind=int64), ubound(v%nlatglo, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.dist1gp')
      if (allocated(v%dist1gp)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%dist1gp, kind=int64), ubound(v%dist1gp, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslsendpos')
      if (allocated(v%nslsendpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendpos, kind=int64), ubound(v%nslsendpos, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslrecvpos')
      if (allocated(v%nslrecvpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvpos, kind=int64), ubound(v%nslrecvpos, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslsendptr')
      if (allocated(v%nslsendptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendptr, kind=int64), ubound(v%nslsendptr, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslrecvptr')
      if (allocated(v%nslrecvptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvptr, kind=int64), ubound(v%nslrecvptr, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslcomm')
      if (allocated(v%nslcomm)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcomm, kind=int64), ubound(v%nslcomm, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.lslcomm')
      if (allocated(v%lslcomm)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 1_int32, lbound(v%lslcomm, kind=int64), ubound(v%lslcomm, kind=int64))
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.naslb1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.naslb1_true')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1_true)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslpad')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslpad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.lslt_arrays_init')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslt_arrays_init)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.lslondem')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.lslondem_active')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem_active)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nunusedhalo')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.distunusedhalo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%distunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.mask_sl1')
      if (allocated(v%mask_sl1)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl1, kind=int64), ubound(v%mask_sl1, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.mask_sl2')
      if (allocated(v%mask_sl2)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl2, kind=int64), ubound(v%mask_sl2, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.mask_sl2t')
      if (allocated(v%mask_sl2t)) then
   call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%mask_sl2t, kind=int64), ubound(v%mask_sl2t, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.mask_sld')
      if (allocated(v%mask_sld)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sld, kind=int64), ubound(v%mask_sld, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslprocs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslprocs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslrpt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslrpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslspt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslspt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslwiden')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwiden)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslwides')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwides)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslwidee')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidee)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslwidew')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidew)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslwide')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwide)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslmap')
      if (allocated(v%nslmap)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslmap, kind=int64), ubound(v%nslmap, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nslcore')
      if (allocated(v%nslcore)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcore, kind=int64), ubound(v%nslcore, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.lslcore')
      if (allocated(v%lslcore)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lslcore, kind=int64), ubound(v%lslcore, kind=int64))
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.mask_sltot')
      if (allocated(v%mask_sltot)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sltot, kind=int64), ubound(v%mask_sltot, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndglg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndglg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndlon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgsag')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsag)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgeng')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgeng)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgsal')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgenl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgsah')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsah)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgenh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndguxl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndlung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndluxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndluxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndguxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndsur1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndsur1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndlsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.ndgsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nptrfloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nptrfloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nfrstloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfrstloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.myfrstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%myfrstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.mylstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mylstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RO.nloeng')
      if (allocated(v%nloeng)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nloeng, kind=int64), ubound(v%nloeng, kind=int64))
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_028

  subroutine write_section_029(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%grid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'RADGRID')
      call put_stream_tag(w, 2_int32, 'RADGRID.ndglg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndglg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndlon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.nsmax')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsmax)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.nfrstloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfrstloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndgsl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndgsah')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsah)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndgenh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndgsal')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndgenl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndlonh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlonh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ndlonm')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlonm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.myfrstlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%myfrstlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.mylstlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mylstlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.rmu')
      if (allocated(v%rmu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rmu, kind=int64), ubound(v%rmu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.rsqm2')
      if (allocated(v%rsqm2)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsqm2, kind=int64), ubound(v%rsqm2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.rlatig')
      if (allocated(v%rlatig)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlatig, kind=int64), ubound(v%rlatig, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.rlati')
      if (allocated(v%rlati)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlati, kind=int64), ubound(v%rlati, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.ripi')
      if (allocated(v%ripi)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%ripi, kind=int64), ubound(v%ripi, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.gelam')
      if (allocated(v%gelam)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%gelam, kind=int64), ubound(v%gelam, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.gelat')
      if (allocated(v%gelat)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%gelat, kind=int64), ubound(v%gelat, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.geslo')
      if (allocated(v%geslo)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%geslo, kind=int64), ubound(v%geslo, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.geclo')
      if (allocated(v%geclo)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%geclo, kind=int64), ubound(v%geclo, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'RADGRID.gemu')
      if (allocated(v%gemu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%gemu, kind=int64), ubound(v%gemu, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_029

  subroutine write_section_030(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%solar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'solar')
      call put_stream_tag(w, 2_int32, 'solar.ryear')
      if (allocated(v%ryear)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryear, kind=int64), ubound(v%ryear, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'solar.rtsi')
      if (allocated(v%rtsi)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rtsi, kind=int64), ubound(v%rtsi, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'solar.ntime')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntime)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_030

  subroutine write_section_031(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'series')
      call put_stream_tag(w, 2_int32, 'series.ryear')
      if (allocated(v%ryear)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryear, kind=int64), ubound(v%ryear, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_co2')
      if (allocated(v%vmr_co2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_co2, kind=int64), ubound(v%vmr_co2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_ch4')
      if (allocated(v%vmr_ch4)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_ch4, kind=int64), ubound(v%vmr_ch4, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_n2o')
      if (allocated(v%vmr_n2o)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_n2o, kind=int64), ubound(v%vmr_n2o, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_cfc11')
      if (allocated(v%vmr_cfc11)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_cfc11, kind=int64), ubound(v%vmr_cfc11, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_cfc12')
      if (allocated(v%vmr_cfc12)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_cfc12, kind=int64), ubound(v%vmr_cfc12, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_hcfc22')
      if (allocated(v%vmr_hcfc22)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_hcfc22, kind=int64), ubound(v%vmr_hcfc22, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.vmr_ccl4')
      if (allocated(v%vmr_ccl4)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_ccl4, kind=int64), ubound(v%vmr_ccl4, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'series.ntime')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntime)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_031

  subroutine write_section_032(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'climate')
      call put_stream_tag(w, 2_int32, 'climate.pressure')
      if (allocated(v%pressure)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%pressure, kind=int64), ubound(v%pressure, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.latitude')
      if (allocated(v%latitude)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%latitude, kind=int64), ubound(v%latitude, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_co2')
      if (allocated(v%vmr_co2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_co2, kind=int64), ubound(v%vmr_co2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_ch4')
      if (allocated(v%vmr_ch4)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_ch4, kind=int64), ubound(v%vmr_ch4, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_n2o')
      if (allocated(v%vmr_n2o)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_n2o, kind=int64), ubound(v%vmr_n2o, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_no2')
      if (allocated(v%vmr_no2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_no2, kind=int64), ubound(v%vmr_no2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_cfc11')
      if (allocated(v%vmr_cfc11)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_cfc11, kind=int64), ubound(v%vmr_cfc11, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_cfc12')
      if (allocated(v%vmr_cfc12)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_cfc12, kind=int64), ubound(v%vmr_cfc12, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_o3')
      if (allocated(v%vmr_o3)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_o3, kind=int64), ubound(v%vmr_o3, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_hcfc22')
      if (allocated(v%vmr_hcfc22)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_hcfc22, kind=int64), ubound(v%vmr_hcfc22, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.vmr_ccl4')
      if (allocated(v%vmr_ccl4)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_ccl4, kind=int64), ubound(v%vmr_ccl4, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_co2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_co2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_ch4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_ch4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_n2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_n2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_no2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_no2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_cfc11')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_cfc11)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_cfc12')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_cfc12)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_hcfc22')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_hcfc22)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.surf_mean_ccl4')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%surf_mean_ccl4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.npressure')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npressure)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'climate.nlatitude')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlatitude)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_032

  subroutine write_section_033(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'workspace')
      call put_stream_tag(w, 2_int32, 'workspace.sinlat')
      if (allocated(v%sinlat)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%sinlat, kind=int64), ubound(v%sinlat, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.pressure_hl')
      if (allocated(v%pressure_hl)) then
       call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%pressure_hl,kind=int64),ubound(v%pressure_hl,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_ch4')
      if (allocated(v%mass_ch4)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_ch4, kind=int64), ubound(v%mass_ch4, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_co2')
      if (allocated(v%mass_co2)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_co2, kind=int64), ubound(v%mass_co2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_n2o')
      if (allocated(v%mass_n2o)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_n2o, kind=int64), ubound(v%mass_n2o, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_no2')
      if (allocated(v%mass_no2)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_no2, kind=int64), ubound(v%mass_no2, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_cfc11')
      if (allocated(v%mass_cfc11)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_cfc11, kind=int64), ubound(v%mass_cfc11, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_cfc12')
      if (allocated(v%mass_cfc12)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_cfc12, kind=int64), ubound(v%mass_cfc12, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_ccl4')
      if (allocated(v%mass_ccl4)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_ccl4, kind=int64), ubound(v%mass_ccl4, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_hcfc22')
      if (allocated(v%mass_hcfc22)) then
       call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%mass_hcfc22,kind=int64),ubound(v%mass_hcfc22,kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.mass_o3')
      if (allocated(v%mass_o3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_o3, kind=int64), ubound(v%mass_o3, kind=int64))
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.nlatitude')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nlatitude)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'workspace.npressure')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%npressure)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_033

  subroutine write_section_034(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.YSPECTPLANCK.PLANCK_LUT')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.YSPECTPLANCK.PLANCK_LUT')
      if (allocated(v%yspectplanck%planck_lut)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%yspectplanck%planck_lut,kind=int64),ubound(v%yspectplanck%planck_lut,kind=int64))
        call put_stream_value(w, v%yspectplanck%planck_lut)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_034

  subroutine write_section_035(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.YSPECTPLANCK.WAVLEN_BOUND')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.YSPECTPLANCK.WAVLEN_BOUND')
      if (allocated(v%yspectplanck%wavlen_bound)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%yspectplanck%wavlen_bound,kind=int64),ubound(v%yspectplanck%wavlen_bound,kind=int64))
        call put_stream_value(w, v%yspectplanck%wavlen_bound)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_035

  subroutine write_section_036(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.YSPECTPLANCK.INTERVAL_MAP')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.YSPECTPLANCK.INTERVAL_MAP')
      if (allocated(v%yspectplanck%interval_map)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%yspectplanck%interval_map,kind=int64),ubound(v%yspectplanck%interval_map,kind=int64))
        call put_stream_value(w, v%yspectplanck%interval_map)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_036

  subroutine write_section_037(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TESWRT.RSUN')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TESWRT.RSUN')
      if (allocated(v%rsun)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsun, kind=int64), ubound(v%rsun, kind=int64))
        call put_stream_value(w, v%rsun)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_037

  subroutine write_section_038(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TESWRT.RSUN2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TESWRT.RSUN2')
      if (allocated(v%rsun2)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsun2, kind=int64), ubound(v%rsun2, kind=int64))
        call put_stream_value(w, v%rsun2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_038

  subroutine write_section_039(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_distribution)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEAERD.CVDAES')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEAERD.CVDAES')
      if (allocated(v%cvdaes)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaes, kind=int64), ubound(v%cvdaes, kind=int64))
        call put_stream_value(w, v%cvdaes)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_039

  subroutine write_section_040(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_distribution)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEAERD.CVDAEL')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEAERD.CVDAEL')
      if (allocated(v%cvdael)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdael, kind=int64), ubound(v%cvdael, kind=int64))
        call put_stream_value(w, v%cvdael)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_040

  subroutine write_section_041(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_distribution)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEAERD.CVDAEU')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEAERD.CVDAEU')
      if (allocated(v%cvdaeu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaeu, kind=int64), ubound(v%cvdaeu, kind=int64))
        call put_stream_value(w, v%cvdaeu)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_041

  subroutine write_section_042(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_distribution)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEAERD.CVDAED')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEAERD.CVDAED')
      if (allocated(v%cvdaed)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaed, kind=int64), ubound(v%cvdaed, kind=int64))
        call put_stream_value(w, v%cvdaed)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_042

  subroutine write_section_043(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.CVDAESS')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.CVDAESS')
      if (allocated(v%cvdaess)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaess, kind=int64), ubound(v%cvdaess, kind=int64))
        call put_stream_value(w, v%cvdaess)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_043

  subroutine write_section_044(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.CVDAEDU')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.CVDAEDU')
      if (allocated(v%cvdaedu)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaedu, kind=int64), ubound(v%cvdaedu, kind=int64))
        call put_stream_value(w, v%cvdaedu)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_044

  subroutine write_section_045(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.CVDAEOM')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.CVDAEOM')
      if (allocated(v%cvdaeom)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaeom, kind=int64), ubound(v%cvdaeom, kind=int64))
        call put_stream_value(w, v%cvdaeom)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_045

  subroutine write_section_046(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.CVDAEBC')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.CVDAEBC')
      if (allocated(v%cvdaebc)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaebc, kind=int64), ubound(v%cvdaebc, kind=int64))
        call put_stream_value(w, v%cvdaebc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_046

  subroutine write_section_047(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TERAD.CVDAESU')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TERAD.CVDAESU')
      if (allocated(v%cvdaesu)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%cvdaesu, kind=int64), ubound(v%cvdaesu, kind=int64))
        call put_stream_value(w, v%cvdaesu)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_047

  subroutine write_section_048(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_atmosphere)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEAERATM.YAERO_DESC')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC')
      if (associated(v%yaero_desc)) then
 call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 1_int32, lbound(v%yaero_desc, kind=int64), ubound(v%yaero_desc, kind=int64))
        do j0_1 = lbound(v%yaero_desc, 1), ubound(v%yaero_desc, 1)
          call put_stream_value(w, int(j0_1, int64))
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].cname')
          call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, int(len(v%yaero_desc(j0_1)%cname), int64))
          call put_stream_value(w, v%yaero_desc(j0_1)%cname)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].igrbcode')
          call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%igrbcode)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].ntyp')
          call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%ntyp)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].nbin')
          call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%nbin)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].igribdiag')
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%yaero_desc(j0_1)%igribdiag,kind=int64),ubound(v%yaero_desc(j0_1)%igribdiag,kind=int64))
          call put_stream_value(w, v%yaero_desc(j0_1)%igribdiag)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].rddepvsea')
          call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%rddepvsea)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].rddepvlic')
          call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%rddepvlic)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].rsedimv')
          call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%rsedimv)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].rscavin')
          call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%rscavin)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].rscavbcr')
          call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%rscavbcr)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].rscavbcs')
          call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%rscavbcs)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].coptclass')
          call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, int(len(v%yaero_desc(j0_1)%coptclass), int64))
          call put_stream_value(w, v%yaero_desc(j0_1)%coptclass)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].chygclass')
          call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, int(len(v%yaero_desc(j0_1)%chygclass), int64))
          call put_stream_value(w, v%yaero_desc(j0_1)%chygclass)
          if (w%status /= 0_int32) return
          call put_stream_tag(w, 2_int32, 'TEAERATM.YAERO_DESC[].iaerocv')
          call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
          call put_stream_value(w, v%yaero_desc(j0_1)%iaerocv)
          if (w%status /= 0_int32) return
        end do
      else
        call put_stream_metadata(w, 5_int32, 0_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_048

  subroutine write_section_049(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cloud_overlap)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEOVLP.RA1OVLP')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEOVLP.RA1OVLP')
      if (allocated(v%ra1ovlp)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ra1ovlp, kind=int64), ubound(v%ra1ovlp, kind=int64))
        call put_stream_value(w, v%ra1ovlp)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_049

  subroutine write_section_050(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.EMTD')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.EMTD')
      if (allocated(v%emtd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%emtd, kind=int64), ubound(v%emtd, kind=int64))
        call put_stream_value(w, v%emtd)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_050

  subroutine write_section_051(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.TRSW')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.TRSW')
      if (allocated(v%trsw)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%trsw, kind=int64), ubound(v%trsw, kind=int64))
        call put_stream_value(w, v%trsw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_051

  subroutine write_section_052(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.EMTC')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.EMTC')
      if (allocated(v%emtc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%emtc, kind=int64), ubound(v%emtc, kind=int64))
        call put_stream_value(w, v%emtc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_052

  subroutine write_section_053(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.TRSC')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.TRSC')
      if (allocated(v%trsc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%trsc, kind=int64), ubound(v%trsc, kind=int64))
        call put_stream_value(w, v%trsc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_053

  subroutine write_section_054(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.TAUAER')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.TAUAER')
      if (allocated(v%tauaer)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%tauaer, kind=int64), ubound(v%tauaer, kind=int64))
        call put_stream_value(w, v%tauaer)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_054

  subroutine write_section_055(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWD')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWD')
      if (allocated(v%srswd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswd, kind=int64), ubound(v%srswd, kind=int64))
        call put_stream_value(w, v%srswd)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_055

  subroutine write_section_056(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWDC')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWDC')
      if (allocated(v%srswdc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswdc, kind=int64), ubound(v%srswdc, kind=int64))
        call put_stream_value(w, v%srswdc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_056

  subroutine write_section_057(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRLWD')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRLWD')
      if (allocated(v%srlwd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%srlwd, kind=int64), ubound(v%srlwd, kind=int64))
        call put_stream_value(w, v%srlwd)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_057

  subroutine write_section_058(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRLWDC')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRLWDC')
      if (allocated(v%srlwdc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srlwdc, kind=int64), ubound(v%srlwdc, kind=int64))
        call put_stream_value(w, v%srlwdc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_058

  subroutine write_section_059(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWDCS')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWDCS')
      if (allocated(v%srswdcs)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswdcs, kind=int64), ubound(v%srswdcs, kind=int64))
        call put_stream_value(w, v%srswdcs)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_059

  subroutine write_section_060(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRLWDCS')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRLWDCS')
      if (allocated(v%srlwdcs)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srlwdcs, kind=int64), ubound(v%srlwdcs, kind=int64))
        call put_stream_value(w, v%srlwdcs)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_060

  subroutine write_section_061(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWDV')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWDV')
      if (allocated(v%srswdv)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswdv, kind=int64), ubound(v%srswdv, kind=int64))
        call put_stream_value(w, v%srswdv)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_061

  subroutine write_section_062(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWDUV')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWDUV')
      if (allocated(v%srswduv)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswduv, kind=int64), ubound(v%srswduv, kind=int64))
        call put_stream_value(w, v%srswduv)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_062

  subroutine write_section_063(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.EDRO')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.EDRO')
      if (allocated(v%edro)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%edro, kind=int64), ubound(v%edro, kind=int64))
        call put_stream_value(w, v%edro)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_063

  subroutine write_section_064(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWPAR')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWPAR')
      if (allocated(v%srswpar)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswpar, kind=int64), ubound(v%srswpar, kind=int64))
        call put_stream_value(w, v%srswpar)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_064

  subroutine write_section_065(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWUVB')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWUVB')
      if (allocated(v%srswuvb)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswuvb, kind=int64), ubound(v%srswuvb, kind=int64))
        call put_stream_value(w, v%srswuvb)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_065

  subroutine write_section_066(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWPARC')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWPARC')
      if (allocated(v%srswparc)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswparc, kind=int64), ubound(v%srswparc, kind=int64))
        call put_stream_value(w, v%srswparc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_066

  subroutine write_section_067(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRSWTINC')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRSWTINC')
      if (allocated(v%srswtinc)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srswtinc, kind=int64), ubound(v%srswtinc, kind=int64))
        call put_stream_value(w, v%srswtinc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_067

  subroutine write_section_068(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRFDIR')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRFDIR')
      if (allocated(v%srfdir)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srfdir, kind=int64), ubound(v%srfdir, kind=int64))
        call put_stream_value(w, v%srfdir)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_068

  subroutine write_section_069(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.SRCDIR')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.SRCDIR')
      if (allocated(v%srcdir)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%srcdir, kind=int64), ubound(v%srcdir, kind=int64))
        call put_stream_value(w, v%srcdir)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_069

  subroutine write_section_070(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%fluxes)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADF.DERIVATIVELW')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'TRADF.DERIVATIVELW')
      if (associated(v%derivativelw)) then
     call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%derivativelw,kind=int64),ubound(v%derivativelw,kind=int64))
        call put_stream_value(w, v%derivativelw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_070

  subroutine write_section_071(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.wavenumber1_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber1_sw')
      if (allocated(v%config%wavenumber1_sw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber1_sw,kind=int64),ubound(v%config%wavenumber1_sw,kind=int64))
        call put_stream_value(w, v%config%wavenumber1_sw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_071

  subroutine write_section_072(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.wavenumber2_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber2_sw')
      if (allocated(v%config%wavenumber2_sw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber2_sw,kind=int64),ubound(v%config%wavenumber2_sw,kind=int64))
        call put_stream_value(w, v%config%wavenumber2_sw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_072

  subroutine write_section_073(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.wavenumber1_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber1_lw')
      if (allocated(v%config%wavenumber1_lw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber1_lw,kind=int64),ubound(v%config%wavenumber1_lw,kind=int64))
        call put_stream_value(w, v%config%wavenumber1_lw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_073

  subroutine write_section_074(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.wavenumber2_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.wavenumber2_lw')
      if (allocated(v%config%wavenumber2_lw)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%wavenumber2_lw,kind=int64),ubound(v%config%wavenumber2_lw,kind=int64))
        call put_stream_value(w, v%config%wavenumber2_lw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_074

  subroutine write_section_075(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_albedo_from_band_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_albedo_from_band_sw')
      if (allocated(v%config%i_albedo_from_band_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_albedo_from_band_sw,kind=int64),ubound(v%config%i_albedo_from_band_sw,kind=int64))
        call put_stream_value(w, v%config%i_albedo_from_band_sw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_075

  subroutine write_section_076(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_emiss_from_band_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_emiss_from_band_lw')
      if (allocated(v%config%i_emiss_from_band_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_emiss_from_band_lw,kind=int64),ubound(v%config%i_emiss_from_band_lw,kind=int64))
        call put_stream_value(w, v%config%i_emiss_from_band_lw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_076

  subroutine write_section_077(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.sw_albedo_weights')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.sw_albedo_weights')
      if (allocated(v%config%sw_albedo_weights)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%sw_albedo_weights,kind=int64),ubound(v%config%sw_albedo_weights,kind=int64))
        call put_stream_value(w, v%config%sw_albedo_weights)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_077

  subroutine write_section_078(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.lw_emiss_weights')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.lw_emiss_weights')
      if (allocated(v%config%lw_emiss_weights)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%lw_emiss_weights,kind=int64),ubound(v%config%lw_emiss_weights,kind=int64))
        call put_stream_value(w, v%config%lw_emiss_weights)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_078

  subroutine write_section_079(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_band_from_g_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_g_lw')
      if (allocated(v%config%i_band_from_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_g_lw,kind=int64),ubound(v%config%i_band_from_g_lw,kind=int64))
        call put_stream_value(w, v%config%i_band_from_g_lw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_079

  subroutine write_section_080(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_band_from_g_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_g_sw')
      if (allocated(v%config%i_band_from_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_g_sw,kind=int64),ubound(v%config%i_band_from_g_sw,kind=int64))
        call put_stream_value(w, v%config%i_band_from_g_sw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_080

  subroutine write_section_081(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_g_from_reordered_g_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_g_from_reordered_g_lw')
      if (allocated(v%config%i_g_from_reordered_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_g_from_reordered_g_lw,kind=int64),ubound(v%config%i_g_from_reordered_g_lw,kind=int64))
        call put_stream_value(w, v%config%i_g_from_reordered_g_lw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_081

  subroutine write_section_082(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_g_from_reordered_g_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_g_from_reordered_g_sw')
      if (allocated(v%config%i_g_from_reordered_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_g_from_reordered_g_sw,kind=int64),ubound(v%config%i_g_from_reordered_g_sw,kind=int64))
        call put_stream_value(w, v%config%i_g_from_reordered_g_sw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_082

  subroutine write_section_083(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_band_from_reordered_g_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_reordered_g_lw')
      if (allocated(v%config%i_band_from_reordered_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_reordered_g_lw,kind=int64),ubound(v%config%i_band_from_reordered_g_lw,kind=int64))
        call put_stream_value(w, v%config%i_band_from_reordered_g_lw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_083

  subroutine write_section_084(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_band_from_reordered_g_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_band_from_reordered_g_sw')
      if (allocated(v%config%i_band_from_reordered_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_band_from_reordered_g_sw,kind=int64),ubound(v%config%i_band_from_reordered_g_sw,kind=int64))
        call put_stream_value(w, v%config%i_band_from_reordered_g_sw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_084

  subroutine write_section_085(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_spec_from_reordered_g_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_spec_from_reordered_g_lw')
      if (associated(v%config%i_spec_from_reordered_g_lw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_spec_from_reordered_g_lw,kind=int64),ubound(v%config%i_spec_from_reordered_g_lw,kind=int64))
        call put_stream_value(w, v%config%i_spec_from_reordered_g_lw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_085

  subroutine write_section_086(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.i_spec_from_reordered_g_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.i_spec_from_reordered_g_sw')
      if (associated(v%config%i_spec_from_reordered_g_sw)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%i_spec_from_reordered_g_sw,kind=int64),ubound(v%config%i_spec_from_reordered_g_sw,kind=int64))
        call put_stream_value(w, v%config%i_spec_from_reordered_g_sw)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_086

  subroutine write_section_087(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.cloud_optics.liq_coeff_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.liq_coeff_lw')
      if (allocated(v%config%cloud_optics%liq_coeff_lw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%liq_coeff_lw,kind=int64),ubound(v%config%cloud_optics%liq_coeff_lw,kind=int64))
        call put_stream_value(w, v%config%cloud_optics%liq_coeff_lw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_087

  subroutine write_section_088(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.cloud_optics.liq_coeff_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.liq_coeff_sw')
      if (allocated(v%config%cloud_optics%liq_coeff_sw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%liq_coeff_sw,kind=int64),ubound(v%config%cloud_optics%liq_coeff_sw,kind=int64))
        call put_stream_value(w, v%config%cloud_optics%liq_coeff_sw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_088

  subroutine write_section_089(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.cloud_optics.ice_coeff_lw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.ice_coeff_lw')
      if (allocated(v%config%cloud_optics%ice_coeff_lw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%ice_coeff_lw,kind=int64),ubound(v%config%cloud_optics%ice_coeff_lw,kind=int64))
        call put_stream_value(w, v%config%cloud_optics%ice_coeff_lw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_089

  subroutine write_section_090(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.cloud_optics.ice_coeff_sw')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.ice_coeff_sw')
      if (allocated(v%config%cloud_optics%ice_coeff_sw)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%cloud_optics%ice_coeff_sw,kind=int64),ubound(v%config%cloud_optics%ice_coeff_sw,kind=int64))
        call put_stream_value(w, v%config%cloud_optics%ice_coeff_sw)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_090

  subroutine write_section_091(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.cloud_optics.liq_coeff_gen')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.liq_coeff_gen')
      if (allocated(v%config%cloud_optics%liq_coeff_gen)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%cloud_optics%liq_coeff_gen,kind=int64),ubound(v%config%cloud_optics%liq_coeff_gen,kind=int64))
        call put_stream_value(w, v%config%cloud_optics%liq_coeff_gen)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_091

  subroutine write_section_092(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.cloud_optics.ice_coeff_gen')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.cloud_optics.ice_coeff_gen')
      if (allocated(v%config%cloud_optics%ice_coeff_gen)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%cloud_optics%ice_coeff_gen,kind=int64),ubound(v%config%cloud_optics%ice_coeff_gen,kind=int64))
        call put_stream_value(w, v%config%cloud_optics%ice_coeff_gen)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_092

  subroutine write_section_093(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.iclass')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.iclass')
      if (allocated(v%config%aerosol_optics%iclass)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%aerosol_optics%iclass,kind=int64),ubound(v%config%aerosol_optics%iclass,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%iclass)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_093

  subroutine write_section_094(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.itype')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.itype')
      if (allocated(v%config%aerosol_optics%itype)) then
call put_stream_metadata(w,1_int32,4_int32,1_int32,1_int32,lbound(v%config%aerosol_optics%itype,kind=int64),ubound(v%config%aerosol_optics%itype,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%itype)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_094

  subroutine write_section_095(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.mass_ext_sw_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_sw_phobic')
      if (allocated(v%config%aerosol_optics%mass_ext_sw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_sw_phobic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_sw_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%mass_ext_sw_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_095

  subroutine write_section_096(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.ssa_sw_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_sw_phobic')
      if (allocated(v%config%aerosol_optics%ssa_sw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%ssa_sw_phobic,kind=int64),ubound(v%config%aerosol_optics%ssa_sw_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%ssa_sw_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_096

  subroutine write_section_097(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.g_sw_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_sw_phobic')
      if (allocated(v%config%aerosol_optics%g_sw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%g_sw_phobic,kind=int64),ubound(v%config%aerosol_optics%g_sw_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%g_sw_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_097

  subroutine write_section_098(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.mass_ext_lw_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_lw_phobic')
      if (allocated(v%config%aerosol_optics%mass_ext_lw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_lw_phobic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_lw_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%mass_ext_lw_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_098

  subroutine write_section_099(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.ssa_lw_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_lw_phobic')
      if (allocated(v%config%aerosol_optics%ssa_lw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%ssa_lw_phobic,kind=int64),ubound(v%config%aerosol_optics%ssa_lw_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%ssa_lw_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_099

  subroutine write_section_100(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.g_lw_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_lw_phobic')
      if (allocated(v%config%aerosol_optics%g_lw_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%g_lw_phobic,kind=int64),ubound(v%config%aerosol_optics%g_lw_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%g_lw_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_100

  subroutine write_section_101(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.mass_ext_sw_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_sw_philic')
      if (allocated(v%config%aerosol_optics%mass_ext_sw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_sw_philic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_sw_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%mass_ext_sw_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_101

  subroutine write_section_102(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.ssa_sw_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_sw_philic')
      if (allocated(v%config%aerosol_optics%ssa_sw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%ssa_sw_philic,kind=int64),ubound(v%config%aerosol_optics%ssa_sw_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%ssa_sw_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_102

  subroutine write_section_103(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.g_sw_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_sw_philic')
      if (allocated(v%config%aerosol_optics%g_sw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%g_sw_philic,kind=int64),ubound(v%config%aerosol_optics%g_sw_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%g_sw_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_103

  subroutine write_section_104(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.mass_ext_lw_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_lw_philic')
      if (allocated(v%config%aerosol_optics%mass_ext_lw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_lw_philic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_lw_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%mass_ext_lw_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_104

  subroutine write_section_105(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.ssa_lw_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_lw_philic')
      if (allocated(v%config%aerosol_optics%ssa_lw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%ssa_lw_philic,kind=int64),ubound(v%config%aerosol_optics%ssa_lw_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%ssa_lw_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_105

  subroutine write_section_106(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.g_lw_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_lw_philic')
      if (allocated(v%config%aerosol_optics%g_lw_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%g_lw_philic,kind=int64),ubound(v%config%aerosol_optics%g_lw_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%g_lw_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_106

  subroutine write_section_107(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.mass_ext_mono_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_mono_phobic')
      if (allocated(v%config%aerosol_optics%mass_ext_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_mono_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%mass_ext_mono_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_107

  subroutine write_section_108(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.ssa_mono_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_mono_phobic')
      if (allocated(v%config%aerosol_optics%ssa_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%ssa_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%ssa_mono_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%ssa_mono_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_108

  subroutine write_section_109(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.g_mono_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_mono_phobic')
      if (allocated(v%config%aerosol_optics%g_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%g_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%g_mono_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%g_mono_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_109

  subroutine write_section_110(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.lidar_ratio_mono_phobic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.lidar_ratio_mono_phobic')
      if (allocated(v%config%aerosol_optics%lidar_ratio_mono_phobic)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%aerosol_optics%lidar_ratio_mono_phobic,kind=int64),ubound(v%config%aerosol_optics%lidar_ratio_mono_phobic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%lidar_ratio_mono_phobic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_110

  subroutine write_section_111(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.mass_ext_mono_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.mass_ext_mono_philic')
      if (allocated(v%config%aerosol_optics%mass_ext_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%mass_ext_mono_philic,kind=int64),ubound(v%config%aerosol_optics%mass_ext_mono_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%mass_ext_mono_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_111

  subroutine write_section_112(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.ssa_mono_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.ssa_mono_philic')
      if (allocated(v%config%aerosol_optics%ssa_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%ssa_mono_philic,kind=int64),ubound(v%config%aerosol_optics%ssa_mono_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%ssa_mono_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_112

  subroutine write_section_113(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.g_mono_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.g_mono_philic')
      if (allocated(v%config%aerosol_optics%g_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%g_mono_philic,kind=int64),ubound(v%config%aerosol_optics%g_mono_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%g_mono_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_113

  subroutine write_section_114(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.lidar_ratio_mono_philic')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.lidar_ratio_mono_philic')
      if (allocated(v%config%aerosol_optics%lidar_ratio_mono_philic)) then
call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%config%aerosol_optics%lidar_ratio_mono_philic,kind=int64),ubound(v%config%aerosol_optics%lidar_ratio_mono_philic,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%lidar_ratio_mono_philic)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_114

  subroutine write_section_115(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.aerosol_optics.rh_lower')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.aerosol_optics.rh_lower')
      if (allocated(v%config%aerosol_optics%rh_lower)) then
call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%config%aerosol_optics%rh_lower,kind=int64),ubound(v%config%aerosol_optics%rh_lower,kind=int64))
        call put_stream_value(w, v%config%aerosol_optics%rh_lower)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_115

  subroutine write_section_116(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ecrad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TRADIATION.config.pdf_sampler.val')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TRADIATION.config.pdf_sampler.val')
      if (allocated(v%config%pdf_sampler%val)) then
call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%config%pdf_sampler%val,kind=int64),ubound(v%config%pdf_sampler%val,kind=int64))
        call put_stream_value(w, v%config%pdf_sampler%val)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_116

  subroutine write_section_117(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%ozone)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEOZOC.ZOZCL')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEOZOC.ZOZCL')
      if (allocated(v%zozcl)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%zozcl, kind=int64), ubound(v%zozcl, kind=int64))
        call put_stream_value(w, v%zozcl)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_117

  subroutine write_section_118(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RAERBC')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RAERBC')
      if (associated(v%raerbc)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raerbc, kind=int64), ubound(v%raerbc, kind=int64))
        call put_stream_value(w, v%raerbc)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_118

  subroutine write_section_119(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RAEROR')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RAEROR')
      if (associated(v%raeror)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raeror, kind=int64), ubound(v%raeror, kind=int64))
        call put_stream_value(w, v%raeror)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_119

  subroutine write_section_120(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RAERSD')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RAERSD')
      if (associated(v%raersd)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raersd, kind=int64), ubound(v%raersd, kind=int64))
        call put_stream_value(w, v%raersd)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_120

  subroutine write_section_121(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RAERSS')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RAERSS')
      if (associated(v%raerss)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raerss, kind=int64), ubound(v%raerss, kind=int64))
        call put_stream_value(w, v%raerss)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_121

  subroutine write_section_122(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RAERSU')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RAERSU')
      if (associated(v%raersu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raersu, kind=int64), ubound(v%raersu, kind=int64))
        call put_stream_value(w, v%raersu)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_122

  subroutine write_section_123(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RAERV')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RAERV')
      if (associated(v%raerv)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%raerv, kind=int64), ubound(v%raerv, kind=int64))
        call put_stream_value(w, v%raerv)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_123

  subroutine write_section_124(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%tegen)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'TEGEN.RLATV')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'TEGEN.RLATV')
      if (associated(v%rlatv)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlatv, kind=int64), ubound(v%rlatv, kind=int64))
        call put_stream_value(w, v%rlatv)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_124

  subroutine write_section_125(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACBC1')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACBC1')
      if (allocated(v%rmacbc1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacbc1, kind=int64), ubound(v%rmacbc1, kind=int64))
        call put_stream_value(w, v%rmacbc1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_125

  subroutine write_section_126(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACBC2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACBC2')
      if (allocated(v%rmacbc2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacbc2, kind=int64), ubound(v%rmacbc2, kind=int64))
        call put_stream_value(w, v%rmacbc2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_126

  subroutine write_section_127(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACOR1')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACOR1')
      if (allocated(v%rmacor1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacor1, kind=int64), ubound(v%rmacor1, kind=int64))
        call put_stream_value(w, v%rmacor1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_127

  subroutine write_section_128(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACOR2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACOR2')
      if (allocated(v%rmacor2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacor2, kind=int64), ubound(v%rmacor2, kind=int64))
        call put_stream_value(w, v%rmacor2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_128

  subroutine write_section_129(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSD1')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSD1')
      if (allocated(v%rmacsd1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd1, kind=int64), ubound(v%rmacsd1, kind=int64))
        call put_stream_value(w, v%rmacsd1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_129

  subroutine write_section_130(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSD2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSD2')
      if (allocated(v%rmacsd2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd2, kind=int64), ubound(v%rmacsd2, kind=int64))
        call put_stream_value(w, v%rmacsd2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_130

  subroutine write_section_131(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSD3')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSD3')
      if (allocated(v%rmacsd3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsd3, kind=int64), ubound(v%rmacsd3, kind=int64))
        call put_stream_value(w, v%rmacsd3)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_131

  subroutine write_section_132(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSS1')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSS1')
      if (allocated(v%rmacss1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss1, kind=int64), ubound(v%rmacss1, kind=int64))
        call put_stream_value(w, v%rmacss1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_132

  subroutine write_section_133(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSS2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSS2')
      if (allocated(v%rmacss2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss2, kind=int64), ubound(v%rmacss2, kind=int64))
        call put_stream_value(w, v%rmacss2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_133

  subroutine write_section_134(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSS3')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSS3')
      if (allocated(v%rmacss3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacss3, kind=int64), ubound(v%rmacss3, kind=int64))
        call put_stream_value(w, v%rmacss3)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_134

  subroutine write_section_135(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMACSU1')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMACSU1')
      if (allocated(v%rmacsu1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rmacsu1, kind=int64), ubound(v%rmacsu1, kind=int64))
        call put_stream_value(w, v%rmacsu1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_135

  subroutine write_section_136(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAEBC1')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAEBC1')
      if (allocated(v%rmaebc1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaebc1, kind=int64), ubound(v%rmaebc1, kind=int64))
        call put_stream_value(w, v%rmaebc1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_136

  subroutine write_section_137(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAEBC2')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAEBC2')
      if (allocated(v%rmaebc2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaebc2, kind=int64), ubound(v%rmaebc2, kind=int64))
        call put_stream_value(w, v%rmaebc2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_137

  subroutine write_section_138(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAEOR1')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAEOR1')
      if (allocated(v%rmaeor1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaeor1, kind=int64), ubound(v%rmaeor1, kind=int64))
        call put_stream_value(w, v%rmaeor1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_138

  subroutine write_section_139(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAEOR2')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAEOR2')
      if (allocated(v%rmaeor2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaeor2, kind=int64), ubound(v%rmaeor2, kind=int64))
        call put_stream_value(w, v%rmaeor2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_139

  subroutine write_section_140(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESD1')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESD1')
      if (allocated(v%rmaesd1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd1, kind=int64), ubound(v%rmaesd1, kind=int64))
        call put_stream_value(w, v%rmaesd1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_140

  subroutine write_section_141(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESD2')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESD2')
      if (allocated(v%rmaesd2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd2, kind=int64), ubound(v%rmaesd2, kind=int64))
        call put_stream_value(w, v%rmaesd2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_141

  subroutine write_section_142(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESD3')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESD3')
      if (allocated(v%rmaesd3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesd3, kind=int64), ubound(v%rmaesd3, kind=int64))
        call put_stream_value(w, v%rmaesd3)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_142

  subroutine write_section_143(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESS1')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESS1')
      if (allocated(v%rmaess1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess1, kind=int64), ubound(v%rmaess1, kind=int64))
        call put_stream_value(w, v%rmaess1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_143

  subroutine write_section_144(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESS2')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESS2')
      if (allocated(v%rmaess2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess2, kind=int64), ubound(v%rmaess2, kind=int64))
        call put_stream_value(w, v%rmaess2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_144

  subroutine write_section_145(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESS3')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESS3')
      if (allocated(v%rmaess3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaess3, kind=int64), ubound(v%rmaess3, kind=int64))
        call put_stream_value(w, v%rmaess3)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_145

  subroutine write_section_146(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cams)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'CAMS.RMAESU1')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'CAMS.RMAESU1')
      if (allocated(v%rmaesu1)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rmaesu1, kind=int64), ubound(v%rmaesu1, kind=int64))
        call put_stream_value(w, v%rmaesu1)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_146

  subroutine write_section_147(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%solar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'solar.RYEAR')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'solar.RYEAR')
      if (allocated(v%ryear)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryear, kind=int64), ubound(v%ryear, kind=int64))
        call put_stream_value(w, v%ryear)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_147

  subroutine write_section_148(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%solar)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'solar.RTSI')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'solar.RTSI')
      if (allocated(v%rtsi)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rtsi, kind=int64), ubound(v%rtsi, kind=int64))
        call put_stream_value(w, v%rtsi)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_148

  subroutine write_section_149(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.RYEAR')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.RYEAR')
      if (allocated(v%ryear)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ryear, kind=int64), ubound(v%ryear, kind=int64))
        call put_stream_value(w, v%ryear)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_149

  subroutine write_section_150(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_CO2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_CO2')
      if (allocated(v%vmr_co2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_co2, kind=int64), ubound(v%vmr_co2, kind=int64))
        call put_stream_value(w, v%vmr_co2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_150

  subroutine write_section_151(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_CH4')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_CH4')
      if (allocated(v%vmr_ch4)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_ch4, kind=int64), ubound(v%vmr_ch4, kind=int64))
        call put_stream_value(w, v%vmr_ch4)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_151

  subroutine write_section_152(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_N2O')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_N2O')
      if (allocated(v%vmr_n2o)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_n2o, kind=int64), ubound(v%vmr_n2o, kind=int64))
        call put_stream_value(w, v%vmr_n2o)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_152

  subroutine write_section_153(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_CFC11')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_CFC11')
      if (allocated(v%vmr_cfc11)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_cfc11, kind=int64), ubound(v%vmr_cfc11, kind=int64))
        call put_stream_value(w, v%vmr_cfc11)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_153

  subroutine write_section_154(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_CFC12')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_CFC12')
      if (allocated(v%vmr_cfc12)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_cfc12, kind=int64), ubound(v%vmr_cfc12, kind=int64))
        call put_stream_value(w, v%vmr_cfc12)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_154

  subroutine write_section_155(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_HCFC22')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_HCFC22')
      if (allocated(v%vmr_hcfc22)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_hcfc22, kind=int64), ubound(v%vmr_hcfc22, kind=int64))
        call put_stream_value(w, v%vmr_hcfc22)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_155

  subroutine write_section_156(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%timeseries)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'series.VMR_CCL4')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'series.VMR_CCL4')
      if (allocated(v%vmr_ccl4)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%vmr_ccl4, kind=int64), ubound(v%vmr_ccl4, kind=int64))
        call put_stream_value(w, v%vmr_ccl4)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_156

  subroutine write_section_157(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.PRESSURE')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.PRESSURE')
      if (allocated(v%pressure)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%pressure, kind=int64), ubound(v%pressure, kind=int64))
        call put_stream_value(w, v%pressure)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_157

  subroutine write_section_158(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.LATITUDE')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.LATITUDE')
      if (allocated(v%latitude)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%latitude, kind=int64), ubound(v%latitude, kind=int64))
        call put_stream_value(w, v%latitude)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_158

  subroutine write_section_159(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_CO2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_CO2')
      if (allocated(v%vmr_co2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_co2, kind=int64), ubound(v%vmr_co2, kind=int64))
        call put_stream_value(w, v%vmr_co2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_159

  subroutine write_section_160(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_CH4')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_CH4')
      if (allocated(v%vmr_ch4)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_ch4, kind=int64), ubound(v%vmr_ch4, kind=int64))
        call put_stream_value(w, v%vmr_ch4)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_160

  subroutine write_section_161(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_N2O')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_N2O')
      if (allocated(v%vmr_n2o)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_n2o, kind=int64), ubound(v%vmr_n2o, kind=int64))
        call put_stream_value(w, v%vmr_n2o)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_161

  subroutine write_section_162(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_NO2')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_NO2')
      if (allocated(v%vmr_no2)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_no2, kind=int64), ubound(v%vmr_no2, kind=int64))
        call put_stream_value(w, v%vmr_no2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_162

  subroutine write_section_163(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_CFC11')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_CFC11')
      if (allocated(v%vmr_cfc11)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_cfc11, kind=int64), ubound(v%vmr_cfc11, kind=int64))
        call put_stream_value(w, v%vmr_cfc11)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_163

  subroutine write_section_164(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_CFC12')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_CFC12')
      if (allocated(v%vmr_cfc12)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_cfc12, kind=int64), ubound(v%vmr_cfc12, kind=int64))
        call put_stream_value(w, v%vmr_cfc12)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_164

  subroutine write_section_165(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_O3')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_O3')
      if (allocated(v%vmr_o3)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_o3, kind=int64), ubound(v%vmr_o3, kind=int64))
        call put_stream_value(w, v%vmr_o3)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_165

  subroutine write_section_166(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_HCFC22')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_HCFC22')
      if (allocated(v%vmr_hcfc22)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_hcfc22, kind=int64), ubound(v%vmr_hcfc22, kind=int64))
        call put_stream_value(w, v%vmr_hcfc22)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_166

  subroutine write_section_167(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%climatology)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'climate.VMR_CCL4')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'climate.VMR_CCL4')
      if (allocated(v%vmr_ccl4)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%vmr_ccl4, kind=int64), ubound(v%vmr_ccl4, kind=int64))
        call put_stream_value(w, v%vmr_ccl4)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_167

  subroutine write_section_168(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.SINLAT')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'workspace.SINLAT')
      if (allocated(v%sinlat)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%sinlat, kind=int64), ubound(v%sinlat, kind=int64))
        call put_stream_value(w, v%sinlat)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_168

  subroutine write_section_169(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.PRESSURE_HL')
      call put_stream_value(w, 1_int32)
      call put_stream_tag(w, 2_int32, 'workspace.PRESSURE_HL')
      if (allocated(v%pressure_hl)) then
       call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%pressure_hl,kind=int64),ubound(v%pressure_hl,kind=int64))
        call put_stream_value(w, v%pressure_hl)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_169

  subroutine write_section_170(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_CH4')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_CH4')
      if (allocated(v%mass_ch4)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_ch4, kind=int64), ubound(v%mass_ch4, kind=int64))
        call put_stream_value(w, v%mass_ch4)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_170

  subroutine write_section_171(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_CO2')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_CO2')
      if (allocated(v%mass_co2)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_co2, kind=int64), ubound(v%mass_co2, kind=int64))
        call put_stream_value(w, v%mass_co2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_171

  subroutine write_section_172(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_N2O')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_N2O')
      if (allocated(v%mass_n2o)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_n2o, kind=int64), ubound(v%mass_n2o, kind=int64))
        call put_stream_value(w, v%mass_n2o)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_172

  subroutine write_section_173(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_NO2')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_NO2')
      if (allocated(v%mass_no2)) then
     call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_no2, kind=int64), ubound(v%mass_no2, kind=int64))
        call put_stream_value(w, v%mass_no2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_173

  subroutine write_section_174(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_CFC11')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_CFC11')
      if (allocated(v%mass_cfc11)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_cfc11, kind=int64), ubound(v%mass_cfc11, kind=int64))
        call put_stream_value(w, v%mass_cfc11)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_174

  subroutine write_section_175(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_CFC12')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_CFC12')
      if (allocated(v%mass_cfc12)) then
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_cfc12, kind=int64), ubound(v%mass_cfc12, kind=int64))
        call put_stream_value(w, v%mass_cfc12)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_175

  subroutine write_section_176(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_CCL4')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_CCL4')
      if (allocated(v%mass_ccl4)) then
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_ccl4, kind=int64), ubound(v%mass_ccl4, kind=int64))
        call put_stream_value(w, v%mass_ccl4)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_176

  subroutine write_section_177(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_HCFC22')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_HCFC22')
      if (allocated(v%mass_hcfc22)) then
       call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%mass_hcfc22,kind=int64),ubound(v%mass_hcfc22,kind=int64))
        call put_stream_value(w, v%mass_hcfc22)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_177

  subroutine write_section_178(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%climate%radiation)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 3_int32, 'workspace.MASS_O3')
      call put_stream_value(w, 0_int32)
      call put_stream_tag(w, 2_int32, 'workspace.MASS_O3')
      if (allocated(v%mass_o3)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%mass_o3, kind=int64), ubound(v%mass_o3, kind=int64))
        call put_stream_value(w, v%mass_o3)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_178

  subroutine write_section_179(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%longwave_input)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b1_fracrefao,kind=int64),ubound(v%b1_fracrefao,kind=int64))
      call put_stream_value(w, v%b1_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b1_fracrefbo,kind=int64),ubound(v%b1_fracrefbo,kind=int64))
      call put_stream_value(w, v%b1_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b1_kao, kind=int64), ubound(v%b1_kao, kind=int64))
      call put_stream_value(w, v%b1_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b1_kbo, kind=int64), ubound(v%b1_kbo, kind=int64))
      call put_stream_value(w, v%b1_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b1_kao_d, kind=int64), ubound(v%b1_kao_d, kind=int64))
      call put_stream_value(w, v%b1_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b1_kbo_d, kind=int64), ubound(v%b1_kbo_d, kind=int64))
      call put_stream_value(w, v%b1_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_kao_mn2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_kao_mn2, kind=int64), ubound(v%b1_kao_mn2, kind=int64))
      call put_stream_value(w, v%b1_kao_mn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_kbo_mn2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_kbo_mn2, kind=int64), ubound(v%b1_kbo_mn2, kind=int64))
      call put_stream_value(w, v%b1_kbo_mn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b1_selfrefo,kind=int64),ubound(v%b1_selfrefo,kind=int64))
      call put_stream_value(w, v%b1_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b1_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_forrefo, kind=int64), ubound(v%b1_forrefo, kind=int64))
      call put_stream_value(w, v%b1_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b2_fracrefao,kind=int64),ubound(v%b2_fracrefao,kind=int64))
      call put_stream_value(w, v%b2_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b2_fracrefbo,kind=int64),ubound(v%b2_fracrefbo,kind=int64))
      call put_stream_value(w, v%b2_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b2_kao, kind=int64), ubound(v%b2_kao, kind=int64))
      call put_stream_value(w, v%b2_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b2_kbo, kind=int64), ubound(v%b2_kbo, kind=int64))
      call put_stream_value(w, v%b2_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b2_kao_d, kind=int64), ubound(v%b2_kao_d, kind=int64))
      call put_stream_value(w, v%b2_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b2_kbo_d, kind=int64), ubound(v%b2_kbo_d, kind=int64))
      call put_stream_value(w, v%b2_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b2_selfrefo,kind=int64),ubound(v%b2_selfrefo,kind=int64))
      call put_stream_value(w, v%b2_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b2_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b2_forrefo, kind=int64), ubound(v%b2_forrefo, kind=int64))
      call put_stream_value(w, v%b2_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b3_fracrefao,kind=int64),ubound(v%b3_fracrefao,kind=int64))
      call put_stream_value(w, v%b3_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b3_fracrefbo,kind=int64),ubound(v%b3_fracrefbo,kind=int64))
      call put_stream_value(w, v%b3_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_kao_mn2o')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b3_kao_mn2o,kind=int64),ubound(v%b3_kao_mn2o,kind=int64))
      call put_stream_value(w, v%b3_kao_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_kbo_mn2o')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b3_kbo_mn2o,kind=int64),ubound(v%b3_kbo_mn2o,kind=int64))
      call put_stream_value(w, v%b3_kbo_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b3_kao, kind=int64), ubound(v%b3_kao, kind=int64))
      call put_stream_value(w, v%b3_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b3_kbo, kind=int64), ubound(v%b3_kbo, kind=int64))
      call put_stream_value(w, v%b3_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b3_kao_d, kind=int64), ubound(v%b3_kao_d, kind=int64))
      call put_stream_value(w, v%b3_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b3_kbo_d, kind=int64), ubound(v%b3_kbo_d, kind=int64))
      call put_stream_value(w, v%b3_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b3_selfrefo,kind=int64),ubound(v%b3_selfrefo,kind=int64))
      call put_stream_value(w, v%b3_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b3_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b3_forrefo, kind=int64), ubound(v%b3_forrefo, kind=int64))
      call put_stream_value(w, v%b3_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b4_fracrefao,kind=int64),ubound(v%b4_fracrefao,kind=int64))
      call put_stream_value(w, v%b4_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b4_fracrefbo,kind=int64),ubound(v%b4_fracrefbo,kind=int64))
      call put_stream_value(w, v%b4_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b4_kao, kind=int64), ubound(v%b4_kao, kind=int64))
      call put_stream_value(w, v%b4_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b4_kbo, kind=int64), ubound(v%b4_kbo, kind=int64))
      call put_stream_value(w, v%b4_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b4_kao_d, kind=int64), ubound(v%b4_kao_d, kind=int64))
      call put_stream_value(w, v%b4_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b4_kbo_d, kind=int64), ubound(v%b4_kbo_d, kind=int64))
      call put_stream_value(w, v%b4_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b4_selfrefo,kind=int64),ubound(v%b4_selfrefo,kind=int64))
      call put_stream_value(w, v%b4_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b4_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b4_forrefo, kind=int64), ubound(v%b4_forrefo, kind=int64))
      call put_stream_value(w, v%b4_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b5_fracrefao,kind=int64),ubound(v%b5_fracrefao,kind=int64))
      call put_stream_value(w, v%b5_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b5_fracrefbo,kind=int64),ubound(v%b5_fracrefbo,kind=int64))
      call put_stream_value(w, v%b5_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_ccl4o')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b5_ccl4o, kind=int64), ubound(v%b5_ccl4o, kind=int64))
      call put_stream_value(w, v%b5_ccl4o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_kao_mo3')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b5_kao_mo3, kind=int64), ubound(v%b5_kao_mo3, kind=int64))
      call put_stream_value(w, v%b5_kao_mo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b5_kao, kind=int64), ubound(v%b5_kao, kind=int64))
      call put_stream_value(w, v%b5_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b5_kbo, kind=int64), ubound(v%b5_kbo, kind=int64))
      call put_stream_value(w, v%b5_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b5_kao_d, kind=int64), ubound(v%b5_kao_d, kind=int64))
      call put_stream_value(w, v%b5_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b5_kbo_d, kind=int64), ubound(v%b5_kbo_d, kind=int64))
      call put_stream_value(w, v%b5_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b5_selfrefo,kind=int64),ubound(v%b5_selfrefo,kind=int64))
      call put_stream_value(w, v%b5_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b5_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b5_forrefo, kind=int64), ubound(v%b5_forrefo, kind=int64))
      call put_stream_value(w, v%b5_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b6_fracrefao,kind=int64),ubound(v%b6_fracrefao,kind=int64))
      call put_stream_value(w, v%b6_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_cfc11adjo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b6_cfc11adjo,kind=int64),ubound(v%b6_cfc11adjo,kind=int64))
      call put_stream_value(w, v%b6_cfc11adjo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_cfc12o')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b6_cfc12o, kind=int64), ubound(v%b6_cfc12o, kind=int64))
      call put_stream_value(w, v%b6_cfc12o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b6_kao, kind=int64), ubound(v%b6_kao, kind=int64))
      call put_stream_value(w, v%b6_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b6_kao_d, kind=int64), ubound(v%b6_kao_d, kind=int64))
      call put_stream_value(w, v%b6_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b6_selfrefo,kind=int64),ubound(v%b6_selfrefo,kind=int64))
      call put_stream_value(w, v%b6_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_kao_mco2')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b6_kao_mco2,kind=int64),ubound(v%b6_kao_mco2,kind=int64))
      call put_stream_value(w, v%b6_kao_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b6_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b6_forrefo, kind=int64), ubound(v%b6_forrefo, kind=int64))
      call put_stream_value(w, v%b6_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b7_fracrefao,kind=int64),ubound(v%b7_fracrefao,kind=int64))
      call put_stream_value(w, v%b7_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b7_fracrefbo,kind=int64),ubound(v%b7_fracrefbo,kind=int64))
      call put_stream_value(w, v%b7_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b7_kao, kind=int64), ubound(v%b7_kao, kind=int64))
      call put_stream_value(w, v%b7_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b7_kbo, kind=int64), ubound(v%b7_kbo, kind=int64))
      call put_stream_value(w, v%b7_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b7_kao_d, kind=int64), ubound(v%b7_kao_d, kind=int64))
      call put_stream_value(w, v%b7_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b7_kbo_d, kind=int64), ubound(v%b7_kbo_d, kind=int64))
      call put_stream_value(w, v%b7_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b7_selfrefo,kind=int64),ubound(v%b7_selfrefo,kind=int64))
      call put_stream_value(w, v%b7_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_kao_mco2')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b7_kao_mco2,kind=int64),ubound(v%b7_kao_mco2,kind=int64))
      call put_stream_value(w, v%b7_kao_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_kbo_mco2')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b7_kbo_mco2,kind=int64),ubound(v%b7_kbo_mco2,kind=int64))
      call put_stream_value(w, v%b7_kbo_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b7_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b7_forrefo, kind=int64), ubound(v%b7_forrefo, kind=int64))
      call put_stream_value(w, v%b7_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b8_fracrefao,kind=int64),ubound(v%b8_fracrefao,kind=int64))
      call put_stream_value(w, v%b8_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b8_fracrefbo,kind=int64),ubound(v%b8_fracrefbo,kind=int64))
      call put_stream_value(w, v%b8_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_cfc12o')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b8_cfc12o, kind=int64), ubound(v%b8_cfc12o, kind=int64))
      call put_stream_value(w, v%b8_cfc12o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_cfc22adjo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b8_cfc22adjo,kind=int64),ubound(v%b8_cfc22adjo,kind=int64))
      call put_stream_value(w, v%b8_cfc22adjo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b8_kao, kind=int64), ubound(v%b8_kao, kind=int64))
      call put_stream_value(w, v%b8_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b8_kbo, kind=int64), ubound(v%b8_kbo, kind=int64))
      call put_stream_value(w, v%b8_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b8_kao_d, kind=int64), ubound(v%b8_kao_d, kind=int64))
      call put_stream_value(w, v%b8_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b8_kbo_d, kind=int64), ubound(v%b8_kbo_d, kind=int64))
      call put_stream_value(w, v%b8_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b8_selfrefo,kind=int64),ubound(v%b8_selfrefo,kind=int64))
      call put_stream_value(w, v%b8_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kao_mco2')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b8_kao_mco2,kind=int64),ubound(v%b8_kao_mco2,kind=int64))
      call put_stream_value(w, v%b8_kao_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kao_mn2o')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b8_kao_mn2o,kind=int64),ubound(v%b8_kao_mn2o,kind=int64))
      call put_stream_value(w, v%b8_kao_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kao_mo3')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_kao_mo3, kind=int64), ubound(v%b8_kao_mo3, kind=int64))
      call put_stream_value(w, v%b8_kao_mo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kbo_mco2')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b8_kbo_mco2,kind=int64),ubound(v%b8_kbo_mco2,kind=int64))
      call put_stream_value(w, v%b8_kbo_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_kbo_mn2o')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b8_kbo_mn2o,kind=int64),ubound(v%b8_kbo_mn2o,kind=int64))
      call put_stream_value(w, v%b8_kbo_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b8_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_forrefo, kind=int64), ubound(v%b8_forrefo, kind=int64))
      call put_stream_value(w, v%b8_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_fracrefao')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b9_fracrefao,kind=int64),ubound(v%b9_fracrefao,kind=int64))
      call put_stream_value(w, v%b9_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_fracrefbo')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b9_fracrefbo,kind=int64),ubound(v%b9_fracrefbo,kind=int64))
      call put_stream_value(w, v%b9_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b9_kao, kind=int64), ubound(v%b9_kao, kind=int64))
      call put_stream_value(w, v%b9_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b9_kbo, kind=int64), ubound(v%b9_kbo, kind=int64))
      call put_stream_value(w, v%b9_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_kao_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b9_kao_d, kind=int64), ubound(v%b9_kao_d, kind=int64))
      call put_stream_value(w, v%b9_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_kbo_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b9_kbo_d, kind=int64), ubound(v%b9_kbo_d, kind=int64))
      call put_stream_value(w, v%b9_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_kao_mn2o')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b9_kao_mn2o,kind=int64),ubound(v%b9_kao_mn2o,kind=int64))
      call put_stream_value(w, v%b9_kao_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_kbo_mn2o')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b9_kbo_mn2o,kind=int64),ubound(v%b9_kbo_mn2o,kind=int64))
      call put_stream_value(w, v%b9_kbo_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_selfrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b9_selfrefo,kind=int64),ubound(v%b9_selfrefo,kind=int64))
      call put_stream_value(w, v%b9_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b9_forrefo')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b9_forrefo, kind=int64), ubound(v%b9_forrefo, kind=int64))
      call put_stream_value(w, v%b9_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b10_fracrefao,kind=int64),ubound(v%b10_fracrefao,kind=int64))
      call put_stream_value(w, v%b10_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_fracrefbo')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b10_fracrefbo,kind=int64),ubound(v%b10_fracrefbo,kind=int64))
      call put_stream_value(w, v%b10_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b10_kao, kind=int64), ubound(v%b10_kao, kind=int64))
      call put_stream_value(w, v%b10_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b10_kbo, kind=int64), ubound(v%b10_kbo, kind=int64))
      call put_stream_value(w, v%b10_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b10_kao_d, kind=int64), ubound(v%b10_kao_d, kind=int64))
      call put_stream_value(w, v%b10_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_kbo_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b10_kbo_d, kind=int64), ubound(v%b10_kbo_d, kind=int64))
      call put_stream_value(w, v%b10_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b10_selfrefo,kind=int64),ubound(v%b10_selfrefo,kind=int64))
      call put_stream_value(w, v%b10_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b10_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b10_forrefo,kind=int64),ubound(v%b10_forrefo,kind=int64))
      call put_stream_value(w, v%b10_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b11_fracrefao,kind=int64),ubound(v%b11_fracrefao,kind=int64))
      call put_stream_value(w, v%b11_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_fracrefbo')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b11_fracrefbo,kind=int64),ubound(v%b11_fracrefbo,kind=int64))
      call put_stream_value(w, v%b11_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b11_kao, kind=int64), ubound(v%b11_kao, kind=int64))
      call put_stream_value(w, v%b11_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b11_kbo, kind=int64), ubound(v%b11_kbo, kind=int64))
      call put_stream_value(w, v%b11_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b11_kao_d, kind=int64), ubound(v%b11_kao_d, kind=int64))
      call put_stream_value(w, v%b11_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_kbo_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b11_kbo_d, kind=int64), ubound(v%b11_kbo_d, kind=int64))
      call put_stream_value(w, v%b11_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_kao_mo2')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b11_kao_mo2,kind=int64),ubound(v%b11_kao_mo2,kind=int64))
      call put_stream_value(w, v%b11_kao_mo2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_kbo_mo2')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b11_kbo_mo2,kind=int64),ubound(v%b11_kbo_mo2,kind=int64))
      call put_stream_value(w, v%b11_kbo_mo2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b11_selfrefo,kind=int64),ubound(v%b11_selfrefo,kind=int64))
      call put_stream_value(w, v%b11_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b11_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b11_forrefo,kind=int64),ubound(v%b11_forrefo,kind=int64))
      call put_stream_value(w, v%b11_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b12_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b12_fracrefao,kind=int64),ubound(v%b12_fracrefao,kind=int64))
      call put_stream_value(w, v%b12_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b12_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b12_kao, kind=int64), ubound(v%b12_kao, kind=int64))
      call put_stream_value(w, v%b12_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b12_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b12_kao_d, kind=int64), ubound(v%b12_kao_d, kind=int64))
      call put_stream_value(w, v%b12_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b12_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b12_selfrefo,kind=int64),ubound(v%b12_selfrefo,kind=int64))
      call put_stream_value(w, v%b12_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b12_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b12_forrefo,kind=int64),ubound(v%b12_forrefo,kind=int64))
      call put_stream_value(w, v%b12_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b13_fracrefao,kind=int64),ubound(v%b13_fracrefao,kind=int64))
      call put_stream_value(w, v%b13_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_fracrefbo')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b13_fracrefbo,kind=int64),ubound(v%b13_fracrefbo,kind=int64))
      call put_stream_value(w, v%b13_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b13_kao, kind=int64), ubound(v%b13_kao, kind=int64))
      call put_stream_value(w, v%b13_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b13_kao_d, kind=int64), ubound(v%b13_kao_d, kind=int64))
      call put_stream_value(w, v%b13_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b13_selfrefo,kind=int64),ubound(v%b13_selfrefo,kind=int64))
      call put_stream_value(w, v%b13_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_kao_mco2')
     call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b13_kao_mco2,kind=int64),ubound(v%b13_kao_mco2,kind=int64))
      call put_stream_value(w, v%b13_kao_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_kao_mco')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b13_kao_mco,kind=int64),ubound(v%b13_kao_mco,kind=int64))
      call put_stream_value(w, v%b13_kao_mco)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_kbo_mo3')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b13_kbo_mo3,kind=int64),ubound(v%b13_kbo_mo3,kind=int64))
      call put_stream_value(w, v%b13_kbo_mo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b13_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b13_forrefo,kind=int64),ubound(v%b13_forrefo,kind=int64))
      call put_stream_value(w, v%b13_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b14_fracrefao,kind=int64),ubound(v%b14_fracrefao,kind=int64))
      call put_stream_value(w, v%b14_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_fracrefbo')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b14_fracrefbo,kind=int64),ubound(v%b14_fracrefbo,kind=int64))
      call put_stream_value(w, v%b14_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b14_kao, kind=int64), ubound(v%b14_kao, kind=int64))
      call put_stream_value(w, v%b14_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b14_kbo, kind=int64), ubound(v%b14_kbo, kind=int64))
      call put_stream_value(w, v%b14_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b14_kao_d, kind=int64), ubound(v%b14_kao_d, kind=int64))
      call put_stream_value(w, v%b14_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_kbo_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b14_kbo_d, kind=int64), ubound(v%b14_kbo_d, kind=int64))
      call put_stream_value(w, v%b14_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b14_selfrefo,kind=int64),ubound(v%b14_selfrefo,kind=int64))
      call put_stream_value(w, v%b14_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b14_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b14_forrefo,kind=int64),ubound(v%b14_forrefo,kind=int64))
      call put_stream_value(w, v%b14_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b15_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b15_fracrefao,kind=int64),ubound(v%b15_fracrefao,kind=int64))
      call put_stream_value(w, v%b15_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b15_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b15_kao, kind=int64), ubound(v%b15_kao, kind=int64))
      call put_stream_value(w, v%b15_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b15_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b15_kao_d, kind=int64), ubound(v%b15_kao_d, kind=int64))
      call put_stream_value(w, v%b15_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b15_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b15_selfrefo,kind=int64),ubound(v%b15_selfrefo,kind=int64))
      call put_stream_value(w, v%b15_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b15_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b15_forrefo,kind=int64),ubound(v%b15_forrefo,kind=int64))
      call put_stream_value(w, v%b15_forrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b15_kao_mn2')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b15_kao_mn2,kind=int64),ubound(v%b15_kao_mn2,kind=int64))
      call put_stream_value(w, v%b15_kao_mn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_fracrefao')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_fracrefao,kind=int64),ubound(v%b16_fracrefao,kind=int64))
      call put_stream_value(w, v%b16_fracrefao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_fracrefbo')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b16_fracrefbo,kind=int64),ubound(v%b16_fracrefbo,kind=int64))
      call put_stream_value(w, v%b16_fracrefbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_kao')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b16_kao, kind=int64), ubound(v%b16_kao, kind=int64))
      call put_stream_value(w, v%b16_kao)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_kbo')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b16_kbo, kind=int64), ubound(v%b16_kbo, kind=int64))
      call put_stream_value(w, v%b16_kbo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_kao_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b16_kao_d, kind=int64), ubound(v%b16_kao_d, kind=int64))
      call put_stream_value(w, v%b16_kao_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_kbo_d')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b16_kbo_d, kind=int64), ubound(v%b16_kbo_d, kind=int64))
      call put_stream_value(w, v%b16_kbo_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_selfrefo')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_selfrefo,kind=int64),ubound(v%b16_selfrefo,kind=int64))
      call put_stream_value(w, v%b16_selfrefo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_original_coefficients.longwave_input.b16_forrefo')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_forrefo,kind=int64),ubound(v%b16_forrefo,kind=int64))
      call put_stream_value(w, v%b16_forrefo)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_179

  subroutine write_section_180(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%longwave_reduced)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.ngc')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngc, kind=int64), ubound(v%ngc, kind=int64))
      call put_stream_value(w, v%ngc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.ngs')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngs, kind=int64), ubound(v%ngs, kind=int64))
      call put_stream_value(w, v%ngs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.ngn')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngn, kind=int64), ubound(v%ngn, kind=int64))
      call put_stream_value(w, v%ngn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.ngb')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngb, kind=int64), ubound(v%ngb, kind=int64))
      call put_stream_value(w, v%ngb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.ngm')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngm, kind=int64), ubound(v%ngm, kind=int64))
      call put_stream_value(w, v%ngm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.wt')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%wt, kind=int64), ubound(v%wt, kind=int64))
      call put_stream_value(w, v%wt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.corr1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%corr1, kind=int64), ubound(v%corr1, kind=int64))
      call put_stream_value(w, v%corr1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.corr2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%corr2, kind=int64), ubound(v%corr2, kind=int64))
      call put_stream_value(w, v%corr2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.rwgt')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rwgt, kind=int64), ubound(v%rwgt, kind=int64))
      call put_stream_value(w, v%rwgt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.frefa')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%frefa, kind=int64), ubound(v%frefa, kind=int64))
      call put_stream_value(w, v%frefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.frefb')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%frefb, kind=int64), ubound(v%frefb, kind=int64))
      call put_stream_value(w, v%frefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.frefadf')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%frefadf, kind=int64), ubound(v%frefadf, kind=int64))
      call put_stream_value(w, v%frefadf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.frefbdf')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%frefbdf, kind=int64), ubound(v%frefbdf, kind=int64))
      call put_stream_value(w, v%frefbdf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b1_fracrefa,kind=int64),ubound(v%b1_fracrefa,kind=int64))
      call put_stream_value(w, v%b1_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b1_fracrefb,kind=int64),ubound(v%b1_fracrefb,kind=int64))
      call put_stream_value(w, v%b1_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b1_ka, kind=int64), ubound(v%b1_ka, kind=int64))
      call put_stream_value(w, v%b1_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b1_kb, kind=int64), ubound(v%b1_kb, kind=int64))
      call put_stream_value(w, v%b1_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_ka_mn2')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_ka_mn2, kind=int64), ubound(v%b1_ka_mn2, kind=int64))
      call put_stream_value(w, v%b1_ka_mn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_kb_mn2')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_kb_mn2, kind=int64), ubound(v%b1_kb_mn2, kind=int64))
      call put_stream_value(w, v%b1_kb_mn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_selfref, kind=int64), ubound(v%b1_selfref, kind=int64))
      call put_stream_value(w, v%b1_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b1_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b1_forref, kind=int64), ubound(v%b1_forref, kind=int64))
      call put_stream_value(w, v%b1_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b2_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b2_fracrefa,kind=int64),ubound(v%b2_fracrefa,kind=int64))
      call put_stream_value(w, v%b2_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b2_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b2_fracrefb,kind=int64),ubound(v%b2_fracrefb,kind=int64))
      call put_stream_value(w, v%b2_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b2_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b2_ka, kind=int64), ubound(v%b2_ka, kind=int64))
      call put_stream_value(w, v%b2_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b2_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b2_kb, kind=int64), ubound(v%b2_kb, kind=int64))
      call put_stream_value(w, v%b2_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b2_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b2_selfref, kind=int64), ubound(v%b2_selfref, kind=int64))
      call put_stream_value(w, v%b2_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b2_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b2_forref, kind=int64), ubound(v%b2_forref, kind=int64))
      call put_stream_value(w, v%b2_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b3_fracrefa,kind=int64),ubound(v%b3_fracrefa,kind=int64))
      call put_stream_value(w, v%b3_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b3_fracrefb,kind=int64),ubound(v%b3_fracrefb,kind=int64))
      call put_stream_value(w, v%b3_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_ka_mn2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b3_ka_mn2o, kind=int64), ubound(v%b3_ka_mn2o, kind=int64))
      call put_stream_value(w, v%b3_ka_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_kb_mn2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b3_kb_mn2o, kind=int64), ubound(v%b3_kb_mn2o, kind=int64))
      call put_stream_value(w, v%b3_kb_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b3_ka, kind=int64), ubound(v%b3_ka, kind=int64))
      call put_stream_value(w, v%b3_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b3_kb, kind=int64), ubound(v%b3_kb, kind=int64))
      call put_stream_value(w, v%b3_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b3_selfref, kind=int64), ubound(v%b3_selfref, kind=int64))
      call put_stream_value(w, v%b3_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b3_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b3_forref, kind=int64), ubound(v%b3_forref, kind=int64))
      call put_stream_value(w, v%b3_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b4_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b4_fracrefa,kind=int64),ubound(v%b4_fracrefa,kind=int64))
      call put_stream_value(w, v%b4_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b4_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b4_fracrefb,kind=int64),ubound(v%b4_fracrefb,kind=int64))
      call put_stream_value(w, v%b4_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b4_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b4_ka, kind=int64), ubound(v%b4_ka, kind=int64))
      call put_stream_value(w, v%b4_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b4_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b4_kb, kind=int64), ubound(v%b4_kb, kind=int64))
      call put_stream_value(w, v%b4_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b4_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b4_selfref, kind=int64), ubound(v%b4_selfref, kind=int64))
      call put_stream_value(w, v%b4_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b4_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b4_forref, kind=int64), ubound(v%b4_forref, kind=int64))
      call put_stream_value(w, v%b4_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b5_fracrefa,kind=int64),ubound(v%b5_fracrefa,kind=int64))
      call put_stream_value(w, v%b5_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b5_fracrefb,kind=int64),ubound(v%b5_fracrefb,kind=int64))
      call put_stream_value(w, v%b5_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_ccl4')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b5_ccl4, kind=int64), ubound(v%b5_ccl4, kind=int64))
      call put_stream_value(w, v%b5_ccl4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b5_ka, kind=int64), ubound(v%b5_ka, kind=int64))
      call put_stream_value(w, v%b5_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b5_kb, kind=int64), ubound(v%b5_kb, kind=int64))
      call put_stream_value(w, v%b5_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_ka_mo3')
   call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b5_ka_mo3, kind=int64), ubound(v%b5_ka_mo3, kind=int64))
      call put_stream_value(w, v%b5_ka_mo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b5_selfref, kind=int64), ubound(v%b5_selfref, kind=int64))
      call put_stream_value(w, v%b5_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b5_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b5_forref, kind=int64), ubound(v%b5_forref, kind=int64))
      call put_stream_value(w, v%b5_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b6_fracrefa,kind=int64),ubound(v%b6_fracrefa,kind=int64))
      call put_stream_value(w, v%b6_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_cfc11adj')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b6_cfc11adj,kind=int64),ubound(v%b6_cfc11adj,kind=int64))
      call put_stream_value(w, v%b6_cfc11adj)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_cfc12')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b6_cfc12, kind=int64), ubound(v%b6_cfc12, kind=int64))
      call put_stream_value(w, v%b6_cfc12)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b6_ka, kind=int64), ubound(v%b6_ka, kind=int64))
      call put_stream_value(w, v%b6_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b6_selfref, kind=int64), ubound(v%b6_selfref, kind=int64))
      call put_stream_value(w, v%b6_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_ka_mco2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b6_ka_mco2, kind=int64), ubound(v%b6_ka_mco2, kind=int64))
      call put_stream_value(w, v%b6_ka_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b6_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b6_forref, kind=int64), ubound(v%b6_forref, kind=int64))
      call put_stream_value(w, v%b6_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b7_fracrefa,kind=int64),ubound(v%b7_fracrefa,kind=int64))
      call put_stream_value(w, v%b7_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b7_fracrefb,kind=int64),ubound(v%b7_fracrefb,kind=int64))
      call put_stream_value(w, v%b7_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b7_ka, kind=int64), ubound(v%b7_ka, kind=int64))
      call put_stream_value(w, v%b7_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b7_kb, kind=int64), ubound(v%b7_kb, kind=int64))
      call put_stream_value(w, v%b7_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b7_selfref, kind=int64), ubound(v%b7_selfref, kind=int64))
      call put_stream_value(w, v%b7_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_ka_mco2')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b7_ka_mco2, kind=int64), ubound(v%b7_ka_mco2, kind=int64))
      call put_stream_value(w, v%b7_ka_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_kb_mco2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b7_kb_mco2, kind=int64), ubound(v%b7_kb_mco2, kind=int64))
      call put_stream_value(w, v%b7_kb_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b7_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b7_forref, kind=int64), ubound(v%b7_forref, kind=int64))
      call put_stream_value(w, v%b7_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b8_fracrefa,kind=int64),ubound(v%b8_fracrefa,kind=int64))
      call put_stream_value(w, v%b8_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b8_fracrefb,kind=int64),ubound(v%b8_fracrefb,kind=int64))
      call put_stream_value(w, v%b8_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_cfc12')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b8_cfc12, kind=int64), ubound(v%b8_cfc12, kind=int64))
      call put_stream_value(w, v%b8_cfc12)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_cfc22adj')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b8_cfc22adj,kind=int64),ubound(v%b8_cfc22adj,kind=int64))
      call put_stream_value(w, v%b8_cfc22adj)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b8_ka, kind=int64), ubound(v%b8_ka, kind=int64))
      call put_stream_value(w, v%b8_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b8_kb, kind=int64), ubound(v%b8_kb, kind=int64))
      call put_stream_value(w, v%b8_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_ka_mco2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_ka_mco2, kind=int64), ubound(v%b8_ka_mco2, kind=int64))
      call put_stream_value(w, v%b8_ka_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_ka_mn2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_ka_mn2o, kind=int64), ubound(v%b8_ka_mn2o, kind=int64))
      call put_stream_value(w, v%b8_ka_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_ka_mo3')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_ka_mo3, kind=int64), ubound(v%b8_ka_mo3, kind=int64))
      call put_stream_value(w, v%b8_ka_mo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_kb_mco2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_kb_mco2, kind=int64), ubound(v%b8_kb_mco2, kind=int64))
      call put_stream_value(w, v%b8_kb_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_kb_mn2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_kb_mn2o, kind=int64), ubound(v%b8_kb_mn2o, kind=int64))
      call put_stream_value(w, v%b8_kb_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_selfref, kind=int64), ubound(v%b8_selfref, kind=int64))
      call put_stream_value(w, v%b8_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b8_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b8_forref, kind=int64), ubound(v%b8_forref, kind=int64))
      call put_stream_value(w, v%b8_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_fracrefa')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b9_fracrefa,kind=int64),ubound(v%b9_fracrefa,kind=int64))
      call put_stream_value(w, v%b9_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_fracrefb')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b9_fracrefb,kind=int64),ubound(v%b9_fracrefb,kind=int64))
      call put_stream_value(w, v%b9_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b9_ka, kind=int64), ubound(v%b9_ka, kind=int64))
      call put_stream_value(w, v%b9_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b9_kb, kind=int64), ubound(v%b9_kb, kind=int64))
      call put_stream_value(w, v%b9_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_ka_mn2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b9_ka_mn2o, kind=int64), ubound(v%b9_ka_mn2o, kind=int64))
      call put_stream_value(w, v%b9_ka_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_kb_mn2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b9_kb_mn2o, kind=int64), ubound(v%b9_kb_mn2o, kind=int64))
      call put_stream_value(w, v%b9_kb_mn2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_selfref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b9_selfref, kind=int64), ubound(v%b9_selfref, kind=int64))
      call put_stream_value(w, v%b9_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b9_forref')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b9_forref, kind=int64), ubound(v%b9_forref, kind=int64))
      call put_stream_value(w, v%b9_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b10_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b10_fracrefa,kind=int64),ubound(v%b10_fracrefa,kind=int64))
      call put_stream_value(w, v%b10_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b10_fracrefb')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b10_fracrefb,kind=int64),ubound(v%b10_fracrefb,kind=int64))
      call put_stream_value(w, v%b10_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b10_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b10_ka, kind=int64), ubound(v%b10_ka, kind=int64))
      call put_stream_value(w, v%b10_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b10_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b10_kb, kind=int64), ubound(v%b10_kb, kind=int64))
      call put_stream_value(w, v%b10_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b10_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b10_selfref,kind=int64),ubound(v%b10_selfref,kind=int64))
      call put_stream_value(w, v%b10_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b10_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b10_forref, kind=int64), ubound(v%b10_forref, kind=int64))
      call put_stream_value(w, v%b10_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b11_fracrefa,kind=int64),ubound(v%b11_fracrefa,kind=int64))
      call put_stream_value(w, v%b11_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_fracrefb')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b11_fracrefb,kind=int64),ubound(v%b11_fracrefb,kind=int64))
      call put_stream_value(w, v%b11_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b11_ka, kind=int64), ubound(v%b11_ka, kind=int64))
      call put_stream_value(w, v%b11_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b11_kb, kind=int64), ubound(v%b11_kb, kind=int64))
      call put_stream_value(w, v%b11_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_ka_mo2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b11_ka_mo2, kind=int64), ubound(v%b11_ka_mo2, kind=int64))
      call put_stream_value(w, v%b11_ka_mo2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_kb_mo2')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b11_kb_mo2, kind=int64), ubound(v%b11_kb_mo2, kind=int64))
      call put_stream_value(w, v%b11_kb_mo2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b11_selfref,kind=int64),ubound(v%b11_selfref,kind=int64))
      call put_stream_value(w, v%b11_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b11_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b11_forref, kind=int64), ubound(v%b11_forref, kind=int64))
      call put_stream_value(w, v%b11_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b12_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b12_fracrefa,kind=int64),ubound(v%b12_fracrefa,kind=int64))
      call put_stream_value(w, v%b12_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b12_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b12_ka, kind=int64), ubound(v%b12_ka, kind=int64))
      call put_stream_value(w, v%b12_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b12_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b12_selfref,kind=int64),ubound(v%b12_selfref,kind=int64))
      call put_stream_value(w, v%b12_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b12_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b12_forref, kind=int64), ubound(v%b12_forref, kind=int64))
      call put_stream_value(w, v%b12_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b12_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b12_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b13_fracrefa,kind=int64),ubound(v%b13_fracrefa,kind=int64))
      call put_stream_value(w, v%b13_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_fracrefb')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b13_fracrefb,kind=int64),ubound(v%b13_fracrefb,kind=int64))
      call put_stream_value(w, v%b13_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b13_ka, kind=int64), ubound(v%b13_ka, kind=int64))
      call put_stream_value(w, v%b13_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b13_selfref,kind=int64),ubound(v%b13_selfref,kind=int64))
      call put_stream_value(w, v%b13_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b13_forref, kind=int64), ubound(v%b13_forref, kind=int64))
      call put_stream_value(w, v%b13_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_ka_mco2')
      call put_stream_metadata(w,2_int32,8_int32,3_int32,1_int32,lbound(v%b13_ka_mco2,kind=int64),ubound(v%b13_ka_mco2,kind=int64))
      call put_stream_value(w, v%b13_ka_mco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_ka_mco')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b13_ka_mco, kind=int64), ubound(v%b13_ka_mco, kind=int64))
      call put_stream_value(w, v%b13_ka_mco)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b13_kb_mo3')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b13_kb_mo3, kind=int64), ubound(v%b13_kb_mo3, kind=int64))
      call put_stream_value(w, v%b13_kb_mo3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b14_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b14_fracrefa,kind=int64),ubound(v%b14_fracrefa,kind=int64))
      call put_stream_value(w, v%b14_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b14_fracrefb')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b14_fracrefb,kind=int64),ubound(v%b14_fracrefb,kind=int64))
      call put_stream_value(w, v%b14_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b14_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b14_ka, kind=int64), ubound(v%b14_ka, kind=int64))
      call put_stream_value(w, v%b14_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b14_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b14_kb, kind=int64), ubound(v%b14_kb, kind=int64))
      call put_stream_value(w, v%b14_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b14_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b14_selfref,kind=int64),ubound(v%b14_selfref,kind=int64))
      call put_stream_value(w, v%b14_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b14_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b14_forref, kind=int64), ubound(v%b14_forref, kind=int64))
      call put_stream_value(w, v%b14_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b15_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b15_fracrefa,kind=int64),ubound(v%b15_fracrefa,kind=int64))
      call put_stream_value(w, v%b15_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b15_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b15_ka, kind=int64), ubound(v%b15_ka, kind=int64))
      call put_stream_value(w, v%b15_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b15_ka_mn2')
 call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b15_ka_mn2, kind=int64), ubound(v%b15_ka_mn2, kind=int64))
      call put_stream_value(w, v%b15_ka_mn2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b15_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b15_selfref,kind=int64),ubound(v%b15_selfref,kind=int64))
      call put_stream_value(w, v%b15_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b15_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b15_forref, kind=int64), ubound(v%b15_forref, kind=int64))
      call put_stream_value(w, v%b15_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b16_fracrefa')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_fracrefa,kind=int64),ubound(v%b16_fracrefa,kind=int64))
      call put_stream_value(w, v%b16_fracrefa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b16_fracrefb')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b16_fracrefb,kind=int64),ubound(v%b16_fracrefb,kind=int64))
      call put_stream_value(w, v%b16_fracrefb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b16_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b16_ka, kind=int64), ubound(v%b16_ka, kind=int64))
      call put_stream_value(w, v%b16_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b16_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b16_kb, kind=int64), ubound(v%b16_kb, kind=int64))
      call put_stream_value(w, v%b16_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b16_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_selfref,kind=int64),ubound(v%b16_selfref,kind=int64))
      call put_stream_value(w, v%b16_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reduced_coefficients.longwave_reduced.b16_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b16_forref, kind=int64), ubound(v%b16_forref, kind=int64))
      call put_stream_value(w, v%b16_forref)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_180

  subroutine write_section_181(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%longwave_reference)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.trans')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%trans, kind=int64), ubound(v%trans, kind=int64))
      call put_stream_value(w, v%trans)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.bpade')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%bpade)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.ng')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ng, kind=int64), ubound(v%ng, kind=int64))
      call put_stream_value(w, v%ng)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.nspa')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nspa, kind=int64), ubound(v%nspa, kind=int64))
      call put_stream_value(w, v%nspa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.nspb')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nspb, kind=int64), ubound(v%nspb, kind=int64))
      call put_stream_value(w, v%nspb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.delwave')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%delwave, kind=int64), ubound(v%delwave, kind=int64))
      call put_stream_value(w, v%delwave)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.totplnk')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%totplnk, kind=int64), ubound(v%totplnk, kind=int64))
      call put_stream_value(w, v%totplnk)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.pref')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%pref, kind=int64), ubound(v%pref, kind=int64))
      call put_stream_value(w, v%pref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.preflog')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%preflog, kind=int64), ubound(v%preflog, kind=int64))
      call put_stream_value(w, v%preflog)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.tref')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%tref, kind=int64), ubound(v%tref, kind=int64))
      call put_stream_value(w, v%tref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_longwave_reference_parameters.longwave_reference.chi_mls')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%chi_mls, kind=int64), ubound(v%chi_mls, kind=int64))
      call put_stream_value(w, v%chi_mls)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_181

  subroutine write_section_182(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave_absorption)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.ng')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ng, kind=int64), ubound(v%ng, kind=int64))
      call put_stream_value(w, v%ng)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.nspa')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nspa, kind=int64), ubound(v%nspa, kind=int64))
      call put_stream_value(w, v%nspa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.nspb')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nspb, kind=int64), ubound(v%nspb, kind=int64))
      call put_stream_value(w, v%nspb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.nmpsrtm')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nmpsrtm, kind=int64), ubound(v%nmpsrtm, kind=int64))
      call put_stream_value(w, v%nmpsrtm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.pref')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%pref, kind=int64), ubound(v%pref, kind=int64))
      call put_stream_value(w, v%pref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.preflog')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%preflog, kind=int64), ubound(v%preflog, kind=int64))
      call put_stream_value(w, v%preflog)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.tref')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%tref, kind=int64), ubound(v%tref, kind=int64))
      call put_stream_value(w, v%tref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.ngm')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngm, kind=int64), ubound(v%ngm, kind=int64))
      call put_stream_value(w, v%ngm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.ngc')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngc, kind=int64), ubound(v%ngc, kind=int64))
      call put_stream_value(w, v%ngc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.ngs')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngs, kind=int64), ubound(v%ngs, kind=int64))
      call put_stream_value(w, v%ngs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.wt')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%wt, kind=int64), ubound(v%wt, kind=int64))
      call put_stream_value(w, v%wt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.wtsm')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%wtsm, kind=int64), ubound(v%wtsm, kind=int64))
      call put_stream_value(w, v%wtsm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.rwgt')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rwgt, kind=int64), ubound(v%rwgt, kind=int64))
      call put_stream_value(w, v%rwgt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.ngn')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngn, kind=int64), ubound(v%ngn, kind=int64))
      call put_stream_value(w, v%ngn)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.ngbsw')
      call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%ngbsw, kind=int64), ubound(v%ngbsw, kind=int64))
      call put_stream_value(w, v%ngbsw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b16_ka, kind=int64), ubound(v%b16_ka, kind=int64))
      call put_stream_value(w, v%b16_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b16_kb, kind=int64), ubound(v%b16_kb, kind=int64))
      call put_stream_value(w, v%b16_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b16_ka_d, kind=int64), ubound(v%b16_ka_d, kind=int64))
      call put_stream_value(w, v%b16_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b16_kb_d, kind=int64), ubound(v%b16_kb_d, kind=int64))
      call put_stream_value(w, v%b16_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_selfref,kind=int64),ubound(v%b16_selfref,kind=int64))
      call put_stream_value(w, v%b16_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b16_forref, kind=int64), ubound(v%b16_forref, kind=int64))
      call put_stream_value(w, v%b16_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b16_sfluxref,kind=int64),ubound(v%b16_sfluxref,kind=int64))
      call put_stream_value(w, v%b16_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b16_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_strrat1')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b16_strrat1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b16_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b16_kac, kind=int64), ubound(v%b16_kac, kind=int64))
      call put_stream_value(w, v%b16_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b16_kbc, kind=int64), ubound(v%b16_kbc, kind=int64))
      call put_stream_value(w, v%b16_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_selfrefc,kind=int64),ubound(v%b16_selfrefc,kind=int64))
      call put_stream_value(w, v%b16_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b16_forrefc,kind=int64),ubound(v%b16_forrefc,kind=int64))
      call put_stream_value(w, v%b16_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b16_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b16_sfluxrefc,kind=int64),ubound(v%b16_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b16_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b17_ka, kind=int64), ubound(v%b17_ka, kind=int64))
      call put_stream_value(w, v%b17_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b17_kb, kind=int64), ubound(v%b17_kb, kind=int64))
      call put_stream_value(w, v%b17_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b17_ka_d, kind=int64), ubound(v%b17_ka_d, kind=int64))
      call put_stream_value(w, v%b17_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b17_kb_d, kind=int64), ubound(v%b17_kb_d, kind=int64))
      call put_stream_value(w, v%b17_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b17_selfref,kind=int64),ubound(v%b17_selfref,kind=int64))
      call put_stream_value(w, v%b17_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b17_forref, kind=int64), ubound(v%b17_forref, kind=int64))
      call put_stream_value(w, v%b17_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b17_sfluxref,kind=int64),ubound(v%b17_sfluxref,kind=int64))
      call put_stream_value(w, v%b17_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b17_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b17_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b17_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b17_kac, kind=int64), ubound(v%b17_kac, kind=int64))
      call put_stream_value(w, v%b17_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b17_kbc, kind=int64), ubound(v%b17_kbc, kind=int64))
      call put_stream_value(w, v%b17_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b17_selfrefc,kind=int64),ubound(v%b17_selfrefc,kind=int64))
      call put_stream_value(w, v%b17_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b17_forrefc,kind=int64),ubound(v%b17_forrefc,kind=int64))
      call put_stream_value(w, v%b17_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b17_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b17_sfluxrefc,kind=int64),ubound(v%b17_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b17_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b18_ka, kind=int64), ubound(v%b18_ka, kind=int64))
      call put_stream_value(w, v%b18_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b18_kb, kind=int64), ubound(v%b18_kb, kind=int64))
      call put_stream_value(w, v%b18_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b18_ka_d, kind=int64), ubound(v%b18_ka_d, kind=int64))
      call put_stream_value(w, v%b18_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b18_kb_d, kind=int64), ubound(v%b18_kb_d, kind=int64))
      call put_stream_value(w, v%b18_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b18_selfref,kind=int64),ubound(v%b18_selfref,kind=int64))
      call put_stream_value(w, v%b18_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b18_forref, kind=int64), ubound(v%b18_forref, kind=int64))
      call put_stream_value(w, v%b18_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b18_sfluxref,kind=int64),ubound(v%b18_sfluxref,kind=int64))
      call put_stream_value(w, v%b18_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b18_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b18_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b18_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b18_kac, kind=int64), ubound(v%b18_kac, kind=int64))
      call put_stream_value(w, v%b18_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b18_kbc, kind=int64), ubound(v%b18_kbc, kind=int64))
      call put_stream_value(w, v%b18_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b18_selfrefc,kind=int64),ubound(v%b18_selfrefc,kind=int64))
      call put_stream_value(w, v%b18_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b18_forrefc,kind=int64),ubound(v%b18_forrefc,kind=int64))
      call put_stream_value(w, v%b18_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b18_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b18_sfluxrefc,kind=int64),ubound(v%b18_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b18_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b19_ka, kind=int64), ubound(v%b19_ka, kind=int64))
      call put_stream_value(w, v%b19_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b19_kb, kind=int64), ubound(v%b19_kb, kind=int64))
      call put_stream_value(w, v%b19_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b19_ka_d, kind=int64), ubound(v%b19_ka_d, kind=int64))
      call put_stream_value(w, v%b19_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b19_kb_d, kind=int64), ubound(v%b19_kb_d, kind=int64))
      call put_stream_value(w, v%b19_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b19_selfref,kind=int64),ubound(v%b19_selfref,kind=int64))
      call put_stream_value(w, v%b19_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b19_forref, kind=int64), ubound(v%b19_forref, kind=int64))
      call put_stream_value(w, v%b19_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b19_sfluxref,kind=int64),ubound(v%b19_sfluxref,kind=int64))
      call put_stream_value(w, v%b19_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b19_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b19_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b19_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b19_kac, kind=int64), ubound(v%b19_kac, kind=int64))
      call put_stream_value(w, v%b19_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b19_kbc, kind=int64), ubound(v%b19_kbc, kind=int64))
      call put_stream_value(w, v%b19_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b19_selfrefc,kind=int64),ubound(v%b19_selfrefc,kind=int64))
      call put_stream_value(w, v%b19_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b19_forrefc,kind=int64),ubound(v%b19_forrefc,kind=int64))
      call put_stream_value(w, v%b19_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b19_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b19_sfluxrefc,kind=int64),ubound(v%b19_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b19_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b20_ka, kind=int64), ubound(v%b20_ka, kind=int64))
      call put_stream_value(w, v%b20_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b20_kb, kind=int64), ubound(v%b20_kb, kind=int64))
      call put_stream_value(w, v%b20_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b20_ka_d, kind=int64), ubound(v%b20_ka_d, kind=int64))
      call put_stream_value(w, v%b20_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b20_kb_d, kind=int64), ubound(v%b20_kb_d, kind=int64))
      call put_stream_value(w, v%b20_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b20_selfref,kind=int64),ubound(v%b20_selfref,kind=int64))
      call put_stream_value(w, v%b20_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b20_forref, kind=int64), ubound(v%b20_forref, kind=int64))
      call put_stream_value(w, v%b20_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b20_sfluxref,kind=int64),ubound(v%b20_sfluxref,kind=int64))
      call put_stream_value(w, v%b20_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_absch4')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b20_absch4, kind=int64), ubound(v%b20_absch4, kind=int64))
      call put_stream_value(w, v%b20_absch4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b20_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b20_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b20_kac, kind=int64), ubound(v%b20_kac, kind=int64))
      call put_stream_value(w, v%b20_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b20_kbc, kind=int64), ubound(v%b20_kbc, kind=int64))
      call put_stream_value(w, v%b20_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b20_selfrefc,kind=int64),ubound(v%b20_selfrefc,kind=int64))
      call put_stream_value(w, v%b20_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b20_forrefc,kind=int64),ubound(v%b20_forrefc,kind=int64))
      call put_stream_value(w, v%b20_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b20_sfluxrefc,kind=int64),ubound(v%b20_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b20_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b20_absch4c')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b20_absch4c,kind=int64),ubound(v%b20_absch4c,kind=int64))
      call put_stream_value(w, v%b20_absch4c)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b21_ka, kind=int64), ubound(v%b21_ka, kind=int64))
      call put_stream_value(w, v%b21_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b21_kb, kind=int64), ubound(v%b21_kb, kind=int64))
      call put_stream_value(w, v%b21_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b21_ka_d, kind=int64), ubound(v%b21_ka_d, kind=int64))
      call put_stream_value(w, v%b21_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b21_kb_d, kind=int64), ubound(v%b21_kb_d, kind=int64))
      call put_stream_value(w, v%b21_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b21_selfref,kind=int64),ubound(v%b21_selfref,kind=int64))
      call put_stream_value(w, v%b21_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b21_forref, kind=int64), ubound(v%b21_forref, kind=int64))
      call put_stream_value(w, v%b21_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b21_sfluxref,kind=int64),ubound(v%b21_sfluxref,kind=int64))
      call put_stream_value(w, v%b21_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b21_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b21_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b21_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b21_kac, kind=int64), ubound(v%b21_kac, kind=int64))
      call put_stream_value(w, v%b21_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b21_kbc, kind=int64), ubound(v%b21_kbc, kind=int64))
      call put_stream_value(w, v%b21_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b21_selfrefc,kind=int64),ubound(v%b21_selfrefc,kind=int64))
      call put_stream_value(w, v%b21_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b21_forrefc,kind=int64),ubound(v%b21_forrefc,kind=int64))
      call put_stream_value(w, v%b21_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b21_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b21_sfluxrefc,kind=int64),ubound(v%b21_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b21_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b22_ka, kind=int64), ubound(v%b22_ka, kind=int64))
      call put_stream_value(w, v%b22_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b22_kb, kind=int64), ubound(v%b22_kb, kind=int64))
      call put_stream_value(w, v%b22_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b22_ka_d, kind=int64), ubound(v%b22_ka_d, kind=int64))
      call put_stream_value(w, v%b22_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b22_kb_d, kind=int64), ubound(v%b22_kb_d, kind=int64))
      call put_stream_value(w, v%b22_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b22_selfref,kind=int64),ubound(v%b22_selfref,kind=int64))
      call put_stream_value(w, v%b22_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b22_forref, kind=int64), ubound(v%b22_forref, kind=int64))
      call put_stream_value(w, v%b22_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b22_sfluxref,kind=int64),ubound(v%b22_sfluxref,kind=int64))
      call put_stream_value(w, v%b22_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b22_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b22_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b22_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b22_kac, kind=int64), ubound(v%b22_kac, kind=int64))
      call put_stream_value(w, v%b22_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b22_kbc, kind=int64), ubound(v%b22_kbc, kind=int64))
      call put_stream_value(w, v%b22_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b22_selfrefc,kind=int64),ubound(v%b22_selfrefc,kind=int64))
      call put_stream_value(w, v%b22_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b22_forrefc,kind=int64),ubound(v%b22_forrefc,kind=int64))
      call put_stream_value(w, v%b22_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b22_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b22_sfluxrefc,kind=int64),ubound(v%b22_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b22_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b23_ka, kind=int64), ubound(v%b23_ka, kind=int64))
      call put_stream_value(w, v%b23_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b23_ka_d, kind=int64), ubound(v%b23_ka_d, kind=int64))
      call put_stream_value(w, v%b23_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b23_selfref,kind=int64),ubound(v%b23_selfref,kind=int64))
      call put_stream_value(w, v%b23_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b23_forref, kind=int64), ubound(v%b23_forref, kind=int64))
      call put_stream_value(w, v%b23_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b23_sfluxref,kind=int64),ubound(v%b23_sfluxref,kind=int64))
      call put_stream_value(w, v%b23_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_rayl')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b23_rayl, kind=int64), ubound(v%b23_rayl, kind=int64))
      call put_stream_value(w, v%b23_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_givfac')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b23_givfac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b23_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b23_kac, kind=int64), ubound(v%b23_kac, kind=int64))
      call put_stream_value(w, v%b23_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b23_selfrefc,kind=int64),ubound(v%b23_selfrefc,kind=int64))
      call put_stream_value(w, v%b23_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b23_forrefc,kind=int64),ubound(v%b23_forrefc,kind=int64))
      call put_stream_value(w, v%b23_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b23_sfluxrefc,kind=int64),ubound(v%b23_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b23_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b23_raylc')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b23_raylc, kind=int64), ubound(v%b23_raylc, kind=int64))
      call put_stream_value(w, v%b23_raylc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b24_ka, kind=int64), ubound(v%b24_ka, kind=int64))
      call put_stream_value(w, v%b24_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b24_kb, kind=int64), ubound(v%b24_kb, kind=int64))
      call put_stream_value(w, v%b24_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b24_ka_d, kind=int64), ubound(v%b24_ka_d, kind=int64))
      call put_stream_value(w, v%b24_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b24_kb_d, kind=int64), ubound(v%b24_kb_d, kind=int64))
      call put_stream_value(w, v%b24_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b24_selfref,kind=int64),ubound(v%b24_selfref,kind=int64))
      call put_stream_value(w, v%b24_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b24_forref, kind=int64), ubound(v%b24_forref, kind=int64))
      call put_stream_value(w, v%b24_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b24_sfluxref,kind=int64),ubound(v%b24_sfluxref,kind=int64))
      call put_stream_value(w, v%b24_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_abso3a')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b24_abso3a, kind=int64), ubound(v%b24_abso3a, kind=int64))
      call put_stream_value(w, v%b24_abso3a)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_abso3b')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b24_abso3b, kind=int64), ubound(v%b24_abso3b, kind=int64))
      call put_stream_value(w, v%b24_abso3b)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_rayla')
   call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b24_rayla, kind=int64), ubound(v%b24_rayla, kind=int64))
      call put_stream_value(w, v%b24_rayla)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_raylb')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b24_raylb, kind=int64), ubound(v%b24_raylb, kind=int64))
      call put_stream_value(w, v%b24_raylb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b24_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b24_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b24_kac, kind=int64), ubound(v%b24_kac, kind=int64))
      call put_stream_value(w, v%b24_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b24_kbc, kind=int64), ubound(v%b24_kbc, kind=int64))
      call put_stream_value(w, v%b24_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b24_selfrefc,kind=int64),ubound(v%b24_selfrefc,kind=int64))
      call put_stream_value(w, v%b24_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b24_forrefc,kind=int64),ubound(v%b24_forrefc,kind=int64))
      call put_stream_value(w, v%b24_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b24_sfluxrefc,kind=int64),ubound(v%b24_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b24_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_abso3ac')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b24_abso3ac,kind=int64),ubound(v%b24_abso3ac,kind=int64))
      call put_stream_value(w, v%b24_abso3ac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_abso3bc')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b24_abso3bc,kind=int64),ubound(v%b24_abso3bc,kind=int64))
      call put_stream_value(w, v%b24_abso3bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_raylac')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b24_raylac, kind=int64), ubound(v%b24_raylac, kind=int64))
      call put_stream_value(w, v%b24_raylac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b24_raylbc')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b24_raylbc, kind=int64), ubound(v%b24_raylbc, kind=int64))
      call put_stream_value(w, v%b24_raylbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b25_ka, kind=int64), ubound(v%b25_ka, kind=int64))
      call put_stream_value(w, v%b25_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b25_ka_d, kind=int64), ubound(v%b25_ka_d, kind=int64))
      call put_stream_value(w, v%b25_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b25_sfluxref,kind=int64),ubound(v%b25_sfluxref,kind=int64))
      call put_stream_value(w, v%b25_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_rayl')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b25_rayl, kind=int64), ubound(v%b25_rayl, kind=int64))
      call put_stream_value(w, v%b25_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_abso3a')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b25_abso3a, kind=int64), ubound(v%b25_abso3a, kind=int64))
      call put_stream_value(w, v%b25_abso3a)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_abso3b')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b25_abso3b, kind=int64), ubound(v%b25_abso3b, kind=int64))
      call put_stream_value(w, v%b25_abso3b)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b25_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b25_kac, kind=int64), ubound(v%b25_kac, kind=int64))
      call put_stream_value(w, v%b25_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b25_sfluxrefc,kind=int64),ubound(v%b25_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b25_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_raylc')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b25_raylc, kind=int64), ubound(v%b25_raylc, kind=int64))
      call put_stream_value(w, v%b25_raylc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_abso3ac')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b25_abso3ac,kind=int64),ubound(v%b25_abso3ac,kind=int64))
      call put_stream_value(w, v%b25_abso3ac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b25_abso3bc')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b25_abso3bc,kind=int64),ubound(v%b25_abso3bc,kind=int64))
      call put_stream_value(w, v%b25_abso3bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b26_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b26_sfluxref,kind=int64),ubound(v%b26_sfluxref,kind=int64))
      call put_stream_value(w, v%b26_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b26_rayl')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b26_rayl, kind=int64), ubound(v%b26_rayl, kind=int64))
      call put_stream_value(w, v%b26_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b26_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b26_sfluxrefc,kind=int64),ubound(v%b26_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b26_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b26_raylc')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b26_raylc, kind=int64), ubound(v%b26_raylc, kind=int64))
      call put_stream_value(w, v%b26_raylc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b27_ka, kind=int64), ubound(v%b27_ka, kind=int64))
      call put_stream_value(w, v%b27_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b27_kb, kind=int64), ubound(v%b27_kb, kind=int64))
      call put_stream_value(w, v%b27_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b27_ka_d, kind=int64), ubound(v%b27_ka_d, kind=int64))
      call put_stream_value(w, v%b27_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b27_kb_d, kind=int64), ubound(v%b27_kb_d, kind=int64))
      call put_stream_value(w, v%b27_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b27_sfluxref,kind=int64),ubound(v%b27_sfluxref,kind=int64))
      call put_stream_value(w, v%b27_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_rayl')
     call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b27_rayl, kind=int64), ubound(v%b27_rayl, kind=int64))
      call put_stream_value(w, v%b27_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_scalekur')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b27_scalekur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b27_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b27_kac, kind=int64), ubound(v%b27_kac, kind=int64))
      call put_stream_value(w, v%b27_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b27_kbc, kind=int64), ubound(v%b27_kbc, kind=int64))
      call put_stream_value(w, v%b27_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b27_sfluxrefc,kind=int64),ubound(v%b27_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b27_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b27_raylc')
   call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b27_raylc, kind=int64), ubound(v%b27_raylc, kind=int64))
      call put_stream_value(w, v%b27_raylc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b28_ka, kind=int64), ubound(v%b28_ka, kind=int64))
      call put_stream_value(w, v%b28_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b28_kb, kind=int64), ubound(v%b28_kb, kind=int64))
      call put_stream_value(w, v%b28_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b28_ka_d, kind=int64), ubound(v%b28_ka_d, kind=int64))
      call put_stream_value(w, v%b28_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b28_kb_d, kind=int64), ubound(v%b28_kb_d, kind=int64))
      call put_stream_value(w, v%b28_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b28_sfluxref,kind=int64),ubound(v%b28_sfluxref,kind=int64))
      call put_stream_value(w, v%b28_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b28_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_strrat')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b28_strrat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b28_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b28_kac, kind=int64), ubound(v%b28_kac, kind=int64))
      call put_stream_value(w, v%b28_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 4_int32, 1_int32, lbound(v%b28_kbc, kind=int64), ubound(v%b28_kbc, kind=int64))
      call put_stream_value(w, v%b28_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b28_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b28_sfluxrefc,kind=int64),ubound(v%b28_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b28_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_ka')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b29_ka, kind=int64), ubound(v%b29_ka, kind=int64))
      call put_stream_value(w, v%b29_ka)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_kb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b29_kb, kind=int64), ubound(v%b29_kb, kind=int64))
      call put_stream_value(w, v%b29_kb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_ka_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b29_ka_d, kind=int64), ubound(v%b29_ka_d, kind=int64))
      call put_stream_value(w, v%b29_ka_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_kb_d')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b29_kb_d, kind=int64), ubound(v%b29_kb_d, kind=int64))
      call put_stream_value(w, v%b29_kb_d)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_selfref')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b29_selfref,kind=int64),ubound(v%b29_selfref,kind=int64))
      call put_stream_value(w, v%b29_selfref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_forref')
 call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%b29_forref, kind=int64), ubound(v%b29_forref, kind=int64))
      call put_stream_value(w, v%b29_forref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_sfluxref')
     call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b29_sfluxref,kind=int64),ubound(v%b29_sfluxref,kind=int64))
      call put_stream_value(w, v%b29_sfluxref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_absh2o')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b29_absh2o, kind=int64), ubound(v%b29_absh2o, kind=int64))
      call put_stream_value(w, v%b29_absh2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_absco2')
 call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%b29_absco2, kind=int64), ubound(v%b29_absco2, kind=int64))
      call put_stream_value(w, v%b29_absco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_rayl')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b29_rayl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_layreffr')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%b29_layreffr)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_kac')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b29_kac, kind=int64), ubound(v%b29_kac, kind=int64))
      call put_stream_value(w, v%b29_kac)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_kbc')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%b29_kbc, kind=int64), ubound(v%b29_kbc, kind=int64))
      call put_stream_value(w, v%b29_kbc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_selfrefc')
     call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b29_selfrefc,kind=int64),ubound(v%b29_selfrefc,kind=int64))
      call put_stream_value(w, v%b29_selfrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_forrefc')
      call put_stream_metadata(w,2_int32,8_int32,2_int32,1_int32,lbound(v%b29_forrefc,kind=int64),ubound(v%b29_forrefc,kind=int64))
      call put_stream_value(w, v%b29_forrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_sfluxrefc')
   call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b29_sfluxrefc,kind=int64),ubound(v%b29_sfluxrefc,kind=int64))
      call put_stream_value(w, v%b29_sfluxrefc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_absh2oc')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b29_absh2oc,kind=int64),ubound(v%b29_absh2oc,kind=int64))
      call put_stream_value(w, v%b29_absh2oc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_absorption_parameters.shortwave_absorption.b29_absco2c')
      call put_stream_metadata(w,2_int32,8_int32,1_int32,1_int32,lbound(v%b29_absco2c,kind=int64),ubound(v%b29_absco2c,kind=int64))
      call put_stream_value(w, v%b29_absco2c)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_182

  subroutine write_section_183(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%longwave_bands)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.mxixt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mxixt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.nsil')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsil)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.nipd')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nipd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.ntra')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntra)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.nua')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nua)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.ng1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ng1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.ng1p1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ng1p1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.alwt')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alwt, kind=int64), ubound(v%alwt, kind=int64))
      call put_stream_value(w, v%alwt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.blwt')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%blwt, kind=int64), ubound(v%blwt, kind=int64))
      call put_stream_value(w, v%blwt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.pdga')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%pdga, kind=int64), ubound(v%pdga, kind=int64))
      call put_stream_value(w, v%pdga)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.pdgb')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%pdgb, kind=int64), ubound(v%pdgb, kind=int64))
      call put_stream_value(w, v%pdgb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.rptype')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rptype, kind=int64), ubound(v%rptype, kind=int64))
      call put_stream_value(w, v%rptype)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.retype')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%retype, kind=int64), ubound(v%retype, kind=int64))
      call put_stream_value(w, v%retype)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.ro1h')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ro1h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.ro2h')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ro2h)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.ro3t')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%ro3t, kind=int64), ubound(v%ro3t, kind=int64))
      call put_stream_value(w, v%ro3t)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.rpialf0')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rpialf0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.rt1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rt1, kind=int64), ubound(v%rt1, kind=int64))
      call put_stream_value(w, v%rt1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.tintp')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%tintp, kind=int64), ubound(v%tintp, kind=int64))
      call put_stream_value(w, v%tintp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.tref')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%tref)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.tstand')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%tstand)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.tstp')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%tstp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.wg1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%wg1, kind=int64), ubound(v%wg1, kind=int64))
      call put_stream_value(w, v%wg1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.xp')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%xp, kind=int64), ubound(v%xp, kind=int64))
      call put_stream_value(w, v%xp)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.rvgco2')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvgco2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.rvgh2o')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvgh2o)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_legacy_longwave_band_parameters.longwave_bands.rvgo3')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rvgo3)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_183

  subroutine write_section_184(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%aerosol_optical)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%alf_bc, kind=int64), ubound(v%alf_bc, kind=int64))
      call put_stream_value(w, v%alf_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%asy_bc, kind=int64), ubound(v%asy_bc, kind=int64))
      call put_stream_value(w, v%asy_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%omg_bc, kind=int64), ubound(v%omg_bc, kind=int64))
      call put_stream_value(w, v%omg_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rali_bc, kind=int64), ubound(v%rali_bc, kind=int64))
      call put_stream_value(w, v%rali_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alf_dd, kind=int64), ubound(v%alf_dd, kind=int64))
      call put_stream_value(w, v%alf_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asy_dd, kind=int64), ubound(v%asy_dd, kind=int64))
      call put_stream_value(w, v%asy_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omg_dd, kind=int64), ubound(v%omg_dd, kind=int64))
      call put_stream_value(w, v%omg_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rali_dd, kind=int64), ubound(v%rali_dd, kind=int64))
      call put_stream_value(w, v%rali_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alf_om, kind=int64), ubound(v%alf_om, kind=int64))
      call put_stream_value(w, v%alf_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asy_om, kind=int64), ubound(v%asy_om, kind=int64))
      call put_stream_value(w, v%asy_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omg_om, kind=int64), ubound(v%omg_om, kind=int64))
      call put_stream_value(w, v%omg_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rali_om, kind=int64), ubound(v%rali_om, kind=int64))
      call put_stream_value(w, v%rali_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%alf_ss, kind=int64), ubound(v%alf_ss, kind=int64))
      call put_stream_value(w, v%alf_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%asy_ss, kind=int64), ubound(v%asy_ss, kind=int64))
      call put_stream_value(w, v%asy_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%omg_ss, kind=int64), ubound(v%omg_ss, kind=int64))
      call put_stream_value(w, v%omg_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rali_ss, kind=int64), ubound(v%rali_ss, kind=int64))
      call put_stream_value(w, v%rali_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alf_su, kind=int64), ubound(v%alf_su, kind=int64))
      call put_stream_value(w, v%alf_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asy_su, kind=int64), ubound(v%asy_su, kind=int64))
      call put_stream_value(w, v%asy_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omg_su, kind=int64), ubound(v%omg_su, kind=int64))
      call put_stream_value(w, v%omg_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rali_su, kind=int64), ubound(v%rali_su, kind=int64))
      call put_stream_value(w, v%rali_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_ni')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%alf_ni, kind=int64), ubound(v%alf_ni, kind=int64))
      call put_stream_value(w, v%alf_ni)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_ni')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%asy_ni, kind=int64), ubound(v%asy_ni, kind=int64))
      call put_stream_value(w, v%asy_ni)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_ni')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%omg_ni, kind=int64), ubound(v%omg_ni, kind=int64))
      call put_stream_value(w, v%omg_ni)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_ni')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rali_ni, kind=int64), ubound(v%rali_ni, kind=int64))
      call put_stream_value(w, v%rali_ni)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_soa')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%alf_soa, kind=int64), ubound(v%alf_soa, kind=int64))
      call put_stream_value(w, v%alf_soa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_soa')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%asy_soa, kind=int64), ubound(v%asy_soa, kind=int64))
      call put_stream_value(w, v%asy_soa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_soa')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%omg_soa, kind=int64), ubound(v%omg_soa, kind=int64))
      call put_stream_value(w, v%omg_soa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_soa')
     call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%rali_soa, kind=int64), ubound(v%rali_soa, kind=int64))
      call put_stream_value(w, v%rali_soa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alf_am')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alf_am, kind=int64), ubound(v%alf_am, kind=int64))
      call put_stream_value(w, v%alf_am)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asy_am')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asy_am, kind=int64), ubound(v%asy_am, kind=int64))
      call put_stream_value(w, v%asy_am)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omg_am')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omg_am, kind=int64), ubound(v%omg_am, kind=int64))
      call put_stream_value(w, v%omg_am)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.rali_am')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rali_am, kind=int64), ubound(v%rali_am, kind=int64))
      call put_stream_value(w, v%rali_am)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfs_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%alfs_bc, kind=int64), ubound(v%alfs_bc, kind=int64))
      call put_stream_value(w, v%alfs_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asys_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%asys_bc, kind=int64), ubound(v%asys_bc, kind=int64))
      call put_stream_value(w, v%asys_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgs_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%omgs_bc, kind=int64), ubound(v%omgs_bc, kind=int64))
      call put_stream_value(w, v%omgs_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfs_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alfs_dd, kind=int64), ubound(v%alfs_dd, kind=int64))
      call put_stream_value(w, v%alfs_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asys_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asys_dd, kind=int64), ubound(v%asys_dd, kind=int64))
      call put_stream_value(w, v%asys_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgs_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omgs_dd, kind=int64), ubound(v%omgs_dd, kind=int64))
      call put_stream_value(w, v%omgs_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfs_fa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%alfs_fa, kind=int64), ubound(v%alfs_fa, kind=int64))
      call put_stream_value(w, v%alfs_fa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asys_fa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%asys_fa, kind=int64), ubound(v%asys_fa, kind=int64))
      call put_stream_value(w, v%asys_fa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgs_fa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%omgs_fa, kind=int64), ubound(v%omgs_fa, kind=int64))
      call put_stream_value(w, v%omgs_fa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfs_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alfs_om, kind=int64), ubound(v%alfs_om, kind=int64))
      call put_stream_value(w, v%alfs_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asys_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asys_om, kind=int64), ubound(v%asys_om, kind=int64))
      call put_stream_value(w, v%asys_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgs_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omgs_om, kind=int64), ubound(v%omgs_om, kind=int64))
      call put_stream_value(w, v%omgs_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfs_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%alfs_ss, kind=int64), ubound(v%alfs_ss, kind=int64))
      call put_stream_value(w, v%alfs_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asys_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%asys_ss, kind=int64), ubound(v%asys_ss, kind=int64))
      call put_stream_value(w, v%asys_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgs_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%omgs_ss, kind=int64), ubound(v%omgs_ss, kind=int64))
      call put_stream_value(w, v%omgs_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfs_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alfs_su, kind=int64), ubound(v%alfs_su, kind=int64))
      call put_stream_value(w, v%alfs_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asys_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asys_su, kind=int64), ubound(v%asys_su, kind=int64))
      call put_stream_value(w, v%asys_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgs_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omgs_su, kind=int64), ubound(v%omgs_su, kind=int64))
      call put_stream_value(w, v%omgs_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfl_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%alfl_bc, kind=int64), ubound(v%alfl_bc, kind=int64))
      call put_stream_value(w, v%alfl_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asyl_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%asyl_bc, kind=int64), ubound(v%asyl_bc, kind=int64))
      call put_stream_value(w, v%asyl_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgl_bc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%omgl_bc, kind=int64), ubound(v%omgl_bc, kind=int64))
      call put_stream_value(w, v%omgl_bc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfl_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alfl_dd, kind=int64), ubound(v%alfl_dd, kind=int64))
      call put_stream_value(w, v%alfl_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asyl_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asyl_dd, kind=int64), ubound(v%asyl_dd, kind=int64))
      call put_stream_value(w, v%asyl_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgl_dd')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omgl_dd, kind=int64), ubound(v%omgl_dd, kind=int64))
      call put_stream_value(w, v%omgl_dd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfl_fa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%alfl_fa, kind=int64), ubound(v%alfl_fa, kind=int64))
      call put_stream_value(w, v%alfl_fa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asyl_fa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%asyl_fa, kind=int64), ubound(v%asyl_fa, kind=int64))
      call put_stream_value(w, v%asyl_fa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgl_fa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%omgl_fa, kind=int64), ubound(v%omgl_fa, kind=int64))
      call put_stream_value(w, v%omgl_fa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfl_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alfl_om, kind=int64), ubound(v%alfl_om, kind=int64))
      call put_stream_value(w, v%alfl_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asyl_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asyl_om, kind=int64), ubound(v%asyl_om, kind=int64))
      call put_stream_value(w, v%asyl_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgl_om')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omgl_om, kind=int64), ubound(v%omgl_om, kind=int64))
      call put_stream_value(w, v%omgl_om)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfl_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%alfl_ss, kind=int64), ubound(v%alfl_ss, kind=int64))
      call put_stream_value(w, v%alfl_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asyl_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%asyl_ss, kind=int64), ubound(v%asyl_ss, kind=int64))
      call put_stream_value(w, v%asyl_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgl_ss')
      call put_stream_metadata(w, 2_int32, 8_int32, 3_int32, 1_int32, lbound(v%omgl_ss, kind=int64), ubound(v%omgl_ss, kind=int64))
      call put_stream_value(w, v%omgl_ss)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.alfl_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%alfl_su, kind=int64), ubound(v%alfl_su, kind=int64))
      call put_stream_value(w, v%alfl_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.asyl_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%asyl_su, kind=int64), ubound(v%asyl_su, kind=int64))
      call put_stream_value(w, v%asyl_su)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_aerosol_optical_parameters.aerosol_optical.omgl_su')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%omgl_su, kind=int64), ubound(v%omgl_su, kind=int64))
      call put_stream_value(w, v%omgl_su)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_184

  subroutine write_section_185(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%scalars)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'owned_radiation_scalar_fields.scalars')
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.nuaer')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nuaer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.ntraer')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ntraer)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.r10e')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%r10e)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.replog')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%replog)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.repsc')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repsc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.repsca')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repsca)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.repsco')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repsco)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.repscq')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repscq)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.repsct')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repsct)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.repscw')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%repscw)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.diff')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%diff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.naeradjdu')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naeradjdu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.rdumulf')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rdumulf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.rwghtdu')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rwghtdu, kind=int64), ubound(v%rwghtdu, kind=int64))
      call put_stream_value(w, v%rwghtdu)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.rch4a')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rch4a)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.rch4b')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rch4b)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.rcn2oa')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcn2oa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.rcn2ob')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rcn2ob)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.lvolcdata')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lvolcdata)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.clistso4')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%clistso4), int64))
      call put_stream_value(w, v%clistso4)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.cvolcdata')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cvolcdata), int64))
      call put_stream_value(w, v%cvolcdata)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation.nslwiden')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%input_interpolation%nslwiden)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation.nslwides')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%input_interpolation%nslwides)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation.nslwidew')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%input_interpolation%nslwidew)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation.nslwidee')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%input_interpolation%nslwidee)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation.lslondem')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%input_interpolation%lslondem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.input_interpolation.naslb1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%input_interpolation%naslb1)
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation')
      call put_stream_metadata(w, 5_int32, 0_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation.nslwiden')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%output_interpolation%nslwiden)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation.nslwides')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%output_interpolation%nslwides)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation.nslwidew')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%output_interpolation%nslwidew)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation.nslwidee')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%output_interpolation%nslwidee)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation.lslondem')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%output_interpolation%lslondem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.output_interpolation.naslb1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%output_interpolation%naslb1)
      if (w%status /= 0_int32) return
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'owned_radiation_scalar_fields.scalars.ngptotmx')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptotmx)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_185

  subroutine write_section_186(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%cloud_optical_550)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_cloud_optical_550_parameters.cloud_optical_550')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_cloud_optical_550_parameters.cloud_optical_550.rsa55')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsa55)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_cloud_optical_550_parameters.cloud_optical_550.rsb55')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsb55)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_cloud_optical_550_parameters.cloud_optical_550.rsc55')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsc55)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_cloud_optical_550_parameters.cloud_optical_550.rsd55')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rsd55)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_cloud_optical_550_parameters.cloud_optical_550.rfa55')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rfa55, kind=int64), ubound(v%rfa55, kind=int64))
      call put_stream_value(w, v%rfa55)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_186

  subroutine write_section_187(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave_transmission)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_transmission')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_transmission.trans')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%trans, kind=int64), ubound(v%trans, kind=int64))
      call put_stream_value(w, v%trans)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_transmission.bpade')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%bpade)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_transmission.rodlow')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rodlow)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_transmission.rtblint')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%rtblint)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_187

  subroutine write_section_188(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave_auxiliary_aerosol)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_aerosol')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_aerosol.rsrtaua')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rsrtaua, kind=int64), ubound(v%rsrtaua, kind=int64))
      call put_stream_value(w, v%rsrtaua)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_aerosol.rsrpiza')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rsrpiza, kind=int64), ubound(v%rsrpiza, kind=int64))
      call put_stream_value(w, v%rsrpiza)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_aerosol.rsrasya')
      call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%rsrasya, kind=int64), ubound(v%rsrasya, kind=int64))
      call put_stream_value(w, v%rsrasya)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_188

  subroutine write_section_189(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%setup%shortwave_auxiliary_cloud)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud')
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsyfwa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsyfwa, kind=int64), ubound(v%rsyfwa, kind=int64))
      call put_stream_value(w, v%rsyfwa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsyfwb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsyfwb, kind=int64), ubound(v%rsyfwb, kind=int64))
      call put_stream_value(w, v%rsyfwb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsyfwc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsyfwc, kind=int64), ubound(v%rsyfwc, kind=int64))
      call put_stream_value(w, v%rsyfwc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsyfwd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsyfwd, kind=int64), ubound(v%rsyfwd, kind=int64))
      call put_stream_value(w, v%rsyfwd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsyfwe')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsyfwe, kind=int64), ubound(v%rsyfwe, kind=int64))
      call put_stream_value(w, v%rsyfwe)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsyfwf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsyfwf, kind=int64), ubound(v%rsyfwf, kind=int64))
      call put_stream_value(w, v%rsyfwf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsecia')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsecia, kind=int64), ubound(v%rsecia, kind=int64))
      call put_stream_value(w, v%rsecia)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsecib')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsecib, kind=int64), ubound(v%rsecib, kind=int64))
      call put_stream_value(w, v%rsecib)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsecic')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsecic, kind=int64), ubound(v%rsecic, kind=int64))
      call put_stream_value(w, v%rsecic)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsecid')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsecid, kind=int64), ubound(v%rsecid, kind=int64))
      call put_stream_value(w, v%rsecid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsecie')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsecie, kind=int64), ubound(v%rsecie, kind=int64))
      call put_stream_value(w, v%rsecie)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsecif')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsecif, kind=int64), ubound(v%rsecif, kind=int64))
      call put_stream_value(w, v%rsecif)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsaswa')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsaswa, kind=int64), ubound(v%rsaswa, kind=int64))
      call put_stream_value(w, v%rsaswa)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsaswb')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsaswb, kind=int64), ubound(v%rsaswb, kind=int64))
      call put_stream_value(w, v%rsaswb)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsaswc')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsaswc, kind=int64), ubound(v%rsaswc, kind=int64))
      call put_stream_value(w, v%rsaswc)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsaswd')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsaswd, kind=int64), ubound(v%rsaswd, kind=int64))
      call put_stream_value(w, v%rsaswd)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsaswe')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsaswe, kind=int64), ubound(v%rsaswe, kind=int64))
      call put_stream_value(w, v%rsaswe)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsaswf')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsaswf, kind=int64), ubound(v%rsaswf, kind=int64))
      call put_stream_value(w, v%rsaswf)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfua0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfua0, kind=int64), ubound(v%rsfua0, kind=int64))
      call put_stream_value(w, v%rsfua0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfua1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfua1, kind=int64), ubound(v%rsfua1, kind=int64))
      call put_stream_value(w, v%rsfua1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfub0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfub0, kind=int64), ubound(v%rsfub0, kind=int64))
      call put_stream_value(w, v%rsfub0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfub1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfub1, kind=int64), ubound(v%rsfub1, kind=int64))
      call put_stream_value(w, v%rsfub1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfub2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfub2, kind=int64), ubound(v%rsfub2, kind=int64))
      call put_stream_value(w, v%rsfub2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfub3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfub3, kind=int64), ubound(v%rsfub3, kind=int64))
      call put_stream_value(w, v%rsfub3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfuc0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfuc0, kind=int64), ubound(v%rsfuc0, kind=int64))
      call put_stream_value(w, v%rsfuc0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfuc1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfuc1, kind=int64), ubound(v%rsfuc1, kind=int64))
      call put_stream_value(w, v%rsfuc1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfuc2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfuc2, kind=int64), ubound(v%rsfuc2, kind=int64))
      call put_stream_value(w, v%rsfuc2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfuc3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfuc3, kind=int64), ubound(v%rsfuc3, kind=int64))
      call put_stream_value(w, v%rsfuc3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfla0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfla0, kind=int64), ubound(v%rsfla0, kind=int64))
      call put_stream_value(w, v%rsfla0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfla1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfla1, kind=int64), ubound(v%rsfla1, kind=int64))
      call put_stream_value(w, v%rsfla1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflb0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflb0, kind=int64), ubound(v%rsflb0, kind=int64))
      call put_stream_value(w, v%rsflb0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflb1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflb1, kind=int64), ubound(v%rsflb1, kind=int64))
      call put_stream_value(w, v%rsflb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflb2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflb2, kind=int64), ubound(v%rsflb2, kind=int64))
      call put_stream_value(w, v%rsflb2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflb3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflb3, kind=int64), ubound(v%rsflb3, kind=int64))
      call put_stream_value(w, v%rsflb3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflc0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflc0, kind=int64), ubound(v%rsflc0, kind=int64))
      call put_stream_value(w, v%rsflc0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflc1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflc1, kind=int64), ubound(v%rsflc1, kind=int64))
      call put_stream_value(w, v%rsflc1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflc2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflc2, kind=int64), ubound(v%rsflc2, kind=int64))
      call put_stream_value(w, v%rsflc2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsflc3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsflc3, kind=int64), ubound(v%rsflc3, kind=int64))
      call put_stream_value(w, v%rsflc3)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfld0')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfld0, kind=int64), ubound(v%rsfld0, kind=int64))
      call put_stream_value(w, v%rsfld0)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfld1')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfld1, kind=int64), ubound(v%rsfld1, kind=int64))
      call put_stream_value(w, v%rsfld1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfld2')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfld2, kind=int64), ubound(v%rsfld2, kind=int64))
      call put_stream_value(w, v%rsfld2)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'md2asm_owned_shortwave_auxiliary_namespace.shortwave_auxiliary_cloud.rsfld3')
      call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsfld3, kind=int64), ubound(v%rsfld3, kind=int64))
      call put_stream_value(w, v%rsfld3)
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_189

  subroutine write_section_190(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%ri)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'native_live_owners.RI')
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.cver')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cver), int64))
      call put_stream_value(w, v%cver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslgroup')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslgroup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslsta')
      if (allocated(v%nslsta)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsta, kind=int64), ubound(v%nslsta, kind=int64))
        call put_stream_value(w, v%nslsta)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslonl')
      if (allocated(v%nslonl)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslonl, kind=int64), ubound(v%nslonl, kind=int64))
        call put_stream_value(w, v%nslonl)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nsloff')
      if (allocated(v%nsloff)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nsloff, kind=int64), ubound(v%nsloff, kind=int64))
        call put_stream_value(w, v%nsloff)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslptswest')
      if (allocated(v%nslptswest)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptswest, kind=int64), ubound(v%nslptswest, kind=int64))
        call put_stream_value(w, v%nslptswest)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslptseast')
      if (allocated(v%nslptseast)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptseast, kind=int64), ubound(v%nslptseast, kind=int64))
        call put_stream_value(w, v%nslptseast)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslext')
      if (allocated(v%nslext)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslext, kind=int64), ubound(v%nslext, kind=int64))
        call put_stream_value(w, v%nslext)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.lcomplat')
      if (allocated(v%lcomplat)) then
     call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lcomplat, kind=int64), ubound(v%lcomplat, kind=int64))
        call put_stream_value(w, v%lcomplat)
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nlatglo')
      if (allocated(v%nlatglo)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nlatglo, kind=int64), ubound(v%nlatglo, kind=int64))
        call put_stream_value(w, v%nlatglo)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.dist1gp')
      if (allocated(v%dist1gp)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%dist1gp, kind=int64), ubound(v%dist1gp, kind=int64))
        call put_stream_value(w, v%dist1gp)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslsendpos')
      if (allocated(v%nslsendpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendpos, kind=int64), ubound(v%nslsendpos, kind=int64))
        call put_stream_value(w, v%nslsendpos)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslrecvpos')
      if (allocated(v%nslrecvpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvpos, kind=int64), ubound(v%nslrecvpos, kind=int64))
        call put_stream_value(w, v%nslrecvpos)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslsendptr')
      if (allocated(v%nslsendptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendptr, kind=int64), ubound(v%nslsendptr, kind=int64))
        call put_stream_value(w, v%nslsendptr)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslrecvptr')
      if (allocated(v%nslrecvptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvptr, kind=int64), ubound(v%nslrecvptr, kind=int64))
        call put_stream_value(w, v%nslrecvptr)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslcomm')
      if (allocated(v%nslcomm)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcomm, kind=int64), ubound(v%nslcomm, kind=int64))
        call put_stream_value(w, v%nslcomm)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.lslcomm')
      if (allocated(v%lslcomm)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 1_int32, lbound(v%lslcomm, kind=int64), ubound(v%lslcomm, kind=int64))
        call put_stream_value(w, v%lslcomm)
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.naslb1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.naslb1_true')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1_true)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslpad')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslpad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.lslt_arrays_init')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslt_arrays_init)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.lslondem')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.lslondem_active')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem_active)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nunusedhalo')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.distunusedhalo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%distunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.mask_sl1')
      if (allocated(v%mask_sl1)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl1, kind=int64), ubound(v%mask_sl1, kind=int64))
        call put_stream_value(w, v%mask_sl1)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.mask_sl2')
      if (allocated(v%mask_sl2)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl2, kind=int64), ubound(v%mask_sl2, kind=int64))
        call put_stream_value(w, v%mask_sl2)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.mask_sl2t')
      if (allocated(v%mask_sl2t)) then
   call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%mask_sl2t, kind=int64), ubound(v%mask_sl2t, kind=int64))
        call put_stream_value(w, v%mask_sl2t)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.mask_sld')
      if (allocated(v%mask_sld)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sld, kind=int64), ubound(v%mask_sld, kind=int64))
        call put_stream_value(w, v%mask_sld)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslprocs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslprocs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslrpt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslrpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslspt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslspt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslwiden')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwiden)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslwides')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwides)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslwidee')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidee)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslwidew')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidew)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslwide')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwide)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslmap')
      if (allocated(v%nslmap)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslmap, kind=int64), ubound(v%nslmap, kind=int64))
        call put_stream_value(w, v%nslmap)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nslcore')
      if (allocated(v%nslcore)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcore, kind=int64), ubound(v%nslcore, kind=int64))
        call put_stream_value(w, v%nslcore)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.lslcore')
      if (allocated(v%lslcore)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lslcore, kind=int64), ubound(v%lslcore, kind=int64))
        call put_stream_value(w, v%lslcore)
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.mask_sltot')
      if (allocated(v%mask_sltot)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sltot, kind=int64), ubound(v%mask_sltot, kind=int64))
        call put_stream_value(w, v%mask_sltot)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndglg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndglg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndlon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgsag')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsag)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgeng')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgeng)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgsal')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgenl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgsah')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsah)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgenh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndguxl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndlung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndluxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndluxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndguxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndsur1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndsur1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndlsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.ndgsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nptrfloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nptrfloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nfrstloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfrstloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.myfrstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%myfrstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.mylstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mylstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RI.nloeng')
      if (allocated(v%nloeng)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nloeng, kind=int64), ubound(v%nloeng, kind=int64))
        call put_stream_value(w, v%nloeng)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_190

  subroutine write_section_191(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%ro)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'native_live_owners.RO')
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.cver')
      call put_stream_metadata(w, 4_int32, 1_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, int(len(v%cver), int64))
      call put_stream_value(w, v%cver)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslgroup')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslgroup)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslsta')
      if (allocated(v%nslsta)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsta, kind=int64), ubound(v%nslsta, kind=int64))
        call put_stream_value(w, v%nslsta)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslonl')
      if (allocated(v%nslonl)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslonl, kind=int64), ubound(v%nslonl, kind=int64))
        call put_stream_value(w, v%nslonl)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nsloff')
      if (allocated(v%nsloff)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nsloff, kind=int64), ubound(v%nsloff, kind=int64))
        call put_stream_value(w, v%nsloff)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslptswest')
      if (allocated(v%nslptswest)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptswest, kind=int64), ubound(v%nslptswest, kind=int64))
        call put_stream_value(w, v%nslptswest)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslptseast')
      if (allocated(v%nslptseast)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslptseast, kind=int64), ubound(v%nslptseast, kind=int64))
        call put_stream_value(w, v%nslptseast)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslext')
      if (allocated(v%nslext)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslext, kind=int64), ubound(v%nslext, kind=int64))
        call put_stream_value(w, v%nslext)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.lcomplat')
      if (allocated(v%lcomplat)) then
     call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lcomplat, kind=int64), ubound(v%lcomplat, kind=int64))
        call put_stream_value(w, v%lcomplat)
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nlatglo')
      if (allocated(v%nlatglo)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nlatglo, kind=int64), ubound(v%nlatglo, kind=int64))
        call put_stream_value(w, v%nlatglo)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.dist1gp')
      if (allocated(v%dist1gp)) then
       call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%dist1gp, kind=int64), ubound(v%dist1gp, kind=int64))
        call put_stream_value(w, v%dist1gp)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslsendpos')
      if (allocated(v%nslsendpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendpos, kind=int64), ubound(v%nslsendpos, kind=int64))
        call put_stream_value(w, v%nslsendpos)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslrecvpos')
      if (allocated(v%nslrecvpos)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvpos, kind=int64), ubound(v%nslrecvpos, kind=int64))
        call put_stream_value(w, v%nslrecvpos)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslsendptr')
      if (allocated(v%nslsendptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslsendptr, kind=int64), ubound(v%nslsendptr, kind=int64))
        call put_stream_value(w, v%nslsendptr)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslrecvptr')
      if (allocated(v%nslrecvptr)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslrecvptr, kind=int64), ubound(v%nslrecvptr, kind=int64))
        call put_stream_value(w, v%nslrecvptr)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslcomm')
      if (allocated(v%nslcomm)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcomm, kind=int64), ubound(v%nslcomm, kind=int64))
        call put_stream_value(w, v%nslcomm)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.lslcomm')
      if (allocated(v%lslcomm)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 1_int32, lbound(v%lslcomm, kind=int64), ubound(v%lslcomm, kind=int64))
        call put_stream_value(w, v%lslcomm)
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.naslb1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.naslb1_true')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%naslb1_true)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslpad')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslpad)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.lslt_arrays_init')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslt_arrays_init)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.lslondem')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.lslondem_active')
      call put_stream_metadata(w, 3_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%lslondem_active)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nunusedhalo')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.distunusedhalo')
      call put_stream_metadata(w, 2_int32, 8_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%distunusedhalo)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.mask_sl1')
      if (allocated(v%mask_sl1)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl1, kind=int64), ubound(v%mask_sl1, kind=int64))
        call put_stream_value(w, v%mask_sl1)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.mask_sl2')
      if (allocated(v%mask_sl2)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sl2, kind=int64), ubound(v%mask_sl2, kind=int64))
        call put_stream_value(w, v%mask_sl2)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.mask_sl2t')
      if (allocated(v%mask_sl2t)) then
   call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%mask_sl2t, kind=int64), ubound(v%mask_sl2t, kind=int64))
        call put_stream_value(w, v%mask_sl2t)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.mask_sld')
      if (allocated(v%mask_sld)) then
     call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sld, kind=int64), ubound(v%mask_sld, kind=int64))
        call put_stream_value(w, v%mask_sld)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslprocs')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslprocs)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslrpt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslrpt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslspt')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslspt)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslwiden')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwiden)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslwides')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwides)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslwidee')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidee)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslwidew')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwidew)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslwide')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nslwide)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslmap')
      if (allocated(v%nslmap)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 1_int32, lbound(v%nslmap, kind=int64), ubound(v%nslmap, kind=int64))
        call put_stream_value(w, v%nslmap)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nslcore')
      if (allocated(v%nslcore)) then
       call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nslcore, kind=int64), ubound(v%nslcore, kind=int64))
        call put_stream_value(w, v%nslcore)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.lslcore')
      if (allocated(v%lslcore)) then
       call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 1_int32, lbound(v%lslcore, kind=int64), ubound(v%lslcore, kind=int64))
        call put_stream_value(w, v%lslcore)
      else
        call put_stream_metadata(w, 3_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.mask_sltot')
      if (allocated(v%mask_sltot)) then
 call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%mask_sltot, kind=int64), ubound(v%mask_sltot, kind=int64))
        call put_stream_value(w, v%mask_sltot)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndglg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndglg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndlon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgsag')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsag)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgeng')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgeng)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgsal')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgenl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgsah')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsah)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgenh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndguxl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndlung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndluxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndluxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgung')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgung)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndguxg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndguxg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndsur1')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndsur1)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndlsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.ndgsur')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsur)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nptrfloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nptrfloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nfrstloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfrstloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.myfrstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%myfrstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.mylstactlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mylstactlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RO.nloeng')
      if (allocated(v%nloeng)) then
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 1_int32, lbound(v%nloeng, kind=int64), ubound(v%nloeng, kind=int64))
        call put_stream_value(w, v%nloeng)
      else
        call put_stream_metadata(w, 1_int32, 4_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_191

  subroutine write_section_192(w)
    type(native_radiation_stream_writer), intent(inout) :: w
integer::j0_1,j0_2,j0_3,j0_4,j0_5,j0_6,j0_7,j1_1,j1_2,j1_3,j1_4,j1_5,j1_6,j1_7,j2_1,j2_2,j2_3,j2_4,j2_5,j2_6,j2_7,j3_1,j3_2,j3_3,j3_4,j3_5,j3_6,j3_7,j4_1,j4_2,j4_3,j4_4,j4_5,j4_6,j4_7,j5_1,j5_2,j5_3,j5_4,j5_5,j5_6,j5_7,j6_1,j6_2,j6_3,j6_4,j6_5,j6_6,j6_7,j7_1,j7_2,j7_3,j7_4,j7_5,j7_6,j7_7,j8_1,j8_2,j8_3,j8_4,j8_5,j8_6,j8_7,j9_1,j9_2,j9_3,j9_4,j9_5,j9_6,j9_7,j10_1,j10_2,j10_3,j10_4,j10_5,j10_6,j10_7,j11_1,j11_2,j11_3,j11_4,j11_5,j11_6,j11_7
    associate (v => context%grid)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 1_int32, 'native_live_owners.RADGRID')
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndglg')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndglg)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndlon')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlon)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.nsmax')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nsmax)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ngptot')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ngptot)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.nfrstloff')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%nfrstloff)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndgsl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndgsah')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsah)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndgenh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndgsal')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgsal)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndgenl')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndgenl)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndlonh')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlonh)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ndlonm')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%ndlonm)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.myfrstlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%myfrstlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.mylstlat')
      call put_stream_metadata(w, 1_int32, 4_int32, 0_int32, 1_int32, [integer(int64) ::], [integer(int64) ::])
      call put_stream_value(w, v%mylstlat)
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.rmu')
      if (allocated(v%rmu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rmu, kind=int64), ubound(v%rmu, kind=int64))
        call put_stream_value(w, v%rmu)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.rsqm2')
      if (allocated(v%rsqm2)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rsqm2, kind=int64), ubound(v%rsqm2, kind=int64))
        call put_stream_value(w, v%rsqm2)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.rlatig')
      if (allocated(v%rlatig)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlatig, kind=int64), ubound(v%rlatig, kind=int64))
        call put_stream_value(w, v%rlatig)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.rlati')
      if (allocated(v%rlati)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%rlati, kind=int64), ubound(v%rlati, kind=int64))
        call put_stream_value(w, v%rlati)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.ripi')
      if (allocated(v%ripi)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 1_int32, lbound(v%ripi, kind=int64), ubound(v%ripi, kind=int64))
        call put_stream_value(w, v%ripi)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 2_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.gelam')
      if (allocated(v%gelam)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%gelam, kind=int64), ubound(v%gelam, kind=int64))
        call put_stream_value(w, v%gelam)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.gelat')
      if (allocated(v%gelat)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%gelat, kind=int64), ubound(v%gelat, kind=int64))
        call put_stream_value(w, v%gelat)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.geslo')
      if (allocated(v%geslo)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%geslo, kind=int64), ubound(v%geslo, kind=int64))
        call put_stream_value(w, v%geslo)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.geclo')
      if (allocated(v%geclo)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%geclo, kind=int64), ubound(v%geclo, kind=int64))
        call put_stream_value(w, v%geclo)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
      call put_stream_tag(w, 2_int32, 'native_live_owners.RADGRID.gemu')
      if (allocated(v%gemu)) then
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 1_int32, lbound(v%gemu, kind=int64), ubound(v%gemu, kind=int64))
        call put_stream_value(w, v%gemu)
      else
        call put_stream_metadata(w, 2_int32, 8_int32, 1_int32, 0_int32, [integer(int64) ::], [integer(int64) ::])
      end if
      if (w%status /= 0_int32) return
    end associate
  end subroutine write_section_192
  end function write_radiation_setup_stream
end module forecast_radiation_setup_stream
