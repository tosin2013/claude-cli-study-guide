---
sidebar_position: 2
title: Configuration
---

# Configuration Guide

This guide explains how to configure CodeCompass for optimal performance with Claude 3.7 Sonnet and other language models.

## Configuration File

CodeCompass uses a JSON configuration file located at `~/.codecompass/config.json` by default. You can specify a different location using the `--config` flag when running commands.

### Basic Configuration

A minimal configuration file looks like this:

```json
{
  "api_keys": {
    "anthropic": "your_anthropic_api_key"
  },
  "default_model": "anthropic/claude-3-sonnet"
}
```

### Full Configuration Options

Here's a complete configuration file with all available options:

```json
{
  "api_keys": {
    "anthropic": "your_anthropic_api_key",
    "openai": "your_openai_api_key",
    "mistral": "your_mistral_api_key",
    "cohere": "your_cohere_api_key"
  },
  "default_model": "anthropic/claude-3-sonnet",
  "max_tokens": 4096,
  "temperature": 0.7,
  "chunk_size": 8000,
  "chunk_overlap": 200,
  "models": {
    "fast": "anthropic/claude-3-haiku",
    "balanced": "anthropic/claude-3-sonnet",
    "powerful": "anthropic/claude-3-opus",
    "cost_effective": "mistral/mistral-large-latest"
  },
  "cache": {
    "enabled": true,
    "directory": "~/.codecompass/cache",
    "max_size_mb": 1024,
    "ttl_hours": 24
  },
  "semantic_chunking": {
    "enabled": true,
    "language_parsers": {
      ".py": "python",
      ".js": "javascript",
      ".ts": "typescript",
      ".java": "java",
      ".cpp": "cpp",
      ".go": "go",
      ".rb": "ruby",
      ".rs": "rust"
    }
  },
  "web_interface": {
    "port": 3000,
    "host": "127.0.0.1",
    "enable_cors": false
  },
  "logging": {
    "level": "info",
    "file": "~/.codecompass/logs/codecompass.log"
  }
}
```

## Configuration Options Explained

### API Keys

```json
"api_keys": {
  "anthropic": "your_anthropic_api_key",
  "openai": "your_openai_api_key",
  "mistral": "your_mistral_api_key"
}
```

Set your API keys for different providers. The Anthropic key is required for Claude 3.7 Sonnet, while others are optional if you want to use multiple models through LiteLLM.

### Model Selection

```json
"default_model": "anthropic/claude-3-sonnet",
"models": {
  "fast": "anthropic/claude-3-haiku",
  "balanced": "anthropic/claude-3-sonnet",
  "powerful": "anthropic/claude-3-opus",
  "cost_effective": "mistral/mistral-large-latest"
}
```

- `default_model`: The model to use when none is specified
- `models`: Named aliases for different models, making it easier to switch between them

### Generation Parameters

```json
"max_tokens": 4096,
"temperature": 0.7
```

- `max_tokens`: Maximum number of tokens to generate in responses
- `temperature`: Controls randomness in the output (0.0 = deterministic, 1.0 = creative)

### Semantic Chunking

```json
"chunk_size": 8000,
"chunk_overlap": 200,
"semantic_chunking": {
  "enabled": true,
  "language_parsers": {
    ".py": "python",
    ".js": "javascript"
    // ... other language mappings
  }
}
```

- `chunk_size`: Maximum size of each chunk in characters
- `chunk_overlap`: Number of characters to overlap between chunks
- `semantic_chunking`: Configuration for language-aware chunking:
  - `enabled`: Whether to use semantic chunking (true) or simple chunking (false)
  - `language_parsers`: Mapping of file extensions to language parsers

### Caching

```json
"cache": {
  "enabled": true,
  "directory": "~/.codecompass/cache",
  "max_size_mb": 1024,
  "ttl_hours": 24
}
```

- `enabled`: Whether to cache API responses
- `directory`: Where to store cache files
- `max_size_mb`: Maximum cache size in megabytes
- `ttl_hours`: Time-to-live for cache entries in hours

### Web Interface

```json
"web_interface": {
  "port": 3000,
  "host": "127.0.0.1",
  "enable_cors": false
}
```

- `port`: The port to run the web interface on
- `host`: The host address to bind to
- `enable_cors`: Whether to enable Cross-Origin Resource Sharing

### Logging

```json
"logging": {
  "level": "info",
  "file": "~/.codecompass/logs/codecompass.log"
}
```

- `level`: Log level (debug, info, warning, error)
- `file`: Path to log file

## Environment Variables

You can also configure CodeCompass using environment variables, which will override the config file values:

```bash
# API Keys
export CODECOMPASS_ANTHROPIC_API_KEY=your_anthropic_api_key
export CODECOMPASS_OPENAI_API_KEY=your_openai_api_key
export CODECOMPASS_MISTRAL_API_KEY=your_mistral_api_key

# General Configuration
export CODECOMPASS_DEFAULT_MODEL=anthropic/claude-3-sonnet
export CODECOMPASS_MAX_TOKENS=4096
export CODECOMPASS_TEMPERATURE=0.7

# Chunking Configuration
export CODECOMPASS_CHUNK_SIZE=8000
export CODECOMPASS_CHUNK_OVERLAP=200
export CODECOMPASS_ENABLE_SEMANTIC_CHUNKING=true

# Caching
export CODECOMPASS_CACHE_ENABLED=true
export CODECOMPASS_CACHE_DIR=~/.codecompass/cache

# Web Interface
export CODECOMPASS_WEB_PORT=3000
export CODECOMPASS_WEB_HOST=127.0.0.1
```

## Command-Line Overrides

Many configuration options can be overridden on the command line:

```bash
codecompass process --model anthropic/claude-3-opus \
                   --max-tokens 8192 \
                   --temperature 0.5 \
                   --no-cache \
                   path/to/file.py
```

## Configuration Profiles

You can create multiple configuration profiles for different use cases:

```bash
# Create a new profile
codecompass config create-profile large-context

# Edit a profile
codecompass config edit-profile large-context --max-tokens 8192 --chunk-size 16000

# Use a profile
codecompass --profile large-context process path/to/file.py
```

## Next Steps

Now that you've configured CodeCompass, you can:

- [Learn about semantic chunking](/docs/guides/semantic-chunking)
- [Understand model selection](/docs/guides/model-selection)
- [Try the Claude 3.7 Sonnet demo](/docs/demos/claude-sonnet-demo) 