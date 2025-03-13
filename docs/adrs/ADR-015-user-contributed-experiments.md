# ADR-015: User-Contributed Experiments and Benchmarks

## Status
Proposed

## Context
The CodeCompass project provides a framework for evaluating various AI-powered development environments. The effectiveness and utility of this system would be significantly enhanced by allowing the broader community to contribute their own experiments, benchmarks, and findings. By creating a standardized system for these contributions, we can leverage the collective experience and diverse use cases of the community, while maintaining consistency and quality.

## Decision
We will implement a user contribution system for experiments and benchmarks that:

1. Defines standardized templates and formats for:
   - Experimental configurations
   - Benchmark datasets
   - Performance metrics
   - Result reporting
   - Environment specifications

2. Establishes a contribution workflow that:
   - Allows submission via pull requests
   - Includes automated validation of submissions
   - Provides clear guidelines and documentation
   - Supports versioning of benchmark datasets
   - Tags contributions by categories (e.g., performance, security, multi-file operations)

3. Creates a repository structure that organizes contributions by:
   - Development environment type (IDE, CLI, VSCode extension, etc.)
   - Task category (code generation, refactoring, debugging, etc.)
   - Programming language or technology stack
   - Complexity level
   - Submission date and contributor

4. Implements automated processing for contributions including:
   - Validation of submission format and completeness
   - Anonymization of sensitive information
   - Generation of standard visualization and comparison charts
   - Integration into the project documentation and website
   - Updating of leaderboards and performance indices

5. Develops a public showcase system that:
   - Highlights particularly valuable or interesting contributions
   - Provides an interactive explorer for benchmark results
   - Enables filtering and comparison of different environments
   - Visualizes performance trends over time
   - Credits contributors appropriately

## Consequences
- **Positive**: Expands the range of environments and scenarios tested
- **Positive**: Involves the community in project development and improvement
- **Positive**: Provides real-world validation from diverse usage patterns
- **Positive**: Creates a valuable resource for the AI coding assistant ecosystem
- **Positive**: Enables discovery of optimization techniques across different setups
- **Negative**: Requires significant effort to maintain quality and consistency
- **Negative**: Introduces complexity in managing and validating external contributions
- **Negative**: May create challenges in normalizing results across different environments

## Implementation Approach

The user contribution system would be structured as follows:

1. **Contribution Templates**:
   - YAML template for experiment configuration
   - Markdown template for results and analysis
   - JSON schema for benchmark metrics
   - Standard format for benchmark datasets
   - README template with required sections

2. **Repository Structure**:
   ```
   /community-experiments/
     /benchmarks/
       /code-generation/
       /refactoring/
       /debugging/
       /documentation/
       /security-review/
     /environments/
       /claude-api/
       /cursor-ai/
       /windsurf-ai/
       /claude-code-cli/
       /cline-vscode/
       /custom-integrations/
     /datasets/
       /python/
       /javascript/
       /java/
       /go/
       /other-languages/
     /visualizations/
     /templates/
     /tools/
     CONTRIBUTING.md
   ```

3. **Contribution Process**:
   - Fork the repository
   - Select appropriate template
   - Configure experiment based on guidelines
   - Run experiment and collect results
   - Generate standardized metrics
   - Submit pull request with complete documentation
   - Automated validation and reviewer feedback
   - Merge and integration into showcase

4. **Validation and Processing**:
   - Automated checks for compliance with templates
   - Verification of complete metrics and results
   - Standardization of output formats
   - Generation of comparison visualizations
   - Integration with existing benchmark data

5. **Public Showcase**:
   - Interactive dashboard of benchmark results
   - Filtering system by environment, task, and language
   - Contribution leaderboard
   - Trend analysis and historical comparisons
   - Integration with GitHub Pages site

## Example Contribution Template

```yaml
# experiment.yaml
name: "Multi-File Refactoring Performance"
contributor:
  github_username: "contributor-username"
  organization: "Optional Organization"  # optional
  contact: "optional-email@example.com"  # optional

environment:
  name: "cursor-ai"
  version: "2.1.0"
  base_llm: "claude-3.5-sonnet"
  configuration:
    temperature: 0.7
    max_tokens: 4000
    features_enabled:
      multi_file_editing: true
      agent_mode: true
      code_search: true

task:
  category: "refactoring"
  language: "python"
  description: "Convert a monolithic Flask application into a modular structure with blueprints"
  complexity: "medium"  # [simple, medium, complex]
  dataset: "flask-monolith-v1"  # Reference to a dataset in /datasets
  
metrics:
  - name: "time_to_completion"
    unit: "seconds"
    value: 420
  - name: "prompt_token_usage"
    unit: "tokens"
    value: 8523
  - name: "completion_token_usage"
    unit: "tokens"
    value: 3145
  - name: "total_cost"
    unit: "USD"
    value: 0.076
  - name: "correctness_score"
    unit: "percentage"
    value: 92
  - name: "user_intervention_count"
    unit: "interventions"
    value: 3

results_summary: >
  The environment successfully refactored the monolithic Flask application 
  into a modular structure with blueprints. It correctly identified major 
  functional areas and reorganized them into appropriate modules. Minor 
  interventions were needed to resolve import issues in one module.

comparison:
  baseline_environment: "manual-implementation"
  improvement_factors:
    time_to_completion: 0.45  # 55% faster than baseline
    total_cost: 0.20  # 80% cheaper than baseline
    correctness_score: 0.92  # 92% as correct as baseline
```

## Example Results Markdown Template

```markdown
# Multi-File Refactoring Performance Results

## Summary

This experiment evaluated Cursor AI's ability to refactor a monolithic Flask application into a modular structure using blueprints. The task represents a common real-world refactoring operation that requires understanding multiple files and their relationships.

## Environment Details

- **Tool**: Cursor AI v2.1.0
- **Base LLM**: Claude 3.5 Sonnet
- **Features Used**: Multi-file editing, Agent mode, Code search
- **Hardware**: MacBook Pro M1, 16GB RAM
- **Date Performed**: 2025-03-15

## Task Description

The task involved converting a single-file Flask application (`app.py`, ~500 lines) into a modular structure with:
- Blueprint modules for each major feature
- Shared models and utilities
- Proper import structure
- Maintained functionality

## Metrics

| Metric | Value | Unit | Notes |
|--------|-------|------|-------|
| Time to Completion | 420 | seconds | Total time from task description to complete working solution |
| Prompt Token Usage | 8,523 | tokens | Total tokens sent to the model |
| Completion Token Usage | 3,145 | tokens | Total tokens generated by the model |
| Total Cost | $0.076 | USD | Based on Claude 3.5 Sonnet pricing |
| Correctness Score | 92% | percentage | Based on test suite passing rate |
| User Intervention Count | 3 | interventions | Number of manual corrections needed |

## Analysis

Cursor AI demonstrated strong capabilities in understanding the overall architecture of the application and correctly identifying components that should be moved to separate modules. The tool performed particularly well in:

1. Identifying logical components for blueprint separation
2. Maintaining route definitions correctly
3. Setting up proper blueprint registration

Areas for improvement included:
1. Handling circular imports (required 2 user interventions)
2. Reorganizing model relationships (required 1 user intervention)

## Comparison to Baseline

Compared to a manual implementation of the same refactoring task:
- **Time**: 55% faster than manual implementation
- **Cost**: 80% cheaper when factoring developer time
- **Quality**: 92% as correct as manual implementation before interventions

## Screenshots

[Screenshot of Cursor AI splitting files]

[Screenshot of blueprint structure]

## Conclusion

Cursor AI provided significant efficiency gains for this refactoring task, though it still required some user guidance for complex dependency issues. The multi-file editing capability was essential for this task's success.
```

## Initial Implementation Tasks

1. Create directory structure for community contributions
2. Develop YAML schema for experiment configuration
3. Create Markdown templates for result reporting
4. Implement GitHub Actions workflow for validation
5. Document contribution process in CONTRIBUTING.md
6. Develop visualization tools for benchmark results
7. Create initial example contributions as references
8. Implement integration with GitHub Pages for public showcase 