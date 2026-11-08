# Terraform behavior evidence

Tested commit: `86737974a4b382a8128f7e41e53898b345c41954`.

[Successful workflow](https://github.com/hdevops9-ops/aws-eks-platform/actions/runs/42449821763) · artifact `terraform-behavior-evidence`.

Native Terraform executed four passing tests with mocked providers. They assert lab/production topology and reject invalid environments and root administrator ARNs. `apply` inside these tests applies mock state only; no AWS account was used. Real AWS plan/apply, remote locking, EKS boot, upgrades, and AZ recovery remain unverified.
