# Claude CLI Study Guide

This repository contains a comprehensive study guide for Claude CLI, exploring its architecture, design patterns, and capabilities. Built with [Docusaurus](https://docusaurus.io/).

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/en/download/) (version 16.14 or higher)
- [npm](https://www.npmjs.com/) (usually comes with Node.js)
- [Git](https://git-scm.com/downloads)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/tosin2013/claude-cli-study-guide.git
   cd claude-cli-study-guide
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

### Local Development

1. Start the development server:
   ```bash
   npm start
   ```
   This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

2. Alternatively, use the provided script:
   ```bash
   chmod +x scripts/start-local.sh
   ./scripts/start-local.sh
   ```

### Building for Production

To generate a static build of the site:

```bash
npm run build
```

The static files will be generated in the `build` directory.

## Project Structure

```
├── blog/               # Blog posts
├── docs/               # Documentation
│   ├── demos/          # Interactive demos
│   ├── experiments/    # Experiments and findings
│   ├── findings/       # Research findings
│   ├── getting-started/ # Getting started guides
│   ├── guides/         # How-to guides
│   └── methodology/    # Study methodology
├── scripts/            # Helper scripts
│   ├── start-local.sh        # Start local development server
│   └── setup-demo-env.sh     # Set up demo environment
├── src/
│   ├── components/     # React components
│   ├── css/            # CSS styles
│   └── pages/          # Custom pages
├── static/             # Static assets like images
│   └── img/
├── docusaurus.config.js # Docusaurus configuration
├── sidebars.js         # Documentation sidebar configuration
└── package.json        # npm dependencies
```

## Key Documentation Pages

- **Getting Started**: Installation and configuration guides
- **Methodology**: Our approach to studying Claude CLI
- **Findings**: 
  - Semantic Chunking Analysis
  - Claude CLI Architecture Analysis
  - Hybrid Architecture Studies
- **Experiments**: 
  - CLI Behavior Analysis
  - Experimental Implementations
- **Guides**: 
  - Semantic Chunking 
  - Prompt Engineering for Code
  - LiteLLM Integration

## Running Experiments

Our experimental code is ready for you to try out using our setup script:

1. Run the provided setup script:
   ```bash
   chmod +x scripts/setup-demo-env.sh
   ./scripts/setup-demo-env.sh
   ```

   This script will:
   - Create a Python virtual environment
   - Install all required dependencies
   - Set up sample code repositories for analysis

2. Follow the instructions printed by the script to:
   - Activate the virtual environment
   - Run the semantic chunking experiments
   - Test the CLI emulator prototype
   - Analyze session management behavior

3. Alternatively, set up manually:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install anthropic litellm scikit-learn streamlit numpy pandas
   ```

   And copy the code examples from the experiments documentation.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.