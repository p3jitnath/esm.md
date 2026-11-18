# {{MODEL_NAME}} Formulation

Explain the physical idea to a first-year undergraduate, define the symbols and units, and give the basic equations. Use one source line per paragraph and GitHub-compatible mathematics.

## Model Idea

{{WHAT_THE_MODEL_DESCRIBES_AND_ITS_MAIN_ASSUMPTIONS}}

Use an example to show what changes with time and which physical effects drive the change.

## Symbols and Units

| Symbol | Meaning and unit |
| --- | --- |
| {{SYMBOL}} | {{MEANING_AND_UNIT}} |

Define unfamiliar terms, including derivatives as rates of change. Identify fixed values and quantities that vary with position or time.

## Governing Equations

**P01. {{EQUATION_NAME}}**

```math
\frac{dq}{dt}=a-bq
```

Replace the example with the model equation and explain each term. Here q is the modelled quantity, a is its input per unit time, and b sets the fraction removed per unit time.

## Parameters and Boundaries

{{PARAMETER_VALUES_WITH_UNITS}}

{{INITIAL_STATE_AND_BOUNDARY_CONDITIONS}}

State the initial values and what happens at each boundary.

Keep equation IDs when revising the formulation. Use [md2fort](../skills/md2fort/SKILL.md) to derive a separate numerical specification beside it, with shared specifications in `formulations/general/`.
