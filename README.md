# merge-pr
GitHub action for merging a PR. It should be run when the PR is in a state of able to merge, so probably it is best used `on: check_suite` that is completed and successful.

Note: `check_suite` events are **not** triggered if the PR has been created by GitHub actions. However, PR creation events are triggered normally (when using personal access token) - so simply adding a `delay` should allow automatic merge. Note that if the delay is too short and branch checks are still in progress, or mandatory checks failed, the automatic merge also fails.

# Inputs
## `repository`
**Required.** Path to repository to make PR in.
## `token`
**Required.** Auth token with enough privileges to merge the given PR in the given repository.
## `pr`
**Required.** Number of an open PR in the repository.
## `merge-method`
Method of merging, one of "merge" (default), "squash" or "rebase".
## `delete-branch`
Whether or not to delete branch. Must be "true" (default) or "false".
## `delay`
The number of seconds to delay the merging. Any non-zero number will cause the action to wait. Defaults to `0` (no waiting).
## `commit-message`
Commit message. Defaults to "automatic merge of PR <number>"
## `commit-details`
Commit message details. Defaults to "merging branch <source> into <target>"
## `must-have-labels`
Comma-separated labels that the given PR must have for the action to run. Defaults to none.
## `must-not-have-labels`
Comma-separated labels that the given PR must not have. Defaults to none.

# Outputs
None. PR will be merged. If anything fails, please check the logs for a detailed message.

# Contributing
Missing a feature? Found a bug? Please create an issue. Thank you!

# Licensing
Code distributed "as is", without liabilities or warranties. Please consult `LICENSE` for details. Written by Miki Olsz. (c) 2020 Unforgiven.pl.
