!> Expose every named aerosol optical field on its canonical owner.
module forecast_owned_aerosol_optical_namespace
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_int64_t
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use forecast_radiation_namespace_views, only: native_radiation_namespace_field
  implicit none
  private
  public :: initialize_owned_aerosol_optical_namespace, get_owned_aerosol_optical_field
contains
!> Initialize source zero-born fields before any setup producer is active.
!! STATE is the actual native owner. Live context or storage is refused.
  integer(int32) function initialize_owned_aerosol_optical_namespace(state) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    status = 2
    if (state%context_ready .or. state%storage_ready .or. state%setup_complete) return
    state%aerosol_optical%alf_bc = 0.0_real64
    state%aerosol_optical%asy_bc = 0.0_real64
    state%aerosol_optical%omg_bc = 0.0_real64
    state%aerosol_optical%rali_bc = 0.0_real64
    state%aerosol_optical%alf_dd = 0.0_real64
    state%aerosol_optical%asy_dd = 0.0_real64
    state%aerosol_optical%omg_dd = 0.0_real64
    state%aerosol_optical%rali_dd = 0.0_real64
    state%aerosol_optical%alf_om = 0.0_real64
    state%aerosol_optical%asy_om = 0.0_real64
    state%aerosol_optical%omg_om = 0.0_real64
    state%aerosol_optical%rali_om = 0.0_real64
    state%aerosol_optical%alf_ss = 0.0_real64
    state%aerosol_optical%asy_ss = 0.0_real64
    state%aerosol_optical%omg_ss = 0.0_real64
    state%aerosol_optical%rali_ss = 0.0_real64
    state%aerosol_optical%alf_su = 0.0_real64
    state%aerosol_optical%asy_su = 0.0_real64
    state%aerosol_optical%omg_su = 0.0_real64
    state%aerosol_optical%rali_su = 0.0_real64
    state%aerosol_optical%alf_ni = 0.0_real64
    state%aerosol_optical%asy_ni = 0.0_real64
    state%aerosol_optical%omg_ni = 0.0_real64
    state%aerosol_optical%rali_ni = 0.0_real64
    state%aerosol_optical%alf_soa = 0.0_real64
    state%aerosol_optical%asy_soa = 0.0_real64
    state%aerosol_optical%omg_soa = 0.0_real64
    state%aerosol_optical%rali_soa = 0.0_real64
    state%aerosol_optical%alf_am = 0.0_real64
    state%aerosol_optical%asy_am = 0.0_real64
    state%aerosol_optical%omg_am = 0.0_real64
    state%aerosol_optical%rali_am = 0.0_real64
    state%aerosol_optical%alfs_bc = 0.0_real64
    state%aerosol_optical%asys_bc = 0.0_real64
    state%aerosol_optical%omgs_bc = 0.0_real64
    state%aerosol_optical%alfs_dd = 0.0_real64
    state%aerosol_optical%asys_dd = 0.0_real64
    state%aerosol_optical%omgs_dd = 0.0_real64
    state%aerosol_optical%alfs_fa = 0.0_real64
    state%aerosol_optical%asys_fa = 0.0_real64
    state%aerosol_optical%omgs_fa = 0.0_real64
    state%aerosol_optical%alfs_om = 0.0_real64
    state%aerosol_optical%asys_om = 0.0_real64
    state%aerosol_optical%omgs_om = 0.0_real64
    state%aerosol_optical%alfs_ss = 0.0_real64
    state%aerosol_optical%asys_ss = 0.0_real64
    state%aerosol_optical%omgs_ss = 0.0_real64
    state%aerosol_optical%alfs_su = 0.0_real64
    state%aerosol_optical%asys_su = 0.0_real64
    state%aerosol_optical%omgs_su = 0.0_real64
    state%aerosol_optical%alfl_bc = 0.0_real64
    state%aerosol_optical%asyl_bc = 0.0_real64
    state%aerosol_optical%omgl_bc = 0.0_real64
    state%aerosol_optical%alfl_dd = 0.0_real64
    state%aerosol_optical%asyl_dd = 0.0_real64
    state%aerosol_optical%omgl_dd = 0.0_real64
    state%aerosol_optical%alfl_fa = 0.0_real64
    state%aerosol_optical%asyl_fa = 0.0_real64
    state%aerosol_optical%omgl_fa = 0.0_real64
    state%aerosol_optical%alfl_om = 0.0_real64
    state%aerosol_optical%asyl_om = 0.0_real64
    state%aerosol_optical%omgl_om = 0.0_real64
    state%aerosol_optical%alfl_ss = 0.0_real64
    state%aerosol_optical%asyl_ss = 0.0_real64
    state%aerosol_optical%omgl_ss = 0.0_real64
    state%aerosol_optical%alfl_su = 0.0_real64
    state%aerosol_optical%asyl_su = 0.0_real64
    state%aerosol_optical%omgl_su = 0.0_real64
    status = 0
  end function
!> Borrow a complete named field by its frozen source-map index.
!! The caller keeps the actual TARGET owner alive. No scientific value is read.
  integer(int32) function get_owned_aerosol_optical_field(state, index, field) result(status)
    type(owned_radiation_setup_state), target, intent(in) :: state
    integer(int32), intent(in) :: index
    type(native_radiation_namespace_field), intent(inout) :: field
    type(native_radiation_namespace_field) :: pending
    status = 2
    select case (index)
    case (1) ! __yoeaerop_MOD_alf_bc
      pending%address = c_loc(state%aerosol_optical%alf_bc(lbound(state%aerosol_optical%alf_bc, 1)))
      pending%bytes = 160_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%alf_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%alf_bc), int64)
    case (2) ! __yoeaerop_MOD_asy_bc
      pending%address = c_loc(state%aerosol_optical%asy_bc(lbound(state%aerosol_optical%asy_bc, 1)))
      pending%bytes = 160_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%asy_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%asy_bc), int64)
    case (3) ! __yoeaerop_MOD_omg_bc
      pending%address = c_loc(state%aerosol_optical%omg_bc(lbound(state%aerosol_optical%omg_bc, 1)))
      pending%bytes = 160_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%omg_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%omg_bc), int64)
    case (4) ! __yoeaerop_MOD_rali_bc
      pending%address = c_loc(state%aerosol_optical%rali_bc(lbound(state%aerosol_optical%rali_bc, 1)))
      pending%bytes = 160_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%rali_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%rali_bc), int64)
    case (5) ! __yoeaerop_MOD_alf_dd
  pending%address=c_loc(state%aerosol_optical%alf_dd(lbound(state%aerosol_optical%alf_dd,1),lbound(state%aerosol_optical%alf_dd,2)))
      pending%bytes = 1440_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alf_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alf_dd), int64)
    case (6) ! __yoeaerop_MOD_asy_dd
  pending%address=c_loc(state%aerosol_optical%asy_dd(lbound(state%aerosol_optical%asy_dd,1),lbound(state%aerosol_optical%asy_dd,2)))
      pending%bytes = 1440_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asy_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asy_dd), int64)
    case (7) ! __yoeaerop_MOD_omg_dd
  pending%address=c_loc(state%aerosol_optical%omg_dd(lbound(state%aerosol_optical%omg_dd,1),lbound(state%aerosol_optical%omg_dd,2)))
      pending%bytes = 1440_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omg_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omg_dd), int64)
    case (8) ! __yoeaerop_MOD_rali_dd
pending%address=c_loc(state%aerosol_optical%rali_dd(lbound(state%aerosol_optical%rali_dd,1),lbound(state%aerosol_optical%rali_dd,2)))
      pending%bytes = 1440_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%rali_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%rali_dd), int64)
    case (9) ! __yoeaerop_MOD_alf_om
  pending%address=c_loc(state%aerosol_optical%alf_om(lbound(state%aerosol_optical%alf_om,1),lbound(state%aerosol_optical%alf_om,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alf_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alf_om), int64)
    case (10) ! __yoeaerop_MOD_asy_om
  pending%address=c_loc(state%aerosol_optical%asy_om(lbound(state%aerosol_optical%asy_om,1),lbound(state%aerosol_optical%asy_om,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asy_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asy_om), int64)
    case (11) ! __yoeaerop_MOD_omg_om
  pending%address=c_loc(state%aerosol_optical%omg_om(lbound(state%aerosol_optical%omg_om,1),lbound(state%aerosol_optical%omg_om,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omg_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omg_om), int64)
    case (12) ! __yoeaerop_MOD_rali_om
pending%address=c_loc(state%aerosol_optical%rali_om(lbound(state%aerosol_optical%rali_om,1),lbound(state%aerosol_optical%rali_om,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%rali_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%rali_om), int64)
    case (13) ! __yoeaerop_MOD_alf_ss
pending%address=c_loc(state%aerosol_optical%alf_ss(lbound(state%aerosol_optical%alf_ss,1),lbound(state%aerosol_optical%alf_ss,2),lbound(state%aerosol_optical%alf_ss,3)))
      pending%bytes = 17280_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%alf_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%alf_ss), int64)
    case (14) ! __yoeaerop_MOD_asy_ss
pending%address=c_loc(state%aerosol_optical%asy_ss(lbound(state%aerosol_optical%asy_ss,1),lbound(state%aerosol_optical%asy_ss,2),lbound(state%aerosol_optical%asy_ss,3)))
      pending%bytes = 17280_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%asy_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%asy_ss), int64)
    case (15) ! __yoeaerop_MOD_omg_ss
pending%address=c_loc(state%aerosol_optical%omg_ss(lbound(state%aerosol_optical%omg_ss,1),lbound(state%aerosol_optical%omg_ss,2),lbound(state%aerosol_optical%omg_ss,3)))
      pending%bytes = 17280_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%omg_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%omg_ss), int64)
    case (16) ! __yoeaerop_MOD_rali_ss
pending%address=c_loc(state%aerosol_optical%rali_ss(lbound(state%aerosol_optical%rali_ss,1),lbound(state%aerosol_optical%rali_ss,2),lbound(state%aerosol_optical%rali_ss,3)))
      pending%bytes = 17280_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%rali_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%rali_ss), int64)
    case (17) ! __yoeaerop_MOD_alf_su
  pending%address=c_loc(state%aerosol_optical%alf_su(lbound(state%aerosol_optical%alf_su,1),lbound(state%aerosol_optical%alf_su,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alf_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alf_su), int64)
    case (18) ! __yoeaerop_MOD_asy_su
  pending%address=c_loc(state%aerosol_optical%asy_su(lbound(state%aerosol_optical%asy_su,1),lbound(state%aerosol_optical%asy_su,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asy_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asy_su), int64)
    case (19) ! __yoeaerop_MOD_omg_su
  pending%address=c_loc(state%aerosol_optical%omg_su(lbound(state%aerosol_optical%omg_su,1),lbound(state%aerosol_optical%omg_su,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omg_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omg_su), int64)
    case (20) ! __yoeaerop_MOD_rali_su
pending%address=c_loc(state%aerosol_optical%rali_su(lbound(state%aerosol_optical%rali_su,1),lbound(state%aerosol_optical%rali_su,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%rali_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%rali_su), int64)
    case (21) ! __yoeaerop_MOD_alf_ni
pending%address=c_loc(state%aerosol_optical%alf_ni(lbound(state%aerosol_optical%alf_ni,1),lbound(state%aerosol_optical%alf_ni,2),lbound(state%aerosol_optical%alf_ni,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%alf_ni), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%alf_ni), int64)
    case (22) ! __yoeaerop_MOD_asy_ni
pending%address=c_loc(state%aerosol_optical%asy_ni(lbound(state%aerosol_optical%asy_ni,1),lbound(state%aerosol_optical%asy_ni,2),lbound(state%aerosol_optical%asy_ni,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%asy_ni), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%asy_ni), int64)
    case (23) ! __yoeaerop_MOD_omg_ni
pending%address=c_loc(state%aerosol_optical%omg_ni(lbound(state%aerosol_optical%omg_ni,1),lbound(state%aerosol_optical%omg_ni,2),lbound(state%aerosol_optical%omg_ni,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%omg_ni), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%omg_ni), int64)
    case (24) ! __yoeaerop_MOD_rali_ni
pending%address=c_loc(state%aerosol_optical%rali_ni(lbound(state%aerosol_optical%rali_ni,1),lbound(state%aerosol_optical%rali_ni,2),lbound(state%aerosol_optical%rali_ni,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%rali_ni), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%rali_ni), int64)
    case (25) ! __yoeaerop_MOD_alf_soa
pending%address=c_loc(state%aerosol_optical%alf_soa(lbound(state%aerosol_optical%alf_soa,1),lbound(state%aerosol_optical%alf_soa,2),lbound(state%aerosol_optical%alf_soa,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%alf_soa), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%alf_soa), int64)
    case (26) ! __yoeaerop_MOD_asy_soa
pending%address=c_loc(state%aerosol_optical%asy_soa(lbound(state%aerosol_optical%asy_soa,1),lbound(state%aerosol_optical%asy_soa,2),lbound(state%aerosol_optical%asy_soa,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%asy_soa), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%asy_soa), int64)
    case (27) ! __yoeaerop_MOD_omg_soa
pending%address=c_loc(state%aerosol_optical%omg_soa(lbound(state%aerosol_optical%omg_soa,1),lbound(state%aerosol_optical%omg_soa,2),lbound(state%aerosol_optical%omg_soa,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%omg_soa), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%omg_soa), int64)
    case (28) ! __yoeaerop_MOD_rali_soa
pending%address=c_loc(state%aerosol_optical%rali_soa(lbound(state%aerosol_optical%rali_soa,1),lbound(state%aerosol_optical%rali_soa,2),lbound(state%aerosol_optical%rali_soa,3)))
      pending%bytes = 3840_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%rali_soa), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%rali_soa), int64)
    case (29) ! __yoeaerop_MOD_alf_am
  pending%address=c_loc(state%aerosol_optical%alf_am(lbound(state%aerosol_optical%alf_am,1),lbound(state%aerosol_optical%alf_am,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alf_am), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alf_am), int64)
    case (30) ! __yoeaerop_MOD_asy_am
  pending%address=c_loc(state%aerosol_optical%asy_am(lbound(state%aerosol_optical%asy_am,1),lbound(state%aerosol_optical%asy_am,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asy_am), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asy_am), int64)
    case (31) ! __yoeaerop_MOD_omg_am
  pending%address=c_loc(state%aerosol_optical%omg_am(lbound(state%aerosol_optical%omg_am,1),lbound(state%aerosol_optical%omg_am,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omg_am), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omg_am), int64)
    case (32) ! __yoeaerop_MOD_rali_am
pending%address=c_loc(state%aerosol_optical%rali_am(lbound(state%aerosol_optical%rali_am,1),lbound(state%aerosol_optical%rali_am,2)))
      pending%bytes = 1920_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%rali_am), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%rali_am), int64)
    case (33) ! __yoeaerop_MOD_alfs_bc
      pending%address = c_loc(state%aerosol_optical%alfs_bc(lbound(state%aerosol_optical%alfs_bc, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%alfs_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%alfs_bc), int64)
    case (34) ! __yoeaerop_MOD_asys_bc
      pending%address = c_loc(state%aerosol_optical%asys_bc(lbound(state%aerosol_optical%asys_bc, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%asys_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%asys_bc), int64)
    case (35) ! __yoeaerop_MOD_omgs_bc
      pending%address = c_loc(state%aerosol_optical%omgs_bc(lbound(state%aerosol_optical%omgs_bc, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%omgs_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%omgs_bc), int64)
    case (36) ! __yoeaerop_MOD_alfs_dd
pending%address=c_loc(state%aerosol_optical%alfs_dd(lbound(state%aerosol_optical%alfs_dd,1),lbound(state%aerosol_optical%alfs_dd,2)))
      pending%bytes = 336_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alfs_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alfs_dd), int64)
    case (37) ! __yoeaerop_MOD_asys_dd
pending%address=c_loc(state%aerosol_optical%asys_dd(lbound(state%aerosol_optical%asys_dd,1),lbound(state%aerosol_optical%asys_dd,2)))
      pending%bytes = 336_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asys_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asys_dd), int64)
    case (38) ! __yoeaerop_MOD_omgs_dd
pending%address=c_loc(state%aerosol_optical%omgs_dd(lbound(state%aerosol_optical%omgs_dd,1),lbound(state%aerosol_optical%omgs_dd,2)))
      pending%bytes = 336_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omgs_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omgs_dd), int64)
    case (39) ! __yoeaerop_MOD_alfs_fa
      pending%address = c_loc(state%aerosol_optical%alfs_fa(lbound(state%aerosol_optical%alfs_fa, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%alfs_fa), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%alfs_fa), int64)
    case (40) ! __yoeaerop_MOD_asys_fa
      pending%address = c_loc(state%aerosol_optical%asys_fa(lbound(state%aerosol_optical%asys_fa, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%asys_fa), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%asys_fa), int64)
    case (41) ! __yoeaerop_MOD_omgs_fa
      pending%address = c_loc(state%aerosol_optical%omgs_fa(lbound(state%aerosol_optical%omgs_fa, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%omgs_fa), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%omgs_fa), int64)
    case (42) ! __yoeaerop_MOD_alfs_om
pending%address=c_loc(state%aerosol_optical%alfs_om(lbound(state%aerosol_optical%alfs_om,1),lbound(state%aerosol_optical%alfs_om,2)))
      pending%bytes = 1344_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alfs_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alfs_om), int64)
    case (43) ! __yoeaerop_MOD_asys_om
pending%address=c_loc(state%aerosol_optical%asys_om(lbound(state%aerosol_optical%asys_om,1),lbound(state%aerosol_optical%asys_om,2)))
      pending%bytes = 1344_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asys_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asys_om), int64)
    case (44) ! __yoeaerop_MOD_omgs_om
pending%address=c_loc(state%aerosol_optical%omgs_om(lbound(state%aerosol_optical%omgs_om,1),lbound(state%aerosol_optical%omgs_om,2)))
      pending%bytes = 1344_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omgs_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omgs_om), int64)
    case (45) ! __yoeaerop_MOD_alfs_ss
pending%address=c_loc(state%aerosol_optical%alfs_ss(lbound(state%aerosol_optical%alfs_ss,1),lbound(state%aerosol_optical%alfs_ss,2),lbound(state%aerosol_optical%alfs_ss,3)))
      pending%bytes = 4032_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%alfs_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%alfs_ss), int64)
    case (46) ! __yoeaerop_MOD_asys_ss
pending%address=c_loc(state%aerosol_optical%asys_ss(lbound(state%aerosol_optical%asys_ss,1),lbound(state%aerosol_optical%asys_ss,2),lbound(state%aerosol_optical%asys_ss,3)))
      pending%bytes = 4032_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%asys_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%asys_ss), int64)
    case (47) ! __yoeaerop_MOD_omgs_ss
pending%address=c_loc(state%aerosol_optical%omgs_ss(lbound(state%aerosol_optical%omgs_ss,1),lbound(state%aerosol_optical%omgs_ss,2),lbound(state%aerosol_optical%omgs_ss,3)))
      pending%bytes = 4032_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%omgs_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%omgs_ss), int64)
    case (48) ! __yoeaerop_MOD_alfs_su
pending%address=c_loc(state%aerosol_optical%alfs_su(lbound(state%aerosol_optical%alfs_su,1),lbound(state%aerosol_optical%alfs_su,2)))
      pending%bytes = 1344_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alfs_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alfs_su), int64)
    case (49) ! __yoeaerop_MOD_asys_su
pending%address=c_loc(state%aerosol_optical%asys_su(lbound(state%aerosol_optical%asys_su,1),lbound(state%aerosol_optical%asys_su,2)))
      pending%bytes = 1344_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asys_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asys_su), int64)
    case (50) ! __yoeaerop_MOD_omgs_su
pending%address=c_loc(state%aerosol_optical%omgs_su(lbound(state%aerosol_optical%omgs_su,1),lbound(state%aerosol_optical%omgs_su,2)))
      pending%bytes = 1344_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omgs_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omgs_su), int64)
    case (51) ! __yoeaerop_MOD_alfl_bc
      pending%address = c_loc(state%aerosol_optical%alfl_bc(lbound(state%aerosol_optical%alfl_bc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%alfl_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%alfl_bc), int64)
    case (52) ! __yoeaerop_MOD_asyl_bc
      pending%address = c_loc(state%aerosol_optical%asyl_bc(lbound(state%aerosol_optical%asyl_bc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%asyl_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%asyl_bc), int64)
    case (53) ! __yoeaerop_MOD_omgl_bc
      pending%address = c_loc(state%aerosol_optical%omgl_bc(lbound(state%aerosol_optical%omgl_bc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%omgl_bc), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%omgl_bc), int64)
    case (54) ! __yoeaerop_MOD_alfl_dd
pending%address=c_loc(state%aerosol_optical%alfl_dd(lbound(state%aerosol_optical%alfl_dd,1),lbound(state%aerosol_optical%alfl_dd,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alfl_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alfl_dd), int64)
    case (55) ! __yoeaerop_MOD_asyl_dd
pending%address=c_loc(state%aerosol_optical%asyl_dd(lbound(state%aerosol_optical%asyl_dd,1),lbound(state%aerosol_optical%asyl_dd,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asyl_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asyl_dd), int64)
    case (56) ! __yoeaerop_MOD_omgl_dd
pending%address=c_loc(state%aerosol_optical%omgl_dd(lbound(state%aerosol_optical%omgl_dd,1),lbound(state%aerosol_optical%omgl_dd,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omgl_dd), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omgl_dd), int64)
    case (57) ! __yoeaerop_MOD_alfl_fa
      pending%address = c_loc(state%aerosol_optical%alfl_fa(lbound(state%aerosol_optical%alfl_fa, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%alfl_fa), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%alfl_fa), int64)
    case (58) ! __yoeaerop_MOD_asyl_fa
      pending%address = c_loc(state%aerosol_optical%asyl_fa(lbound(state%aerosol_optical%asyl_fa, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%asyl_fa), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%asyl_fa), int64)
    case (59) ! __yoeaerop_MOD_omgl_fa
      pending%address = c_loc(state%aerosol_optical%omgl_fa(lbound(state%aerosol_optical%omgl_fa, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%aerosol_optical%omgl_fa), int64)
      pending%upper(1:1) = int(ubound(state%aerosol_optical%omgl_fa), int64)
    case (60) ! __yoeaerop_MOD_alfl_om
pending%address=c_loc(state%aerosol_optical%alfl_om(lbound(state%aerosol_optical%alfl_om,1),lbound(state%aerosol_optical%alfl_om,2)))
      pending%bytes = 1536_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alfl_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alfl_om), int64)
    case (61) ! __yoeaerop_MOD_asyl_om
pending%address=c_loc(state%aerosol_optical%asyl_om(lbound(state%aerosol_optical%asyl_om,1),lbound(state%aerosol_optical%asyl_om,2)))
      pending%bytes = 1536_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asyl_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asyl_om), int64)
    case (62) ! __yoeaerop_MOD_omgl_om
pending%address=c_loc(state%aerosol_optical%omgl_om(lbound(state%aerosol_optical%omgl_om,1),lbound(state%aerosol_optical%omgl_om,2)))
      pending%bytes = 1536_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omgl_om), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omgl_om), int64)
    case (63) ! __yoeaerop_MOD_alfl_ss
pending%address=c_loc(state%aerosol_optical%alfl_ss(lbound(state%aerosol_optical%alfl_ss,1),lbound(state%aerosol_optical%alfl_ss,2),lbound(state%aerosol_optical%alfl_ss,3)))
      pending%bytes = 4608_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%alfl_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%alfl_ss), int64)
    case (64) ! __yoeaerop_MOD_asyl_ss
pending%address=c_loc(state%aerosol_optical%asyl_ss(lbound(state%aerosol_optical%asyl_ss,1),lbound(state%aerosol_optical%asyl_ss,2),lbound(state%aerosol_optical%asyl_ss,3)))
      pending%bytes = 4608_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%asyl_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%asyl_ss), int64)
    case (65) ! __yoeaerop_MOD_omgl_ss
pending%address=c_loc(state%aerosol_optical%omgl_ss(lbound(state%aerosol_optical%omgl_ss,1),lbound(state%aerosol_optical%omgl_ss,2),lbound(state%aerosol_optical%omgl_ss,3)))
      pending%bytes = 4608_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%aerosol_optical%omgl_ss), int64)
      pending%upper(1:3) = int(ubound(state%aerosol_optical%omgl_ss), int64)
    case (66) ! __yoeaerop_MOD_alfl_su
pending%address=c_loc(state%aerosol_optical%alfl_su(lbound(state%aerosol_optical%alfl_su,1),lbound(state%aerosol_optical%alfl_su,2)))
      pending%bytes = 1536_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%alfl_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%alfl_su), int64)
    case (67) ! __yoeaerop_MOD_asyl_su
pending%address=c_loc(state%aerosol_optical%asyl_su(lbound(state%aerosol_optical%asyl_su,1),lbound(state%aerosol_optical%asyl_su,2)))
      pending%bytes = 1536_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%asyl_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%asyl_su), int64)
    case (68) ! __yoeaerop_MOD_omgl_su
pending%address=c_loc(state%aerosol_optical%omgl_su(lbound(state%aerosol_optical%omgl_su,1),lbound(state%aerosol_optical%omgl_su,2)))
      pending%bytes = 1536_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%aerosol_optical%omgl_su), int64)
      pending%upper(1:2) = int(ubound(state%aerosol_optical%omgl_su), int64)
    case default
      return
    end select
    field = pending
    status = 0
  end function
end module forecast_owned_aerosol_optical_namespace
