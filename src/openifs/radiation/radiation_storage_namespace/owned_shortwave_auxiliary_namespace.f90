!> Expose every named shortwave auxiliary field on its canonical owner.
module forecast_owned_shortwave_auxiliary_namespace
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_int64_t
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use forecast_radiation_namespace_views, only: native_radiation_namespace_field
  implicit none
  private
  public :: initialize_owned_shortwave_auxiliary_namespace, get_owned_shortwave_auxiliary_field
contains
!> Initialize source zero-born fields before any setup producer is active.
!! STATE is the actual native owner. Live context or storage is refused.
  integer(int32) function initialize_owned_shortwave_auxiliary_namespace(state) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    status = 2
    if (state%context_ready .or. state%storage_ready .or. state%setup_complete) return
    state%shortwave_transmission%trans = 0.0_real64
    state%shortwave_transmission%bpade = 0.0_real64
    state%shortwave_transmission%rodlow = 0.0_real64
    state%shortwave_transmission%rtblint = 0.0_real64
    state%shortwave_auxiliary_aerosol%rsrtaua = 0.0_real64
    state%shortwave_auxiliary_aerosol%rsrpiza = 0.0_real64
    state%shortwave_auxiliary_aerosol%rsrasya = 0.0_real64
    state%shortwave_auxiliary_cloud%rsyfwa = 0.0_real64
    state%shortwave_auxiliary_cloud%rsyfwb = 0.0_real64
    state%shortwave_auxiliary_cloud%rsyfwc = 0.0_real64
    state%shortwave_auxiliary_cloud%rsyfwd = 0.0_real64
    state%shortwave_auxiliary_cloud%rsyfwe = 0.0_real64
    state%shortwave_auxiliary_cloud%rsyfwf = 0.0_real64
    state%shortwave_auxiliary_cloud%rsecia = 0.0_real64
    state%shortwave_auxiliary_cloud%rsecib = 0.0_real64
    state%shortwave_auxiliary_cloud%rsecic = 0.0_real64
    state%shortwave_auxiliary_cloud%rsecid = 0.0_real64
    state%shortwave_auxiliary_cloud%rsecie = 0.0_real64
    state%shortwave_auxiliary_cloud%rsecif = 0.0_real64
    state%shortwave_auxiliary_cloud%rsaswa = 0.0_real64
    state%shortwave_auxiliary_cloud%rsaswb = 0.0_real64
    state%shortwave_auxiliary_cloud%rsaswc = 0.0_real64
    state%shortwave_auxiliary_cloud%rsaswd = 0.0_real64
    state%shortwave_auxiliary_cloud%rsaswe = 0.0_real64
    state%shortwave_auxiliary_cloud%rsaswf = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfua0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfua1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfub0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfub1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfub2 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfub3 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfuc0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfuc1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfuc2 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfuc3 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfla0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfla1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflb0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflb1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflb2 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflb3 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflc0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflc1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflc2 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsflc3 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfld0 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfld1 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfld2 = 0.0_real64
    state%shortwave_auxiliary_cloud%rsfld3 = 0.0_real64
    status = 0
  end function
!> Borrow a complete named field by its frozen source-map index.
!! The caller keeps the actual TARGET owner alive. No scientific value is read.
  integer(int32) function get_owned_shortwave_auxiliary_field(state, index, field) result(status)
    type(owned_radiation_setup_state), target, intent(in) :: state
    integer(int32), intent(in) :: index
    type(native_radiation_namespace_field), intent(inout) :: field
    type(native_radiation_namespace_field) :: pending
    status = 2
    select case (index)
    case (1) ! __yoesrtab_MOD_trans
      pending%address = c_loc(state%shortwave_transmission%trans(lbound(state%shortwave_transmission%trans, 1)))
      pending%bytes = 80008_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_transmission%trans), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_transmission%trans), int64)
    case (2) ! __yoesrtab_MOD_bpade
      pending%address = c_loc(state%shortwave_transmission%bpade)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (3) ! __yoesrtab_MOD_rodlow
      pending%address = c_loc(state%shortwave_transmission%rodlow)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (4) ! __yoesrtab_MOD_rtblint
      pending%address = c_loc(state%shortwave_transmission%rtblint)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (5) ! __yoesrtaer_MOD_rsrtaua
pending%address=c_loc(state%shortwave_auxiliary_aerosol%rsrtaua(lbound(state%shortwave_auxiliary_aerosol%rsrtaua,1),lbound(state%shortwave_auxiliary_aerosol%rsrtaua,2)))
      pending%bytes = 672_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_auxiliary_aerosol%rsrtaua), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_auxiliary_aerosol%rsrtaua), int64)
    case (6) ! __yoesrtaer_MOD_rsrpiza
pending%address=c_loc(state%shortwave_auxiliary_aerosol%rsrpiza(lbound(state%shortwave_auxiliary_aerosol%rsrpiza,1),lbound(state%shortwave_auxiliary_aerosol%rsrpiza,2)))
      pending%bytes = 672_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_auxiliary_aerosol%rsrpiza), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_auxiliary_aerosol%rsrpiza), int64)
    case (7) ! __yoesrtaer_MOD_rsrasya
pending%address=c_loc(state%shortwave_auxiliary_aerosol%rsrasya(lbound(state%shortwave_auxiliary_aerosol%rsrasya,1),lbound(state%shortwave_auxiliary_aerosol%rsrasya,2)))
      pending%bytes = 672_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_auxiliary_aerosol%rsrasya), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_auxiliary_aerosol%rsrasya), int64)
    case (8) ! __yoesrtcop_MOD_rsyfwa
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsyfwa(lbound(state%shortwave_auxiliary_cloud%rsyfwa, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsyfwa), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsyfwa), int64)
    case (9) ! __yoesrtcop_MOD_rsyfwb
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsyfwb(lbound(state%shortwave_auxiliary_cloud%rsyfwb, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsyfwb), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsyfwb), int64)
    case (10) ! __yoesrtcop_MOD_rsyfwc
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsyfwc(lbound(state%shortwave_auxiliary_cloud%rsyfwc, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsyfwc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsyfwc), int64)
    case (11) ! __yoesrtcop_MOD_rsyfwd
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsyfwd(lbound(state%shortwave_auxiliary_cloud%rsyfwd, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsyfwd), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsyfwd), int64)
    case (12) ! __yoesrtcop_MOD_rsyfwe
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsyfwe(lbound(state%shortwave_auxiliary_cloud%rsyfwe, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsyfwe), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsyfwe), int64)
    case (13) ! __yoesrtcop_MOD_rsyfwf
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsyfwf(lbound(state%shortwave_auxiliary_cloud%rsyfwf, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsyfwf), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsyfwf), int64)
    case (14) ! __yoesrtcop_MOD_rsecia
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsecia(lbound(state%shortwave_auxiliary_cloud%rsecia, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsecia), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsecia), int64)
    case (15) ! __yoesrtcop_MOD_rsecib
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsecib(lbound(state%shortwave_auxiliary_cloud%rsecib, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsecib), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsecib), int64)
    case (16) ! __yoesrtcop_MOD_rsecic
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsecic(lbound(state%shortwave_auxiliary_cloud%rsecic, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsecic), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsecic), int64)
    case (17) ! __yoesrtcop_MOD_rsecid
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsecid(lbound(state%shortwave_auxiliary_cloud%rsecid, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsecid), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsecid), int64)
    case (18) ! __yoesrtcop_MOD_rsecie
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsecie(lbound(state%shortwave_auxiliary_cloud%rsecie, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsecie), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsecie), int64)
    case (19) ! __yoesrtcop_MOD_rsecif
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsecif(lbound(state%shortwave_auxiliary_cloud%rsecif, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsecif), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsecif), int64)
    case (20) ! __yoesrtcop_MOD_rsaswa
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsaswa(lbound(state%shortwave_auxiliary_cloud%rsaswa, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsaswa), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsaswa), int64)
    case (21) ! __yoesrtcop_MOD_rsaswb
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsaswb(lbound(state%shortwave_auxiliary_cloud%rsaswb, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsaswb), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsaswb), int64)
    case (22) ! __yoesrtcop_MOD_rsaswc
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsaswc(lbound(state%shortwave_auxiliary_cloud%rsaswc, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsaswc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsaswc), int64)
    case (23) ! __yoesrtcop_MOD_rsaswd
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsaswd(lbound(state%shortwave_auxiliary_cloud%rsaswd, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsaswd), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsaswd), int64)
    case (24) ! __yoesrtcop_MOD_rsaswe
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsaswe(lbound(state%shortwave_auxiliary_cloud%rsaswe, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsaswe), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsaswe), int64)
    case (25) ! __yoesrtcop_MOD_rsaswf
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsaswf(lbound(state%shortwave_auxiliary_cloud%rsaswf, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsaswf), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsaswf), int64)
    case (26) ! __yoesrtcop_MOD_rsfua0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfua0(lbound(state%shortwave_auxiliary_cloud%rsfua0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfua0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfua0), int64)
    case (27) ! __yoesrtcop_MOD_rsfua1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfua1(lbound(state%shortwave_auxiliary_cloud%rsfua1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfua1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfua1), int64)
    case (28) ! __yoesrtcop_MOD_rsfub0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfub0(lbound(state%shortwave_auxiliary_cloud%rsfub0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfub0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfub0), int64)
    case (29) ! __yoesrtcop_MOD_rsfub1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfub1(lbound(state%shortwave_auxiliary_cloud%rsfub1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfub1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfub1), int64)
    case (30) ! __yoesrtcop_MOD_rsfub2
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfub2(lbound(state%shortwave_auxiliary_cloud%rsfub2, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfub2), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfub2), int64)
    case (31) ! __yoesrtcop_MOD_rsfub3
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfub3(lbound(state%shortwave_auxiliary_cloud%rsfub3, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfub3), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfub3), int64)
    case (32) ! __yoesrtcop_MOD_rsfuc0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfuc0(lbound(state%shortwave_auxiliary_cloud%rsfuc0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfuc0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfuc0), int64)
    case (33) ! __yoesrtcop_MOD_rsfuc1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfuc1(lbound(state%shortwave_auxiliary_cloud%rsfuc1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfuc1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfuc1), int64)
    case (34) ! __yoesrtcop_MOD_rsfuc2
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfuc2(lbound(state%shortwave_auxiliary_cloud%rsfuc2, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfuc2), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfuc2), int64)
    case (35) ! __yoesrtcop_MOD_rsfuc3
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfuc3(lbound(state%shortwave_auxiliary_cloud%rsfuc3, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfuc3), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfuc3), int64)
    case (36) ! __yoesrtcop_MOD_rsfla0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfla0(lbound(state%shortwave_auxiliary_cloud%rsfla0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfla0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfla0), int64)
    case (37) ! __yoesrtcop_MOD_rsfla1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfla1(lbound(state%shortwave_auxiliary_cloud%rsfla1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfla1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfla1), int64)
    case (38) ! __yoesrtcop_MOD_rsflb0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflb0(lbound(state%shortwave_auxiliary_cloud%rsflb0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflb0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflb0), int64)
    case (39) ! __yoesrtcop_MOD_rsflb1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflb1(lbound(state%shortwave_auxiliary_cloud%rsflb1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflb1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflb1), int64)
    case (40) ! __yoesrtcop_MOD_rsflb2
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflb2(lbound(state%shortwave_auxiliary_cloud%rsflb2, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflb2), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflb2), int64)
    case (41) ! __yoesrtcop_MOD_rsflb3
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflb3(lbound(state%shortwave_auxiliary_cloud%rsflb3, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflb3), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflb3), int64)
    case (42) ! __yoesrtcop_MOD_rsflc0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflc0(lbound(state%shortwave_auxiliary_cloud%rsflc0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflc0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflc0), int64)
    case (43) ! __yoesrtcop_MOD_rsflc1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflc1(lbound(state%shortwave_auxiliary_cloud%rsflc1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflc1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflc1), int64)
    case (44) ! __yoesrtcop_MOD_rsflc2
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflc2(lbound(state%shortwave_auxiliary_cloud%rsflc2, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflc2), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflc2), int64)
    case (45) ! __yoesrtcop_MOD_rsflc3
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsflc3(lbound(state%shortwave_auxiliary_cloud%rsflc3, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsflc3), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsflc3), int64)
    case (46) ! __yoesrtcop_MOD_rsfld0
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfld0(lbound(state%shortwave_auxiliary_cloud%rsfld0, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfld0), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfld0), int64)
    case (47) ! __yoesrtcop_MOD_rsfld1
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfld1(lbound(state%shortwave_auxiliary_cloud%rsfld1, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfld1), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfld1), int64)
    case (48) ! __yoesrtcop_MOD_rsfld2
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfld2(lbound(state%shortwave_auxiliary_cloud%rsfld2, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfld2), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfld2), int64)
    case (49) ! __yoesrtcop_MOD_rsfld3
      pending%address = c_loc(state%shortwave_auxiliary_cloud%rsfld3(lbound(state%shortwave_auxiliary_cloud%rsfld3, 1)))
      pending%bytes = 112_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_auxiliary_cloud%rsfld3), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_auxiliary_cloud%rsfld3), int64)
    case default
      return
    end select
    field = pending
    status = 0
  end function
end module forecast_owned_shortwave_auxiliary_namespace
