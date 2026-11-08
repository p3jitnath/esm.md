!> Construct the selected three-stage shortwave auxiliary parameters.
!! Native records replace the old radiation module namespaces. The selected
!! generated body is shortwave_auxiliary_fields.S; its literal include owns
!! every table word. Original modules are declaration references only.
module shortwave_auxiliary_parameter_fields_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: shortwave_transmission_parameter_record
  public :: shortwave_aerosol_parameter_record
  public :: shortwave_cloud_parameter_record
  public :: initialize_shortwave_auxiliary_fields
  public :: initialize_shortwave_transmission_fields
  public :: initialize_shortwave_aerosol_optical_fields
  public :: initialize_shortwave_cloud_optical_fields

  !> Caller-owned SUSRTAB data; transmission and its coefficients are dimensionless.
  !! TRANS has the original lower bound zero. RTBLINT is the source interval
  !! count stored as FP64. All four components are written by their initializer.
  type :: shortwave_transmission_parameter_record
    real(real64) :: trans(0:10000), bpade, rodlow, rtblint
  end type shortwave_transmission_parameter_record

  !> Caller-owned SUSRTAER coefficients for fourteen bands and six aerosol types.
  !! RSRTAUA is normalized optical thickness. RSRPIZA is single-scattering
  !! albedo and RSRASYA is asymmetry; all are dimensionless source coefficients.
  type :: shortwave_aerosol_parameter_record
    real(real64) :: rsrtaua(14, 6)
    real(real64) :: rsrpiza(14, 6)
    real(real64) :: rsrasya(14, 6)
  end type shortwave_aerosol_parameter_record

  !> Caller-owned SUSRTCOP cloud optical fit coefficients in source order.
  !! Each field has fourteen spectral intervals. The source consumers supply
  !! particle radius in micrometres; retain these fitted coefficient units
  !! and the two declared runtime unit conversions without changing the fit.
  type :: shortwave_cloud_parameter_record
    real(real64) :: rsyfwa(14)
    real(real64) :: rsyfwb(14)
    real(real64) :: rsyfwc(14)
    real(real64) :: rsyfwd(14)
    real(real64) :: rsyfwe(14)
    real(real64) :: rsyfwf(14)
    real(real64) :: rsecia(14)
    real(real64) :: rsecib(14)
    real(real64) :: rsecic(14)
    real(real64) :: rsecid(14)
    real(real64) :: rsecie(14)
    real(real64) :: rsecif(14)
    real(real64) :: rsaswa(14)
    real(real64) :: rsaswb(14)
    real(real64) :: rsaswc(14)
    real(real64) :: rsaswd(14)
    real(real64) :: rsaswe(14)
    real(real64) :: rsaswf(14)
    real(real64) :: rsfua0(14)
    real(real64) :: rsfua1(14)
    real(real64) :: rsfub0(14)
    real(real64) :: rsfub1(14)
    real(real64) :: rsfub2(14)
    real(real64) :: rsfub3(14)
    real(real64) :: rsfuc0(14)
    real(real64) :: rsfuc1(14)
    real(real64) :: rsfuc2(14)
    real(real64) :: rsfuc3(14)
    real(real64) :: rsfla0(14)
    real(real64) :: rsfla1(14)
    real(real64) :: rsflb0(14)
    real(real64) :: rsflb1(14)
    real(real64) :: rsflb2(14)
    real(real64) :: rsflb3(14)
    real(real64) :: rsflc0(14)
    real(real64) :: rsflc1(14)
    real(real64) :: rsflc2(14)
    real(real64) :: rsflc3(14)
    real(real64) :: rsfld0(14)
    real(real64) :: rsfld1(14)
    real(real64) :: rsfld2(14)
    real(real64) :: rsfld3(14)
  end type shortwave_cloud_parameter_record

  interface
    function selected_public_exp(value) bind(C, name='exp') result(exponential)
      import :: c_double
      real(c_double), value, intent(in) :: value
      real(c_double) :: exponential
    end function selected_public_exp
  end interface

  ! Named arrays retain all exact source literals before any unit conversion.
  real(real64), parameter :: rsrtaua_column_1(14) = [ &
                     transfer(int(z'3fbbc60029f16b12', int64), 0.0_real64), transfer(int(z'3fbbc60029f16b12', int64), 0.0_real64), &
                     transfer(int(z'3fca4b87bdcf0308', int64), 0.0_real64), transfer(int(z'3fca4b87bdcf0308', int64), 0.0_real64), &
                     transfer(int(z'3fca4b87bdcf0308', int64), 0.0_real64), transfer(int(z'3fca4b87bdcf0308', int64), 0.0_real64), &
                     transfer(int(z'3fca4b87bdcf0308', int64), 0.0_real64), transfer(int(z'3fe0e87d2c7b890d', int64), 0.0_real64), &
                     transfer(int(z'3fe0e87d2c7b890d', int64), 0.0_real64), transfer(int(z'3ffb1c8216c61523', int64), 0.0_real64), &
                     transfer(int(z'3ffb1c8216c61523', int64), 0.0_real64), transfer(int(z'3ffb1c8216c61523', int64), 0.0_real64), &
                       transfer(int(z'3ffb1c8216c61523', int64), 0.0_real64), transfer(int(z'3fbbc60029f16b12', int64), 0.0_real64)]
  real(real64), parameter :: rsrtaua_column_2(14) = [ &
                     transfer(int(z'3fe557fb69984a0e', int64), 0.0_real64), transfer(int(z'3fe557fb69984a0e', int64), 0.0_real64), &
                     transfer(int(z'3feb15df6555c52e', int64), 0.0_real64), transfer(int(z'3feb15df6555c52e', int64), 0.0_real64), &
                     transfer(int(z'3feb15df6555c52e', int64), 0.0_real64), transfer(int(z'3feb15df6555c52e', int64), 0.0_real64), &
                     transfer(int(z'3feb15df6555c52e', int64), 0.0_real64), transfer(int(z'3fedd9e83e425aee', int64), 0.0_real64), &
                     transfer(int(z'3fedd9e83e425aee', int64), 0.0_real64), transfer(int(z'3ff1e594af4f0d84', int64), 0.0_real64), &
                     transfer(int(z'3ff1e594af4f0d84', int64), 0.0_real64), transfer(int(z'3ff1e594af4f0d84', int64), 0.0_real64), &
                       transfer(int(z'3ff1e594af4f0d84', int64), 0.0_real64), transfer(int(z'3fe557fb69984a0e', int64), 0.0_real64)]
  real(real64), parameter :: rsrtaua_column_3(14) = [ &
                     transfer(int(z'3fe4e1b089a02752', int64), 0.0_real64), transfer(int(z'3fe4e1b089a02752', int64), 0.0_real64), &
                     transfer(int(z'3feb2fc2656abde4', int64), 0.0_real64), transfer(int(z'3feb2fc2656abde4', int64), 0.0_real64), &
                     transfer(int(z'3feb2fc2656abde4', int64), 0.0_real64), transfer(int(z'3feb2fc2656abde4', int64), 0.0_real64), &
                     transfer(int(z'3feb2fc2656abde4', int64), 0.0_real64), transfer(int(z'3fede757928e0c9e', int64), 0.0_real64), &
                     transfer(int(z'3fede757928e0c9e', int64), 0.0_real64), transfer(int(z'3ff17952d234eb9a', int64), 0.0_real64), &
                     transfer(int(z'3ff17952d234eb9a', int64), 0.0_real64), transfer(int(z'3ff17952d234eb9a', int64), 0.0_real64), &
                       transfer(int(z'3ff17952d234eb9a', int64), 0.0_real64), transfer(int(z'3fe4e1b089a02752', int64), 0.0_real64)]
  real(real64), parameter :: rsrtaua_column_4(14) = [ &
                     transfer(int(z'3fbdb22d0e560419', int64), 0.0_real64), transfer(int(z'3fbdb22d0e560419', int64), 0.0_real64), &
                     transfer(int(z'3fcbbdcf0307f23d', int64), 0.0_real64), transfer(int(z'3fcbbdcf0307f23d', int64), 0.0_real64), &
                     transfer(int(z'3fcbbdcf0307f23d', int64), 0.0_real64), transfer(int(z'3fcbbdcf0307f23d', int64), 0.0_real64), &
                     transfer(int(z'3fcbbdcf0307f23d', int64), 0.0_real64), transfer(int(z'3fe0fc2656abde40', int64), 0.0_real64), &
                     transfer(int(z'3fe0fc2656abde40', int64), 0.0_real64), transfer(int(z'3ffb8b0f27bb2fec', int64), 0.0_real64), &
                     transfer(int(z'3ffb8b0f27bb2fec', int64), 0.0_real64), transfer(int(z'3ffb8b0f27bb2fec', int64), 0.0_real64), &
                       transfer(int(z'3ffb8b0f27bb2fec', int64), 0.0_real64), transfer(int(z'3fbdb22d0e560419', int64), 0.0_real64)]
  real(real64), parameter :: rsrtaua_column_5(14) = [ &
                     transfer(int(z'3fb0b6d86ec17ebb', int64), 0.0_real64), transfer(int(z'3fb0b6d86ec17ebb', int64), 0.0_real64), &
                     transfer(int(z'3fd217c1bda5119d', int64), 0.0_real64), transfer(int(z'3fd217c1bda5119d', int64), 0.0_real64), &
                     transfer(int(z'3fd217c1bda5119d', int64), 0.0_real64), transfer(int(z'3fd217c1bda5119d', int64), 0.0_real64), &
                     transfer(int(z'3fd217c1bda5119d', int64), 0.0_real64), transfer(int(z'3fe57cc39ffd60e9', int64), 0.0_real64), &
                     transfer(int(z'3fe57cc39ffd60e9', int64), 0.0_real64), transfer(int(z'3ff09e060fe47992', int64), 0.0_real64), &
                     transfer(int(z'3ff09e060fe47992', int64), 0.0_real64), transfer(int(z'3ff09e060fe47992', int64), 0.0_real64), &
                       transfer(int(z'3ff09e060fe47992', int64), 0.0_real64), transfer(int(z'3fb0b6d86ec17ebb', int64), 0.0_real64)]
  real(real64), parameter :: rsrtaua_column_6(14) = [ &
                     transfer(int(z'3fa6e04c05921038', int64), 0.0_real64), transfer(int(z'3fa6e04c05921038', int64), 0.0_real64), &
                     transfer(int(z'3fbbf141205bc01a', int64), 0.0_real64), transfer(int(z'3fbbf141205bc01a', int64), 0.0_real64), &
                     transfer(int(z'3fbbf141205bc01a', int64), 0.0_real64), transfer(int(z'3fbbf141205bc01a', int64), 0.0_real64), &
                     transfer(int(z'3fbbf141205bc01a', int64), 0.0_real64), transfer(int(z'3fddd441355475a3', int64), 0.0_real64), &
                     transfer(int(z'3fddd441355475a3', int64), 0.0_real64), transfer(int(z'3ff1ed527e521577', int64), 0.0_real64), &
                     transfer(int(z'3ff1ed527e521577', int64), 0.0_real64), transfer(int(z'3ff1ed527e521577', int64), 0.0_real64), &
                       transfer(int(z'3ff1ed527e521577', int64), 0.0_real64), transfer(int(z'3fa6e04c05921038', int64), 0.0_real64)]
  real(real64), parameter :: rsrpiza_column_1(14) = [ &
                     transfer(int(z'3fe0bcd431451c6a', int64), 0.0_real64), transfer(int(z'3fe0bcd431451c6a', int64), 0.0_real64), &
                     transfer(int(z'3fea84d40fb72d28', int64), 0.0_real64), transfer(int(z'3fea84d40fb72d28', int64), 0.0_real64), &
                     transfer(int(z'3fea84d40fb72d28', int64), 0.0_real64), transfer(int(z'3fea84d40fb72d28', int64), 0.0_real64), &
                     transfer(int(z'3fea84d40fb72d28', int64), 0.0_real64), transfer(int(z'3fecb454d112acab', int64), 0.0_real64), &
                     transfer(int(z'3fecb454d112acab', int64), 0.0_real64), transfer(int(z'3fed46c8dc7d43f8', int64), 0.0_real64), &
                     transfer(int(z'3fed46c8dc7d43f8', int64), 0.0_real64), transfer(int(z'3fed46c8dc7d43f8', int64), 0.0_real64), &
                       transfer(int(z'3fed46c8dc7d43f8', int64), 0.0_real64), transfer(int(z'3fe0bcd431451c6a', int64), 0.0_real64)]
  real(real64), parameter :: rsrpiza_column_2(14) = [ &
                     transfer(int(z'3fe92de3d3798f38', int64), 0.0_real64), transfer(int(z'3fe92de3d3798f38', int64), 0.0_real64), &
                     transfer(int(z'3fefd68b926fd9ad', int64), 0.0_real64), transfer(int(z'3fefd68b926fd9ad', int64), 0.0_real64), &
                     transfer(int(z'3fefd68b926fd9ad', int64), 0.0_real64), transfer(int(z'3fefd68b926fd9ad', int64), 0.0_real64), &
                     transfer(int(z'3fefd68b926fd9ad', int64), 0.0_real64), transfer(int(z'3feff3a9b0681238', int64), 0.0_real64), &
                     transfer(int(z'3feff3a9b0681238', int64), 0.0_real64), transfer(int(z'3fefdc18cfda9e47', int64), 0.0_real64), &
                     transfer(int(z'3fefdc18cfda9e47', int64), 0.0_real64), transfer(int(z'3fefdc18cfda9e47', int64), 0.0_real64), &
                       transfer(int(z'3fefdc18cfda9e47', int64), 0.0_real64), transfer(int(z'3fe92de3d3798f38', int64), 0.0_real64)]
  real(real64), parameter :: rsrpiza_column_3(14) = [ &
                     transfer(int(z'3feb4d07badf647f', int64), 0.0_real64), transfer(int(z'3feb4d07badf647f', int64), 0.0_real64), &
                     transfer(int(z'3fedb1cd3755d7a3', int64), 0.0_real64), transfer(int(z'3fedb1cd3755d7a3', int64), 0.0_real64), &
                     transfer(int(z'3fedb1cd3755d7a3', int64), 0.0_real64), transfer(int(z'3fedb1cd3755d7a3', int64), 0.0_real64), &
                     transfer(int(z'3fedb1cd3755d7a3', int64), 0.0_real64), transfer(int(z'3fed95fd9846b343', int64), 0.0_real64), &
                     transfer(int(z'3fed95fd9846b343', int64), 0.0_real64), transfer(int(z'3fe803c155a04585', int64), 0.0_real64), &
                     transfer(int(z'3fe803c155a04585', int64), 0.0_real64), transfer(int(z'3fe803c155a04585', int64), 0.0_real64), &
                       transfer(int(z'3fe803c155a04585', int64), 0.0_real64), transfer(int(z'3feb4d07badf647f', int64), 0.0_real64)]
  real(real64), parameter :: rsrpiza_column_4(14) = [ &
                     transfer(int(z'3fd9e87cc11bbea2', int64), 0.0_real64), transfer(int(z'3fd9e87cc11bbea2', int64), 0.0_real64), &
                     transfer(int(z'3fe5a5ee06027880', int64), 0.0_real64), transfer(int(z'3fe5a5ee06027880', int64), 0.0_real64), &
                     transfer(int(z'3fe5a5ee06027880', int64), 0.0_real64), transfer(int(z'3fe5a5ee06027880', int64), 0.0_real64), &
                     transfer(int(z'3fe5a5ee06027880', int64), 0.0_real64), transfer(int(z'3fe8dbdc69f8c21e', int64), 0.0_real64), &
                     transfer(int(z'3fe8dbdc69f8c21e', int64), 0.0_real64), transfer(int(z'3fea05308bb90646', int64), 0.0_real64), &
                     transfer(int(z'3fea05308bb90646', int64), 0.0_real64), transfer(int(z'3fea05308bb90646', int64), 0.0_real64), &
                       transfer(int(z'3fea05308bb90646', int64), 0.0_real64), transfer(int(z'3fd9e87cc11bbea2', int64), 0.0_real64)]
  real(real64), parameter :: rsrpiza_column_5(14) = [ &
                     transfer(int(z'3febfe8d0389217c', int64), 0.0_real64), transfer(int(z'3febfe8d0389217c', int64), 0.0_real64), &
                     transfer(int(z'3fee4bd7038773fd', int64), 0.0_real64), transfer(int(z'3fee4bd7038773fd', int64), 0.0_real64), &
                     transfer(int(z'3fee4bd7038773fd', int64), 0.0_real64), transfer(int(z'3fee4bd7038773fd', int64), 0.0_real64), &
                     transfer(int(z'3fee4bd7038773fd', int64), 0.0_real64), transfer(int(z'3fee813d4c91a90a', int64), 0.0_real64), &
                     transfer(int(z'3fee813d4c91a90a', int64), 0.0_real64), transfer(int(z'3fee160a63305101', int64), 0.0_real64), &
                     transfer(int(z'3fee160a63305101', int64), 0.0_real64), transfer(int(z'3fee160a63305101', int64), 0.0_real64), &
                       transfer(int(z'3fee160a63305101', int64), 0.0_real64), transfer(int(z'3febfe8d0389217c', int64), 0.0_real64)]
  real(real64), parameter :: rsrpiza_column_6(14) = [ &
                     transfer(int(z'3fce270cb443690b', int64), 0.0_real64), transfer(int(z'3fce270cb443690b', int64), 0.0_real64), &
                     transfer(int(z'3fefdbe787633630', int64), 0.0_real64), transfer(int(z'3fefdbe787633630', int64), 0.0_real64), &
                     transfer(int(z'3fefdbe787633630', int64), 0.0_real64), transfer(int(z'3fefdbe787633630', int64), 0.0_real64), &
                     transfer(int(z'3fefdbe787633630', int64), 0.0_real64), transfer(int(z'3fefffffca501acb', int64), 0.0_real64), &
                     transfer(int(z'3fefffffca501acb', int64), 0.0_real64), transfer(int(z'3fefffffca501acb', int64), 0.0_real64), &
                     transfer(int(z'3fefffffca501acb', int64), 0.0_real64), transfer(int(z'3fefffffca501acb', int64), 0.0_real64), &
                       transfer(int(z'3fefffffca501acb', int64), 0.0_real64), transfer(int(z'3fce270cb443690b', int64), 0.0_real64)]
  real(real64), parameter :: rsrasya_column_1(14) = [ &
                     transfer(int(z'3fe66b65a9a80496', int64), 0.0_real64), transfer(int(z'3fe66b65a9a80496', int64), 0.0_real64), &
                     transfer(int(z'3fe45ce9e5e24788', int64), 0.0_real64), transfer(int(z'3fe45ce9e5e24788', int64), 0.0_real64), &
                     transfer(int(z'3fe45ce9e5e24788', int64), 0.0_real64), transfer(int(z'3fe45ce9e5e24788', int64), 0.0_real64), &
                     transfer(int(z'3fe45ce9e5e24788', int64), 0.0_real64), transfer(int(z'3fe563c968943e10', int64), 0.0_real64), &
                     transfer(int(z'3fe563c968943e10', int64), 0.0_real64), transfer(int(z'3fe7541fa7653437', int64), 0.0_real64), &
                     transfer(int(z'3fe7541fa7653437', int64), 0.0_real64), transfer(int(z'3fe7541fa7653437', int64), 0.0_real64), &
                       transfer(int(z'3fe7541fa7653437', int64), 0.0_real64), transfer(int(z'3fe66b65a9a80496', int64), 0.0_real64)]
  real(real64), parameter :: rsrasya_column_2(14) = [ &
                     transfer(int(z'3fea3430f49491f3', int64), 0.0_real64), transfer(int(z'3fea3430f49491f3', int64), 0.0_real64), &
                     transfer(int(z'3fe9adcf4623d0c0', int64), 0.0_real64), transfer(int(z'3fe9adcf4623d0c0', int64), 0.0_real64), &
                     transfer(int(z'3fe9adcf4623d0c0', int64), 0.0_real64), transfer(int(z'3fe9adcf4623d0c0', int64), 0.0_real64), &
                     transfer(int(z'3fe9adcf4623d0c0', int64), 0.0_real64), transfer(int(z'3fe93ba3443d46b2', int64), 0.0_real64), &
                     transfer(int(z'3fe93ba3443d46b2', int64), 0.0_real64), transfer(int(z'3fe9b33b96af038e', int64), 0.0_real64), &
                     transfer(int(z'3fe9b33b96af038e', int64), 0.0_real64), transfer(int(z'3fe9b33b96af038e', int64), 0.0_real64), &
                       transfer(int(z'3fe9b33b96af038e', int64), 0.0_real64), transfer(int(z'3fea3430f49491f3', int64), 0.0_real64)]
  real(real64), parameter :: rsrasya_column_3(14) = [ &
                     transfer(int(z'3fe67a0d77b7c782', int64), 0.0_real64), transfer(int(z'3fe67a0d77b7c782', int64), 0.0_real64), &
                     transfer(int(z'3fe61f2ba9d1f601', int64), 0.0_real64), transfer(int(z'3fe61f2ba9d1f601', int64), 0.0_real64), &
                     transfer(int(z'3fe61f2ba9d1f601', int64), 0.0_real64), transfer(int(z'3fe61f2ba9d1f601', int64), 0.0_real64), &
                     transfer(int(z'3fe61f2ba9d1f601', int64), 0.0_real64), transfer(int(z'3fe65b9a5a89b952', int64), 0.0_real64), &
                     transfer(int(z'3fe65b9a5a89b952', int64), 0.0_real64), transfer(int(z'3fe91b60ae9680e0', int64), 0.0_real64), &
                     transfer(int(z'3fe91b60ae9680e0', int64), 0.0_real64), transfer(int(z'3fe91b60ae9680e0', int64), 0.0_real64), &
                       transfer(int(z'3fe91b60ae9680e0', int64), 0.0_real64), transfer(int(z'3fe67a0d77b7c782', int64), 0.0_real64)]
  real(real64), parameter :: rsrasya_column_4(14) = [ &
                     transfer(int(z'3fe6138bcdfefbf4', int64), 0.0_real64), transfer(int(z'3fe6138bcdfefbf4', int64), 0.0_real64), &
                     transfer(int(z'3fe4147496aad1d0', int64), 0.0_real64), transfer(int(z'3fe4147496aad1d0', int64), 0.0_real64), &
                     transfer(int(z'3fe4147496aad1d0', int64), 0.0_real64), transfer(int(z'3fe4147496aad1d0', int64), 0.0_real64), &
                     transfer(int(z'3fe4147496aad1d0', int64), 0.0_real64), transfer(int(z'3fe50999dcb5781c', int64), 0.0_real64), &
                     transfer(int(z'3fe50999dcb5781c', int64), 0.0_real64), transfer(int(z'3fe6ca686e7e62dc', int64), 0.0_real64), &
                     transfer(int(z'3fe6ca686e7e62dc', int64), 0.0_real64), transfer(int(z'3fe6ca686e7e62dc', int64), 0.0_real64), &
                       transfer(int(z'3fe6ca686e7e62dc', int64), 0.0_real64), transfer(int(z'3fe6138bcdfefbf4', int64), 0.0_real64)]
  real(real64), parameter :: rsrasya_column_5(14) = [ &
                     transfer(int(z'3fdda1928c5f1e74', int64), 0.0_real64), transfer(int(z'3fdda1928c5f1e74', int64), 0.0_real64), &
                     transfer(int(z'3fe389d495182a99', int64), 0.0_real64), transfer(int(z'3fe389d495182a99', int64), 0.0_real64), &
                     transfer(int(z'3fe389d495182a99', int64), 0.0_real64), transfer(int(z'3fe389d495182a99', int64), 0.0_real64), &
                     transfer(int(z'3fe389d495182a99', int64), 0.0_real64), transfer(int(z'3fe58d760a48585e', int64), 0.0_real64), &
                     transfer(int(z'3fe58d760a48585e', int64), 0.0_real64), transfer(int(z'3fe66d2857371e7a', int64), 0.0_real64), &
                     transfer(int(z'3fe66d2857371e7a', int64), 0.0_real64), transfer(int(z'3fe66d2857371e7a', int64), 0.0_real64), &
                       transfer(int(z'3fe66d2857371e7a', int64), 0.0_real64), transfer(int(z'3fdda1928c5f1e74', int64), 0.0_real64)]
  real(real64), parameter :: rsrasya_column_6(14) = [ &
                     transfer(int(z'3fc86af393e0f2f4', int64), 0.0_real64), transfer(int(z'3fc86af393e0f2f4', int64), 0.0_real64), &
                     transfer(int(z'3fde7815bb5327c5', int64), 0.0_real64), transfer(int(z'3fde7815bb5327c5', int64), 0.0_real64), &
                     transfer(int(z'3fde7815bb5327c5', int64), 0.0_real64), transfer(int(z'3fde7815bb5327c5', int64), 0.0_real64), &
                     transfer(int(z'3fde7815bb5327c5', int64), 0.0_real64), transfer(int(z'3fe4dcf1729e830d', int64), 0.0_real64), &
                     transfer(int(z'3fe4dcf1729e830d', int64), 0.0_real64), transfer(int(z'3fe744086d8ccb55', int64), 0.0_real64), &
                     transfer(int(z'3fe744086d8ccb55', int64), 0.0_real64), transfer(int(z'3fe744086d8ccb55', int64), 0.0_real64), &
                       transfer(int(z'3fe744086d8ccb55', int64), 0.0_real64), transfer(int(z'3fc86af393e0f2f4', int64), 0.0_real64)]
  real(real64), parameter :: rsaswa_values(14) = [ &
                     transfer(int(z'bff05e353f7ced91', int64), 0.0_real64), transfer(int(z'3fff333333333333', int64), 0.0_real64), &
                     transfer(int(z'3ffd99999999999a', int64), 0.0_real64), transfer(int(z'3fff851eb851eb85', int64), 0.0_real64), &
                     transfer(int(z'3fff851eb851eb85', int64), 0.0_real64), transfer(int(z'4003b4395810624e', int64), 0.0_real64), &
                     transfer(int(z'40046872b020c49c', int64), 0.0_real64), transfer(int(z'4004f9db22d0e560', int64), 0.0_real64), &
                     transfer(int(z'400728f5c28f5c29', int64), 0.0_real64), transfer(int(z'4005604189374bc7', int64), 0.0_real64), &
                     transfer(int(z'40066872b020c49c', int64), 0.0_real64), transfer(int(z'40078d4fdf3b645a', int64), 0.0_real64), &
                       transfer(int(z'4008c083126e978d', int64), 0.0_real64), transfer(int(z'bff05e353f7ced91', int64), 0.0_real64)]
  real(real64), parameter :: rsaswb_values(14) = [ &
                     transfer(int(z'3ffeed916872b021', int64), 0.0_real64), transfer(int(z'3ff8a3d70a3d70a4', int64), 0.0_real64), &
                     transfer(int(z'3ff8e5604189374c', int64), 0.0_real64), transfer(int(z'3ff804189374bc6a', int64), 0.0_real64), &
                     transfer(int(z'3ff804189374bc6a', int64), 0.0_real64), transfer(int(z'3ff6b851eb851eb8', int64), 0.0_real64), &
                     transfer(int(z'3ff66a7ef9db22d1', int64), 0.0_real64), transfer(int(z'3ff5cac083126e98', int64), 0.0_real64), &
                     transfer(int(z'3ff50a3d70a3d70a', int64), 0.0_real64), transfer(int(z'3ff51eb851eb851f', int64), 0.0_real64), &
                     transfer(int(z'3ff4b020c49ba5e3', int64), 0.0_real64), transfer(int(z'3ff451eb851eb852', int64), 0.0_real64), &
                       transfer(int(z'3ff4083126e978d5', int64), 0.0_real64), transfer(int(z'3ffeed916872b021', int64), 0.0_real64)]
  real(real64), parameter :: rsaswc_values(14) = [ &
                     transfer(int(z'3f9999999999999a', int64), 0.0_real64), transfer(int(z'3fdcbc6a7ef9db23', int64), 0.0_real64), &
                     transfer(int(z'3f28e757928e0c9e', int64), 0.0_real64), transfer(int(z'3f53a92a30553261', int64), 0.0_real64), &
                     transfer(int(z'3f53a92a30553261', int64), 0.0_real64), transfer(int(z'3f2f75104d551d69', int64), 0.0_real64), &
                     transfer(int(z'3f1040bfe3b03e21', int64), 0.0_real64), transfer(int(z'3ecbaeb22f9294c3', int64), 0.0_real64), &
                     transfer(int(z'be801b2b29a4692b', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'3eb0c6f7a0b5ed8d', int64), 0.0_real64), transfer(int(z'bea5cf751db94e6b', int64), 0.0_real64), &
                       transfer(int(z'3eaa820c5f33ed17', int64), 0.0_real64), transfer(int(z'3f9999999999999a', int64), 0.0_real64)]
  real(real64), parameter :: rsaswd_values(14) = [ &
                     transfer(int(z'3f88fc504816f007', int64), 0.0_real64), transfer(int(z'3f593b3a68b19a41', int64), 0.0_real64), &
                     transfer(int(z'3f64cec41dd1a21f', int64), 0.0_real64), transfer(int(z'3f61b1d92b7fe08b', int64), 0.0_real64), &
                     transfer(int(z'3f61b1d92b7fe08b', int64), 0.0_real64), transfer(int(z'3f4c0ca600b02928', int64), 0.0_real64), &
                     transfer(int(z'3f310a137f38c543', int64), 0.0_real64), transfer(int(z'3ec77cf44765195f', int64), 0.0_real64), &
                     transfer(int(z'3e9d87247702c0d0', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'3e9d0ee223a9b0f2', int64), 0.0_real64), &
                       transfer(int(z'3e98c35f299ffb4c', int64), 0.0_real64), transfer(int(z'3f88fc504816f007', int64), 0.0_real64)]
  real(real64), parameter :: rsaswe_values(14) = [ &
                     transfer(int(z'3fe73b645a1cac08', int64), 0.0_real64), transfer(int(z'3fea978d4fdf3b64', int64), 0.0_real64), &
                     transfer(int(z'3fe89ba5e353f7cf', int64), 0.0_real64), transfer(int(z'3fe7ae147ae147ae', int64), 0.0_real64), &
                     transfer(int(z'3fe7ae147ae147ae', int64), 0.0_real64), transfer(int(z'3fe820c49ba5e354', int64), 0.0_real64), &
                     transfer(int(z'3fe8bc6a7ef9db23', int64), 0.0_real64), transfer(int(z'3fe9cac083126e98', int64), 0.0_real64), &
                     transfer(int(z'3fea2d0e56041893', int64), 0.0_real64), transfer(int(z'3fea7ef9db22d0e5', int64), 0.0_real64), &
                     transfer(int(z'3feac083126e978d', int64), 0.0_real64), transfer(int(z'3feae978d4fdf3b6', int64), 0.0_real64), &
                       transfer(int(z'3feb020c49ba5e35', int64), 0.0_real64), transfer(int(z'3fe73b645a1cac08', int64), 0.0_real64)]
  real(real64), parameter :: rsaswf_values(14) = [ &
                     transfer(int(z'401a9ba5e353f7cf', int64), 0.0_real64), transfer(int(z'40186872b020c49c', int64), 0.0_real64), &
                     transfer(int(z'4014af1a9fbe76c9', int64), 0.0_real64), transfer(int(z'401de04189374bc7', int64), 0.0_real64), &
                     transfer(int(z'401de04189374bc7', int64), 0.0_real64), transfer(int(z'401a3851eb851eb8', int64), 0.0_real64), &
                     transfer(int(z'40159eb851eb851f', int64), 0.0_real64), transfer(int(z'400ad70a3d70a3d7', int64), 0.0_real64), &
                     transfer(int(z'4007e978d4fdf3b6', int64), 0.0_real64), transfer(int(z'4003bc6a7ef9db23', int64), 0.0_real64), &
                     transfer(int(z'4001395810624dd3', int64), 0.0_real64), transfer(int(z'3ffae147ae147ae1', int64), 0.0_real64), &
                       transfer(int(z'3ff8ed916872b021', int64), 0.0_real64), transfer(int(z'401a9ba5e353f7cf', int64), 0.0_real64)]
  real(real64), parameter :: rsecia_values(14) = [ &
                     transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), &
                     transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), &
                     transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), &
                     transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), &
                     transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), &
                     transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), &
                       transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64), transfer(int(z'3f6c3efae7924af1', int64), 0.0_real64)]
  real(real64), parameter :: rsecib_values(14) = [ &
                     transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64), &
                     transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64), &
                     transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64), &
                     transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64), &
                     transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64), &
                     transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64), &
                       transfer(int(z'400372b020c49ba6', int64), 0.0_real64), transfer(int(z'400372b020c49ba6', int64), 0.0_real64)]
  real(real64), parameter :: rsecic_values(14) = [ &
                     transfer(int(z'3fdddc725c3dee78', int64), 0.0_real64), transfer(int(z'3fdddc725c3dee78', int64), 0.0_real64), &
                     transfer(int(z'3fa35935fc3b4f61', int64), 0.0_real64), transfer(int(z'3fa35935fc3b4f61', int64), 0.0_real64), &
                     transfer(int(z'3f89652bd3c36113', int64), 0.0_real64), transfer(int(z'3f89652bd3c36113', int64), 0.0_real64), &
                     transfer(int(z'3f1cd5f99c38b04b', int64), 0.0_real64), transfer(int(z'3f1cd5f99c38b04b', int64), 0.0_real64), &
                     transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                     transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), &
                       transfer(int(z'3ee4f8b588e368f1', int64), 0.0_real64), transfer(int(z'3fdddc725c3dee78', int64), 0.0_real64)]
  real(real64), parameter :: rsecid_values(14) = [ &
                     transfer(int(z'3ef57eed45e9185d', int64), 0.0_real64), transfer(int(z'3ef57eed45e9185d', int64), 0.0_real64), &
                     transfer(int(z'3f55097c80841ede', int64), 0.0_real64), transfer(int(z'3f55097c80841ede', int64), 0.0_real64), &
                     transfer(int(z'3f46807505659a8f', int64), 0.0_real64), transfer(int(z'3f46807505659a8f', int64), 0.0_real64), &
                     transfer(int(z'3eed77094bd91c66', int64), 0.0_real64), transfer(int(z'3eed77094bd91c66', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'3ef57eed45e9185d', int64), 0.0_real64)]
  real(real64), parameter :: rsecie_values(14) = [ &
                     transfer(int(z'3feeb4395810624e', int64), 0.0_real64), transfer(int(z'3feeb4395810624e', int64), 0.0_real64), &
                     transfer(int(z'3fea26809d495183', int64), 0.0_real64), transfer(int(z'3fea26809d495183', int64), 0.0_real64), &
                     transfer(int(z'3fe92b020c49ba5e', int64), 0.0_real64), transfer(int(z'3fe92b020c49ba5e', int64), 0.0_real64), &
                     transfer(int(z'3fe8bc6a7ef9db23', int64), 0.0_real64), transfer(int(z'3fe8bc6a7ef9db23', int64), 0.0_real64), &
                     transfer(int(z'3fe883e425aee632', int64), 0.0_real64), transfer(int(z'3fe883e425aee632', int64), 0.0_real64), &
                     transfer(int(z'3fe883e425aee632', int64), 0.0_real64), transfer(int(z'3fe883e425aee632', int64), 0.0_real64), &
                       transfer(int(z'3fe883e425aee632', int64), 0.0_real64), transfer(int(z'3feeb4395810624e', int64), 0.0_real64)]
  real(real64), parameter :: rsecif_values(14) = [ &
                     transfer(int(z'3f1c34e9ec98442f', int64), 0.0_real64), transfer(int(z'3f1c34e9ec98442f', int64), 0.0_real64), &
                     transfer(int(z'3f48746b0be794cf', int64), 0.0_real64), transfer(int(z'3f48746b0be794cf', int64), 0.0_real64), &
                     transfer(int(z'3f479b2738532da4', int64), 0.0_real64), transfer(int(z'3f479b2738532da4', int64), 0.0_real64), &
                     transfer(int(z'3f4290257c914b16', int64), 0.0_real64), transfer(int(z'3f4290257c914b16', int64), 0.0_real64), &
                     transfer(int(z'3f432c2caeb4b3d1', int64), 0.0_real64), transfer(int(z'3f432c2caeb4b3d1', int64), 0.0_real64), &
                     transfer(int(z'3f432c2caeb4b3d1', int64), 0.0_real64), transfer(int(z'3f432c2caeb4b3d1', int64), 0.0_real64), &
                       transfer(int(z'3f432c2caeb4b3d1', int64), 0.0_real64), transfer(int(z'3f1c34e9ec98442f', int64), 0.0_real64)]
  real(real64), parameter :: rsyfwa_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsyfwb_values(14) = [ &
                     transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                     transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                     transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                     transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                     transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                     transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64), &
                       transfer(int(z'3ff8000000000000', int64), 0.0_real64), transfer(int(z'3ff8000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsyfwc_values(14) = [ &
                     transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), &
                     transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), &
                     transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), &
                     transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64), &
                     transfer(int(z'3fefff2e48e8a71e', int64), 0.0_real64), transfer(int(z'3fefff2e48e8a71e', int64), 0.0_real64), &
                     transfer(int(z'3fefff2e48e8a71e', int64), 0.0_real64), transfer(int(z'3fefff2e48e8a71e', int64), 0.0_real64), &
                       transfer(int(z'3fefff2e48e8a71e', int64), 0.0_real64), transfer(int(z'3feff62b6ae7d567', int64), 0.0_real64)]
  real(real64), parameter :: rsyfwd_values(14) = [ &
                     transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), transfer(int(z'3f647ae147ae147b', int64), 0.0_real64), &
                     transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64), transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64), &
                     transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64), transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64), &
                       transfer(int(z'3f40624dd2f1a9fc', int64), 0.0_real64), transfer(int(z'3f647ae147ae147b', int64), 0.0_real64)]
  real(real64), parameter :: rsyfwe_values(14) = [ &
                     transfer(int(z'3fa999999999999a', int64), 0.0_real64), transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                     transfer(int(z'3fa999999999999a', int64), 0.0_real64), transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                     transfer(int(z'3fa999999999999a', int64), 0.0_real64), transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                     transfer(int(z'3fa999999999999a', int64), 0.0_real64), transfer(int(z'3fa999999999999a', int64), 0.0_real64), &
                     transfer(int(z'3fe0000000000000', int64), 0.0_real64), transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                     transfer(int(z'3fe0000000000000', int64), 0.0_real64), transfer(int(z'3fe0000000000000', int64), 0.0_real64), &
                       transfer(int(z'3fe0000000000000', int64), 0.0_real64), transfer(int(z'3fa999999999999a', int64), 0.0_real64)]
  real(real64), parameter :: rsyfwf_values(14) = [ &
                     transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), &
                     transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), &
                     transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), &
                     transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64), &
                     transfer(int(z'3febae147ae147ae', int64), 0.0_real64), transfer(int(z'3febae147ae147ae', int64), 0.0_real64), &
                     transfer(int(z'3febae147ae147ae', int64), 0.0_real64), transfer(int(z'3febae147ae147ae', int64), 0.0_real64), &
                       transfer(int(z'3febae147ae147ae', int64), 0.0_real64), transfer(int(z'3fed1eb851eb851f', int64), 0.0_real64)]
  real(real64), parameter :: rsfla0_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsfla1_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflb0_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflb1_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflb2_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflb3_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflc0_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflc1_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflc2_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsflc3_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsfld0_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsfld1_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsfld2_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsfld3_values(14) = [ &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                     transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64), &
                       transfer(int(z'0000000000000000', int64), 0.0_real64), transfer(int(z'0000000000000000', int64), 0.0_real64)]
  real(real64), parameter :: rsfua0_values(14) = [ &
                     transfer(int(z'3f2896be8cb1ee69', int64), 0.0_real64), transfer(int(z'3f337bc84d6131c9', int64), 0.0_real64), &
                     transfer(int(z'3f400a07da83b36d', int64), 0.0_real64), transfer(int(z'bee18f5ab797c290', int64), 0.0_real64), &
                     transfer(int(z'bee18f5ab797c290', int64), 0.0_real64), transfer(int(z'bf4a62213254bbef', int64), 0.0_real64), &
                     transfer(int(z'3f111535a32350d5', int64), 0.0_real64), transfer(int(z'3f153eca78dc202c', int64), 0.0_real64), &
                     transfer(int(z'3f253b3f60010b5d', int64), 0.0_real64), transfer(int(z'bf18c8dc79d45c82', int64), 0.0_real64), &
                     transfer(int(z'bf30f6eaa4f15df3', int64), 0.0_real64), transfer(int(z'bf317ec2fe97cb0d', int64), 0.0_real64), &
                       transfer(int(z'bf2efdd843b49be5', int64), 0.0_real64), transfer(int(z'bf30b338738656e9', int64), 0.0_real64)]
  real(real64), parameter :: rsfua1_values(14) = [ &
                     transfer(int(z'40041c970f7b9e06', int64), 0.0_real64), transfer(int(z'4003e95e9e1b089a', int64), 0.0_real64), &
                     transfer(int(z'4003e6eeb702602d', int64), 0.0_real64), transfer(int(z'400433482be8bc17', int64), 0.0_real64), &
                     transfer(int(z'400433482be8bc17', int64), 0.0_real64), transfer(int(z'40049ba5e353f7cf', int64), 0.0_real64), &
                     transfer(int(z'400421ff2e48e8a7', int64), 0.0_real64), transfer(int(z'4004212839042d8c', int64), 0.0_real64), &
                     transfer(int(z'40040f47304039ac', int64), 0.0_real64), transfer(int(z'40042a35935fc3b5', int64), 0.0_real64), &
                     transfer(int(z'40044e219652bd3c', int64), 0.0_real64), transfer(int(z'40045595feda6613', int64), 0.0_real64), &
                       transfer(int(z'40044e2c12ad81ae', int64), 0.0_real64), transfer(int(z'40043b9389b52008', int64), 0.0_real64)]
  real(real64), parameter :: rsfub0_values(14) = [ &
                     transfer(int(z'3fc93083558a7610', int64), 0.0_real64), transfer(int(z'3fddb8fde2ef4e01', int64), 0.0_real64), &
                     transfer(int(z'3f431e7e22f931e3', int64), 0.0_real64), transfer(int(z'3f64beb3af6f6ece', int64), 0.0_real64), &
                     transfer(int(z'3f64beb3af6f6ece', int64), 0.0_real64), transfer(int(z'befdf050c180c1c6', int64), 0.0_real64), &
                     transfer(int(z'be83dda75205ef2f', int64), 0.0_real64), transfer(int(z'be8533913df81b0e', int64), 0.0_real64), &
                     transfer(int(z'be74e261d55e902b', int64), 0.0_real64), transfer(int(z'3ea10f86c6f79acd', int64), 0.0_real64), &
                     transfer(int(z'be8aa5678d360bde', int64), 0.0_real64), transfer(int(z'be7aff1e26864f84', int64), 0.0_real64), &
                       transfer(int(z'be921d1f1f415d8d', int64), 0.0_real64), transfer(int(z'3fd0a6612839042e', int64), 0.0_real64)]
  real(real64), parameter :: rsfub1_values(14) = [ &
                     transfer(int(z'3f778fc6b20098ac', int64), 0.0_real64), transfer(int(z'3ef5774da3d3ad87', int64), 0.0_real64), &
                     transfer(int(z'3f535a9b0122bfc9', int64), 0.0_real64), transfer(int(z'3f5caf4db5eb5ede', int64), 0.0_real64), &
                     transfer(int(z'3f5caf4db5eb5ede', int64), 0.0_real64), transfer(int(z'3f5c2de8c67d7d59', int64), 0.0_real64), &
                     transfer(int(z'3f17a79a15f3e5c9', int64), 0.0_real64), transfer(int(z'3ebcefbeae14ea8d', int64), 0.0_real64), &
                     transfer(int(z'3e9100b11065cc35', int64), 0.0_real64), transfer(int(z'3e5d55d44feb0c1b', int64), 0.0_real64), &
                     transfer(int(z'3e79380eb1cacdd7', int64), 0.0_real64), transfer(int(z'3e8588b5f5e85046', int64), 0.0_real64), &
                       transfer(int(z'3e8c937f5e882b6a', int64), 0.0_real64), transfer(int(z'3f76587993bfbaeb', int64), 0.0_real64)]
  real(real64), parameter :: rsfub2_values(14) = [ &
                     transfer(int(z'bf0bbf1212ebd9c7', int64), 0.0_real64), transfer(int(z'be9ee52ea99cd824', int64), 0.0_real64), &
                     transfer(int(z'becc85ae3d88264b', int64), 0.0_real64), transfer(int(z'bee0cc4dc55e8523', int64), 0.0_real64), &
                     transfer(int(z'bee0cc4dc55e8523', int64), 0.0_real64), transfer(int(z'bedf3162bf630fee', int64), 0.0_real64), &
                     transfer(int(z'be5547ce240f3660', int64), 0.0_real64), transfer(int(z'3dd8cc5bc529fe63', int64), 0.0_real64), &
                     transfer(int(z'bddfbed0de95087a', int64), 0.0_real64), transfer(int(z'3dcb4c5cb9806b26', int64), 0.0_real64), &
                     transfer(int(z'bdf17dea3fc85a3b', int64), 0.0_real64), transfer(int(z'bdec441f9ecdcd6f', int64), 0.0_real64), &
                       transfer(int(z'bdf23ce9d48ee27c', int64), 0.0_real64), transfer(int(z'bf0d4b8cbdb57a17', int64), 0.0_real64)]
  real(real64), parameter :: rsfub3_values(14) = [ &
                     transfer(int(z'3e87b48c5b7e5378', int64), 0.0_real64), transfer(int(z'3e21745f0bddcaec', int64), 0.0_real64), &
                     transfer(int(z'3e42dddfcbec1138', int64), 0.0_real64), transfer(int(z'3e58d62c627ba45e', int64), 0.0_real64), &
                     transfer(int(z'3e58d62c627ba45e', int64), 0.0_real64), transfer(int(z'3e5682bb9c6e8650', int64), 0.0_real64), &
                     transfer(int(z'3dc6186fcae1cdb4', int64), 0.0_real64), transfer(int(z'bd5ab313be81e90d', int64), 0.0_real64), &
                     transfer(int(z'3d605d1ab0aa34ce', int64), 0.0_real64), transfer(int(z'bd4a2d646c171201', int64), 0.0_real64), &
                     transfer(int(z'3d7381693f58bea9', int64), 0.0_real64), transfer(int(z'3d6f43c0919b0ec4', int64), 0.0_real64), &
                       transfer(int(z'3d73e04d4db57325', int64), 0.0_real64), transfer(int(z'3e8a73d2ca1478f7', int64), 0.0_real64)]
  real(real64), parameter :: rsfuc0_values(14) = [ &
                     transfer(int(z'3fe84b3a2595bbbf', int64), 0.0_real64), transfer(int(z'3fed6d5ae1cde5d2', int64), 0.0_real64), &
                     transfer(int(z'3fe8d44dca8e2e2c', int64), 0.0_real64), transfer(int(z'3fe847a9e2bcf91a', int64), 0.0_real64), &
                     transfer(int(z'3fe847a9e2bcf91a', int64), 0.0_real64), transfer(int(z'3fe814b599aa6091', int64), 0.0_real64), &
                     transfer(int(z'3fe80a7610279570', int64), 0.0_real64), transfer(int(z'3fe812fd32c625ea', int64), 0.0_real64), &
                     transfer(int(z'3fe7fd7c2ca148bb', int64), 0.0_real64), transfer(int(z'3fe7fed20296b335', int64), 0.0_real64), &
                     transfer(int(z'3fe7cb20fb224aae', int64), 0.0_real64), transfer(int(z'3fe79c219eb6390d', int64), 0.0_real64), &
                       transfer(int(z'3fe776ddaceee0f4', int64), 0.0_real64), transfer(int(z'3fe992189bd8383b', int64), 0.0_real64)]
  real(real64), parameter :: rsfuc1_values(14) = [ &
                     transfer(int(z'3f743980544e35ee', int64), 0.0_real64), transfer(int(z'3f407badf647f05a', int64), 0.0_real64), &
                     transfer(int(z'3f5c97c604dc88ad', int64), 0.0_real64), transfer(int(z'3f609b1da8318ceb', int64), 0.0_real64), &
                     transfer(int(z'3f609b1da8318ceb', int64), 0.0_real64), transfer(int(z'3f60092212a47266', int64), 0.0_real64), &
                     transfer(int(z'3f55453695e935e4', int64), 0.0_real64), transfer(int(z'3f511378adbbba81', int64), 0.0_real64), &
                     transfer(int(z'3f5146b9cdc1945f', int64), 0.0_real64), transfer(int(z'3f4d22d2b53b8305', int64), 0.0_real64), &
                     transfer(int(z'3f4dc6828e6dca11', int64), 0.0_real64), transfer(int(z'3f4d68e6c94d3b72', int64), 0.0_real64), &
                       transfer(int(z'3f4e1766bdbdffef', int64), 0.0_real64), transfer(int(z'3f73bb0db29b1d52', int64), 0.0_real64)]
  real(real64), parameter :: rsfuc2_values(14) = [ &
                     transfer(int(z'bf0960ee0f394449', int64), 0.0_real64), transfer(int(z'bed81b8e7e98ef48', int64), 0.0_real64), &
                     transfer(int(z'bee3524451ddd30d', int64), 0.0_real64), transfer(int(z'bee88af2541e4ef0', int64), 0.0_real64), &
                     transfer(int(z'bee88af2541e4ef0', int64), 0.0_real64), transfer(int(z'bee57ea88db977c2', int64), 0.0_real64), &
                     transfer(int(z'bed4eec6ea01327c', int64), 0.0_real64), transfer(int(z'bec30295a15c6f8e', int64), 0.0_real64), &
                     transfer(int(z'bec3828814ead35d', int64), 0.0_real64), transfer(int(z'be9775b44da25cf3', int64), 0.0_real64), &
                     transfer(int(z'be9f3a3d640d2be2', int64), 0.0_real64), transfer(int(z'be8d2376ffc05229', int64), 0.0_real64), &
                       transfer(int(z'be9c62a3533264e5', int64), 0.0_real64), transfer(int(z'bf0ae8527e15f44d', int64), 0.0_real64)]
  real(real64), parameter :: rsfuc3_values(14) = [ &
                     transfer(int(z'3e8640e104e8a8f0', int64), 0.0_real64), transfer(int(z'3e55a923b6925669', int64), 0.0_real64), &
                     transfer(int(z'3e5715f51c45fe8f', int64), 0.0_real64), transfer(int(z'3e5fb24224ccf79f', int64), 0.0_real64), &
                     transfer(int(z'3e5fb24224ccf79f', int64), 0.0_real64), transfer(int(z'3e5948cc26a95388', int64), 0.0_real64), &
                     transfer(int(z'3e3b383b5e3f382d', int64), 0.0_real64), transfer(int(z'be2fa2a0fa19f5a2', int64), 0.0_real64), &
                     transfer(int(z'be2ec74116f05f7b', int64), 0.0_real64), transfer(int(z'3e479a87f4acae91', int64), 0.0_real64), &
                     transfer(int(z'be46b7a59825126a', int64), 0.0_real64), transfer(int(z'be48ee1d8097d8db', int64), 0.0_real64), &
                       transfer(int(z'be47300b1ab124a4', int64), 0.0_real64), transfer(int(z'3e88c09f79a3cc20', int64), 0.0_real64)]

contains

  !> Run SUSRTAB, SUSRTAER and SUSRTCOP in their original enclosing order.
  !! All three native output records have intent INOUT. The caller supplies
  !! complete mutually disjoint owners, nearest-even rounding and gradual
  !! underflow. No storage is allocated or released and no original state is
  !! consumed. Link EXP to the independently qualified public C provider.
  subroutine initialize_shortwave_auxiliary_fields(transmission, aerosol, cloud)
    type(shortwave_transmission_parameter_record), intent(inout) :: transmission
    type(shortwave_aerosol_parameter_record), intent(inout) :: aerosol
    type(shortwave_cloud_parameter_record), intent(inout) :: cloud
    call initialize_shortwave_transmission_fields(transmission)
    call initialize_shortwave_aerosol_optical_fields(aerosol)
    call initialize_shortwave_cloud_optical_fields(cloud)
  end subroutine initialize_shortwave_auxiliary_fields

  !> Evaluate SUSRTAB in increasing interval order with separate FP64 operations.
  !! OUTPUT is INOUT and all its fields are written. Integer indices up to
  !! 9999 are exactly representable in both the source default real and FP64.
  !! Natural EXP flags and errno remain observable to the enclosing caller.
  subroutine initialize_shortwave_transmission_fields(output)
    type(shortwave_transmission_parameter_record), intent(inout) :: output
    integer(int32) :: index
    real(real64) :: coordinate, numerator, denominator, optical_depth, argument
    output%rodlow = transfer(int(z'3faeb851eb851eb8', int64), 0.0_real64)
    output%rtblint = transfer(int(z'40c3880000000000', int64), 0.0_real64)
    output%bpade = transfer(int(z'400cc6e80ebbdb2a', int64), 0.0_real64)
    output%trans(0) = 1.0_real64
    output%trans(ubound(output%trans, 1)) = 0.0_real64
    do index = 1_int32, ubound(output%trans, 1) - 1_int32
      coordinate = real(index, real64)/output%rtblint
      numerator = output%bpade*coordinate
      denominator = 1.0_real64 - coordinate
      optical_depth = numerator/denominator
      argument = -optical_depth
      output%trans(index) = selected_public_exp(argument)
    end do
  end subroutine initialize_shortwave_transmission_fields

  !> Set SUSRTAER in source interval, aerosol-type and field order.
  !! OUTPUT is INOUT and all three native arrays are changed. Literal copies
  !! retain all bits and perform no floating-point arithmetic.
  subroutine initialize_shortwave_aerosol_optical_fields(output)
    type(shortwave_aerosol_parameter_record), intent(inout) :: output
    integer(int32) :: interval
    do interval = 1_int32, size(output%rsrtaua, 1)
      output%rsrtaua(interval, 1) = rsrtaua_column_1(interval)
      output%rsrpiza(interval, 1) = rsrpiza_column_1(interval)
      output%rsrasya(interval, 1) = rsrasya_column_1(interval)
      output%rsrtaua(interval, 2) = rsrtaua_column_2(interval)
      output%rsrpiza(interval, 2) = rsrpiza_column_2(interval)
      output%rsrasya(interval, 2) = rsrasya_column_2(interval)
      output%rsrtaua(interval, 3) = rsrtaua_column_3(interval)
      output%rsrpiza(interval, 3) = rsrpiza_column_3(interval)
      output%rsrasya(interval, 3) = rsrasya_column_3(interval)
      output%rsrtaua(interval, 4) = rsrtaua_column_4(interval)
      output%rsrpiza(interval, 4) = rsrpiza_column_4(interval)
      output%rsrasya(interval, 4) = rsrasya_column_4(interval)
      output%rsrtaua(interval, 5) = rsrtaua_column_5(interval)
      output%rsrpiza(interval, 5) = rsrpiza_column_5(interval)
      output%rsrasya(interval, 5) = rsrasya_column_5(interval)
      output%rsrtaua(interval, 6) = rsrtaua_column_6(interval)
      output%rsrpiza(interval, 6) = rsrpiza_column_6(interval)
      output%rsrasya(interval, 6) = rsrasya_column_6(interval)
    end do
  end subroutine initialize_shortwave_aerosol_optical_fields

  !> Set SUSRTCOP in source interval and field order.
  !! OUTPUT is INOUT and all forty-two native arrays are changed. The two
  !! per-interval value-times-scale products use volatile operands to keep
  !! all twenty-eight runtime multiplications, rounding points and flags.
  subroutine initialize_shortwave_cloud_optical_fields(output)
    type(shortwave_cloud_parameter_record), intent(inout) :: output
    integer(int32) :: interval
    real(real64), volatile :: source_coefficient, conversion_scale
    real(real64) :: converted_coefficient
    do interval = 1_int32, size(output%rsaswa)
      source_coefficient = rsaswa_values(interval)
      conversion_scale = transfer(int(z'3f847ae147ae147b', int64), 0.0_real64)
      converted_coefficient = source_coefficient*conversion_scale
      output%rsaswa(interval) = converted_coefficient
      output%rsaswb(interval) = rsaswb_values(interval)
      output%rsaswc(interval) = rsaswc_values(interval)
      output%rsaswd(interval) = rsaswd_values(interval)
      output%rsaswe(interval) = rsaswe_values(interval)
      source_coefficient = rsaswf_values(interval)
      conversion_scale = transfer(int(z'3f50624dd2f1a9fc', int64), 0.0_real64)
      converted_coefficient = source_coefficient*conversion_scale
      output%rsaswf(interval) = converted_coefficient
      output%rsecia(interval) = rsecia_values(interval)
      output%rsecib(interval) = rsecib_values(interval)
      output%rsecic(interval) = rsecic_values(interval)
      output%rsecid(interval) = rsecid_values(interval)
      output%rsecie(interval) = rsecie_values(interval)
      output%rsecif(interval) = rsecif_values(interval)
      output%rsyfwa(interval) = rsyfwa_values(interval)
      output%rsyfwb(interval) = rsyfwb_values(interval)
      output%rsyfwc(interval) = rsyfwc_values(interval)
      output%rsyfwd(interval) = rsyfwd_values(interval)
      output%rsyfwe(interval) = rsyfwe_values(interval)
      output%rsyfwf(interval) = rsyfwf_values(interval)
      output%rsfla0(interval) = rsfla0_values(interval)
      output%rsfla1(interval) = rsfla1_values(interval)
      output%rsflb0(interval) = rsflb0_values(interval)
      output%rsflb1(interval) = rsflb1_values(interval)
      output%rsflb2(interval) = rsflb2_values(interval)
      output%rsflb3(interval) = rsflb3_values(interval)
      output%rsflc0(interval) = rsflc0_values(interval)
      output%rsflc1(interval) = rsflc1_values(interval)
      output%rsflc2(interval) = rsflc2_values(interval)
      output%rsflc3(interval) = rsflc3_values(interval)
      output%rsfld0(interval) = rsfld0_values(interval)
      output%rsfld1(interval) = rsfld1_values(interval)
      output%rsfld2(interval) = rsfld2_values(interval)
      output%rsfld3(interval) = rsfld3_values(interval)
      output%rsfua0(interval) = rsfua0_values(interval)
      output%rsfua1(interval) = rsfua1_values(interval)
      output%rsfub0(interval) = rsfub0_values(interval)
      output%rsfub1(interval) = rsfub1_values(interval)
      output%rsfub2(interval) = rsfub2_values(interval)
      output%rsfub3(interval) = rsfub3_values(interval)
      output%rsfuc0(interval) = rsfuc0_values(interval)
      output%rsfuc1(interval) = rsfuc1_values(interval)
      output%rsfuc2(interval) = rsfuc2_values(interval)
      output%rsfuc3(interval) = rsfuc3_values(interval)
    end do
  end subroutine initialize_shortwave_cloud_optical_fields

end module shortwave_auxiliary_parameter_fields_mod
