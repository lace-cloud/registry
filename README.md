# registry

The public Lace registry monorepo. One repo, four artifact axes, one publish endpoint.

## What lives here

```
registry/
├── modules/                ← Terraform modules
├── scanners/               ← Observatory scanners (drift, cost, anomalies, …)
├── handlers/               ← Handlers (Run-lifecycle gates: pre/post-plan + apply)
└── chaos-providers/        ← Chaos engineering providers (AWS, Wiz, Gremlin, …)
```

Each axis subdir holds `<author>/<name>/{manifest.yaml, README.md, …}`. Modules additionally carry `*.tf` siblings and may nest under a cloud-system tier (`modules/aws/<name>/`).

## Branch strategy

```
feature/* → develop → main
```

| Branch     | Purpose                                                                  |
|------------|--------------------------------------------------------------------------|
| `feature/*` | Manifest authoring — branch from `develop`                              |
| `develop`   | Integration. CI validates structure + envelope + Terraform on PR.       |
| `main`      | Production. Push to `main` publishes to the registry.                   |

Both branches require PR + passing checks. Changes to `.github/` need `@lace-cloud/platform-team` review (CODEOWNERS).

## Manifest envelope

Every artifact ships a `manifest.yaml` with the same base envelope:

```yaml
apiVersion: '1'
axis: module | scanner | handler | chaos_provider
author: lace                       # kebab-case (1-64 chars)
name: aws-iam-role                 # kebab-case (1-64 chars), unique within axis+author
version: v1.0.0                    # semver, must be 'v'-prefixed
displayName: "AWS IAM Role"        # human-readable (1-96 chars)
description: "..."                 # optional
categories: [iam, security]        # optional
configSchema: { ... }              # JSON-Schema for per-install config
runtime:
  location: lace-managed | customer-hosted
  # customer-hosted requires `dispatch: lace-pull | customer-push`
authors: ["Lace Team <team@lace.cloud>"]
# Axis-specific fields layered on top:
# - module: bundle.{system, modulePath, gitUrl, commitSha, ...}
# - scanner: outputs.{findings, snapshots, time_series, inventory}
# - handler: hooks.{available, default}, endpointSource, signing, verdictMode
# - chaos_provider: targetCatalog, callbackSigning
```

Validation: per-axis zod schemas in `apps/api/src/lib/registry/axes/*.ts` are the source of truth. CI runs an envelope-shape pre-check; the API does deep validation at publish time.

## How publishing works

A push to `main` that touches `modules/**`, `scanners/**`, `handlers/**`, or `chaos-providers/**` triggers `publish.yml`:

1. Detect changed `manifest.yaml` directories.
2. Install the `lace` CLI from `releases.lace.cloud`.
3. Per manifest: `lace registry register --axis <axis> --manifest <dir>/manifest.yaml --readme <dir>/README.md`.
4. The CLI POSTs to `/api/v1/registry/index` with `Authorization: Bearer ${LACE_REGISTRY_KEY}`.

`LACE_REGISTRY_KEY` is a service-token API key with the `REGISTRY_PUBLISH` scope (publishes public manifests, `org_id = NULL`). It is held only by this repo's CI.

The publish endpoint is idempotent on `(axis, author, name, version) + sha256(manifest.yaml)`. Re-publishing identical content is a no-op (`result: 'unchanged'`). Re-publishing a different `manifest.yaml` at the same `(axis, author, name, version)` is rejected (409): manifests are immutable per version.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the per-axis acceptance criteria and review checklist.

```bash
git checkout develop && git pull
git checkout -b feature/scanner-aws-foo
mkdir -p scanners/lace/aws-foo
# author scanners/lace/aws-foo/manifest.yaml + README.md
git add scanners/lace/aws-foo
git commit -m "feat(scanners): seed lace/aws-foo"
git push -u origin feature/scanner-aws-foo
gh pr create --base develop
```

Once merged to `develop`, open a develop → main PR. Merging to `main` publishes.

## Running a private registry

Customer orgs that want PR-reviewed authoring of internal manifests use the [`registry-template`](https://github.com/lace-cloud/registry-template) repo as a starting point. Same folder structure, same workflows, same `LACE_REGISTRY_KEY` secret name, same `lace registry register` CLI — the only difference is the API key's scope:

- **This repo (public):** key holds `REGISTRY_PUBLISH` scope. Manifests land at `org_id = NULL`, visible to every Lace org.
- **Customer private repo:** key holds `REGISTRY_PUBLISH:org` scope. Manifests land at `org_id = <caller's org>`, visible only to that org's catalog browse.

The unified publish endpoint clamps `org_id` server-side based on the bearer token's scope; the request body cannot override.

## Troubleshooting

### `authentication failed` / `unauthorized`

Verify `LACE_REGISTRY_KEY` is set in repo secrets and the service token has the `REGISTRY_PUBLISH` scope.

### Manifest envelope rejected at publish

The CI envelope check is a fast fail; the API's per-axis zod is the deep gate. If publish fails with a validation error, read the per-axis schema in [`apps/api/src/lib/registry/axes/`](https://github.com/lace-cloud/lace/tree/develop/apps/api/src/lib/registry/axes) — that's the contract.

### `409: manifest at this version already published with different content`

Manifests are immutable per `(axis, author, name, version)`. Bump the `version` field and reopen the PR.
