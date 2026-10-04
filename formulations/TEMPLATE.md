# {{MODEL_NAME}}

Use this template to write a complete physics and mathematics formulation, retaining all 12 section headings in their stated order and all table column headings. Add rows and equations where the model requires them, replacing every `{{PLACEHOLDER}}` with a complete definition before generation.

If a feature is absent, write `None` with its reason, while providing an explicit equation or numerical value for every required definition and acceptance limit. Write the explanatory prose in ASD-STE100-CONV, defining model terminology in Section 02 and keeping the mathematical meaning precise.

Keep each prose paragraph or list item on one physical source line, with separate lines for display equations, tables, headings, and code blocks.

Use GitHub-compatible inline math delimited by a dollar sign and a backtick on each side, with fenced `math` blocks for display equations, following [GitHub’s mathematical-expression guidance](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions). Replace each displayed template marker with the required LaTeX equation, and use `\lvert` and `\rvert` for absolute values inside tables so that vertical bars do not divide cells.

Use LaTeX display equations with stable IDs: `P` for physics, `D` for space, `T` for time, `I` for invariants, and `A` for acceptance criteria, beginning each series at `01`. The formulation is the scientific source for the model and its numerical realisation, while prompts, provider settings, timing records, source code, and compiler representations belong in separate files.

## 01. Document control

| Field | Value |
| --- | --- |
| Template revision | 1.2 |
| Formulation ID | {{FORMULATION_ID}} |
| Formulation revision | {{FORMULATION_REVISION}} |
| Status | {{Draft_OR_Frozen}} |
| Date | {{YYYY-MM-DD}} |
| Model name | {{MODEL_NAME}} |

## 02. Physical scope and assumptions

{{PHYSICAL_SYSTEM_AND_PURPOSE}}

| ID | Assumption | Mathematical consequence | Validity limit |
| --- | --- | --- | --- |
| S01 | {{ASSUMPTION}} | {{CONSEQUENCE}} | {{LIMIT}} |

| Term | Definition | Permitted technical use |
| --- | --- | --- |
| {{TECHNICAL_TERM}} | {{ONE_MEANING}} | {{NOUN_OR_VERB_AND_USE}} |

Describe the included physics and explain the scope of any linearisation, forcing, dissipation, or neglected terms so that the assumptions and their validity limits are clear.

## 03. Symbols and units

| Symbol | Meaning | SI unit or dimension | Kind | Valid range |
| --- | --- | --- | --- | --- |
| {{SYMBOL}} | {{MEANING}} | {{UNIT}} | {{SCALAR_VECTOR_TENSOR_OR_INDEX}} | {{RANGE}} |

Define every symbol used in an equation or table, including vector and tensor components, and give the reference scales and transformations whenever the formulation uses dimensionless variables.

## 04. Domain, geometry, state, and parameters

{{DOMAIN_EQUATIONS}}

| Item | Definition |
| --- | --- |
| Spatial domain | {{COORDINATE_LIMITS}} |
| Time interval | {{START_AND_END_TIMES}} |
| Coordinate system | {{AXES_ORIENTATION_AND_METRIC}} |
| Geometry | {{TOPOGRAPHY_AND_GEOMETRIC_ASSUMPTIONS}} |

Specify the sign conventions, normal directions, and coordinate singularities alongside the geometry so that directional operators have an unambiguous meaning.

{{STATE_VECTOR_DEFINITION}}

| Quantity | Value or input rule | Unit | Dependence | Constraint |
| --- | --- | --- | --- | --- |
| {{PARAMETER}} | {{VALUE_OR_INPUT_RULE}} | {{UNIT}} | {{SPACE_TIME_OR_CONSTANT}} | {{CONSTRAINT}} |

Explain how prognostic and diagnostic variables are related, expressing each constitutive relation, closure, and conversion as an equation that can be used directly in the numerical operation.

## 05. Governing equations

**P01. {{EQUATION_NAME}}**

```math
\texttt{\{\{GOVERNING\_EQUATION\}\}}
```

{{P01_PHYSICAL_MEANING_AND_ASSUMPTIONS}}

Give every flux, source, and constraint explicitly, stating the units of each equation and writing a source's zero value when it is absent. If an operator requires a further definition, identify the corresponding equation in this file so that the governing system is complete.

## 06. Initial and boundary conditions

| ID | State component | Region | Mathematical condition | Unit |
| --- | --- | --- | --- | --- |
| IC01 | {{COMPONENT}} | {{REGION}} | {{INITIAL_CONDITION}} | {{UNIT}} |
| BC01 | {{COMPONENT}} | {{BOUNDARY}} | {{BOUNDARY_CONDITION}} | {{UNIT}} |

Provide initial conditions for every prognostic variable and specify all boundary faces and corner rules, including compatibility conditions and discontinuities that affect the mathematical problem.

## 07. Spatial discretisation

| Item | Definition |
| --- | --- |
| Mesh and variable location | {{MESH_AND_CELL_OR_FACE_LOCATIONS}} |
| Cell dimensions and measures | {{SPACING_VOLUME_AND_FACE_MEASURE}} |
| Index ranges | {{INTERIOR_BOUNDARY_AND_HALO_INDICES}} |
| Reconstruction | {{RECONSTRUCTION_OR_None_WITH_REASON}} |
| Numerical flux | {{EXACT_FLUX_FORMULA}} |
| Limiter or filter | {{EXACT_RULE_OR_None_WITH_REASON}} |
| Boundary operator | {{EXACT_DISCRETE_BOUNDARY_RULE}} |
| Spatial order | {{ORDER_AND_REQUIRED_REGULARITY}} |

**D01. {{DISCRETE_OPERATOR_NAME}}**

```math
\texttt{\{\{DISCRETE\_OPERATOR\}\}}
```

Define the stencil, coefficients, neighbour values, and operation signs, explaining how discrete variables represent the continuous state. Include the halo update rule and its evaluation times so that boundary work is part of the specified operator.

## 08. Time discretisation

**T01. {{COMPLETE_TIME_UPDATE_NAME}}**

```math
\texttt{\{\{TIME\_UPDATE\_WITH\_ALL\_STAGES\}\}}
```

| Item | Definition |
| --- | --- |
| Time method and order | {{METHOD_AND_ORDER}} |
| Stage dependencies | {{INPUT_STATE_FOR_EACH_STAGE}} |
| Source evaluation | {{SOURCE_TIME_AND_STATE_OR_None_WITH_REASON}} |
| Time-step rule | {{FIXED_OR_ADAPTIVE_RULE_WITH_FORMULA}} |
| Stability condition | {{CFL_OR_OTHER_EXACT_BOUND}} |
| Final step and stop rule | {{END_TIME_AND_STEP_COUNT_RULE}} |

Specify every stage, split operation, and buffer update, including the times at which boundary values change during a step. Explain physical stability assumptions separately from numerical limits so that each requirement has a clear role in the complete update.

## 09. Invariants and admissible states

**I01. {{INVARIANT_OR_BUDGET_NAME}}**

```math
\texttt{\{\{INVARIANT\_OR\_BUDGET\}\}}
```

| Quantity | Continuous property | Discrete property | Required condition |
| --- | --- | --- | --- |
| {{QUANTITY}} | {{EXACT_CONSERVATION_BALANCE_OR_OTHER_PROPERTY}} | {{NUMERICAL_PROPERTY}} | {{CONDITION}} |

State positivity, admissibility, and singular-state rules, accounting for numerical dissipation and any permitted drift when defining the required discrete behaviour. Conservation requirements must match the properties that the chosen numerical method can provide.

## 10. Numerical representation and operation contract

| Quantity | Shape and index map | Storage type | Unit | Input or output | Mutation and alias rule |
| --- | --- | --- | --- | --- | --- |
| {{BUFFER}} | {{SHAPE_AND_INDEX_TO_OFFSET_FORMULA}} | {{TYPE}} | {{UNIT}} | {{ROLE}} | {{RULE}} |

| Property | Required rule |
| --- | --- |
| Precision and rounding | {{PRECISION_AND_ROUNDING}} |
| Floating-point environment | {{ROUNDING_MODE_UNDERFLOW_AND_CONTROL_REGISTER_RULES}} |
| Input and constant bytes | {{CANONICAL_INPUT_ENCODING_AND_EXACT_CONSTANT_BITS}} |
| Operation order | {{REQUIRED_ORDER_AND_PERMITTED_REORDERING}} |
| Intermediate rounding | {{ORDERED_DEPENDENCIES_AND_FP64_ROUNDING_POINTS}} |
| Fused multiply-add | {{PERMITTED_OR_FORBIDDEN_AND_SCOPE}} |
| Division and square root | {{EXACT_OR_APPROXIMATE_RULE_AND_ERROR_BOUND}} |
| Reductions | {{ORDER_AND_ACCURACY_RULE}} |
| Non-finite values and underflow | {{PRECONDITION_OR_REQUIRED_BEHAVIOUR}} |
| Signed zero and ties | {{BIT_PRESERVATION_AND_DETERMINISTIC_TIE_RULES}} |
| Memory bounds and alignment | {{BUFFER_SIZE_HALO_STRIDE_AND_ALIGNMENT}} |
| Inputs and outputs | {{MATHEMATICAL_OPERATION_AND_COMPLETE_OUTPUT_STATE}} |
| Output byte encoding | {{FIELD_CELL_AND_BYTE_ORDER_WITH_DETERMINISTIC_METADATA}} |
| Output checkpoints | {{STAGES_STEPS_AND_FINAL_STATE_TO_COMPARE}} |
| Scratch storage | {{SIZE_LIFETIME_AND_OVERLAP_RULE}} |
| Invalid input | {{REQUIRED_BEHAVIOUR_OR_EXCLUDED_INPUT_DOMAIN}} |

Give an exact index-to-byte-offset formula for each distinct layout and define the full operation boundary, including every time stage and boundary update. Keep CPU register choices and generation instructions separate from the formulation so that this contract describes the numerical operation itself.

For the current implementation intercomparison, use identical binary inputs and constants, ordered FP64 operations, round-to-nearest with ties to even, gradual underflow, and preserved signed zeros. Forbid fused multiply-add, contraction, reassociation, fast-math, reduced precision, and approximate division or square root, while permitting independent-cell scheduling that preserves each output's arithmetic dependencies and rounding points.

Define all output bytes and deterministic metadata explicitly, keeping runtime records separate and preserving every declared bit without rounding, masking, or normalisation to conceal differences.

## 11. Numerical acceptance criteria

**A01. {{ERROR_OR_CONSERVATION_METRIC_NAME}}**

```math
\texttt{\{\{METRIC\_WITH\_NORMALISATION\_AND\_UNITS\}\}}
```

| ID | Physical case and inputs | Independent reference | Metric | Numerical limit | Evaluation time |
| --- | --- | --- | --- | --- | --- |
| V01 | {{CASE_AND_INPUTS}} | {{EXACT_SOLUTION_OR_REFERENCE_AND_ORIGIN}} | {{METRIC_ID}} | {{NUMBER_AND_UNIT}} | {{TIME_OR_STEP_COUNT}} |
| V02 | {{IDENTICAL_INPUT_BYTES_AND_ALL_CHECKPOINTS}} | {{REVIEWED_CANONICAL_IMPLEMENTATION}} | Byte differences | 0 bytes | {{EACH_STAGE_STEP_AND_REQUIRED_OUTPUT_TIME}} |

Specify at least one independent physical reference, since agreement with another generated solver alone does not establish scientific correctness. Provide exact inputs, resolutions, time steps, durations, and scalar limits, together with the expected convergence order and its measurement conditions.

Include conservation, admissibility, boundary, and buffer checks wherever the model requires them, giving each criterion a numerical limit that can be evaluated without an additional scientific choice.

Require byte-for-byte agreement for every declared output at each verification stage and step and in the checkpoint and final files, including signed zeros and deterministic metadata. Compare bytes directly, reporting the first mismatching field, cell, and bit patterns before timing; retain physical error and conservation limits as separate scientific criteria.

## 12. References and limitations

| ID | Source | Definition used | Location in this document |
| --- | --- | --- | --- |
| R01 | {{PRIMARY_SOURCE_WITH_LINK_OR_DOI}} | {{SUPPORTED_DEFINITION}} | {{SECTION_OR_EQUATION_ID}} |

{{KNOWN_LIMITATIONS_AND_VALIDITY_DOMAIN}}

Include all equations needed to implement the stated operation within this file, using references to establish their origin rather than to supply mathematical definitions omitted from the formulation.
