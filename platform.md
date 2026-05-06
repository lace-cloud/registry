# Platform Guide

Internal reference for `@lace-cloud/platform-team`. For contributor-facing docs, see [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

## CI Workflows

Two workflows: **CI** (PR gate) → **Publish** (push to `main`).

### CI (`ci.yml`)

Runs on PRs targeting `develop` or `main`.

**Jobs:** Detect Manifests → Validate (matrix) → Summary.

| Job              | What it does                                                                                                                                                  |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Detect Manifests | `tj-actions/changed-files` over `{modules,scanners,run-tasks,chaos-providers}/**`. Walks up to find `manifest.yaml` roots. Fails if any changed file is orphaned (no `manifest.yaml` ancestor). |
| Validate         | Matrix per manifest dir (`fail-fast: false`). Per-axis steps below.                                                                                            |
| Summary          | Rollup gate — reports pass/fail to PR.                                                                                                                        |

**Validate steps (in order):**

1. **Structure check** — `manifest.yaml` exists. For modules, `main.tf` also exists.
2. **Envelope check** — required fields (`apiVersion`, `axis`, `author`, `name`, `version`, `displayName`, `configSchema`, `runtime`) are present; `axis` matches the directory.
3. **Identity uniqueness** — `(axis, author, name)` is unique across the repo.
4. **Version bump** — `version` differs from base branch when `*.tf` changed (modules only) or when the manifest itself changed.
5. **Terraform** (modules only) — `terraform fmt -check -recursive` + `terraform init -backend=false && terraform validate`.

The deep zod validation runs server-side at publish time. CI is a fail-fast envelope check.

**Concurrency:** `ci-${{ github.event.pull_request.number }}`, cancels in-progress.
**Permissions:** `contents: read`.

### Publish (`publish.yml`)

| Trigger             | Condition                                                                                  | Authorization                                |
|---------------------|--------------------------------------------------------------------------------------------|----------------------------------------------|
| Push to `main`      | `paths: [modules/**, scanners/**, run-tasks/**, chaos-providers/**]`                       | Already gated by branch protection.          |
| `workflow_dispatch` | Manual, accepts `manifest_dir` input                                                       | Requires `@lace-cloud/platform-team` member. |

**Jobs:** Authorize (conditional) → Prepare → Register (matrix) → Summary.

| Job       | Details                                                                                                                                                                                                                                                                                                  |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Authorize | Runs only for `workflow_dispatch`. Generates GitHub App token (`LACE_ORG_CI_APP_ID` + `LACE_ORG_CI_PRIVATE_KEY`), checks actor's membership in `platform-team`.                                                                                                                                          |
| Prepare   | For push: `git diff HEAD^ HEAD` over the four axis paths to find changed manifest dirs (walk-up to `manifest.yaml`). For dispatch: validates the provided `manifest_dir` exists.                                                                                                                         |
| Register  | Matrix per manifest dir (`fail-fast: false`). Each: install Lace CLI → `lace whoami` → resolve axis from the dir prefix → `lace registry register --axis <axis> --manifest <dir>/manifest.yaml --readme <dir>/README.md`. Auth: `LACE_REGISTRY_KEY` env (sourced from repo secret `LACE_REGISTRY_BOT_KEY`). |
| Summary   | Reports registered manifests and result.                                                                                                                                                                                                                                                                  |

**Concurrency:** `publish-${{ github.ref }}`, does **not** cancel in-progress (every merge must publish).
**Permissions:** `contents: read`.

## Branch Protection

Both `main` and `develop` are protected via GitHub rulesets:

| Rule                       | `main`    | `develop` |
|----------------------------|-----------|-----------|
| Require PR                 | Yes       | Yes       |
| Required status checks     | `Summary` | `Summary` |
| CODEOWNERS review          | Yes       | Yes       |

CODEOWNERS pins `*` and the four axis subdirs to `@lace-cloud/platform-team`. Partner namespaces (e.g. `scanners/wiz/`, `chaos-providers/gremlin/`) are added with paired CODEOWNERS entries when partnerships land.

## Secrets

| Secret                       | Purpose                                                                                       | Used by                       |
|------------------------------|-----------------------------------------------------------------------------------------------|-------------------------------|
| `LACE_REGISTRY_BOT_KEY`      | Service-token API key with `REGISTRY_PUBLISH` scope. Publishes public manifests (`org_id = NULL`). | `publish.yml` (Register job)  |
| `LACE_ORG_CI_APP_ID`         | GitHub App ID for org API access (membership lookup).                                         | `publish.yml` (Authorize job) |
| `LACE_ORG_CI_PRIVATE_KEY`    | GitHub App private key.                                                                       | `publish.yml` (Authorize job) |

### Registry Bot

- **User:** `Lace Registry Bot` (`registry-bot@lace.cloud`).
- **API Key:** service token with the `REGISTRY_PUBLISH` scope (publishes public manifests). Stored as repo secret `LACE_REGISTRY_BOT_KEY`.
- Publishes public manifests via `POST /api/v1/registry/index`. The endpoint clamps `org_id = NULL` on the resulting row.

## Troubleshooting

### CI validation passes but publish fails

The Register job requires `LACE_REGISTRY_BOT_KEY`. Verify the secret is set and the service token is active + scoped to `REGISTRY_PUBLISH`.

### Manual dispatch authorization failure

The `workflow_dispatch` Authorize job checks `platform-team` membership via the GitHub API using a GitHub App token. Possible causes:

- Actor is not a member of `@lace-cloud/platform-team`.
- `LACE_ORG_CI_APP_ID` or `LACE_ORG_CI_PRIVATE_KEY` secrets are missing or expired.

### Required status check not found

Status check names include the workflow name prefix. If a workflow is renamed, update the branch ruleset to match (e.g. `CI / Summary`, not just `Summary`).

### Path filter triggers on deletions

The four axis path filters match deleted files too. Cleanup PRs that remove a manifest dir will trigger `ci.yml`. The Detect Manifests job handles this — orphaned files (no `manifest.yaml` ancestor) cause a failure.

## Gotchas

- `lace registry register` reads the manifest YAML from disk and POSTs as-is. The CLI does not transform the file before publish. The on-disk shape must match the per-axis zod in `apps/api/src/lib/registry/axes/`.
- The publish endpoint is idempotent on `(axis, author, name, version) + sha256(manifest_yaml)`. Re-publishing identical content is a no-op.
- Re-publishing different content at the same `(axis, author, name, version)` returns 409 — manifests are immutable per version. Bump `version` to ship a fix.
- CODEOWNERS file must be on the default branch (`main`) to take effect.
