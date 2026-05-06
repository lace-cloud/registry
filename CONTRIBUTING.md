# Contributing

This repo holds the public `lace/*` manifests for four axes: Terraform modules, observatory scanners, run-tasks, and chaos providers. PRs are reviewed by `@lace-cloud/platform-team`.

## Folder shape

```
<axis>/<author>/<name>/manifest.yaml
<axis>/<author>/<name>/README.md
```

`<axis>` ∈ {`modules`, `scanners`, `run-tasks`, `chaos-providers`}. `<author>` is `lace` for first-party manifests; partner namespaces (e.g. `wiz`, `snyk`, `gremlin`) are added with paired CODEOWNERS entries when partnerships land.

Modules carry `*.tf` files alongside `manifest.yaml` and may nest under a cloud-system tier (e.g. `modules/aws/<name>/main.tf`). Non-module axes are manifest + README only.

## Per-axis acceptance criteria

### `modules/`

- `manifest.yaml` envelope: `apiVersion: '1'`, `axis: module`, `author`, `name` (unique within `lace/`), `version` (`v`-prefixed semver), `displayName`, `runtime: { location: lace-managed }`, `bundle: { system, modulePath, ... }`.
- `main.tf` exists. `terraform fmt -check` passes. `terraform validate` passes after `terraform init -backend=false`.
- `version` bumped on any `*.tf` change. Metadata-only edits skip the bump check.
- `bundle.modulePath` is the path under the repo root (e.g. `modules/aws/iam/role`).

### `scanners/`

- `manifest.yaml` envelope as above with `axis: scanner`.
- `outputs` declares ≥1 of `findings | snapshots | time_series | inventory` with sub-kind schemas.
- For `runtime: { location: lace-managed }` (the default for `lace/*` scanners), the handler must be wired in `apps/api/src/lib/scanners/in-tree-handlers.ts` in the lace monorepo. Manifests can land here ahead of the handler — they will publish but stay un-installable until the handler ships in `observatory-platform-axis` Arc 0.
- Customer-hosted scanners declare `runtime: { location: customer-hosted, dispatch: lace-pull | customer-push, ... }` and must include `oidcTrust` (lace-pull) or `scopeRequired` (customer-push).

### `run-tasks/`

- `manifest.yaml` envelope as above with `axis: run_task`.
- `hooks.available` ⊆ {`pre_plan`, `post_plan`, `pre_apply`, `post_apply`, `post_destroy`}, ≥ 1 entry. `hooks.default` ⊆ `hooks.available`.
- `signing` is `{ kind: hmac_sha256 }` for any task carrying secrets; `{ kind: none }` reserved for in-tree dispatch.
- `verdictMode` ∈ {`sync`, `async`}.
- `endpointSource: 'install'` (per-org URL on the install row) or `'manifest'` (single URL pinned in the manifest; `endpointUrl` required).

> **Note:** Lace-managed run-task manifests are not seeded here yet. The endpoint-source contract for `runtime: { location: lace-managed }` lands with `run-tasks-platform-axis` Arc 0, which also ships the in-tree dispatcher and the first `lace/snyk-bridge` and `lace/datadog-notifier` seeds.

### `chaos-providers/`

- `manifest.yaml` envelope as above with `axis: chaos_provider`.
- `targetCatalog.targets` lists `(resourceType, uriPattern, actions, rollbackKinds)` tuples covering every action the provider supports.
- `callbackSigning: { kind: hmac_sha256 }` for customer-hosted providers; `{ kind: none }` is reserved for `runtime: { location: lace-managed }`.

## Review checklist

For every PR:

- [ ] Envelope fields present (apiVersion, axis, author, name, version, displayName, configSchema, runtime).
- [ ] `version` is a fresh `v`-prefixed semver, bumped vs. base branch.
- [ ] `(axis, author, name)` is unique across the repo.
- [ ] Per-axis fields conform to the schema referenced above.
- [ ] `README.md` exists alongside `manifest.yaml` and explains usage.
- [ ] Modules: `terraform fmt -check` + `terraform init -backend=false && terraform validate` pass.
- [ ] No secrets, credentials, or customer data in any manifest or README.

CI runs an envelope-shape pre-check + Terraform validation. The API does the deep zod validation at publish time. If the CI passes but publish fails, read the per-axis zod in `apps/api/src/lib/registry/axes/` — that's the contract.

## Manifest immutability

Once a `(axis, author, name, version)` row lands in `registry_manifest`, its content is frozen. Re-publishing the same version with different content is rejected with HTTP 409. To ship a fix, bump `version`.
