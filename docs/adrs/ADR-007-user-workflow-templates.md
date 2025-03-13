# ADR-007: User Workflow Templates

## Status
Proposed

## Context
For developers to effectively use AI-assisted coding, they need standardized workflows that integrate with their daily routines.

## Decision
We will design and implement user workflow templates that:
1. Provide morning sync scripts to update Claude with overnight changes
2. Create task-specific workflows for bug fixes, feature development, and code reviews
3. Design architecture discussion templates for system-level questions
4. Implement weekly comprehensive update scripts for maintaining knowledge
5. Include tooling for major version updates and documentation integration
6. Leverage Claude Code's command-line capabilities for direct integration with the development workflow

## Consequences
- **Positive**: Standardizes interactions with Claude across the team
- **Positive**: Reduces learning curve for new team members
- **Positive**: Ensures consistent and effective utilization of AI capabilities
- **Negative**: May be too rigid for some development styles
- **Negative**: Requires maintenance as AI capabilities evolve

## Implementation Details
```bash
#!/bin/bash
# morning_claude_sync.sh

# Update Claude with overnight changes
git diff --name-only HEAD~1 HEAD > ./today_changes.txt
claude-code file send ./today_changes.txt
claude-code prompt "Here are the files changed since yesterday. Please update your understanding of the codebase."

# Get a summary of changes
claude-code prompt "Summarize the key architectural changes from yesterday's commits."
``` 