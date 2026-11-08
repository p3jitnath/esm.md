!> Complete native SURFRAD_LAYER wind, calendar, ice and radiation sequence.
!! P is KLON, L is KLEV; winds use m/s, temperature K and albedo is dimensionless.
!! Inputs borrow live canonical owners. Only selected output cells change.
module forecast_complete_surface_radiation_layer
  use iso_fortran_env, only: int32, int64, real64
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use forecast_physics_work_types, only: dimension_type, aux_type, state_type, keys_local_type, &
                                         aux_diag_local_type, surf_and_more_type, surf_and_more_local_type
  use forecast_surface_catalog_lookup, only: surface_catalog_index
  use forecast_layer_private_surface_radiation, only: surfrad
  use forecast_calendar_and_monthly_fields, only: update_calendar
  implicit none
  private
  public :: surfrad_layer, md2asm_surfrad_layer
  interface md2asm_surfrad_layer
    module procedure surfrad_layer
  end interface
contains
  logical function surface_inputs_ready(inputs, d) result(ready)
    type(native_complete_physics_driver_inputs), intent(in) :: inputs
    type(dimension_type), intent(in) :: d
    ready = .false.
    if (.not. associated(inputs%physics)) return
    if (.not. associated(inputs%physics%surface)) return
    if (.not. associated(inputs%records%surface_metadata)) return
    if (.not. associated(inputs%records%model)) return
    if (.not. inputs%records%surface_metadata%ready) return
    if (d%klon < 1 .or. d%klon > 4096 .or. d%klev < 1 .or. d%klev > 512) return
    if (d%ktiles /= 9 .and. d%ktiles /= 10) return
    if (d%kidia < 1 .or. d%kidia > d%klon + 1 .or. d%kfdia < 0 .or. d%kfdia > d%klon) return
    ready = .true.
  end function surface_inputs_ready
  !> Copy only the consumed PALBICE branch of ICESTATENEMO.
 !! SOURCE is the actual global ocean albedo vector, without conversion or a copy.
 !! Its first element is source global index1. Both precisions are real64.
 !! Empty/disabled branches read no payload. Metadata is admitted by the parent.
  subroutine copy_actual_coupled_ice_albedo(source, global_start, first, last, output)
    real(real64), intent(in) :: source(:)
    integer(int32), intent(in) :: global_start, first, last
    real(real64), intent(inout) :: output(:)
    integer :: j
    integer(int64) :: global_index
    do j = first, last
      global_index = int(global_start, int64) - 1_int64 + int(j, int64)
      output(j) = source(global_index)
    end do
  end subroutine copy_actual_coupled_ice_albedo
  subroutine surfrad_layer(inputs, d, aux, tmp, keys, auxl, surface, surfl, status, coupled_ice_albedo)
    type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    type(dimension_type), intent(in) :: d
    type(aux_type), intent(in) :: aux
    type(state_type), intent(in) :: tmp
    type(keys_local_type), intent(in) :: keys
    type(aux_diag_local_type), intent(inout) :: auxl
    type(surf_and_more_type), intent(inout) :: surface
    type(surf_and_more_local_type), intent(inout) :: surfl
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: coupled_ice_albedo(:)
    integer(int32)::i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,idd,imm,iyy,ilmon(12),isec,idincr,initial,year,month,day,seconds,jl,nsw,nlwemiss
    real(real64) :: zalbice(max(1, min(d%klon, 4096))), wind(max(1, min(d%klon, 4096)))
    real(real64), volatile :: wind_u, wind_v
    integer(int64) :: clock_bits, absolute_clock, elapsed_seconds, global_first, global_last
    logical :: coupled
    logical :: lnemolimalb
    status = 2_int32
    if (.not. surface_inputs_ready(inputs, d)) return
    if (.not. associated(aux%pmu0m)) return
    if (.not. associated(auxl%zccnl)) return
    if (.not. associated(auxl%zccno)) return
    if (.not. associated(auxl%zwnd)) return
    if (.not. associated(keys%llnh)) return
    if (.not. associated(surface%isoty)) return
    if (.not. associated(surface%pemis)) return
    if (.not. associated(surface%psd_vd)) return
    if (.not. associated(surface%psd_vf)) return
    if (.not. associated(surface%psp_rr)) return
    if (.not. associated(surface%psp_sb)) return
    if (.not. associated(surface%psp_sg)) return
    if (.not. associated(surface%psp_sl)) return
    if (.not. associated(surfl%zalbd)) return
    if (.not. associated(surfl%zalbp)) return
    if (.not. associated(surfl%zalbti)) return
    if (.not. associated(surfl%zfrti)) return
    if (.not. associated(surfl%zspectralemiss)) return
    if (.not. associated(tmp%u)) return
    if (.not. associated(tmp%v)) return
    i1 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YALBF', 1_int32)
    if (i1 < 1 .or. i1 > size(surface%psd_vf, 2)) return
    i2 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YTVH', 1_int32)
    if (i2 < 1 .or. i2 > size(surface%psd_vf, 2)) return
    i3 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCUR', 1_int32)
    if (i3 < 1 .or. i3 > size(surface%psd_vf, 2)) return
    i4 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VF%YCVH', 1_int32)
    if (i4 < 1 .or. i4 > size(surface%psd_vf, 2)) return
    i5 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SG%YA', 3_int32)
    if (i5 < 1 .or. i5 > size(surface%psp_sg, 3)) return
    i6 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_RR%YT', 3_int32)
    if (i6 < 1 .or. i6 > size(surface%psp_rr, 2)) return
    i7 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SB%YQ', 3_int32)
    if (i7 < 1 .or. i7 > size(surface%psp_sb, 3)) return
    i8 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICD', 3_int32)
    if (i8 < 1 .or. i8 > size(surface%psp_sl, 2)) return
    i9 = surface_catalog_index(inputs%records%surface_metadata, 'YSP_SL%YLICT', 3_int32)
    if (i9 < 1 .or. i9 > size(surface%psp_sl, 2)) return
    i10 = surface_catalog_index(inputs%records%surface_metadata, 'YSD_VD%YALB', 1_int32)
    if (i10 < 1 .or. i10 > size(surface%psd_vd, 2)) return
    if (.not. associated(inputs%providers)) return
    if (.not. associated(inputs%providers%physical)) return
    if (.not. associated(inputs%solar_clock%initial_date)) return
    if (.not. associated(inputs%solar_clock%initial_seconds)) return
    if (.not. associated(inputs%solar_clock%rstati)) return
    lnemolimalb = inputs%records%model%climate%lnemolimalb
    coupled = inputs%records%model%climate%lnemocoup
    if (lnemolimalb .and. coupled) then
      if (.not. present(coupled_ice_albedo)) return
      global_first = int(d%kstglo, int64) - 1_int64 + int(d%kidia, int64)
      global_last = int(d%kstglo, int64) - 1_int64 + int(d%kfdia, int64)
      if (global_first < 1_int64 .or. global_last > size(coupled_ice_albedo, kind=int64)) return
    end if
    nsw = inputs%physics%radiation%radiation%nsw
    nlwemiss = inputs%physics%radiation%radiation%nlwemiss
    if (nsw < 1 .or. nlwemiss < 1) return
    if (size(tmp%u, 1) < d%klon .or. size(tmp%u, 2) < d%klev) return
    if (size(tmp%v, 1) < d%klon .or. size(tmp%v, 2) < d%klev) return
    if (size(auxl%zwnd) < d%klon) return
    if (size(surfl%zalbd, 2) < nsw .or. size(surfl%zalbp, 2) < nsw) return
    if (size(surfl%zspectralemiss, 2) < nlwemiss) return
    if (inputs%records%surface_metadata%albedo_first < 1) return
    if (inputs%records%surface_metadata%albedo_last > size(surface%psd_vf, 2)) return
    do jl = d%kidia, d%kfdia
      wind_u = tmp%u(jl, d%klev); wind_u = wind_u*wind_u
      wind_v = tmp%v(jl, d%klev); wind_v = wind_v*wind_v
      wind_u = wind_u + wind_v; wind(jl) = sqrt(wind_u)
    end do
    initial = inputs%solar_clock%initial_date
    day = mod(initial, 100)
    month = mod((initial - day)/100, 100)
    year = initial/10000
    if (year < 1600 .or. year > 3000) return
    clock_bits = transfer(inputs%solar_clock%rstati, 0_int64)
    absolute_clock = iand(clock_bits, int(z'7fffffffffffffff', int64))
    if (btest(clock_bits, 63) .and. absolute_clock /= 0_int64) return
    if (absolute_clock > transfer(2147483647.0_real64, 0_int64)) return
    if (transfer(inputs%providers%physical%rday, 0_int64) /= transfer(86400.0_real64, 0_int64)) return
    if (inputs%solar_clock%initial_seconds < 0_int32) return
    elapsed_seconds = int(nint(inputs%solar_clock%rstati, int32), int64) + int(inputs%solar_clock%initial_seconds, int64)
    if (elapsed_seconds > int(huge(0_int32), int64)) return
    seconds = int(elapsed_seconds, int32)
    idincr = seconds/nint(inputs%providers%physical%rday, int32)
    isec = mod(seconds, nint(inputs%providers%physical%rday, int32))
    call update_calendar(day, month, year, idincr, idd, imm, iyy, ilmon, status)
    if (status /= 0_int32) return
    do jl = d%kidia, d%kfdia
      zalbice(jl) = 0.0_real64
    end do
    if (lnemolimalb .and. coupled) then
      call copy_actual_coupled_ice_albedo(coupled_ice_albedo, d%kstglo, d%kidia, d%kfdia, zalbice)
    end if
    call surfrad( &
      ydsurf=inputs%physics%surface, &
      kdd=idd, &
      kmm=imm, &
      kmon=ilmon, &
      kseco=isec, &
      kidia=d%kidia, &
      kfdia=d%kfdia, &
      klon=d%klon, &
      ktiles=d%ktiles, &
      ksw=nsw, &
      klw=nlwemiss, &
      ldnh=keys%llnh, &
      palbf=surface%psd_vf(:, i1), &
      palbicef=zalbice, &
      ptvh=surface%psd_vf(:, i2), &
      palcoeff=surface%psd_vf(:, inputs%records%surface_metadata%albedo_first:inputs%records%surface_metadata%albedo_last), &
      pcurc=surface%psd_vf(:, i3), &
      pcvh=surface%psd_vf(:, i4), &
      pasn=surface%psp_sg(:, 1, i5), &
      pmu0=aux%pmu0m, &
      pts=surface%psp_rr(:, i6), &
      pwnd=wind, &
      pws1=surface%psp_sb(:, 1, i7), &
      ksoty=surface%isoty, &
      pfrti=surfl%zfrti, &
      phlice=surface%psp_sl(:, i8), &
      ptlice=surface%psp_sl(:, i9), &
      palbd=surfl%zalbd(:, 1:nsw), &
      palbp=surfl%zalbp(:, 1:nsw), &
      palb=surface%psd_vd(:, i10), &
      pspectralemiss=surfl%zspectralemiss(:, 1:nlwemiss), &
      pemit=surface%pemis, &
      palbti=surfl%zalbti, &
      pccnl=auxl%zccnl, &
      pccno=auxl%zccno, &
      lnemolimalb=lnemolimalb, status=status)
    if (status /= 0_int32) return
    do jl = d%kidia, d%kfdia
      auxl%zwnd(jl) = wind(jl)
    end do
  end subroutine surfrad_layer
end module forecast_complete_surface_radiation_layer
