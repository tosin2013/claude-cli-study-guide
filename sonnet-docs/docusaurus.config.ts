import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Claude CLI Study Project',
  tagline: 'Learning from Claude CLI\'s architecture and design patterns',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://tosin2013.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  baseUrl: '/sonnet-3.7-docs/',

  // GitHub pages deployment config.
  organizationName: 'tosin2013',
  projectName: 'sonnet-3.7-docs',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  markdown: {
    mermaid: true,
  },
  
  themes: ['@docusaurus/theme-mermaid', '@docusaurus/theme-live-codeblock'],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/tosin2013/sonnet-3.7-docs/tree/main/',
        },
        blog: {
          showReadingTime: true,
          editUrl: 'https://github.com/tosin2013/sonnet-3.7-docs/tree/main/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Claude CLI Study Project',
      logo: {
        alt: 'Claude CLI Study Logo',
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
          to: '/docs/findings',
          label: 'Research Findings',
          position: 'left',
        },
        {
          to: '/docs/experiments',
          label: 'Experiments',
          position: 'left',
        },
        {
          to: '/docs/adrs/ADR-018-docusaurus-migration',
          label: 'ADRs',
          position: 'left',
        },
        {
          href: 'https://github.com/tosin2013/sonnet-3.7-docs',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'Introduction',
              to: '/docs/intro',
            },
            {
              label: 'Methodology',
              to: '/docs/methodology',
            },
            {
              label: 'Architecture Decisions',
              to: '/docs/adrs',
            },
          ],
        },
        {
          title: 'Research',
          items: [
            {
              label: 'Findings',
              to: '/docs/findings',
            },
            {
              label: 'Experiments',
              to: '/docs/experiments',
            },
            {
              label: 'Implementations',
              to: '/docs/experiments/implementations',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/tosin2013/sonnet-3.7-docs',
            },
            {
              label: 'Anthropic',
              href: 'https://www.anthropic.com/',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Claude CLI Study Project. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;