# Contributing

This repository holds the `lace` organization's registry artifacts. Pull
requests are reviewed by `@lace-cloud/platform-team`.

## Folder shape

```
<axis>/<author>/<name>/manifest.yaml
<axis>/<author>/<name>/README.md
modules/<system>/…/manifest.yaml
```

`<axis>` is one of `scanners`, `handlers` or `agents`, and `<author>` is
`lace`. A module sits under its system's directory, `modules/<system>/`, as in
`modules/aws/lace/team-role/`, and carries its `*.tf` files beside
`manifest.yaml` and `README.md`; its manifest names it, not its path. Every
other axis is a manifest and a README.

What each axis's manifest must declare is in the
[registry docs](https://lace.cloud/docs/registry). The publish endpoint is the
contract: it validates every manifest against its axis when it is published.

## What the check enforces

`check.yml` runs on every pull request into `develop` or `main` and fails it
unless each changed manifest:

- passes the registry's publish validator, `lace registry validate`, with its
  README;
- declares a version the registry does not already hold at the manifest's
  identity;
- for a module, passes `lace module validate` with the verdict
  `already-lace-style`.

## Review checklist

- [ ] The check passes.
- [ ] Each artifact's identity is unique across the repository:
      `(axis, author, name)`, and for a module `(author, name, system)`, its
      system being the manifest's `bundle.system`.
- [ ] `README.md` sits beside `manifest.yaml` and explains what the artifact does
      and how to configure it.
- [ ] No secrets, credentials or customer data in any manifest or README.

## Manifest immutability

Once a version is published, its content is frozen. Publishing different
content at the same release, `(axis, author, name, version)` or a module's
`(author, name, system, version)`, is refused with `409`. To ship a fix, bump
`version`.
