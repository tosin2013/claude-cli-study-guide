/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      items: ['getting-started/installation', 'getting-started/configuration'],
    },
    {
      type: 'category',
      label: 'Methodology',
      items: ['methodology/index'],
    },
    {
      type: 'category',
      label: 'Research Findings',
      items: [
        'findings/index',
        'findings/claude-cli-analysis',
        'findings/semantic-chunking',
        'findings/hybrid-architecture',
      ],
    },
    {
      type: 'category',
      label: 'Experiments',
      items: [
        'experiments/index',
        'experiments/chunking/behavior-analysis',
        {
          type: 'category',
          label: 'Implementations',
          items: [
            'experiments/implementations/index',
            'experiments/implementations/cli-emulator',
            'experiments/implementations/semantic-chunker',
            'experiments/implementations/multi-provider',
            'experiments/implementations/session-manager',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'Guides',
      items: [
        'guides/semantic-chunking',
        'guides/prompt-engineering',
        'guides/litellm-integration',
      ],
    },
    {
      type: 'category',
      label: 'Demos',
      items: [
        'demos/claude-sonnet-demo',
        'demos/codecompass-litellm-demo',
      ],
    },
  ],
};

export default sidebars; 