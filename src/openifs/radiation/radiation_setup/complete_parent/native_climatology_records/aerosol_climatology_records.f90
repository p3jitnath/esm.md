!> Own aerosol climatology records without calling original finalizers.
!! Component declarations follow the public OpenIFS data types. The new
!! records have no original type-bound setup or finalization procedure.
!! Native setup and explicit release routines own every selected resource.
!! This declaration port contains no original numerical routine.
!!
!! Original declaration copyright: ECMWF and Meteo-France, Apache-2.0.
!! The license is https://www.apache.org/licenses/LICENSE-2.0.
module owned_aerosol_climatology_records
  use iso_fortran_env, only: real64, int32
  implicit none
  private
  public :: teaerc_tegen, teaerc_macc
  integer(int32), parameter :: ishist = 1850_int32, iehist = 2100_int32
  TYPE :: TEAERC_TEGEN
    real(real64) :: REPAER = -HUGE(1._real64)
    real(real64), POINTER, DIMENSION(:, :, :) :: RAERBC => NULL(), RAEROR => NULL(), RAERSD => NULL()
    real(real64), POINTER, DIMENSION(:, :, :) :: RAERSS => NULL(), RAERSU => NULL()
    real(real64), POINTER, DIMENSION(:, :, :) :: RAERV => NULL()
    real(real64), POINTER, DIMENSION(:) :: RLATV => NULL()
    real(real64) :: RTAEBC(72, 46), RTAEOR(72, 46), RTAESD(72, 46)
    real(real64) :: RTAESS(72, 46), RTAESU(72, 46), RTAEVO(46)
    integer(int32) :: ISYEAR = IEHIST, IEYEAR = ISHIST

    LOGICAL :: IS_INITIALISED = .FALSE.
  end type TEAERC_TEGEN

  TYPE :: TEAERC_MACC
!- based on optical depth

    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMACBC, RMACOR, RMACSD, RMACSS, RMACSU !! appear not to be used
    real(real64), ALLOCATABLE, DIMENSION(:, :) :: RMAEBC, RMAEOR, RMAESD, RMAESS, RMAESU

!- based on vertically integrated mass

    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMACBC1, RMACBC2
    real(real64), ALLOCATABLE, DIMENSION(:, :) :: RMAEBC1, RMAEBC2
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMACOR1, RMACOR2
    real(real64), ALLOCATABLE, DIMENSION(:, :) :: RMAEOR1, RMAEOR2
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMACSD1, RMACSD2, RMACSD3
    real(real64), ALLOCATABLE, DIMENSION(:, :) :: RMAESD1, RMAESD2, RMAESD3
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMACSS1, RMACSS2, RMACSS3
    real(real64), ALLOCATABLE, DIMENSION(:, :) :: RMAESS1, RMAESS2, RMAESS3
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMACSU1
    real(real64), ALLOCATABLE, DIMENSION(:, :) :: RMAESU1

!arrays for input 3D climatology on a 3x3 deg and 60 level grid
!lon,lat,lev,month
    real(real64), POINTER, CONTIGUOUS, DIMENSION(:, :, :, :) :: RMACBC13D => NULL(), RMACBC23D => NULL()
    real(real64), POINTER, CONTIGUOUS, DIMENSION(:, :, :, :) :: RMACOR13D => NULL(), RMACOR23D => NULL()
    real(real64), POINTER, CONTIGUOUS, DIMENSION(:, :, :, :) :: RMACSD13D => NULL(), RMACSD23D => NULL(), RMACSD33D => NULL()
    real(real64), POINTER, CONTIGUOUS, DIMENSION(:, :, :, :) :: RMACSS13D => NULL(), RMACSS23D => NULL(), RMACSS33D => NULL()
    real(real64), POINTER, CONTIGUOUS, DIMENSION(:, :, :, :) :: RMACSU13D => NULL()
    real(real64), POINTER, CONTIGUOUS, DIMENSION(:, :, :, :) :: REF_MON_AER_PRS => NULL(), REF_MON_AER_DPRS => NULL()
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMAEBC13D, RMAEBC23D
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMAEOR13D, RMAEOR23D
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMAESD13D, RMAESD23D, RMAESD33D
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMAESS13D, RMAESS23D, RMAESS33D
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: RMAESU13D
    real(real64), ALLOCATABLE, DIMENSION(:, :, :) :: REF_AER_PRS, REF_AER_DPRS

    LOGICAL :: IS_INITIALISED = .FALSE.
  end type TEAERC_MACC
end module owned_aerosol_climatology_records
