module operational_grid_field_component_definition_port
  !! Register the next selected atmospheric field without private layouts.
  !! The caller owns components(:), with capacity 9..2163. Only the next
  !! component and named counters change. Plans are read only and must not
  !! alias the output. Family 0 is water, 1 cloud fraction and 2 NOGW.
  !! Real attributes retain their source units and are copied without math.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use grid_field_component_types_port, only: field_component_metadata, grid_field_mode_supported
  use grid_field_registration_types_port, only: grid_field_registration_state, field_definition_plan
  implicit none
  private
  public :: define_operational_grid_field_component
contains
  integer(int32) function define_operational_grid_field_component(state, components, index, plan, family) result(status)
    type(grid_field_registration_state), intent(inout) :: state
    type(field_component_metadata), contiguous, intent(inout) :: components(:)
    integer(int32), intent(in) :: index, family
    type(field_definition_plan), intent(in) :: plan
    integer(int32) :: n, next_count, time_count, j
    status = 2_int32
    if (size(components) < 9 .or. size(components) > 2163) return
    if (family < 0 .or. family > 2) return
    if (.not. grid_field_mode_supported()) return
    n = state%numflds
    if (n < 0 .or. n > 8) return
    if (index /= n + 1) return
    if (n < 5) then
      if (family /= 0) return
    else if (n < 7) then
      if (family /= 1) return
    else
      if (family /= 2) return
    end if
    time_count = min(n, 7_int32)
    if (state%numgpflds /= n .or. state%ndim /= n .or. state%ndim0 /= n) return
    if (state%numflds1 /= time_count .or. state%ndim1 /= time_count) return
    if (state%nders /= 0 .or. state%numspflds /= 0 .or. state%numflds9 /= 0) return
    if (state%numspflds1 /= 0 .or. state%numflds5 /= 0 .or. state%numfldsphy /= 0) return
    if (state%numflds_spl /= 0 .or. state%numflds_sl1 /= 0 .or. state%numfldspc /= 0) return
    if (state%numfldspt /= 0 .or. state%ndim9 /= 0 .or. state%ndim5 /= 0) return
    if (state%ndimslp /= 0 .or. state%ndim_spl /= 0 .or. state%ndimpt /= 0 .or. state%ndimpc /= 0) return
    do j = 1, n
      if (components(j)%lgp /= 1 .or. components(j)%lcders /= 0 .or. components(j)%lt5 /= 0) return
      if (components(j)%mp /= j .or. components(j)%previous_index /= j - 1) return
    end do
    if (state%last_index /= n) return
    if (.not. flag(plan%lreqout)) return
    if (plan%nreqin < -1 .or. plan%nreqin > 1) return
    if (components(index)%ldiag /= 0) return
    if (family /= 2) then
      if (.not. flag(plan%lgpingp) .or. .not. flag(plan%lmgrid) .or. .not. flag(plan%ltrajio)) return
      if (.not. flag(plan%lmassfix) .or. .not. flag(plan%lcomad) .or. .not. flag(plan%lnegfix)) return
      if (family == 0) then
        if (.not. flag(plan%lthermact) .or. .not. flag(plan%lprecip)) return
      end if
    else
      if (plan%nreqin /= 0) return
    end if
    if (family /= 0) then
      if (components(index)%lthermact /= 0 .or. components(index)%lwater /= 0) return
    end if
    associate (c => components(index))
      c%lactive = 1
      c%cname = plan%cname
      c%igrbcode = plan%igrbcode
      c%nreqin = plan%nreqin
      c%refvali = plan%refvali
      if (family /= 2) c%ifid = plan%ifid
      c%lreqout = plan%lreqout
      c%lgp = 1; c%lsp = 0; c%lt5 = 0; c%lcders = 0
      c%lt1 = 0
      if (family /= 2) c%lt1 = 1
      if (family /= 2) then
        c%lgpingp = plan%lgpingp; c%lmgrid = plan%lmgrid; c%ltrajio = plan%ltrajio
      else
        c%lgpingp = 1; c%lmgrid = 0; c%ltrajio = 0
      end if
      if (family == 0) then
        c%lthermact = plan%lthermact
        if (plan%lthermact /= 0) then
          c%r = plan%r; c%rcp = plan%rcp
        end if
      end if
      c%ncouplo4 = -1; c%lassim = 0
      c%ldiff = 1; c%lconv = 1
      c%igribtc = -9999; c%igrbflxo = -9999; c%igrbwdflx = -9999; c%igrbddflx = -9999; c%igribdv = -9999
      c%rmolmass = -99999.9_real64; c%refold = -99999.9_real64
      c%henrya = -99999.9_real64; c%henryb = -99999.9_real64
      c%lcomad = 0; c%lmassfix = 0; c%weno_alpha = 0.0_real64; c%lnegfix = 0; c%betamfbc = 1.0_real64
      if (family /= 2) then
        c%betamfbc = plan%betamfbc; c%lmassfix = plan%lmassfix
        c%weno_alpha = plan%weno_alpha; c%lcomad = plan%lcomad; c%lnegfix = plan%lnegfix
      end if
      if (family == 0) then
        c%lwater = 1; c%lprecip = plan%lprecip; c%rlzer = plan%rlzer
        c%rcp = plan%rcp
      end if
      next_count = n + 1
      state%numflds = next_count; state%ndim = next_count
      state%ndim0 = next_count; state%numgpflds = next_count
      if (family /= 2) then
        time_count = time_count + 1; state%numflds1 = time_count; state%ndim1 = time_count
      end if
      c%mp5 = -99999; c%mp = next_count; c%mpl = -99999; c%mpm = -99999
      c%mp5l = -99999; c%mp5m = -99999; c%mpsp = -99999
      c%mp1 = -99999
      if (family /= 2) c%mp1 = time_count
      c%previous_index = state%last_index; state%last_index = index
    end associate
    status = 0_int32
  end function
  pure logical function flag(value) result(valid)
    integer(int32), intent(in) :: value
    valid = value >= 0 .and. value <= 1
  end function
end module operational_grid_field_component_definition_port
