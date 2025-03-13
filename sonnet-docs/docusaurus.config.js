// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Claude CLI Study Guide',
  tagline: 'Learning from Claude CLI\'s architecture and design patterns',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://tosin2013.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  baseUrl: '/claude-cli-study-guide/',

  // GitHub pages deployment config.
  organizationName: 'tosin2013',
  projectName: 'claude-cli-study-guide',

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
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/tosin2013/claude-cli-study-guide/tree/main/',
        },
        blog: {
          showReadingTime: true,
          editUrl: 'https://github.com/tosin2013/claude-cli-study-guide/tree/main/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      navbar: {
        title: 'Claude CLI Study Guide',
        logo: {
          alt: 'Claude CLI Study Guide Logo',
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
            href: 'https://github.com/tosin2013/claude-cli-study-guide',
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
                label: 'Introduction',
                to: '/docs/intro',
              },
              {
                label: 'Methodology',
                to: '/docs/methodology',
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
                href: 'https://github.com/tosin2013/claude-cli-study-guide',
              },
              {
                label: 'Anthropic',
                href: 'https://www.anthropic.com/',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Claude CLI Study Guide. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;