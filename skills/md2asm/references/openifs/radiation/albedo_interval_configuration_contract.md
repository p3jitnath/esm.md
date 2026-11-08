# Albedo Interval Configuration

This source is compiled only. Numerical verification of the added scheme-two branch remains pending.

Albedo is the fraction of incoming sunlight that a surface reflects. It is dimensionless. The existing ecRad library maps surface albedo intervals to its wavelength bands. Scheme one chooses the nearest interval. Scheme two uses the existing weighted-average route.

The [Fortran configuration](../../../../../src/openifs/physics/radiation_configuration_albedo_schemes_one_and_two.f90) admits NALBEDOSCHEME equal to one or two. It passes NALBEDOSCHEME < 2 as the existing DO_NEAREST argument. Thus scheme one retains the previous true value, and scheme two receives false. Other selectors, coefficients, call order, record types and guards are unchanged. Unsupported schemes are refused before the configuration is changed.

The retained OpenIFS radiation_setup.F90 source uses the same selector at lines 469–483. The actual captured forecast requested scheme two and stopped at radiation setup stage 15 because the previous generated child admitted only scheme one. This observation establishes the missing supported branch; it does not establish numerical agreement for the corrected branch.

The fresh source passed the retained strict compilation and library link. Its retained preformat build-source hash is a726c72a15734d5b9522d9ab73f0d5bdcdcc7c7fec932a5544d99a00e6e90ac8. No model was run with this correction. Compare the resulting scheme-two configuration and output bytes against the separate Fortran reference before accepting the change or measuring performance. Keep the previous source and library as retained evidence.

The published source was subsequently formatted with fprettify 0.3.7. Its compiler tokens were preserved, and a second formatting pass was unchanged. Retained build records identify the preformat source; the handoff catalog also records the current formatted hash. This style check adds no numerical acceptance.
