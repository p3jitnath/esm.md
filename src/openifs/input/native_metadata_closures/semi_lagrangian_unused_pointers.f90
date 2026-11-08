!> Store the complete source unused-index prefix in its original order.
!! Indices are dimensionless. BUFFERS is the one canonical model owner.
!! Only the listed scalar components change; both parity owners stay untouched.
!! The full buffer constructor remains responsible for later active map stores.
module forecast_native_unused_interpolation_pointers
  use iso_fortran_env, only: int32
  use forecast_semi_lagrangian_buffer_types, only: native_semi_lagrangian_buffers
  implicit none
  private
  public :: initialize_native_unused_interpolation_pointers
contains
  subroutine initialize_native_unused_interpolation_pointers(buffers)
    type(native_semi_lagrangian_buffers), intent(inout) :: buffers
    buffers%first%mslbuf1 = -99999_int32
    buffers%first%mslb1ur9 = -99999_int32
    buffers%first%mslb1vr9 = -99999_int32
    buffers%first%mslb1zr9 = -99999_int32
    buffers%first%mslb1u9 = -99999_int32
    buffers%first%mslb1v9 = -99999_int32
    buffers%first%mslb1z9 = -99999_int32
    buffers%first%mslb1t9 = -99999_int32
    buffers%first%mslb1gfl9 = -99999_int32
    buffers%first%mslb1gflsp9 = -99999_int32
    buffers%first%mslb1sp9 = -99999_int32
    buffers%first%mslb1c9 = -99999_int32
    buffers%first%mslb1vd9 = -99999_int32
    buffers%first%mslb1nhx9 = -99999_int32
    buffers%first%mslb1pd9 = -99999_int32
    buffers%first%mslb1u9_si = -99999_int32
    buffers%first%mslb1v9_si = -99999_int32
    buffers%first%mslb1t9_si = -99999_int32
    buffers%first%mslb1c9_si = -99999_int32
    buffers%first%mslb1vd9_si = -99999_int32
    buffers%first%mslb1pd9_si = -99999_int32
    buffers%first%mslb1u9_nl = -99999_int32
    buffers%first%mslb1v9_nl = -99999_int32
    buffers%first%mslb1t9_nl = -99999_int32
    buffers%first%mslb1c9_nl = -99999_int32
    buffers%first%mslb1vd9_nl = -99999_int32
    buffers%first%mslb1pd9_nl = -99999_int32
    buffers%first%mslb1uf9 = -99999_int32
    buffers%first%mslb1vf9 = -99999_int32
    buffers%first%mslb1tf9 = -99999_int32
    buffers%first%mslb1gflf9 = -99999_int32
    buffers%first%mslb1vdf9 = -99999_int32
    buffers%first%mslb1gflspf9 = -99999_int32
    buffers%first%mslb1dbbc9 = -99999_int32
    buffers%first%mslb1dphi9 = -99999_int32
    buffers%first%mslb1gws9 = -99999_int32
    buffers%first%mslb1ur0 = -99999_int32
    buffers%first%mslb1vr0 = -99999_int32
    buffers%first%mslb1zr0 = -99999_int32
    buffers%first%mslb1wr0 = -99999_int32
    buffers%first%mslb1ur00 = -99999_int32
    buffers%first%mslb1vr00 = -99999_int32
    buffers%first%mslb1zr00 = -99999_int32
    buffers%first%mslb1wr00 = -99999_int32
    buffers%first%mslb1wra = -99999_int32
    buffers%first%mslb1u0 = -99999_int32
    buffers%first%mslb1v0 = -99999_int32
    buffers%first%mslb1z0 = -99999_int32
    buffers%first%mslb1t0 = -99999_int32
    buffers%first%mslb1c0 = -99999_int32
    buffers%first%mslb1vd0 = -99999_int32
    buffers%first%mslb1pd0 = -99999_int32
    buffers%first%mslb1up9 = -99999_int32
    buffers%first%mslb1vp9 = -99999_int32
    buffers%first%mslb1zp9 = -99999_int32
    buffers%first%mslb1tp9 = -99999_int32
    buffers%first%mslb1gflp9 = -99999_int32
    buffers%second%mslbuf2 = -99999_int32
    buffers%second%mslb2dbbc1 = -99999_int32
    buffers%second%mslb2dphi1 = -99999_int32
    buffers%second%mslb2usi = -99999_int32
    buffers%second%mslb2vsi = -99999_int32
    buffers%second%mslb2tsi = -99999_int32
    buffers%second%mslb2pdsi = -99999_int32
    buffers%second%mslb2vdsi = -99999_int32
    buffers%second%mslb2spsi = -99999_int32
    buffers%second%mslb2vvel = -99999_int32
    buffers%second%mslb2url = -99999_int32
    buffers%second%mslb2vrl = -99999_int32
    buffers%second%mslb2wrl = -99999_int32
    buffers%second%mslb2zrl = -99999_int32
    buffers%second%mslb2u15 = -99999_int32
    buffers%second%mslb2v15 = -99999_int32
    buffers%second%mslb2t15 = -99999_int32
    buffers%second%mslb2q15 = -99999_int32
    buffers%second%mslb2url5 = -99999_int32
    buffers%second%mslb2vrl5 = -99999_int32
    buffers%second%mslb2wrl5 = -99999_int32
    buffers%second%mslb2zrl5 = -99999_int32
    buffers%second%mslb2kappa = -99999_int32
    buffers%second%mslb2kappa5 = -99999_int32
    buffers%second%mslb2kappat = -99999_int32
    buffers%second%mslb2kappat5 = -99999_int32
    buffers%second%mslb2kappam = -99999_int32
    buffers%second%mslb2kappah = -99999_int32
    buffers%second%mslb2gwf = -99999_int32
    buffers%second%mslb2gdw = -99999_int32
    buffers%second%mslb2gws = -99999_int32
    buffers%second%mslb2stddisu = -99999_int32
    buffers%second%mslb2stddisu5 = -99999_int32
    buffers%second%mslb2stddisv = -99999_int32
    buffers%second%mslb2stddisv5 = -99999_int32
    buffers%second%mslb2stddisw = -99999_int32
    buffers%second%mslb2stddisw5 = -99999_int32
    buffers%refined%mslbuf15 = -99999_int32
    buffers%refined%mslb1u95 = -99999_int32
    buffers%refined%mslb1v95 = -99999_int32
    buffers%refined%mslb1z95 = -99999_int32
    buffers%refined%mslb1t95 = -99999_int32
    buffers%refined%mslb1gfl95 = -99999_int32
    buffers%refined%mslb1u05 = -99999_int32
    buffers%refined%mslb1v05 = -99999_int32
    buffers%refined%mslb1z05 = -99999_int32
    buffers%refined%mslb1t05 = -99999_int32
    buffers%refined%mslb1c95 = -99999_int32
    buffers%refined%mslb1c05 = -99999_int32
    buffers%refined%mslb1sp95 = -99999_int32
    buffers%refined%mslb1ur05 = -99999_int32
    buffers%refined%mslb1vr05 = -99999_int32
    buffers%refined%mslb1zr05 = -99999_int32
    buffers%refined%mslb1wr05 = -99999_int32
    buffers%refined%mslb1ur005 = -99999_int32
    buffers%refined%mslb1vr005 = -99999_int32
    buffers%refined%mslb1zr005 = -99999_int32
    buffers%refined%mslb1wr005 = -99999_int32
    buffers%refined%mslb1ur95 = -99999_int32
    buffers%refined%mslb1vr95 = -99999_int32
    buffers%refined%mslb1zr95 = -99999_int32
    buffers%refined%mslb1up95 = -99999_int32
    buffers%refined%mslb1vp95 = -99999_int32
    buffers%refined%mslb1zp95 = -99999_int32
    buffers%refined%mslb1tp95 = -99999_int32
    buffers%refined%mslb1gflp95 = -99999_int32
  end subroutine
end module
