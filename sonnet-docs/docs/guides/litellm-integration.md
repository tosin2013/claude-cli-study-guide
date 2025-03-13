---
sidebar_position: 3
title: LiteLLM Integration
---

# LiteLLM Integration Guide

This guide explains how to integrate LiteLLM with our Claude CLI study implementations, allowing you to extend Claude CLI's architectural patterns to other language models.

## What is LiteLLM?

[LiteLLM](https://github.com/BerriAI/litellm) is an open-source library that provides a unified interface for interacting with various large language models (LLMs) from different providers, including:

- Anthropic (Claude)
- OpenAI (GPT models)
- Google (Gemini)
- Mistral AI
- Cohere
- And many others

By integrating our Claude CLI study implementations with LiteLLM, you can:

1. **Extend Claude CLI patterns** to other language models
2. **Compare architecture effectiveness** across different providers
3. **Test semantic chunking** with various models
4. **Evaluate hybrid architecture performance** with different LLMs

## Prerequisites

Before integrating LiteLLM with our Claude CLI study implementations, ensure you have:

- Our experimental implementations set up (see [CLI Emulator](/docs/experiments/implementations/cli-emulator) and [Multi-Provider CLI](/docs/experiments/implementations/multi-provider))
- Python 3.8 or higher
- API keys for the language model providers you want to use

## Installation

### 1. Install LiteLLM

First, install the LiteLLM package:

```bash
pip install litellm
```

### 2. Configure API Keys

Set up your API keys for the different providers. You can do this in several ways:

**Option 1: Environment Variables**

```bash
# For Anthropic (Claude)
export ANTHROPIC_API_KEY=your_anthropic_api_key

# For OpenAI
export OPENAI_API_KEY=your_openai_api_key

# For Google
export GOOGLE_API_KEY=your_google_api_key

# For Mistral AI
export MISTRAL_API_KEY=your_mistral_api_key
```

**Option 2: LiteLLM Config File**

Create a `litellm-config.yaml` file:

```yaml
# litellm-config.yaml
model_list:
  - model_name: claude-3-sonnet-20240229
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: your_anthropic_api_key

  - model_name: gpt-4-turbo
    litellm_params:
      model: openai/gpt-4-turbo
      api_key: your_openai_api_key

  - model_name: gemini-pro
    litellm_params:
      model: google/gemini-pro
      api_key: your_google_api_key

  - model_name: mistral-large
    litellm_params:
      model: mistral/mistral-large-latest
      api_key: your_mistral_api_key

general_settings:
  default_model: claude-3-sonnet-20240229
```

### 3. Configure Multi-Provider CLI for LiteLLM

Update your Multi-Provider CLI configuration to use LiteLLM:

```json
{
  "model": {
    "provider": "litellm",
    "config_path": "/path/to/litellm-config.yaml",
    "default_model": "claude-3-sonnet-20240229",
    "fallback_models": ["gpt-4-turbo", "mistral-large"]
  },
  "chunking": {
    "semantic_chunking": true,
    "chunk_size": 8000,
    "chunk_overlap": 200
  },
  "hybrid_processing": {
    "enabled": true,
    "local_tools": ["file_read", "search", "git"]
  }
}
```

## Basic Usage

### Using Different Models

With LiteLLM integration, you can specify which model to use with our Multi-Provider CLI:

```bash
# Use Claude 3 Sonnet (default)
multi_provider_cli.py "Explain the authentication flow in this codebase"

# Use GPT-4 Turbo
multi_provider_cli.py --provider openai --model gpt-4 "Explain the authentication flow in this codebase"

# Use Mistral Large
multi_provider_cli.py --provider mistral --model mistral-large "Explain the authentication flow in this codebase"
```

### Model Comparison

You can compare responses from different models with our Multi-Provider CLI:

```bash
multi_provider_cli.py --compare "What design patterns are used in this codebase?" \
  --models claude-3-sonnet-20240229 gpt-4-turbo mistral-large
```

This will display the responses from each model side by side, allowing you to compare their analysis.

## Advanced Configuration

### Model-Specific Parameters

You can configure different parameters for each model:

```yaml
# litellm-config.yaml
model_list:
  - model_name: claude-3-sonnet-20240229
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: your_anthropic_api_key
      temperature: 0.1
      max_tokens: 4000

  - model_name: gpt-4-turbo
    litellm_params:
      model: openai/gpt-4-turbo
      api_key: your_openai_api_key
      temperature: 0.2
      max_tokens: 3000
```

### Fallback Mechanisms

Configure fallback models in case the primary model fails:

```json
{
  "model": {
    "provider": "litellm",
    "default_model": "claude-3-sonnet-20240229",
    "fallback_models": ["gpt-4-turbo", "mistral-large"],
    "fallback_strategy": "sequential",
    "max_fallback_attempts": 2
  }
}
```

With this configuration, if Claude 3 Sonnet fails, CodeCompass will automatically try GPT-4 Turbo, and if that fails, it will try Mistral Large.

### Cost Optimization

Configure cost-based routing to automatically select the most cost-effective model:

```json
{
  "model": {
    "provider": "litellm",
    "routing_strategy": "cost",
    "cost_thresholds": {
      "low_complexity": {
        "model": "mistral-large",
        "max_tokens": 2000
      },
      "medium_complexity": {
        "model": "gpt-4-turbo",
        "max_tokens": 3000
      },
      "high_complexity": {
        "model": "claude-3-sonnet-20240229",
        "max_tokens": 4000
      }
    }
  }
}
```

With this configuration, CodeCompass will automatically select the appropriate model based on the complexity of the query and the estimated cost.

## Prompt Templates for Different Models

Different models may perform better with different prompt formats. You can configure model-specific prompt templates:

```json
{
  "prompt_templates": {
    "claude-3-sonnet-20240229": {
      "code_explanation": "Human: Please analyze this {language} code and explain what it does:\n\n{code}\n\nAssistant:",
      "semantic_search": "Human: Find code in the codebase related to: {query}\n\nAssistant:"
    },
    "gpt-4-turbo": {
      "code_explanation": "You are an expert programmer. Analyze this {language} code and explain what it does:\n\n{code}",
      "semantic_search": "Find code in the codebase related to: {query}"
    },
    "mistral-large": {
      "code_explanation": "<s>[INST] Analyze this {language} code and explain what it does:\n\n{code} [/INST]",
      "semantic_search": "<s>[INST] Find code in the codebase related to: {query} [/INST]"
    }
  }
}
```

## Programmatic Usage

You can use the LiteLLM integration programmatically in your Python code with our implementation:

```python
from multi_provider_cli import MultiProviderCLI

# Initialize MultiProviderCLI with LiteLLM
cli = MultiProviderCLI(
    provider_config_path="/path/to/litellm-config.yaml",
    default_provider="anthropic",
    default_model="claude-3-sonnet-20240229"
)

# Process a file with a specific model
chunks = cli.semantic_chunker.chunk_file('main.py')

# Process a query using the default model
response = cli.process_query("What does this code do?")

# Process a query using a different model
response_gpt4 = cli.process_query(
    "What does this code do?", 
    provider="openai", 
    model="gpt-4-turbo"
)

# Compare responses from multiple models
responses = cli.compare_models(
    "What design patterns are used in this code?",
    models=[
        {"provider": "anthropic", "model": "claude-3-sonnet-20240229"},
        {"provider": "openai", "model": "gpt-4-turbo"},
        {"provider": "mistral", "model": "mistral-large"}
    ]
)

for provider_model, response in responses.items():
    print(f"=== {provider_model} ===")
    print(response)
    print()
```

## Model Performance Comparison

Different models have different strengths when it comes to code understanding. Here's a general comparison:

| Model | Code Understanding | Documentation Generation | Bug Finding | Performance |
|-------|-------------------|------------------------|------------|------------|
| Claude 3 Sonnet | Excellent | Excellent | Very Good | Fast |
| GPT-4 Turbo | Excellent | Very Good | Excellent | Medium |
| Gemini Pro | Very Good | Good | Good | Fast |
| Mistral Large | Very Good | Good | Good | Fast |
| Claude 3 Opus | Outstanding | Outstanding | Outstanding | Slow |

## Example: Multi-Model Code Analysis

Here's an example of using our Multi-Provider CLI with multiple models to analyze a complex function:

```python
from multi_provider_cli import MultiProviderCLI

# Initialize MultiProviderCLI with LiteLLM
cli = MultiProviderCLI(provider_config_path="/path/to/litellm-config.yaml")

# Load a complex function
with open("complex_algorithm.py", "r") as f:
    code = f.read()

# Define the models to use
models = [
    {"provider": "anthropic", "model": "claude-3-sonnet-20240229"},
    {"provider": "openai", "model": "gpt-4-turbo"},
    {"provider": "mistral", "model": "mistral-large"}
]
analysis_results = {}

for model_config in models:
    provider = model_config["provider"]
    model = model_config["model"]
    model_key = f"{provider}/{model}"
    
    # Time complexity analysis
    time_analysis = cli.process_query(
        f"Analyze the time complexity of this function:\n\n{code}",
        provider=provider,
        model=model
    )
    
    # Bug detection
    bug_analysis = cli.process_query(
        f"Identify potential bugs or edge cases in this function:\n\n{code}",
        provider=provider,
        model=model
    )
    
    # Refactoring suggestions
    refactor_suggestions = cli.process_query(
        f"Suggest ways to refactor this function for better readability and performance:\n\n{code}",
        provider=provider,
        model=model
    )
    
    analysis_results[model_key] = {
        "time_complexity": time_analysis,
        "bugs": bug_analysis,
        "refactoring": refactor_suggestions
    }

# Compare and consolidate results
consolidated_analysis = cli.process_query(
    f"I've analyzed this function with multiple models. Here are their findings:\n\n" +
    "\n\n".join([f"{model}:\n{results}" for model, results in analysis_results.items()]) +
    "\n\nPlease provide a consolidated analysis that takes the best insights from each model.",
    provider="anthropic",
    model="claude-3-sonnet-20240229"  # Use Claude for the final consolidation
)

print(consolidated_analysis)
```

## Troubleshooting

### API Key Issues

If you encounter authentication errors:

1. Verify that your API keys are correct
2. Check that the environment variables are properly set
3. Ensure the API keys have the necessary permissions

### Model Availability

If a model is unavailable:

1. Check if the model name is correct in your configuration
2. Verify that you have access to the model with your API key
3. Check if the model provider is experiencing any outages

### Rate Limiting

If you encounter rate limiting:

1. Implement exponential backoff in your requests
2. Consider using a different model temporarily
3. Check your usage limits with the provider

## Best Practices

### 1. Model Selection Guidelines

Choose the appropriate model based on the task:

- **Code Explanation**: Claude 3 Sonnet or GPT-4 Turbo
- **Bug Finding**: GPT-4 Turbo or Claude 3 Opus
- **Documentation Generation**: Claude 3 Sonnet
- **Simple Queries**: Mistral Large or Gemini Pro (more cost-effective)

### 2. Cost Management

- Use less expensive models for simpler tasks
- Implement caching to avoid redundant API calls
- Monitor your usage and costs regularly

### 3. Prompt Engineering

- Adapt your prompts to each model's strengths
- Use model-specific prompt templates
- Include clear instructions and context

### 4. Fallback Strategies

- Configure multiple fallback models
- Implement retry logic with exponential backoff
- Log failures for analysis

## Conclusion

Integrating CodeCompass with LiteLLM provides flexibility, reliability, and cost optimization by allowing you to leverage multiple language models. By following this guide, you can configure CodeCompass to use the most appropriate model for each task, compare model performances, and implement fallback mechanisms for robust code analysis.

For more information on LiteLLM, visit the [official LiteLLM documentation](https://docs.litellm.ai/). 