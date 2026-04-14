# registry-tf

Terraform modules for the [Lace](https://lace.cloud) public registry.

## Branch Strategy

All changes follow a three-tier flow:

```
feature/* → develop → main
```

| Branch | Purpose |
|--------|---------|
| `feature/*` | Individual module work — branch from `develop` |
| `develop` | Integration branch — every module is validated before merging here |
| `main` | Production — merging here publishes modules to the registry |

Both `develop` and `main` are protected branches requiring a PR and passing status checks.

Changes to `.github/` require review from `@lace-cloud/platform-team` (CODEOWNERS).

## Repository Structure

```
registry-tf/
├── modules/
│   └── aws/
│       └── <service>/
│           └── <module-name>/
│               ├── module.yaml   # Module metadata (required)
│               ├── main.tf       # Terraform resources (required)
│               ├── variables.tf
│               ├── outputs.tf
│               └── versions.tf
└── .github/
    ├── CODEOWNERS
    └── workflows/
        ├── validate.yml   # PR validation on develop
        ├── gate.yml       # Source branch check on main
        └── publish.yml    # Auto-registers on merge to main
```

## Module Structure

Every module requires:

- `module.yaml` — module metadata
- `main.tf` — Terraform resources

```
modules/aws/s3/bucket/
modules/aws/iam/role/
modules/aws/cloudwatch/log_group/
```

`variables.tf`, `outputs.tf`, and `versions.tf` are optional but recommended.

## module.yaml Reference

```yaml
module:
  id: aws/service/module-name            # Required: unique registry ID
  name: module-name                      # Required: kebab-case name
  system: aws                            # Required: aws | google | azure
  version: 1.0.0                         # Required: semantic version
  description: "What this module does"   # Required

  categories:
    - storage                            # Optional: for discoverability

  authors:
    - name: "Lace Platform Team"
      email: "team@lace.cloud"

  example: |                             # Optional but recommended
    module "example" {
      source = "git::https://github.com/lace-cloud/registry-tf.git//modules/aws/s3/bucket?ref=<sha>"
      bucket_name = "my-bucket"
    }
```

### Critical fields

| Field | Value | Why it matters |
|---|---|---|
| `id` | `aws/service/name` | Must be unique across the registry. |

## Contributing a Module

1. Branch from `develop`:
   ```bash
   git checkout develop && git pull
   git checkout -b feature/aws-<service>-<name>
   ```

2. Create the module directory: `modules/aws/<service>/<name>/`

3. Add required files:

   **`module.yaml`**
   ```yaml
   module:
     id: aws/<service>/<name>
     name: <name>
     system: aws
     version: 1.0.0
     description: "..."
   ```

   **`main.tf`** — your Terraform resources

   **`versions.tf`** (recommended)
   ```hcl
   terraform {
     required_version = ">= 1.3"
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = ">= 5.0"
       }
     }
   }
   ```

4. Validate locally:
   ```bash
   cd modules/aws/<service>/<name>
   terraform init -backend=false && terraform validate
   terraform fmt -check
   ```

5. Open a PR to `develop` — CI validates structure, fields, uniqueness, version bump, formatting, and `terraform validate`.

6. Once merged, open a PR from `develop` to `main`.

7. Merge to `main` — the module is automatically registered in the Lace registry.

## Using This Repo as a Private Module Registry

Enterprise teams can fork this repository to run a private Terraform module registry under their Lace organization.

### Setup

1. **Fork** this repo into your GitHub organization.

2. **Make the repository private** (Settings → General → Danger Zone → Change repository visibility → Make private). This ensures your modules are not publicly accessible.

   > **Note:** GitHub currently does not allow changing the visibility of a forked repository directly. If you cannot change the visibility, create a new private repository and push the contents of the fork to it instead. A fix for this limitation is being tracked separately.

3. **Set repository secret** (Settings → Secrets and variables → Actions → Secrets):

   | Secret | Value |
   |--------|-------|
   | `LACE_REGISTRY_KEY` | Org-scoped API key (create via `lace api-key create --organization <slug>` or in the portal at Organization Settings → Registry Keys) |

4. **Enable GitHub Actions workflows** — forked repositories have workflows disabled by default. Go to the **Actions** tab in your repository and click **"I understand my workflows, go ahead and enable them"** to activate the CI/CD pipelines.

5. **Configure branches:**

   Create the `develop` branch if it doesn't exist:
   ```bash
   git checkout -b develop
   git push -u origin develop
   ```

   Then configure branch protection rules (Settings → Branches → Add branch protection rule) for both `develop` and `main`:

   - **Branch name pattern:** `develop` (repeat for `main`)
   - Enable **Require a pull request before merging**
   - Enable **Require status checks to pass before merging** and add the required checks:
     - For `develop`: `Summary`
     - For `main`: `Summary`, `Gate / Source Branch`
   - Enable **Require branches to be up to date before merging**
   - Optionally enable **Include administrators** to enforce rules for all users

   Set the **default branch** to `develop` (Settings → General → Default branch) so that new PRs target `develop` by default.

6. **Customize the `authorize` job** (optional) — the Authorize job in `publish.yml` checks membership in `@<org>/platform-team` using a GitHub App. If you don't use the Lace GitHub App, either:
   - Remove the `authorize` job and the `needs: authorize` line from the `prepare` job
   - Or replace it with your own authorization mechanism

### How it works

When you push module changes to `main` (via the `develop` → `main` PR flow), the publish workflow automatically registers modules in the Lace registry using the `LACE_REGISTRY_KEY` secret. The API key determines which organization the modules are scoped to — no additional organization flag is needed.

## Troubleshooting

### `authentication failed` or `unauthorized`

Ensure `LACE_REGISTRY_KEY` is set in repository secrets and that the API key is valid and has not expired.

### `terraform validate` fails with provider errors

Ensure `versions.tf` declares the correct provider and version constraint.
Run `terraform init -backend=false` locally to reproduce.

### Module ID conflict

Each module must have a globally unique `id` in `module.yaml`.
Check existing modules for conflicts: `grep -r "^  id:" modules/`.

### Gate fails: "PRs to main must come from develop"

Only `develop` can be merged into `main`. If you opened a PR from a feature branch directly to `main`, close it and follow the standard flow: PR to `develop` first, then `develop` to `main`.
