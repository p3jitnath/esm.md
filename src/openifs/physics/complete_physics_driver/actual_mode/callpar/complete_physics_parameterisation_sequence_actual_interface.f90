!> Direct native interface for the complete selected physical process sequence.
!! The implementation follows the generated CALLPAR arithmetic and call order.
!! This file declares the interface only and supplies no numerical stage.
module forecast_complete_physics_parameterisation_sequence
  use iso_fortran_env, only: int32, int64, real64
  use forecast_complete_physics_context_types, only: native_complete_physics_context, native_complete_physics_driver_inputs
  use forecast_physics_provider_targets, only: callpar_provider_targets
  implicit none
  private
  public :: callpar_provider_targets, callpar, callpar_runtime
  !> Borrow the actual produced constants, parameters and live clock targets.
  !! Every target remains at a stable address through the complete call.
  !! No provider owns a second clock, numerical field or parameter record.
  !! BYTE_LIMIT is the available local-work payload budget, measured in bytes.
  interface
    !> Run one actual column block through the complete native physics sequence.
    !! CONTEXT owns the current work records and borrows the same live fields
    !! as INPUTS. ZAG and ZRECO are the caller's KLON-element carbon flux scratch
    !! arrays, in kg(C)/m2/s; CGPP/CREC adjustment coefficients remain separate.
    !! No input array is copied before its metadata admission. Physical fields
    !! keep their source units: K,Pa,m/s,kg/kg and rates per second.
    !! Status0 completes the sequence. Other statuses leave the source prefix
    !! visible and release only local work acquired by this invocation.
    module integer(int32) function callpar(context, inputs, providers, zag, zreco) result(status)
      type(native_complete_physics_context), target, intent(inout) :: context
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
      type(callpar_provider_targets), intent(in) :: providers
      real(real64), intent(inout) :: zag(:), zreco(:)
    end function
    module integer(int32) function callpar_runtime(context, inputs, providers, zag, zreco) result(status)
      type(native_complete_physics_context), target, intent(inout) :: context
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
      type(callpar_provider_targets), intent(in) :: providers
      real(real64), intent(inout) :: zag(:), zreco(:)
    end function
  end interface
end module forecast_complete_physics_parameterisation_sequence
