# ADR-005: Strategic Session Management

## Status
Proposed

## Context
Claude's API costs can accumulate quickly without proper management. Additionally, keeping sessions open indefinitely consumes resources unnecessarily. Claude 3.7 Sonnet introduces extended thinking mode, which can significantly increase token usage but provides deeper insights.

## Decision
We will implement a strategic session management system that:
1. Creates time-limited sessions with automatic expiration (8 hours)
2. Implements token budgets per session to prevent overruns
3. Schedules bulk operations during off-peak hours when possible
4. Provides tools for monitoring and managing session usage
5. Automatically prunes old sessions to prevent accumulation
6. Controls extended thinking mode usage based on task complexity
7. Sets thinking token budgets for different types of tasks

## Consequences
- **Positive**: Enforces responsible token usage
- **Positive**: Prevents unexpected cost overruns
- **Positive**: Optimizes when possible for off-peak pricing
- **Positive**: Makes effective use of Claude 3.7's hybrid reasoning capabilities
- **Negative**: May interrupt long-running operations if not properly managed
- **Negative**: Requires additional scheduling complexity

## Implementation Details
```bash
# session_manager.sh  
HOUR=$(date +%H)  
RATE_MULTIPLIER=1.0  
if [[ $HOUR -ge 2 && $HOUR -lt 8 ]]; then  
    RATE_MULTIPLIER=0.7  # 30% off-peak discount  
fi  
claude-code session create \
    --name "project-$(date +%s)" \
    --budget $(echo "10000 * $RATE_MULTIPLIER" | bc) \
    --ttl 8h \
    --thinking-budget 30000
``` 