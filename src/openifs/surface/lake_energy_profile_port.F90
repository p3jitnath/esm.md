module flakeene_mod
  use iso_fortran_env, only: int32,int64,real64
  use iso_c_binding, only: c_double,c_int64_t
  use ieee_arithmetic, only: ieee_round_type,ieee_get_rounding_mode,ieee_nearest,operator(/=)
  use ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use yos_flake, only: tflake
  implicit none
  private
  public :: flakeene,md2asm_flakeene_calls_get
  integer(c_int64_t), save :: native_calls=0_c_int64_t
  interface
    function selected_exponential(value) bind(c,name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_exponential
    function selected_power(value,power) bind(c,name="md2asm_pow_original_rounding_candidate") result(answer)
      import c_double
      real(c_double), value :: value,power
      real(c_double) :: answer
    end function selected_power
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Advance the lake column while retaining the frozen FP64 operation order.
  !!
  !! Arrays have KLON rows. KIDIA:KFDIA selects the active columns.
  !! Temperatures use kelvin, depths use metres, heat fluxes use W m^-2,
  !! radiation attenuation uses m^-1, and PDEL_TIME uses seconds.
  !! The seven state arrays are first copied across the complete owner.
  !! PQ_W_FLK and PT_SFC_N change only at active lake columns.
  !! The native TFLAKE type supplies coefficients without private byte offsets.
  subroutine flakeene(kidia,kfdia,klon,pdepth_w,par_coriolis,ldlakepoint,pextincoef_water_typ,ydflake, &
      pdel_time,pt_sfc_p,pt_ice_p_flk,pt_wml_p_flk,pt_mnw_p_flk,pt_bot_p_flk,ph_ice_p_flk,ph_ml_p_flk,pc_t_p_flk, &
      pq_w_flk,pq_ice_flk,pu_star_w_flk,pi_ice_flk,pi_bot_flk,pi_w_flk,pi_h_flk,pi_intm_0_h_flk,pi_intm_h_d_flk, &
      pt_ice_n_flk,pt_wml_n_flk,pt_mnw_n_flk,pt_bot_n_flk,ph_ice_n_flk,ph_ml_n_flk,pc_t_n_flk,pt_sfc_n)
    integer(int32), intent(in) :: kidia,kfdia,klon
    logical(int32), intent(in) :: ldlakepoint(:)
    type(tflake), intent(in) :: ydflake
    real(real64), intent(in) :: pextincoef_water_typ,pdel_time
    real(real64), intent(in) :: pdepth_w(:),par_coriolis(:),pt_sfc_p(:),pt_ice_p_flk(:),pt_wml_p_flk(:)
    real(real64), intent(in) :: pt_mnw_p_flk(:),pt_bot_p_flk(:),ph_ice_p_flk(:),ph_ml_p_flk(:),pc_t_p_flk(:)
    real(real64), intent(in) :: pq_ice_flk(:),pu_star_w_flk(:),pi_ice_flk(:),pi_bot_flk(:),pi_w_flk(:)
    real(real64), intent(in) :: pi_h_flk(:),pi_intm_0_h_flk(:),pi_intm_h_d_flk(:)
    real(real64), intent(inout) :: pq_w_flk(:),pt_ice_n_flk(:),pt_wml_n_flk(:),pt_mnw_n_flk(:),pt_bot_n_flk(:)
    real(real64), intent(inout) :: ph_ice_n_flk(:),ph_ml_n_flk(:),pc_t_n_flk(:),pt_sfc_n(:)
    integer(int32) :: column
    integer(int64) :: word,bound_word,ice_word,depth_word
    logical :: create_ice,melt_above,cold_ice,no_create
    real(real64) :: warm_threshold
    real(real64), volatile :: smallest,subnormal
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved_status
    real(real64), parameter :: zero=transfer(int(z'0000000000000000',int64),0.0_real64)
    real(real64), parameter :: one=transfer(int(z'3ff0000000000000',int64),0.0_real64)
    real(real64), parameter :: two=transfer(int(z'4000000000000000',int64),0.0_real64)
    real(real64), parameter :: half=transfer(int(z'3fe0000000000000',int64),0.0_real64)
    real(real64), parameter :: six=transfer(int(z'4018000000000000',int64),0.0_real64)
    real(real64), parameter :: nine_tenths=transfer(int(z'3feccccccccccccd',int64),0.0_real64)
    real(real64), parameter :: cube_root=transfer(int(z'3fd5555555555555',int64),0.0_real64)
    real(real64), parameter :: seconds_month=transfer(int(z'4143c68000000000',int64),0.0_real64)
    real(real64), parameter :: depth_min=transfer(int(z'4000000000000000',int64),0.0_real64)
    real(real64), parameter :: depth_max=transfer(int(z'4049000000000000',int64),0.0_real64)
    real(real64), parameter :: ice_temperature_min=transfer(int(z'405249999999999a',int64),0.0_real64)
    real(real64), parameter :: eps=transfer(int(z'3ce4000000000000',int64),0.0_real64)
    real(real64) :: q_star,depth,coriolis,sfc_p,ice_p,wml_p,mean_p
    real(real64) :: bot_p,hice_p,hml_p,shape_p,qw,qice,ustar
    real(real64) :: iice,ibot,iw,ih,i0h,ihd,ice_n
    real(real64) :: wml_n,mean_n,bot_n,hice_n,hml_n,shape_n,sfc_n
    real(real64) :: dt,ext,depth_used,shape_mean,shape_rate_max,dmean,dice
    real(real64) :: dbot,dhice,dhml,dshape,n_mean,wind_scale,conv_scale
    real(real64) :: ice_threshold,str1,str2,r_h,r_rho,r_ti,r_star
    real(real64) :: c_tt,c_q,c_ice,phi_t0,phi_i0,phi_i1,wstar
    real(real64) :: t0,t1,t2,t3,t4,t5
    call ieee_get_rounding_mode(rounding)
    if (rounding/=ieee_nearest) call reject_contract()
    smallest=tiny(one)
    subnormal=smallest*half
    if (subnormal==zero) call reject_contract()
    if (klon<1 .or. klon>4096 .or. kidia<1 .or. kidia>klon+1) call reject_contract()
    if (kfdia<kidia-1 .or. kfdia>klon) call reject_contract()
    if (min(size(pdepth_w),size(par_coriolis),size(ldlakepoint),size(pt_sfc_p),size(pt_ice_p_flk), &
        size(pt_wml_p_flk),size(pt_mnw_p_flk),size(pt_bot_p_flk),size(ph_ice_p_flk),size(ph_ml_p_flk),size(pc_t_p_flk), &
        size(pq_w_flk),size(pq_ice_flk),size(pu_star_w_flk),size(pi_ice_flk),size(pi_bot_flk),size(pi_w_flk), &
        size(pi_h_flk),size(pi_intm_0_h_flk),size(pi_intm_h_d_flk),size(pt_ice_n_flk),size(pt_wml_n_flk), &
        size(pt_mnw_n_flk),size(pt_bot_n_flk),size(ph_ice_n_flk),size(ph_ml_n_flk),size(pc_t_n_flk),size(pt_sfc_n))<klon) &
        call reject_contract()
    associate( &
      rc_cbl_1=>ydflake%rc_cbl_1, &
      rc_cbl_2=>ydflake%rc_cbl_2, &
      rc_i_lin=>ydflake%rc_i_lin, &
      rc_i_mr=>ydflake%rc_i_mr, &
      rc_relax_c=>ydflake%rc_relax_c, &
      rc_relax_h=>ydflake%rc_relax_h, &
      rc_sbl_zm_i=>ydflake%rc_sbl_zm_i, &
      rc_sbl_zm_n=>ydflake%rc_sbl_zm_n, &
      rc_sbl_zm_s=>ydflake%rc_sbl_zm_s, &
      rc_small_flk=>ydflake%rc_small_flk, &
      rc_tt_1=>ydflake%rc_tt_1, &
      rc_tt_2=>ydflake%rc_tt_2, &
      rc_t_max=>ydflake%rc_t_max, &
      rc_t_min=>ydflake%rc_t_min, &
      rh_ice_max=>ydflake%rh_ice_max, &
      rh_ice_min_flk=>ydflake%rh_ice_min_flk, &
      rh_ml_max_flk=>ydflake%rh_ml_max_flk, &
      rh_ml_min_flk=>ydflake%rh_ml_min_flk, &
      rphi_i_ast_mr=>ydflake%rphi_i_ast_mr, &
      rphi_i_pr0_lin=>ydflake%rphi_i_pr0_lin, &
      rphi_i_pr1_lin=>ydflake%rphi_i_pr1_lin, &
      rphi_t_pr0_1=>ydflake%rphi_t_pr0_1, &
      rphi_t_pr0_2=>ydflake%rphi_t_pr0_2, &
      rtpl_a_t=>ydflake%rtpl_a_t, &
      rtpl_c_i=>ydflake%rtpl_c_i, &
      rtpl_c_w=>ydflake%rtpl_c_w, &
      rtpl_grav=>ydflake%rtpl_grav, &
      rtpl_kappa_i=>ydflake%rtpl_kappa_i, &
      rtpl_kappa_w=>ydflake%rtpl_kappa_w, &
      rtpl_l_f=>ydflake%rtpl_l_f, &
      rtpl_rho_i=>ydflake%rtpl_rho_i, &
      rtpl_rho_w_r=>ydflake%rtpl_rho_w_r, &
      rtpl_t_f=>ydflake%rtpl_t_f, &
      rtpl_t_r=>ydflake%rtpl_t_r, &
      ru_star_min_flk=>ydflake%ru_star_min_flk)
    if (.not.all(finite_word([ &
      rc_cbl_1,rc_cbl_2,rc_i_lin,rc_i_mr,rc_relax_c, &
      rc_relax_h,rc_sbl_zm_i,rc_sbl_zm_n,rc_sbl_zm_s,rc_small_flk, &
      rc_tt_1,rc_tt_2,rc_t_max,rc_t_min,rh_ice_max, &
      rh_ice_min_flk,rh_ml_max_flk,rh_ml_min_flk,rphi_i_ast_mr,rphi_i_pr0_lin, &
      rphi_i_pr1_lin,rphi_t_pr0_1,rphi_t_pr0_2,rtpl_a_t,rtpl_c_i, &
      rtpl_c_w,rtpl_grav,rtpl_kappa_i,rtpl_kappa_w,rtpl_l_f, &
      rtpl_rho_i,rtpl_rho_w_r,rtpl_t_f,rtpl_t_r,ru_star_min_flk]))) call reject_contract()
    dt=pdel_time
    ext=pextincoef_water_typ
    if (.not.finite_word(dt) .or. .not.finite_word(ext)) call reject_contract()
    if (dt<=zero .or. ext<=zero) call reject_contract()
    shape_mean=rc_t_max+rc_t_min
    shape_mean=shape_mean/two
    shape_rate_max=rc_t_max-rc_t_min
    shape_rate_max=shape_rate_max/seconds_month
    ! Check the stored finite states before the complete setup writes.
    do column=kidia,kfdia
      if (.not.ldlakepoint(column)) cycle
      if (.not.all(finite_word([pdepth_w(column),par_coriolis(column),pt_ice_p_flk(column), &
          pt_wml_p_flk(column),pt_mnw_p_flk(column),pt_bot_p_flk(column),ph_ice_p_flk(column), &
          ph_ml_p_flk(column),pc_t_p_flk(column),pq_w_flk(column),pq_ice_flk(column),pu_star_w_flk(column), &
          pi_ice_flk(column),pi_bot_flk(column),pi_w_flk(column),pi_h_flk(column),pi_intm_0_h_flk(column), &
          pi_intm_h_d_flk(column)]))) call reject_contract()
      hice_p=ph_ice_p_flk(column)
      hml_p=ph_ml_p_flk(column)
      shape_p=pc_t_p_flk(column)
      depth_word=transfer(pdepth_w(column),0_int64)
      if (btest(depth_word,63) .or. unsigned_less(depth_word,transfer(depth_min,0_int64))) &
          depth_word=transfer(depth_min,0_int64)
      if (unsigned_less(transfer(depth_max,0_int64),depth_word)) depth_word=transfer(depth_max,0_int64)
      bound_word=ishft(iand(shiftr(depth_word,52),2047_int64)-52_int64,52)
      if (hice_p<zero) then
        if (transfer(pt_ice_p_flk(column),0_int64)/=transfer(rtpl_t_f,0_int64)) call reject_contract()
        word=transfer(pq_w_flk(column),0_int64)
        no_create=.not.btest(word,63) .or. iand(word,int(z'7fffffffffffffff',int64))==0_int64
        if (.not.no_create) then
          call ieee_get_status(saved_status)
          warm_threshold=rtpl_t_f+rc_small_flk
          no_create=pt_wml_p_flk(column)>warm_threshold
          call ieee_set_status(saved_status)
        end if
        if (.not.no_create) call reject_contract()
        word=iand(transfer(hice_p,0_int64),int(z'7fffffffffffffff',int64))
        if (unsigned_less(bound_word,word)) call reject_contract()
      end if
      if (hml_p<zero) then
        ice_word=transfer(hice_p,0_int64)
        if (unsigned_less(ice_word,transfer(rh_ice_min_flk,0_int64))) call reject_contract()
        if (transfer(pt_wml_p_flk(column),0_int64)/=transfer(rtpl_t_f,0_int64)) call reject_contract()
        word=iand(transfer(hml_p,0_int64),int(z'7fffffffffffffff',int64))
        if (unsigned_less(bound_word,word)) call reject_contract()
      end if
      if (shape_p<rc_t_min) call reject_contract()
      if (shape_p>rc_t_max) then
        if (transfer(rc_t_max,0_int64)/=int(z'3fe999999999999a',int64)) call reject_contract()
        if (unsigned_less(int(z'3fe999a000000000',int64),transfer(shape_p,0_int64))) call reject_contract()
      end if
    end do
    do column=1,klon
      pt_ice_n_flk(column)=pt_ice_p_flk(column)
      pt_wml_n_flk(column)=pt_wml_p_flk(column)
      pt_mnw_n_flk(column)=pt_mnw_p_flk(column)
      pt_bot_n_flk(column)=pt_bot_p_flk(column)
      ph_ice_n_flk(column)=ph_ice_p_flk(column)
      ph_ml_n_flk(column)=ph_ml_p_flk(column)
      pc_t_n_flk(column)=pc_t_p_flk(column)
    end do
    do column=kidia,kfdia
      if (.not.ldlakepoint(column)) cycle
      depth=pdepth_w(column)
      coriolis=par_coriolis(column)
      sfc_p=pt_sfc_p(column)
      ice_p=pt_ice_p_flk(column)
      wml_p=pt_wml_p_flk(column)
      mean_p=pt_mnw_p_flk(column)
      bot_p=pt_bot_p_flk(column)
      hice_p=ph_ice_p_flk(column)
      hml_p=ph_ml_p_flk(column)
      shape_p=pc_t_p_flk(column)
      qw=pq_w_flk(column)
      qice=pq_ice_flk(column)
      ustar=pu_star_w_flk(column)
      iice=pi_ice_flk(column)
      ibot=pi_bot_flk(column)
      iw=pi_w_flk(column)
      ih=pi_h_flk(column)
      i0h=pi_intm_0_h_flk(column)
      ihd=pi_intm_h_d_flk(column)
      ice_n=pt_ice_n_flk(column)
      wml_n=pt_wml_n_flk(column)
      mean_n=pt_mnw_n_flk(column)
      bot_n=pt_bot_n_flk(column)
      hice_n=ph_ice_n_flk(column)
      hml_n=ph_ml_n_flk(column)
      shape_n=pc_t_n_flk(column)
      sfc_n=pt_sfc_n(column)
      depth_used=maximum(depth_min,depth)
      depth_used=minimum(depth_max,depth_used)
      hml_n=minimum(hml_n,depth_used)
      hice_n=minimum(hice_n,depth_used)
      wml_n=maximum(wml_n,rtpl_t_f)
      mean_n=maximum(mean_n,rtpl_t_f)
      bot_n=maximum(bot_n,rtpl_t_f)
      ice_n=minimum(ice_n,rtpl_t_f)
      dmean=zero
      dice=zero
      dbot=zero
      dhice=zero
      dhml=zero
      dshape=zero
      create_ice=.false.
      melt_above=.false.
      ! Recompute heat through the ice from the previous water profile.
      if (hice_p>=rh_ice_min_flk) then
        if (hml_p<=rh_ml_min_flk) then
          t0=bot_p-wml_p
          t1=-rtpl_kappa_w
          t0=t1*t0
          qw=t0/depth_used
          t0=rphi_t_pr0_1*shape_p
          phi_t0=t0-rphi_t_pr0_2
          t0=maximum(phi_t0,one)
          qw=qw*t0
        else
          qw=zero
        end if
      end if
      t0=qw+iw
      t0=t0+ih
      t1=two*i0h
      str1=t0-t1
      q_star=str1
      if (hice_p<rh_ice_min_flk) then
        t0=rtpl_t_f+rc_small_flk
        if (wml_p<=t0) then
          if (qw<zero) then
            create_ice=.true.
            t0=-qw
            t0=t0/rtpl_rho_i
            dhice=t0/rtpl_l_f
            t0=dhice*dt
            hice_n=hice_p+t0
            t0=hice_n*qw
            t0=t0/rtpl_kappa_i
            t0=t0/rphi_i_pr0_lin
            ice_n=rtpl_t_f+t0
            t0=hice_n/rh_ice_max
            t0=minimum(one,t0)
            t0=rphi_i_ast_mr*t0
            phi_i1=rphi_i_pr1_lin+t0
          end if
        end if
      else
        t0=rtpl_t_f-rc_small_flk
        cold_ice=ice_p<t0
        if (.not.cold_ice) then
          t0=qice+iice
          t0=t0-iw
          t0=t0-qw
          cold_ice=t0<zero
          if (.not.cold_ice) then
            melt_above=.true.
            t0=-t0
            t0=t0/rtpl_l_f
            dhice=t0/rtpl_rho_i
            t0=dhice*dt
            hice_n=hice_p+t0
            ice_n=rtpl_t_f
          end if
        end if
        if (cold_ice) then
          phi_i0=hice_p/rh_ice_max
          t0=one+rphi_i_ast_mr
          t0=rc_i_mr*t0
          t0=t0*phi_i0
          c_ice=rc_i_lin-t0
          t0=rphi_i_ast_mr*phi_i0
          phi_i1=rphi_i_pr1_lin+t0
          phi_i0=rphi_i_pr0_lin-phi_i0
          t0=two*c_ice
          t0=t0*rtpl_c_i
          t1=rtpl_t_f-ice_p
          t0=t0*t1
          t0=t0/rtpl_l_f
          ice_threshold=maximum(one,t0)
          t0=phi_i0/c_ice
          t0=t0*rtpl_kappa_i
          t0=t0/rtpl_rho_i
          t0=t0/rtpl_c_i
          ice_threshold=t0*ice_threshold
          t0=ice_threshold*dt
          t0=maximum(zero,t0)
          ice_threshold=sqrt(t0)
          t0=nine_tenths*rh_ice_max
          t1=maximum(ice_threshold,rh_ice_min_flk)
          ice_threshold=minimum(t0,t1)
          if (hice_p<ice_threshold) then
            t0=qice+iice
            str2=t0-iw
            t0=str2-qw
            t0=-t0
            t0=t0/rtpl_l_f
            dhice=t0/rtpl_rho_i
            t0=dhice*dt
            hice_n=hice_p+t0
            t0=hice_n*str2
            t0=t0/rtpl_kappa_i
            t0=t0/phi_i0
            ice_n=rtpl_t_f+t0
          else
            t0=rtpl_t_f-ice_p
            t0=rtpl_kappa_i*t0
            t0=t0/hice_p
            dhice=t0*phi_i0
            t0=qw+dhice
            t0=t0/rtpl_l_f
            dhice=t0/rtpl_rho_i
            t0=dhice*dt
            hice_n=hice_p+t0
            t0=rtpl_t_f-ice_p
            t0=rtpl_c_i*t0
            r_ti=t0/rtpl_l_f
            r_star=one-c_ice
            r_star=r_star*r_ti
            t0=qice+iice
            str2=t0-iw
            t3=c_ice*hice_p
            dice=zero
            t0=rtpl_t_f-ice_p
            t0=rtpl_kappa_i*t0
            t0=t0/hice_p
            t0=t0*phi_i0
            t1=one-r_star
            t0=t0*t1
            dice=dice+t0
            t0=r_star*qw
            dice=dice-t0
            dice=dice+str2
            dice=dice/rtpl_rho_i
            dice=dice/rtpl_c_i
            dice=dice/t3
            t0=dice*dt
            ice_n=ice_p+t0
          end if
          t0=hice_n/rh_ice_max
          t0=minimum(one,t0)
          t0=rphi_i_ast_mr*t0
          phi_i1=rphi_i_pr1_lin+t0
        end if
      end if
      hice_n=minimum(hice_n,rh_ice_max)
      ice_n=minimum(ice_n,rtpl_t_f)
      ice_n=maximum(ice_n,ice_temperature_min)
      if (hice_n<rh_ice_min_flk) then
        hice_n=zero
        ice_n=rtpl_t_f
        create_ice=.false.
      end if
      if (create_ice) qw=zero
      ! Advance the mean temperature from the net water heat input.
      t0=qw-zero
      t0=t0+iw
      t0=t0-ibot
      t0=t0/rtpl_rho_w_r
      t0=t0/rtpl_c_w
      dmean=t0/depth_used
      t0=dmean*dt
      mean_n=mean_p+t0
      mean_n=maximum(mean_n,rtpl_t_f)
      if (hice_n>=rh_ice_min_flk) then
        mean_n=minimum(mean_n,rtpl_t_r)
        wml_n=rtpl_t_f
        if (create_ice) then
          t0=depth_used-rh_ml_min_flk
          if (hml_p>=t0) then
            hml_n=zero
            shape_n=shape_mean
          else
            hml_n=hml_p
            shape_n=shape_p
          end if
        else if (bot_p<rtpl_t_r) then
          hml_n=hml_p
          shape_n=shape_p
        else
          bot_n=rtpl_t_r
          if (hml_p>=rc_small_flk) then
            t0=wml_n-mean_n
            t1=wml_n-bot_n
            t0=t0/t1
            t0=t0/shape_p
            t0=one-t0
            hml_n=depth_used*t0
            hml_n=maximum(hml_n,zero)
            shape_n=shape_p
            t0=depth_used-rh_ml_min_flk
            if (hml_n>=t0) then
              hml_n=zero
              t0=wml_n-mean_n
              t0=t0/shape_n
              bot_n=wml_n-t0
            end if
          else
            hml_n=hml_p
            t0=wml_n-mean_n
            t1=wml_n-bot_n
            shape_n=t0/t1
            t0=maximum(shape_n,rc_t_min)
            shape_n=minimum(rc_t_max,t0)
          end if
          t0=shape_n-shape_p
          dshape=t0/dt
          t0=abs(dshape)
          if (t0>shape_rate_max) then
            t0=copy_sign(shape_rate_max,dshape)
            t0=t0*dt
            shape_n=shape_p+t0
          end if
        end if
        if (create_ice .or. bot_p<rtpl_t_r) then
          t0=hml_n-depth_used
          t0=abs(t0)
          if (t0>eps) then
            t0=wml_n-mean_n
            t0=t0/shape_n
            t1=hml_n/depth_used
            t1=one-t1
            t0=t0/t1
            bot_n=wml_n-t0
          end if
        end if
        bot_n=minimum(bot_n,rtpl_t_r)
      else
        ! Open-water mixing uses the stored heat and buoyancy scales.
        t4=rtpl_grav*rtpl_a_t
        t5=wml_p-rtpl_t_r
        t0=t4*t5
        t0=t0*str1
        t0=t0/rtpl_rho_w_r
        str1=t0/rtpl_c_w
        if (str1<zero .and. hml_p>zero) then
          t0=-str1
          t0=t0*hml_p
          wstar=selected_power(t0,cube_root)
        else
          wstar=zero
        end if
        t0=-qw
        t1=maximum(iw,rc_small_flk)
        conv_scale=t0/t1
        if (conv_scale>zero .and. conv_scale<one .and. wml_p>rtpl_t_r) then
          t0=six*conv_scale
          t0=sqrt(t0)
          t1=two*conv_scale
          t2=one-conv_scale
          t1=t1/t2
          conv_scale=t0+t1
          t0=conv_scale/ext
          conv_scale=minimum(depth_used,t0)
        else
          conv_scale=zero
        end if
        t0=wml_p+bot_p
        t0=half*t0
        t4=rtpl_grav*rtpl_a_t
        t5=t0-rtpl_t_r
        t0=t4*t5
        t1=wml_p-bot_p
        n_mean=t0*t1
        t0=depth_used-rh_ml_min_flk
        if (hml_p<=t0) then
          t0=depth_used-hml_p
          t0=n_mean/t0
          t0=maximum(t0,zero)
          n_mean=sqrt(t0)
        else
          n_mean=zero
        end if
        t0=maximum(wstar,ustar)
        t0=maximum(t0,ru_star_min_flk)
        dshape=t0*t0
        t0=depth_used-hml_p
        t0=t0*t0
        t0=n_mean*t0
        t0=t0/rc_relax_c
        dshape=t0/dshape
        t0=rc_t_max-rc_t_min
        t1=maximum(dshape,rc_small_flk)
        dshape=t0/t1
        t0=rc_tt_1*shape_p
        c_tt=t0-rc_tt_2
        t0=two*c_tt
        c_q=t0/shape_p
        if (str1<zero) then
          t0=abs(dshape)
          if (t0>shape_rate_max) dshape=copy_sign(shape_rate_max,dshape)
          t0=dshape*dt
          shape_n=shape_p+t0
          t0=maximum(shape_n,rc_t_min)
          shape_n=minimum(rc_t_max,t0)
          t0=shape_n-shape_p
          dshape=t0/dt
          t0=depth_used-rh_ml_min_flk
          if (hml_p<=t0) then
            if (hml_p<=rh_ml_min_flk) then
              t0=rc_cbl_1/rc_cbl_2
              t1=maximum(wstar,rc_small_flk)
              dhml=t0*t1
            else
              r_h=depth_used/hml_p
              r_rho=r_h-one
              r_ti=shape_p/c_tt
              t0=r_ti/two
              t0=t0-one
              t0=t0*r_rho
              r_star=t0+one
              t0=one+rc_cbl_1
              t0=r_star*t0
              t0=t0-one
              t1=-q_star
              t0=t1*t0
              t0=t0-zero
              t0=t0/rtpl_rho_w_r
              dhml=t0/rtpl_c_w
              t0=depth_used-hml_p
              t1=wml_p-bot_p
              t0=t0*t1
              t0=t0*rc_tt_2
              t0=t0/c_tt
              str2=t0*dshape
              dhml=dhml+str2
              t0=r_ti-one
              t0=t0*ih
              t0=ibot+t0
              t1=r_ti*ihd
              str2=t0-t1
              t0=r_ti-two
              t0=t0*r_rho
              t1=ih-i0h
              t0=t0*t1
              str2=str2+t0
              str2=str2/rtpl_rho_w_r
              str2=str2/rtpl_c_w
              dhml=dhml+str2
              t0=-rc_cbl_2
              t0=t0*r_star
              t0=t0*q_star
              t0=t0/rtpl_rho_w_r
              t0=t0/rtpl_c_w
              t1=maximum(wstar,rc_small_flk)
              str2=t0/t1
              t0=wml_p-bot_p
              t0=shape_p*t0
              str2=str2+t0
              t0=abs(str2)
              t0=maximum(t0,rc_small_flk)
              t0=copy_sign(t0,str2)
              dhml=dhml/t0
            end if
            dhml=maximum(dhml,rc_small_flk)
            t0=dhml*dt
            hml_n=hml_p+t0
            t0=minimum(hml_n,depth_used)
            hml_n=maximum(rh_ml_min_flk,t0)
          else
            hml_n=depth_used
          end if
        else
          dhml=maximum(ustar,ru_star_min_flk)
          t0=abs(coriolis)
          t0=t0/rc_sbl_zm_n
          t1=n_mean/rc_sbl_zm_i
          t0=t0+t1
          t1=dhml*dhml
          wind_scale=t0*t1
          t0=str1/rc_sbl_zm_s
          wind_scale=wind_scale+t0
          wind_scale=maximum(wind_scale,rc_small_flk)
          t0=dhml*dhml
          t0=t0*dhml
          wind_scale=t0/wind_scale
          t0=minimum(wind_scale,rh_ml_max_flk)
          wind_scale=maximum(rh_ml_min_flk,t0)
          wind_scale=maximum(wind_scale,conv_scale)
          t0=rc_relax_h*dhml
          t0=t0/wind_scale
          dhml=t0*dt
          t0=-dhml
          t0=selected_exponential(t0)
          t1=wind_scale-hml_p
          t0=t1*t0
          hml_n=wind_scale-t0
          t0=minimum(hml_n,depth_used)
          hml_n=maximum(rh_ml_min_flk,t0)
          t0=hml_n-hml_p
          dhml=t0/dt
          if (hml_n<=hml_p) dshape=-dshape
          t0=abs(dshape)
          if (t0>shape_rate_max) dshape=copy_sign(shape_rate_max,dshape)
          t0=dshape*dt
          shape_n=shape_p+t0
          t0=maximum(shape_n,rc_t_min)
          shape_n=minimum(rc_t_max,t0)
          t0=shape_n-shape_p
          dshape=t0/dt
        end if
        t0=depth_used-rh_ml_min_flk
        if (hml_n<=t0) then
          if (hml_n>hml_p) then
            r_h=hml_p/depth_used
            r_rho=one-r_h
            t0=half*shape_p
            t0=t0*r_rho
            t1=two*r_h
            t1=t1-one
            t1=c_tt*t1
            r_ti=t0+t1
            t0=half+c_tt
            t0=t0-c_q
            r_star=t0/r_ti
            t0=shape_p*r_rho
            t0=one-t0
            r_ti=t0/r_ti
            t0=qw-zero
            t0=t0+iw
            t0=t0-ibot
            t0=t0/rtpl_rho_w_r
            dbot=t0/rtpl_c_w
            t0=wml_p-bot_p
            t0=shape_p*t0
            t0=t0*dhml
            dbot=dbot-t0
            dbot=dbot*r_star
            dbot=dbot/depth_used
            t0=one-c_q
            t0=t0*ih
            str2=ihd-t0
            t0=c_q*ibot
            str2=str2-t0
            str2=str2*r_ti
            t0=depth_used-hml_p
            str2=str2/t0
            str2=str2/rtpl_rho_w_r
            str2=str2/rtpl_c_w
            dbot=dbot+str2
            t0=rc_tt_2*r_ti
            t0=one-t0
            str2=t0/shape_p
            t0=wml_p-bot_p
            str2=str2*t0
            str2=str2*dshape
            dbot=dbot+str2
          else
            dbot=zero
          end if
          t0=dbot*dt
          bot_n=bot_p+t0
          bot_n=maximum(bot_n,rtpl_t_f)
          t0=bot_n-rtpl_t_r
          t4=rtpl_grav*rtpl_a_t
          t5=mean_n-rtpl_t_r
          t1=t4*t5
          str2=t0*t1
          if (str2<zero) bot_n=rtpl_t_r
          t0=hml_n/depth_used
          t0=one-t0
          wml_n=shape_n*t0
          t0=bot_n*wml_n
          t0=mean_n-t0
          t1=one-wml_n
          wml_n=t0/t1
          wml_n=maximum(wml_n,rtpl_t_f)
        else
          hml_n=depth_used
          wml_n=mean_n
          bot_n=mean_n
          shape_n=shape_mean
        end if
      end if
      t0=wml_n-bot_n
      t4=rtpl_grav*rtpl_a_t
      t5=mean_n-rtpl_t_r
      t1=t4*t5
      str2=t0*t1
      if (str2<zero) then
        hml_n=depth_used
        wml_n=mean_n
        bot_n=mean_n
        shape_n=shape_mean
      end if
      if (hice_n>=rh_ice_min_flk) then
        sfc_n=ice_n
      else
        sfc_n=wml_n
      end if
      pq_w_flk(column)=qw
      pt_ice_n_flk(column)=ice_n
      pt_wml_n_flk(column)=wml_n
      pt_mnw_n_flk(column)=mean_n
      pt_bot_n_flk(column)=bot_n
      ph_ice_n_flk(column)=hice_n
      ph_ml_n_flk(column)=hml_n
      pc_t_n_flk(column)=shape_n
      pt_sfc_n(column)=sfc_n
    end do
    end associate
    native_calls=native_calls+1_c_int64_t
  end subroutine flakeene
  !> Return the retained complete-call activity count.
  function md2asm_flakeene_calls_get() bind(c,name="md2asm_flakeene_calls_get") result(count)
    integer(c_int64_t) :: count
    count=native_calls
  end function md2asm_flakeene_calls_get
  !> Read the IEEE exponent without evaluating a possible NaN.
  elemental pure logical function finite_word(value)
    real(real64), intent(in) :: value
    finite_word=iand(shiftr(transfer(value,0_int64),52),2047_int64)/=2047_int64
  end function finite_word
  !> Compare complete unsigned words while keeping standard signed integers.
  pure logical function unsigned_less(left,right)
    integer(int64), intent(in) :: left,right
    integer(int64), parameter :: sign_bit=int(z'8000000000000000',int64)
    unsigned_less=ieor(left,sign_bit)<ieor(right,sign_bit)
  end function unsigned_less
  !> Keep the sign of zero in a finite minimum.
  pure real(real64) function minimum(left,right) result(value)
    real(real64), intent(in) :: left,right
    if (left<right) then
      value=left
    else if (right<left) then
      value=right
    else if (left==0.0_real64 .and. right==0.0_real64) then
      value=transfer(ior(transfer(left,0_int64),transfer(right,0_int64)),value)
    else
      value=left
    end if
  end function minimum
  !> Keep the sign of zero in a finite maximum.
  pure real(real64) function maximum(left,right) result(value)
    real(real64), intent(in) :: left,right
    if (left>right) then
      value=left
    else if (right>left) then
      value=right
    else if (left==0.0_real64 .and. right==0.0_real64) then
      value=transfer(iand(transfer(left,0_int64),transfer(right,0_int64)),value)
    else
      value=left
    end if
  end function maximum
  !> Copy an IEEE sign bit without a floating-point operation.
  pure real(real64) function copy_sign(magnitude,direction) result(value)
    real(real64), intent(in) :: magnitude,direction
    integer(int64) :: bits
    bits=ior(iand(transfer(magnitude,0_int64),int(z'7fffffffffffffff',int64)), &
        iand(transfer(direction,0_int64),int(z'8000000000000000',int64)))
    value=transfer(bits,value)
  end function copy_sign
end module flakeene_mod
