!> Produce the source SUDYN time-filter weights in one actual startup owner.
module forecast_source_time_filter_weights
  use iso_fortran_env, only: int32, real64
  use physics_configuration_text_port, only: find_physics_group
  implicit none
  private
  public :: native_time_filter_weights, initialize_source_time_filter_weights
  !> Dimensionless FP64 source weights. READY records this producer's completion.
 !! The owner is caller-owned and remains at its final address through GPTF1/2.
  type :: native_time_filter_weights
    real(real64) :: reps1, reps2, repsm1, repsm2, repsp1
    logical :: ready = .false.
  end type
contains
  !> Preserve every branch of SUDYN section1.03 and the admitted NAMDYN READ.
 !! TEXT is the same active configuration,1:262144 ASCII bytes. LECMWF,
 !! SEMI_LAGRANGIAN and TWO_TIME_LEVELS are actual produced source controls.
 !! NITMP_IN/LMASCOR_IN are the already produced trajectory values, supplied
 !! because the current admitted first NAMDYN also contains those names.
 !! All five source weights support formatted namelist overrides. Other keys
 !! refuse with status2 before OUTPUT changes. The public Fortran runtime
 !! owns decimal conversion and its natural IEEE/errno effects; none are reset.
 !! Source diagnostic file output is outside this numerical/control interface.
 !! These are startup constants: the original forecast routines only read them.
  integer(int32) function initialize_source_time_filter_weights(text, lecmwf, semi_lagrangian, two_time_levels, &
                                                                nitmp_in, lmascor_in, output) result(status)
    character(*), intent(in) :: text
    logical, intent(in) :: lecmwf, semi_lagrangian, two_time_levels, lmascor_in
    integer(int32), intent(in) :: nitmp_in
    type(native_time_filter_weights), intent(inout) :: output
    real(real64) :: reps1, reps2, repsm1, repsm2, repsp1
    logical :: lmascor
    integer(int32) :: nitmp
    integer :: cursor, io
    namelist /NAMDYN/ reps1, reps2, repsp1, repsm1, repsm2, nitmp, lmascor
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    cursor = find_physics_group(text, 'NAMDYN', .false.)
    if (cursor == 0) return
    if (lecmwf) then
      reps1 = 0.1_real64
      reps2 = 0.1_real64
      repsp1 = 0.1_real64
      repsm1 = 0.1_real64
      repsm2 = 0.1_real64
    else
      if (semi_lagrangian .and. two_time_levels) then
        reps1 = 0.0_real64
        reps2 = 0.0_real64
        repsp1 = 0.0_real64
        repsm1 = 0.0_real64
        repsm2 = 0.0_real64
      else
        reps1 = 0.05_real64
        reps2 = 0.05_real64
        repsp1 = 0.05_real64
        repsm1 = 0.05_real64
        repsm2 = 0.05_real64
      end if
    end if
    nitmp = nitmp_in; lmascor = lmascor_in
    block
      character(len=len(text) + 8) :: group
      group = '&NAMDYN '//text(cursor:)
      read (group, nml=NAMDYN, iostat=io)
    end block
    if (io /= 0) return
    output%reps1 = reps1
    output%reps2 = reps2
    output%repsp1 = repsp1
    output%repsm1 = repsm1
    output%repsm2 = repsm2
    output%ready = .true.
    status = 0_int32
  end function
end module
