# Claude CLI Experimental Studies

This directory contains documentation and code for our experimental studies of Claude CLI. Each subdirectory focuses on a specific aspect of Claude CLI's architecture and behavior.

## Experiment Categories

### 1. Semantic Chunking Studies

These experiments investigate how Claude CLI processes large codebases:

- [Chunking Behavior Analysis](chunking/README.md): Studies how Claude CLI divides codebases into semantic chunks
- [File Selection Patterns](chunking/file_selection.md): Examines how Claude CLI determines which files are relevant
- [Context Preservation](chunking/context_preservation.md): Analyzes how context is maintained across chunks

### 2. Differential Update Studies

These experiments analyze how Claude CLI handles codebase changes:

- [Change Detection Mechanisms](differential/change_detection.md): Studies how changes are identified
- [Update Efficiency Analysis](differential/efficiency.md): Measures token usage in update scenarios
- [Context Integration](differential/context_integration.md): Examines how changes are integrated into existing context

### 3. Session Management Studies

These experiments explore how Claude CLI maintains session state:

- [Session Persistence](sessions/persistence.md): Analyzes how context is maintained between interactions
- [Context Window Management](sessions/context_window.md): Studies how Claude CLI manages token limits
- [Extended Thinking Triggers](sessions/extended_thinking.md): Identifies when extended thinking mode is activated

### 4. Hybrid Architecture Studies

These experiments investigate how Claude CLI balances local and remote processing:

- [Local Processing Identification](hybrid/local_processing.md): Determines which operations happen locally
- [Tool Implementation Analysis](hybrid/tools.md): Studies how Claude CLI's tools work
- [Remote API Optimization](hybrid/api_optimization.md): Examines how API calls are optimized

## Running Experiments

Each experiment directory contains detailed instructions for running that specific experiment. Generally, experiments follow this pattern:

```bash
# Install dependencies
npm install

# Run a specific experiment
npm run experiment:chunking -- --repo=/path/to/test/repo

# Generate reports
npm run report:chunking
```

## Experimental Implementations

Our experimental implementations based on study findings:

### Claude CLI Emulator

A prototype implementation that emulates Claude CLI's core functionality:

```python
from claude_study.emulator import ClaudeCliEmulator

# Create emulator
emulator = ClaudeCliEmulator("anthropic/claude-3-sonnet")

# Create session
session = emulator.session_create(name="test-session")

# Send file
emulator.file_send("path/to/file.py")

# Send prompt
response = emulator.prompt("Explain this code")
```

### Multi-Provider Adaptation

Our experimental extension to support multiple LLM providers via LiteLLM:

```python
from claude_study.multi_provider import MultiProviderCLI

# Create CLI with any supported model
cli = MultiProviderCLI("mistral/mistral-large")

# Use with same interface as our Claude CLI emulator
cli.session_create("test-session")
cli.file_send("path/to/file.py")
response = cli.prompt("Explain this code")
```

## Contributing Experiments

We welcome contributions of new experiments! To add a new experiment:

1. Create a directory under the appropriate category
2. Include a README.md explaining the experiment's purpose and methodology
3. Add any necessary code or scripts
4. Document your findings

Please follow our [contribution guidelines](../CONTRIBUTING.md) when submitting experiments.