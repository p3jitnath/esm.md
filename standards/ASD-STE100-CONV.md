# ASD-STE100-CONV

ASD-STE100-CONV is the project's writing convention for clear, fluent technical prose, using [ASD-STE100, Issue 9](https://www.asd-ste100.org/) as its foundation. Revision 1.0 defines CONV as connected scientific English that is easy to follow and appropriate for technical papers.

## Scope and relationship to ASD-STE100

Use this convention for all project prose, including physics and mathematics formulations, research plans, handover records, instructions, code documentation, skills, progress reports, and conversation.

Retain ASD-STE100's emphasis on unambiguous vocabulary, consistent terminology, and clear grammatical relationships. For all project prose, choose sentence length according to the argument and the reader's needs, allowing related clauses to form a complete explanation. This project convention overrides any earlier requirement to use strict ASD-STE100 prose in formulations.

## Sentences and paragraphs

Develop each paragraph around a clear purpose, introducing the subject before explaining the method, evidence, or consequence that the reader needs next. Carry familiar information into the next sentence so that the argument advances through meaning rather than through a sequence of isolated statements.

Use well-formed sentences with connected clauses and natural variation in length. Keep the subject and main verb easy to identify, and place conditions or qualifications beside the claim they govern. Avoid telegraphic prose, repeated short sentences, and rigid word-count limits that interrupt the explanation.

Keep each prose paragraph or list item on one physical Markdown source line in all project documents, while preserving the layout of equations, tables, headings, and code blocks. Use editor soft wrapping when displaying long lines. Use GitHub-compatible mathematics, with dollar-and-backtick inline delimiters and fenced `math` display blocks, while keeping mathematical delimiters outside ordinary code spans and escaping table separators where necessary.

Use transitions to identify a real relationship between ideas. For example, `therefore` can introduce a supported consequence, `however` can qualify a finding, and `in this case` can identify a condition. Often, a precise repeated term or a clear pronoun provides enough continuity without an added connector.

## Technical precision and scientific voice

Use familiar English where it conveys the intended meaning, while retaining necessary technical terms and defining unfamiliar terms at first use. Give each defined object a consistent name, and preserve equations, units, identifiers, quotations, and reference titles during language revision.

Write with the precision and restraint expected in a technical paper, stating the method, comparator, conditions, and uncertainty whenever they affect the interpretation. Distinguish proposals, executed checks, and measured results so that fluent prose does not imply evidence that the project does not have.

Use active voice when it makes responsibility clear, and use passive voice when the scientific object needs the emphasis. First-person language is appropriate for author choices, shared work, or progress reports, provided that the actor and the scope of the statement remain clear.

## Instructions and documentation

Make instructions direct and informative, explaining their purpose when that explanation helps the reader perform the task. Use connected paragraphs for arguments and explanations, and use lists when steps or parallel requirements are easier to assess separately.

Preserve the required documentation structure while applying this prose style: Python uses NumPy docstrings, Fortran uses FORD comments, and Julia uses its native documentation conventions. Assembly documentation must explain the application binary interface, buffer contract, and correspondence to the equations.

## Example of the intended register

> We will compare the generated solvers under the same numerical conditions so that runtime differences can be interpreted alongside physical accuracy. Before measuring performance, we will verify conservation and complete trajectories against independent references, which will also identify outputs that fail the scientific requirements. The resulting comparison will therefore describe both the speed of valid implementations and the reliability of the process that produced them.

## Review

Read each paragraph continuously, checking that its terms, clauses, and transitions make the reasoning easy to follow without losing technical precision. Revise awkward structure or unnecessary wording while preserving the premises and qualifications needed to assess the claim.

This convention is a project adaptation of ASD-STE100; formal compliance with the official standard requires a separate review against its rules and dictionary.
