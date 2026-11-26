# registry

Lace's own registry repository. The `lace` organization publishes the default
modules, scanners, handlers and agents that every Lace organization can install
from here. It publishes through the same two GitHub Actions any organization's
registry repository uses: [`lace-cloud/registry-check`](https://github.com/lace-cloud/registry-check)
on pull requests and [`lace-cloud/registry-publish`](https://github.com/lace-cloud/registry-publish)
on merges.

To run a registry repository for your own organization, follow
[Publishing to the registry from CI](https://lace.cloud/docs/registry-publishing).

## Layout

```
registry/
├── modules/     ← Terraform modules
├── scanners/    ← Observatory scanners
├── handlers/    ← Handlers (Run gates)
└── agents/      ← Agents
```

A scanner, handler or agent is a directory `<axis>/<author>/<name>/` holding
`manifest.yaml` and `README.md`; Lace's defaults live under `<axis>/lace/`. A
module is a directory under its system's, `modules/<system>/`, holding
`manifest.yaml`, `README.md` and its `*.tf` files, as in
`modules/aws/lace/team-role/`. Its manifest names it, not its path.

## Workflows

| File | Runs on | What it does |
|---|---|---|
| `check.yml` | a pull request to `develop` or `main` | `registry-check` checks every manifest the pull request changes against the Lace a merge would publish to (preview, https://preview.lace.cloud, for `develop`; production, https://lace.cloud, for `main`): the registry's publish validator (`lace registry validate`) on its manifest and README, a version the registry does not already hold at the manifest's identity, and for a module a `lace module validate` verdict of `already-lace-style`. |
| `publish.yml` | a push to `main` or `develop`, or a dispatch on either | `registry-publish` publishes every manifest the push changed, or the one directory a dispatch names as `path`. `main` publishes to production, https://lace.cloud, with `LACE_TOKEN`; `develop` publishes to preview, https://preview.lace.cloud, with `LACE_TOKEN_PREVIEW`. |

`check.yml` and `publish.yml` are the two files the publishing guide gives every
organization, `publish.yml` with the hand republish the `registry-publish` action
documents; this repository runs exactly those two.

## Branches

```
feature/* → develop → main
```

A pull request into `develop` is checked. A `develop` → `main` pull request is
checked again. Merging into `develop` publishes to preview; merging `develop` into
`main` publishes to production.

## Tokens

Two repository secrets, each a service token minted with the `registry:publish`
scope, naming `lace-cloud/registry` as the repository and one branch as the
branch it publishes from:

| Secret | Minted in | Branch | Publishes to |
|---|---|---|---|
| `LACE_TOKEN` | the production `lace` organization | `main` | https://lace.cloud |
| `LACE_TOKEN_PREVIEW` | the preview `lace` organization | `develop` | https://preview.lace.cloud |

A token publishes only from a run of this repository on its branch, so whoever
can push to `main` or `develop` can publish to that environment.

## Manifest envelope

Every artifact's `manifest.yaml` starts with the same envelope:

```yaml
apiVersion: '1'
axis: module | scanner | handler | agent
author: lace                  # kebab-case, 1-64 characters
name: iam-role                # kebab-case, 1-64 characters
version: v1.0.0               # v-prefixed semver
displayName: AWS IAM Role     # 1-96 characters
description: ...              # optional
categories: [iam, security]   # optional
configSchema: { ... }         # JSON Schema for per-install config
```

Each axis adds its own fields on top. A scanner, handler or agent declares
where its code runs:

```yaml
runtime:
  location: in-tree | external
  # external also declares dispatch: lace-pull | customer-push | customer-poll
```

A module declares the Terraform system it is written for:

```yaml
bundle:
  system: aws                 # lowercase letters and digits, 1-64 characters
```

The system is part of a module's identity. A scanner, handler or agent is
`(axis, author, name)`, unique within its axis and author; a module is
`(author, name, system)`, published at `lace.cloud/<author>/<name>/<system>`,
and each such address has its own versions, as Terraform's
[module registry protocol](https://developer.hashicorp.com/terraform/internals/module-registry-protocol)
has it. So one module name carries a version line for each system it is
written for: `lace/team-role` has one for `aws` and one for `gcp`.

The publish endpoint validates each manifest against its axis when it is
published; the [registry docs](https://lace.cloud/docs/registry) list what each
axis needs.

## Publishing rules

- A release is its identity and its version: `(axis, author, name, version)`,
  and for a module `(author, name, system, version)`.
- Publishing is idempotent on the release and the manifest's content.
  Re-publishing identical content reports `unchanged`.
- A manifest is immutable per release. Publishing different content at a
  release that already exists is refused with `409`. Bump `version` to ship a
  change.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

```bash
git checkout develop && git pull
git checkout -b feature/scanner-foo
mkdir -p scanners/lace/foo
# write scanners/lace/foo/manifest.yaml and README.md
git add scanners/lace/foo
git commit -m "feat(scanners): lace/foo"
git push -u origin feature/scanner-foo
gh pr create --base develop
```

## Troubleshooting

### The publish job fails with `publish is CI-only: refused for a run of … this token publishes from another repository` or `… another branch`

The secret holds a token minted for another repository or branch. Mint a new
`registry:publish` token in that environment's `lace` organization naming
`lace-cloud/registry` and the branch in the table above, and replace the
secret.

### The publish job fails with `no token`

The secret the workflow passes is not set. Add it as in the table above.

### The publish job fails with `401`

The token in the secret was revoked or has expired. Mint a new one as above.

### The publish job fails with `Manifest already published at this identity with different content`

Bump `version` in the manifest and push again.
