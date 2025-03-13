# ADR-004: Context-Aware Caching System

## Status
Proposed

## Context
Many queries to the AI are repetitive or similar, especially for documentation and architecture questions. Repeatedly querying the AI for similar information is inefficient and costly.

## Decision
We will implement a context-aware caching system that:
1. Caches responses based on both the prompt and code context
2. Uses SHA-256 hashing for cache keys to ensure uniqueness
3. Sets reasonable expiration times (1 week) for cached responses
4. Integrates with the workflow to check the cache before querying Claude
5. Provides a mechanism to invalidate cache entries when the codebase changes significantly
6. Supports partial cache invalidation when specific code sections change

## Consequences
- **Positive**: Eliminates duplicate queries, reducing costs by ~50%
- **Positive**: Faster response times for cached queries
- **Positive**: Particularly effective for common documentation/architecture questions
- **Negative**: Cache management adds complexity to the system
- **Negative**: Risk of stale responses if cache invalidation isn't properly implemented

## Implementation Details
```python
# claude_cache.py  
from diskcache import Cache  
cache = Cache('./.claude_cache')  
def get_cached_response(prompt, code_context):  
    key = hashlib.sha256((prompt + json.dumps(code_context)).encode()).hexdigest()  
    return cache.get(key)  
def cache_response(prompt, code_context, response):  
    key = hashlib.sha256((prompt + json.dumps(code_context)).encode()).hexdigest()  
    cache.set(key, response, expire=604800)  # 1 week
``` 