# Documentation Assets

This directory contains assets (images, GIFs, etc.) used in the documentation.

## Expected Assets

The following assets are referenced in the documentation and should be added here:

- `vscode-semantic-navigation.gif` - Used in VS Code integration demo
- `vscode-inline-explanation.gif` - Used in VS Code integration demo
- `vscode-semantic-search.gif` - Used in VS Code integration demo

## Adding New Assets

When adding new assets:

1. Use descriptive filenames that indicate what the asset shows
2. Optimize images for web (compress PNGs, use WebP where possible)
3. For GIFs, keep them under 5MB and consider converting to video formats
4. Reference assets in markdown using relative paths: `../assets/filename.png`

## Temporary Placeholders

If you're referencing an asset that doesn't exist yet:

1. Add a comment above the image reference: `<!-- Image will be added later -->`
2. Comment out the actual image reference: `<!-- ![Alt text](../assets/image.png) -->`
3. Add a note: `**Note:** Image coming soon!` 