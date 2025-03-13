---
sidebar_position: 4
---

# Multi-Provider CLI

Our Multi-Provider CLI is an experimental implementation that extends Claude CLI patterns to multiple LLM providers using LiteLLM. This implementation explores how the architectural patterns we've identified in Claude CLI can be applied to other language models.

## Overview

The Multi-Provider CLI is designed to:

1. Implement core Claude CLI architectural patterns
2. Support multiple LLM providers through LiteLLM
3. Optimize context for different model capabilities
4. Compare performance and capabilities across providers

This implementation allows us to explore how Claude CLI's architecture can be extended beyond Claude models to create a unified interface for AI-assisted programming with any LLM.

## Architecture

The Multi-Provider CLI follows a similar architecture to our Claude CLI Emulator, with additional components for provider management:

```
┌─────────────────────────┐
│   Command-Line Interface│
└───────────┬─────────────┘
            │
┌───────────▼─────────────┐
│    Local Processing     │
│  ┌─────────────────────┐│
│  │  Semantic Chunker   ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │  Context Manager    ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │  Tool Manager       ││
│  └─────────────────────┘│
└───────────┬─────────────┘
            │
┌───────────▼─────────────┐
│  Provider Manager       │
│  ┌─────────────────────┐│
│  │  Provider Registry  ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │  Context Optimizer  ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │  Response Adapter   ││
│  └─────────────────────┘│
└───────────┬─────────────┘
            │
┌───────────▼─────────────┐
│  LiteLLM Integration    │
└───────────┬─────────────┘
            │
┌───────────▼─────────────┐
│  Response Processing    │
└─────────────────────────┘
```

### Key Components

#### 1. Provider Manager

The Provider Manager handles LLM provider selection and configuration:

```python
class ProviderManager:
    def __init__(self, config_path):
        self.providers = {}
        self.load_provider_config(config_path)
        
    def load_provider_config(self, config_path):
        with open(config_path, 'r') as f:
            config = json.load(f)
            
        for provider_config in config['providers']:
            provider_id = provider_config['id']
            self.providers[provider_id] = {
                'name': provider_config['name'],
                'model_map': provider_config['model_map'],
                'context_optimizer': self._load_optimizer(provider_config['optimizer']),
                'response_adapter': self._load_adapter(provider_config['adapter'])
            }
            
    def get_provider(self, provider_id):
        if provider_id in self.providers:
            return self.providers[provider_id]
        else:
            raise ValueError(f"Unknown provider: {provider_id}")
            
    def list_providers(self):
        return [{'id': k, 'name': v['name']} for k, v in self.providers.items()]
```

#### 2. Context Optimizer

The Context Optimizer adapts context for different models:

```python
class ContextOptimizer:
    def __init__(self, provider_config):
        self.provider_config = provider_config
        
    def optimize_context(self, context, model_id):
        # Get model-specific settings
        model_config = self.provider_config['model_map'].get(model_id, {})
        max_tokens = model_config.get('max_context_tokens', 8000)
        token_budget = int(max_tokens * 0.9)  # Leave 10% for response
        
        # Optimize context based on provider
        if self.provider_config['name'] == 'anthropic':
            # Claude-specific optimizations
            return self._optimize_for_claude(context, token_budget)
        elif self.provider_config['name'] == 'openai':
            # OpenAI-specific optimizations
            return self._optimize_for_openai(context, token_budget)
        # Add other provider-specific optimizations
        
        # Default optimization
        return self._default_optimize(context, token_budget)
```

#### 3. Response Adapter

The Response Adapter normalizes responses from different providers:

```python
class ResponseAdapter:
    def __init__(self, provider_config):
        self.provider_config = provider_config
        
    def adapt_response(self, provider_response, expected_format):
        # Convert provider-specific response to standardized format
        if self.provider_config['name'] == 'anthropic':
            return self._adapt_claude_response(provider_response, expected_format)
        elif self.provider_config['name'] == 'openai':
            return self._adapt_openai_response(provider_response, expected_format)
        # Add other provider-specific adaptations
        
        # Default adaptation
        return self._default_adapt(provider_response, expected_format)
        
    def _adapt_claude_response(self, response, expected_format):
        # Extract tool calls and content from Claude response
        tool_calls = self._extract_claude_tool_calls(response)
        content = response['content'][0]['text']
        
        # Format according to expected format
        return {
            'content': content,
            'tool_calls': tool_calls
        }
```

#### 4. LiteLLM Integration

The LiteLLM Integration handles communication with different providers:

```python
class LiteLLMClient:
    def __init__(self):
        self.litellm_client = litellm.LiteLLM()
        
    def send_prompt(self, provider, model, prompt, context, tools=None):
        # Convert to LiteLLM format
        litellm_request = self._create_litellm_request(provider, model, prompt, context, tools)
        
        # Send request through LiteLLM
        response = self.litellm_client.completion(litellm_request)
        
        # Return raw provider response for adaptation
        return response
        
    def _create_litellm_request(self, provider, model, prompt, context, tools):
        # Map to provider-specific model
        model_string = f"{provider}/{model}"
        
        # Create messages array
        messages = [
            {"role": "system", "content": context},
            {"role": "user", "content": prompt}
        ]
        
        # Convert tools to provider-specific format if needed
        provider_tools = self._convert_tools(provider, tools) if tools else None
        
        # Create LiteLLM request
        request = {
            "model": model_string,
            "messages": messages,
        }
        
        if provider_tools:
            request["tools"] = provider_tools
            
        return request
```

## Provider Configuration

The Multi-Provider CLI supports configuration for different providers:

```json
{
  "providers": [
    {
      "id": "anthropic",
      "name": "Anthropic",
      "model_map": {
        "claude-3-opus": {
          "model_id": "claude-3-opus-20240229",
          "max_context_tokens": 200000,
          "capabilities": ["code", "reasoning", "tool_use"]
        },
        "claude-3-sonnet": {
          "model_id": "claude-3-sonnet-20240229",
          "max_context_tokens": 180000,
          "capabilities": ["code", "reasoning", "tool_use"]
        }
      },
      "optimizer": "anthropic_optimizer",
      "adapter": "anthropic_adapter"
    },
    {
      "id": "openai",
      "name": "OpenAI",
      "model_map": {
        "gpt-4": {
          "model_id": "gpt-4-turbo-preview",
          "max_context_tokens": 128000,
          "capabilities": ["code", "reasoning", "tool_use"]
        },
        "gpt-3.5": {
          "model_id": "gpt-3.5-turbo",
          "max_context_tokens": 16000,
          "capabilities": ["code", "tool_use"]
        }
      },
      "optimizer": "openai_optimizer",
      "adapter": "openai_adapter"
    }
  ],
  "default_provider": "anthropic",
  "default_model": "claude-3-sonnet"
}
```

## Provider-Specific Adaptations

### Claude Adaptations

For Claude models, we implement these adaptations:

1. **Context Formatting**: Using Claude's context format for optimal processing
2. **Tool Definition**: Formatting tools in Claude's expected format
3. **Response Handling**: Extracting tool calls and content from Claude's responses

Example of Claude-specific tool formatting:

```python
def _format_claude_tools(self, tools):
    claude_tools = []
    
    for tool in tools:
        claude_tool = {
            "name": tool["name"],
            "description": tool["description"],
            "parameters": {
                "type": "object",
                "properties": {}
            }
        }
        
        # Convert parameters
        for param_name, param_def in tool["parameters"].items():
            claude_tool["parameters"]["properties"][param_name] = {
                "type": param_def["type"],
                "description": param_def["description"]
            }
            
        # Add required parameters
        if "required" in tool:
            claude_tool["parameters"]["required"] = tool["required"]
            
        claude_tools.append(claude_tool)
        
    return claude_tools
```

### OpenAI Adaptations

For OpenAI models, we implement these adaptations:

1. **Context Structuring**: Formatting context for OpenAI models
2. **Function Calling**: Converting tools to OpenAI's function calling format
3. **Response Processing**: Extracting function calls from OpenAI responses

Example of OpenAI-specific response processing:

```python
def _adapt_openai_response(self, response, expected_format):
    # Extract content from OpenAI response
    content = response['choices'][0]['message']['content']
    
    # Extract tool calls from OpenAI response
    tool_calls = []
    if 'tool_calls' in response['choices'][0]['message']:
        for call in response['choices'][0]['message']['tool_calls']:
            tool_calls.append({
                'name': call['function']['name'],
                'arguments': json.loads(call['function']['arguments'])
            })
    
    # Format according to expected format
    return {
        'content': content,
        'tool_calls': tool_calls
    }
```

## Usage Example

Using the Multi-Provider CLI:

```bash
# Initialize with default provider (Anthropic)
python multi_provider_cli.py

# Specify a different provider and model
python multi_provider_cli.py --provider openai --model gpt-4

# Compare results across providers
python multi_provider_cli.py --compare "How do I implement authentication in Express.js?"
```

## Performance Comparison

We've conducted experiments comparing performance across providers:

| Provider | Model | Task Type | Speed | Token Efficiency | Code Quality |
|----------|-------|-----------|-------|------------------|--------------|
| Anthropic | Claude 3 Opus | Code Generation | Medium | Very High | Excellent |
| Anthropic | Claude 3 Sonnet | Code Generation | High | High | Very Good |
| OpenAI | GPT-4 | Code Generation | Medium | High | Excellent |
| OpenAI | GPT-3.5 | Code Generation | Very High | Medium | Good |
| Cohere | Command | Code Generation | High | Medium | Good |

## Lessons Learned

Implementing the Multi-Provider CLI has provided several insights:

1. **Common Architectural Patterns**: The core architecture of Claude CLI works well across providers
2. **Provider-Specific Optimizations**: Each provider benefits from custom context preparation
3. **Tool Integration Differences**: Tool/function calling interfaces vary significantly between providers
4. **Response Format Variations**: Response formats and structures differ between providers
5. **Performance Tradeoffs**: Different providers excel in different areas (speed, accuracy, etc.)

These insights help us understand which aspects of Claude CLI's design are provider-specific and which are universal to AI-assisted programming tools.

## Future Work

Planned improvements to the Multi-Provider CLI include:

1. **More Providers**: Support for additional LLM providers
2. **Smarter Provider Selection**: Automatic selection of the best provider for a given task
3. **Hybrid Approaches**: Using different providers for different aspects of a workflow
4. **Caching Across Providers**: Sharing context and caching across different providers
5. **Performance Optimization**: Provider-specific optimizations for better performance

## Conclusion

The Multi-Provider CLI demonstrates how Claude CLI's architectural patterns can be extended to other LLM providers. While each provider has unique characteristics, the core architectural patterns remain effective across providers, suggesting that these patterns represent fundamental approaches to AI-assisted programming rather than Claude-specific implementations.