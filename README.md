# Claude CLI Study Guide

[![GitHub Pages Status](https://github.com/tosin2013/claude-cli-study-guide/workflows/deploy/badge.svg)](https://github.com/tosin2013/claude-cli-study-guide/actions)

This project focuses on studying and learning from Claude CLI's architecture, design patterns, and capabilities. We analyze how Claude CLI efficiently processes large codebases and create experimental implementations to test our understanding.

## 🔍 Learning Focus Areas

- **🧠 Semantic Chunking Analysis**: Studying how Claude CLI divides codebases into meaningful segments
- **📊 Differential Update Patterns**: Investigating how Claude CLI tracks and processes changes
- **🔄 Hybrid Architecture Study**: Understanding how Claude CLI balances local and remote processing
- **💾 Session Management Research**: Learning how Claude CLI maintains context across interactions
- **⚙️ LiteLLM Integration Experiment**: Extending Claude CLI patterns to other LLM providers
- **🧪 Experimental CLI Emulator**: Testing our understanding by building an experimental implementation

## 📚 Documentation & Learning Resources

Visit our [GitHub Pages site](https://tosin2013.github.io/claude-cli-study-guide/) for interactive learning resources, architecture visualizations, and detailed documentation of our findings.

- [Interactive Demos](https://tosin2013.github.io/claude-cli-study-guide/docs/demos/)
- [Experimental Findings](https://tosin2013.github.io/claude-cli-study-guide/docs/findings/)

Comprehensive documentation is also available in the [docs](docs) directory:

- [Study Methodology](docs/METHODOLOGY.md)
- [Experimental Implementations](docs/experiments/README.md)

## 🚀 Getting Started with Our Study

### Prerequisites

- Node.js 18+
- Git 2.23+
- An Anthropic API key with access to Claude 3.7 Sonnet
- Claude CLI installed (for comparative analysis)

### Setup for Documentation Site

```bash
# Clone the repository
git clone https://github.com/tosin2013/claude-cli-study-guide.git
cd claude-cli-study-guide

# Install dependencies for the main project
npm install

# Install dependencies for the Docusaurus site
cd sonnet-docs
npm install

# Start the documentation site locally
npm run start
```

### Running the Documentation Site

```bash
# In the sonnet-docs directory
npm run start     # Start development server
npm run build     # Build for production
npm run serve     # Serve production build locally
```

## 🧪 Experimental Code

Our project includes experimental code based on our study of Claude CLI:

### Semantic Chunking Analyzer

We've created a Python script to analyze how Claude CLI processes and chunks large codebases:

```python
# Run our semantic chunking analysis on a codebase
python experiments/chunking/analyze_chunking.py --repo=/path/to/repo --query="Explain the auth system"
```

This script:
1. Creates a Claude CLI session
2. Sends a directory to Claude
3. Queries Claude about the codebase
4. Analyzes which files and sections are referenced in the response
5. Generates detailed reports on Claude's semantic chunking behavior

## 📋 Research Roadmap

- [x] Study Claude CLI's command structure and API
- [x] Document findings in methodical research
- [ ] Analyze semantic chunking behavior (In Progress)
- [ ] Study differential update patterns (In Progress)
- [ ] Implement experimental CLI emulator (In Progress)
- [ ] Extend patterns to other LLM providers via LiteLLM (Planned)
- [ ] Create interactive demos to share findings (Planned)
- [ ] Publish comprehensive documentation of learnings (Planned)

## 🚀 Deployment

This project is automatically deployed to GitHub Pages. You can access the deployed site at [https://tosin2013.github.io/claude-cli-study-guide/](https://tosin2013.github.io/claude-cli-study-guide/).

For more information about the deployment process, see [README-DEPLOY.md](README-DEPLOY.md).

## 🤝 Contributing

This is an educational project focused on learning from Claude CLI. Contributions, experiments, and insights are welcome! Please check our [Contributing Guide](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

This project was inspired by Claude CLI and the article ["Claude 3.7 Sonnet: the first AI model that understands your entire codebase"](https://medium.com/@DaveThackeray/claude-3-7-sonnet-the-first-ai-model-that-understands-your-entire-codebase-560915c6a703) by Thack. Our goal is to learn from Claude CLI's architecture and design patterns through observation and experimentation.