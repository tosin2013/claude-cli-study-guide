# CLAUDE.md - Agent Instructions

## Build/Test/Lint Commands
- Root Build: `npm run build` (Jekyll build)
- Root Serve: `npm run serve`
- Docusaurus Build: `cd sonnet-docs && npm run build`
- Docusaurus Dev: `cd sonnet-docs && npm run start`
- Docusaurus Serve: `cd sonnet-docs && npm run serve`
- Lint Markdown: `npm run lint-md`
- TypeCheck: `cd sonnet-docs && npm run typecheck`
- Generate SVGs: `npm run generate-svgs`

## Code Style Guidelines
- **Imports**: Group imports by: external libraries, internal modules, types/interfaces
- **Formatting**: Use consistent indentation (2 spaces) and semicolons
- **Types**: Prefer TypeScript interfaces for complex objects, use type annotations
- **Naming**: camelCase for variables/functions, PascalCase for classes/components
- **Error Handling**: Use try/catch for async operations, proper error messages
- **Documentation**: JSDoc comments for functions with @param and @return
- **File Structure**: One component per file, consistent directory organization
- **Testing**: Write unit tests for core functionality, use mocks for external services

## Architecture
- Follow modular design with clear separation of concerns
- Prioritize reusable components and utilities
- Use semantic chunking for better code organization
- Maintain comprehensive documentation
- Use Docusaurus for structured documentation with MDX support