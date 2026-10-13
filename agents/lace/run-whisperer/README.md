# Run Whisperer

Preview advisory layer. Reads the plan a Preview shows — a plan you preview
before submitting it, or a submitted Run's plan at its `post_plan` — and
surfaces up to four signals:

1. **Own-history similarity** — vector match against your org's past
   Runs whose plan-diff is structurally similar AND whose outcome went
   bad (rolled back, apply failed, or caused an incident).
2. **Own-stack pattern** — share of recent Runs against this stack
   that touched the same resource types AND went bad.
3. **Module README warning** — a section heading like `## Warning`,
   `## Migration`, or `## Breaking` in a manifest README that matches
   the structural shape of your plan-diff.
4. **Stack-timeline pressure** — the density of apply failures and handler
   blocks on this stack's recent timeline.

Confidence is the count of corroborating signals divided by 4. Every
Advisory is recorded with its confidence; the Preview shows it only at or
above the Preview floor (70%), so three signals are the fewest that show.

## Where it shows up

- **CLI** — `lace stack preview` lists the Preview's Advisories beside the
  plan and the Verdicts its gates would record.
- **Portal** — a Run's Advisories (org-admin gated). Heed / Dismiss / thumbs
  feedback ranks the next Preview.

## Configuration

None — Whisperer has no per-install knobs. Turn it off by disabling or
removing its Binding; scope it by binding to specific stacks via the org
admin surface.

## Enforcement

Advisory only — structurally. An Agent never gates a Run.
