# ASD-STE100 Writing Convention

ASD-STE100-CONV revision 1.0 adapts [ASD-STE100, Issue 9](https://www.asd-ste100.org/) for connected scientific English throughout the project. Its principles apply to formulations, code documentation, research reports and conversation. A formal claim of ASD-STE100 compliance requires a separate check against its rules and dictionary.

## Sentences and Paragraphs

Give each paragraph one purpose and connect its sentences through the method, evidence or consequence the reader needs next. Keep the subject and main verb clear, and place each qualification beside its claim. Vary sentence length to suit the explanation.

## Technical Precision

Define unfamiliar terms at first use and use them consistently. Preserve equations, units, identifiers, quotations and reference titles. Report the method, comparison, conditions and uncertainty when they affect interpretation, distinguishing plans, completed checks and measurements.

## Markdown and Code

Keep each prose paragraph or list item on one physical source line. Write inline mathematics with GitHub’s dollar-and-backtick delimiters and display equations in fenced `math` blocks. Preserve table and code layout.

Use NumPy docstrings for Python, FORD comments for Fortran and Julia’s documentation conventions for Julia. For assembly, describe the calling interface, buffers and correspondence to the equations.

## Example Paragraph

> We will compare the generated solvers under the same numerical conditions so that runtime differences can be interpreted alongside physical accuracy. Before measuring performance, we will verify conservation and complete trajectories against independent references, which will also identify outputs that fail the scientific requirements. The resulting comparison will therefore describe both the speed of valid implementations and the reliability of the process that produced them.
