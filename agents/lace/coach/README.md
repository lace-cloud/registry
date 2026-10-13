# Coach

A Preview Agent for experiments. Bound at Preview, it activates at the
Preview of a Run whose input is an experiment: it reads the experiment, how
the same fault went on the Run's Stack and on the org's other Stacks, the
assertion Verdicts those Runs recorded and the Stack's open drift, then emits
one Advisory, with its confidence, beside the experiment before the Run's
gate decides. Read-only; never gates a Run.
