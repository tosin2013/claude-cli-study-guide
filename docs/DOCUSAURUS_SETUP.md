# Docusaurus Setup Guide

This document provides detailed instructions for setting up the Docusaurus documentation site for our project.

## Prerequisites

- Node.js version 16.14 or above (recommended: 18.x or 20.x)
- Yarn (recommended) or npm
- Git

## Initial Setup

### Step 1: Install Docusaurus

```bash
# Create a new Docusaurus site in the current directory
npx create-docusaurus@latest sonnet-docs classic

# Move into the newly created directory
cd sonnet-docs

# Install dependencies
yarn
```

### Step 2: Customize Configuration

Edit the `docusaurus.config.js` file with our project-specific information:

```js
// docusaurus.config.js
const config = {
  title: 'CodeCompass & Claude 3.7 Sonnet',
  tagline: 'Understanding large codebases with advanced LLMs',
  favicon: 'img/favicon.ico',
  url: 'https://your-github-username.github.io',
  baseUrl: '/sonnet-3.7-docs/',
  organizationName: 'your-github-username', // Usually your GitHub org/user name.
  projectName: 'sonnet-3.7-docs', // Usually your repo name.
  
  // Add more customizations below...
  
  themeConfig: {
    // Replace with your repo details
    navbar: {
      title: 'CodeCompass',
      logo: {
        alt: 'CodeCompass Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          to: '/demos/claude-sonnet',
          label: 'Claude 3.7 Demo',
          position: 'left',
        },
        {
          to: '/demos/codecompass-litellm',
          label: 'CodeCompass LiteLLM',
          position: 'left',
        },
        {
          href: 'https://github.com/your-github-username/sonnet-3.7-docs',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/intro',
            },
            {
              label: 'ADRs',
              to: '/docs/adrs',
            },
          ],
        },
        {
          title: 'Demos',
          items: [
            {
              label: 'Claude 3.7 Sonnet',
              to: '/demos/claude-sonnet',
            },
            {
              label: 'CodeCompass LiteLLM',
              to: '/demos/codecompass-litellm',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/your-github-username/sonnet-3.7-docs',
            },
            {
              label: 'Anthropic',
              href: 'https://www.anthropic.com/',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} CodeCompass Project. Built with Docusaurus.`,
    },
  },
  
  // Add plugins
  plugins: [],
  
  // Configure Markdown/MDX processing
  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/your-github-username/sonnet-3.7-docs/tree/main/',
        },
        blog: {
          showReadingTime: true,
          editUrl: 'https://github.com/your-github-username/sonnet-3.7-docs/tree/main/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};

module.exports = config;
```

### Step 3: Install Required Plugins

```bash
# Install Mermaid plugin for diagrams
yarn add @docusaurus/theme-mermaid

# Install live code blocks for interactive examples
yarn add @docusaurus/theme-live-codeblock
```

Update the docusaurus.config.js to include these plugins:

```js
// Add to docusaurus.config.js
module.exports = {
  // ... other config
  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid', '@docusaurus/theme-live-codeblock'],
  // ... rest of config
};
```

### Step 4: Set Up Directory Structure

Create the following directory structure:

```
sonnet-docs/
├── blog/                    # Optional blog posts
├── docs/                    # Main documentation
│   ├── adrs/                # Architecture Decision Records
│   ├── intro.md             # Introduction page
│   └── ...                  # Other documentation pages
├── src/
│   ├── components/          # Custom React components
│   │   └── ...
│   ├── css/                 # CSS customizations
│   │   └── custom.css
│   └── pages/               # Custom standalone pages
│       ├── index.js         # Homepage
│       └── demos/           # Demo pages
│           ├── claude-sonnet.js
│           └── codecompass-litellm.js
├── static/                  # Static assets
│   ├── img/                 # Images
│   └── ...
├── docusaurus.config.js     # Docusaurus configuration
├── sidebars.js              # Sidebar configuration
└── package.json             # Project dependencies
```

### Step 5: Customize Homepage

Create a custom homepage at `src/pages/index.js`:

```jsx
import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">{siteConfig.title}</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro">
            Get Started
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Understanding large codebases with advanced LLMs">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
```

### Step 6: Configure Sidebars

Edit the `sidebars.js` file to organize your documentation:

```js
// sidebars.js
module.exports = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      items: ['getting-started/installation', 'getting-started/configuration'],
    },
    {
      type: 'category',
      label: 'Guides',
      items: ['guides/semantic-chunking', 'guides/model-selection'],
    },
    {
      type: 'category',
      label: 'ADRs',
      items: [
        'adrs/ADR-018-docusaurus-migration',
        'adrs/ADR-019-claude-sonnet-demo',
        'adrs/ADR-020-codecompass-litellm-demo',
        // Add other ADRs here
      ],
    },
  ],
};
```

### Step 7: Create Initial Documentation Pages

Create an introduction page at `docs/intro.md`:

```md
---
sidebar_position: 1
---

# Introduction

Welcome to the CodeCompass documentation! 

CodeCompass is a conceptual project that demonstrates how to use advanced Large Language Models like Claude 3.7 Sonnet to understand and navigate large codebases. This documentation will guide you through:

1. Setting up and using Claude 3.7 Sonnet for code understanding
2. Using CodeCompass with LiteLLM for multi-model support
3. Best practices for working with large codebases

## Project Goals

- Demonstrate the capabilities of Claude 3.7 Sonnet for code understanding
- Show how to work with multiple LLM providers through a unified interface
- Provide practical examples and tutorials for real-world use cases

## Getting Started

- [Installation Guide](/docs/getting-started/installation)
- [Configuration Guide](/docs/getting-started/configuration)
- [Claude 3.7 Sonnet Demo](/demos/claude-sonnet)
- [CodeCompass LiteLLM Demo](/demos/codecompass-litellm)
```

### Step 8: Local Development

Run the development server to preview the site:

```bash
# Start the local development server
yarn start
```

This will start a local development server on http://localhost:3000.

### Step 9: Build for Production

When you're ready to deploy, build the static files:

```bash
# Build the static site
yarn build
```

This will generate a `build` directory with all the static files needed for deployment.

## Next Steps

After completing the initial setup:

1. Migrate existing content from the Jekyll site
2. Implement the demo pages
3. Configure GitHub Actions for automatic deployment
4. Start developing custom components for the demos 