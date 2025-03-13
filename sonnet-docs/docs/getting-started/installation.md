---
sidebar_position: 1
title: Installation
---

# Installation Guide

This guide will help you set up CodeCompass and its dependencies for working with large codebases using Claude 3.7 Sonnet.

## Prerequisites

Before installing CodeCompass, ensure you have the following prerequisites:

- **Python**: Version 3.8 or higher
- **Node.js**: Version 18.0.0 or higher (required for web interface components)
- **API Keys**:
  - Anthropic API key for Claude (required)
  - OpenAI API key (optional, for comparison testing)
  - Mistral AI API key (optional, for comparison testing)

## Installation Options

CodeCompass can be installed through pip, the Python package manager:

```bash
# Install the latest stable version
pip install codecompass

# Install with all optional dependencies
pip install codecompass[full]

# Install development version from GitHub
pip install git+https://github.com/your-github-username/codecompass.git
```

## API Key Configuration

After installation, you need to configure your API keys:

### Option 1: Environment Variables

Set the following environment variables:

```bash
# Required for Claude 3.7 Sonnet
export ANTHROPIC_API_KEY=your_anthropic_api_key

# Optional for LiteLLM multi-model support
export OPENAI_API_KEY=your_openai_api_key
export MISTRAL_API_KEY=your_mistral_api_key
```

### Option 2: Configuration File

Create a configuration file at `~/.codecompass/config.json`:

```json
{
  "api_keys": {
    "anthropic": "your_anthropic_api_key",
    "openai": "your_openai_api_key",
    "mistral": "your_mistral_api_key"
  },
  "default_model": "anthropic/claude-3-sonnet",
  "max_tokens": 4096,
  "temperature": 0.7
}
```

## Verifying Installation

To verify your installation, run the following command:

```bash
codecompass --version
```

You should see the version number and a list of available models based on your API keys.

## Installing the Web Interface

For the web interface components:

```bash
# Navigate to the web directory
cd codecompass/web

# Install dependencies
npm install

# Start the development server
npm start
```

The web interface will be available at `http://localhost:3000`.

## Docker Installation

For containerized deployment, you can use Docker:

```bash
# Build the Docker image
docker build -t codecompass .

# Run the container with your API key
docker run -e ANTHROPIC_API_KEY=your_api_key -p 3000:3000 codecompass
```

## Next Steps

Now that you have CodeCompass installed, you can:

- [Configure your settings](/docs/getting-started/configuration)
- [Try the Claude 3.7 Sonnet demo](/docs/demos/claude-sonnet-demo)
- [Explore the LiteLLM multi-model demo](/docs/demos/codecompass-litellm-demo)

## Troubleshooting

If you encounter issues during installation:

- **API Authentication Errors**: Verify your API keys are correctly set
- **Dependency Conflicts**: Try creating a virtual environment with `python -m venv venv`
- **Web Interface Issues**: Make sure Node.js and npm are correctly installed

For further help, check the [GitHub issues](https://github.com/your-github-username/codecompass/issues) or [contact support](mailto:support@example.com). 