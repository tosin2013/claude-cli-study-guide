# ADR-008: Multi-Module Knowledge Management

## Status
Proposed

## Context
Large applications consist of multiple interconnected modules. Claude needs to understand not just individual modules but their relationships and dependencies.

## Decision
We will implement a multi-module knowledge management system that:
1. Creates a structural map of the entire codebase
2. Generates module summaries that explain purpose and key components
3. Documents core workflows across module boundaries
4. Maps user journeys to relevant code files
5. Segments the codebase logically for effective ingestion within context limits
6. Leverages Claude 3.7 Sonnet's 128K context window to maintain broader awareness

## Consequences
- **Positive**: Enables Claude to understand cross-module dependencies
- **Positive**: Provides a holistic view of the application architecture
- **Positive**: Facilitates more accurate analysis of complex systems
- **Negative**: Requires significant upfront effort to implement
- **Negative**: Needs regular maintenance as the application evolves

## Implementation Details
```bash
# Create a comprehensive directory structure
find . -type f -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" | sort > codebase_structure.txt

# Segment the codebase into logical modules
# Segment 1: application overview and frontend core (components, pages)
# Segment 2: frontend utilities, context, styles
# Segment 3: backend core (controllers, models, routes)
# Segment 4: backend services, middleware, utils
# Segment 5: database, tests, config

# Initial ingestion session
claude-code session create --name "Project-Initial"
claude-code file send ./codebase_structure.txt
claude-code file send ./application_overview.md
``` 