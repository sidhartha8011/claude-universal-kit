---
description: Harden a finished feature before merge
argument-hint: [branch or feature name]
---

The work below is functionally complete. Get it to merge quality: review
the full diff against the default branch, address correctness and security
issues, fill thin test coverage, and verify the feature end-to-end with
proof. Flag anything in the diff that doesn't belong to this feature.
Don't commit or push unless I say so.

Run the review as a fresh-context `spec-verifier` dispatch (diff +
requirements only — not this conversation); security-sensitive diffs also
get `security-auditor`. Load `model-adaptation` token discipline; on any
failed check, retry per `grounded-loops` (max 3, evidence-quoted).

SCOPE: $ARGUMENTS
(if empty: current branch / uncommitted changes vs the default branch)
