# Development Workflow

Applies to application code projects. For dotfiles, config, scripts and docs, skip steps 1 to 3 unless asked.

> This file extends [common/git-workflow.md](./git-workflow.md) with the full feature development process that happens before git operations.

The Feature Implementation Workflow describes the development pipeline: research, planning, TDD, code review, and then committing to git.

## Feature Implementation Workflow

0. **Research & Reuse** _(before any new non-trivial implementation)_
   - **GitHub code search first:** Run `gh search repos` and `gh search code` to find existing implementations, templates, and patterns before writing anything new.
   - **Library docs second:** Use Context7 or primary vendor docs to confirm API behavior, package usage, and version-specific details before implementing.
   - **Kagi (MCP) only when the first two are insufficient:** use it for broader web research or discovery after GitHub search and primary docs.
   - **Check package registries:** Search npm, PyPI, crates.io, and other registries before writing utility code. Prefer battle-tested libraries over hand-rolled solutions.
   - **Search for adaptable implementations:** Look for open-source projects that solve 80%+ of the problem and can be forked, ported, or wrapped.
   - Prefer adopting or porting a proven approach over writing net-new code when it meets the requirement.

1. **Plan First** (superpowers `brainstorming`, then `writing-plans`)
   - Generate planning docs before coding when the feature is large: architecture, task list
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach** (superpowers `test-driven-development`)
   - Write tests first (RED), implement to pass (GREEN), refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review** (superpowers `requesting-code-review`, `verification-before-completion`)
   - Review right after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format
   - See [git-workflow.md](./git-workflow.md) for commit message format and PR process
