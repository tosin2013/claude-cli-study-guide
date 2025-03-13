# CodeCompass Documentation

This repository contains the documentation and demo implementations for the CodeCompass project, which demonstrates how to use Claude 3.7 Sonnet and other Large Language Models for code understanding and analysis.

## Overview

This documentation is built using [Docusaurus 2](https://docusaurus.io/), a modern static website generator optimized for documentation sites. It includes:

1. **Comprehensive Documentation**: Detailed guides on using Claude 3.7 Sonnet for code understanding
2. **Interactive Demos**: Working demonstrations of semantic chunking and multi-model selection
3. **Architecture Decision Records (ADRs)**: Technical decisions and their rationales
4. **Implementation Code**: Sample implementations for semantic chunking and LiteLLM integration

## Directory Structure

```
docs/
├── adrs/                # Architecture Decision Records
│   ├── ADR-018-docusaurus-migration.md
│   ├── ADR-019-claude-sonnet-demo.md
│   └── ADR-020-codecompass-litellm-demo.md
├── IMPLEMENTATION_PLAN.md # Overall implementation plan
├── DOCUSAURUS_SETUP.md    # Guide for setting up Docusaurus
├── SEMANTIC_CHUNKING.md   # Semantic chunking implementation details
├── LITELLM_INTEGRATION.md # LiteLLM integration details
└── README.md            # This file
```

## Getting Started

To set up the documentation site locally:

1. Follow the instructions in [DOCUSAURUS_SETUP.md](./DOCUSAURUS_SETUP.md) to initialize a new Docusaurus project.
2. Review the [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) to understand the overall structure and timeline.
3. Migrate content from this `docs` directory to the Docusaurus project structure.

## Implementation Details

### Claude 3.7 Sonnet Demo

The Claude 3.7 Sonnet demo showcases the model's capabilities for code understanding through semantic chunking. Details are documented in:

- [ADR-019: Claude Sonnet Demo Implementation](./adrs/ADR-019-claude-sonnet-demo.md)
- [Semantic Chunking Implementation](./SEMANTIC_CHUNKING.md)

### CodeCompass LiteLLM Integration

The CodeCompass LiteLLM integration demonstrates how to use multiple LLM providers through a unified interface. Implementation details are available in:

- [ADR-020: CodeCompass LiteLLM Demo](./adrs/ADR-020-codecompass-litellm-demo.md)
- [LiteLLM Integration Details](./LITELLM_INTEGRATION.md)

## Main Components

1. **Semantic Chunking Algorithm**: A Python implementation that divides codebases into semantically meaningful segments.
2. **LiteLLM Client**: A client that supports multiple LLM providers for code understanding.
3. **Web Interface**: React components for interacting with multiple models and comparing results.
4. **CLI Tools**: Command-line interfaces for easy interaction.

## Development

The development process follows these key phases:

1. **Project Setup and Cleanup** (Days 1-2)
2. **Content Migration** (Days 3-5)
3. **Claude 3.7 Sonnet Demo** (Days 6-9)
4. **CodeCompass LiteLLM Demo** (Days 10-14)
5. **Deployment** (Days 15-16)

For more details, see the [Implementation Plan](./IMPLEMENTATION_PLAN.md).

## Contributing

To contribute to this documentation:

1. Set up the Docusaurus site locally
2. Create a branch for your changes
3. Make your changes and test them locally
4. Submit a pull request

## Resources

- [Docusaurus Documentation](https://docusaurus.io/docs)
- [Claude 3.7 Sonnet Documentation](https://docs.anthropic.com/claude/docs/claude-3-7-sonnet)
- [LiteLLM Documentation](https://docs.litellm.ai/docs/)

## License

This project is licensed under the MIT License - see the LICENSE file for details. 