# AI Agent Instructions for this Repository

This file contains rules and context that any AI agent working on this repository must follow.

## Documentation Rules
- **No Permanent Artifacts**: Do not leave important, permanent documentation (such as architecture, app usage, workflows, or walkthroughs) solely inside the chat session's Artifacts directory (`<appDataDir>\brain\...`).
- **Use the Repository**: Permanent documentation MUST be saved directly into the repository.
  - Project overview and setup instructions go in `README.md`.
  - Detailed design and specifications should be placed in a `docs/` directory.
- Artifacts (`task.md`, `implementation_plan.md`, `walkthrough.md`) should only be used as temporary scratchpads for the current chat session.

## Project Context
- **Stack**: Flutter (Android & Web support).
- **State Management**: (Currently simple state, SharedPreferences for persistence).
