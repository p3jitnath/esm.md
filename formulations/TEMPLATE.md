# {{MODEL_NAME}}

Write a short note for a first-year undergraduate. Explain the physical idea, define each symbol and its unit, then show only the basic mathematical equations. Use one source line per prose paragraph and GitHub-compatible mathematics.

## The idea

{{WHAT_THE_MODEL_DESCRIBES_AND_ITS_MAIN_ASSUMPTIONS}}

Explain what changes with time, what causes that change, and which physical effects the model includes. Give one familiar example that helps the reader picture the system.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| {{SYMBOL}} | {{MEANING_AND_UNIT}} |

Define unfamiliar terms before using them. State whether each quantity changes with position or time, or has a fixed value. Explain a derivative as a rate of change before introducing one.

## Equations

**P01. {{EQUATION_NAME}}**

```math
\frac{dq}{dt}=a-bq
```

Replace this example with the model equation, then explain each term in plain language. In the example, q is the quantity being modelled, a is its input per unit time, and b is a removal rate per unit time; define their units for the chosen model. Explain what makes the quantity increase or decrease.

## Parameters, initial state, and boundaries

{{PARAMETER_VALUES_WITH_UNITS}}

{{INITIAL_STATE_AND_BOUNDARY_CONDITIONS}}

Describe the state at the start and what happens at each edge of the domain. Use words alongside the mathematics so that the reader can understand the physical setup.

The [md2fort skill](../skills/md2fort/SKILL.md) supplies the numerical method, arithmetic, storage, verification, and implementation details in its supporting solver contract. Keep those details out of this note. Preserve physical equation IDs when revising it.
