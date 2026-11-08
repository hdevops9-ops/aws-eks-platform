# Validation status

Status: code prepared; cloud deployment has not been performed.

- Local formatting/syntax and Python plan-policy tests: run during authoring.
- Provider-aware validation, mocked module tests, and security scans: results will
  be linked here after the GitHub validation workflow actually completes.
- Remote S3 locking, AWS OIDC plan/apply, real HA and recovery: require an authorized
  AWS sandbox and are not claimed by mocked tests.
