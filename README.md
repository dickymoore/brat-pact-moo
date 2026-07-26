# Brat Pact Moo

A stylish, editable family agreement system for allowance, phone rules, responsibilities, rewards, and routines.

## Contents

- `family-pact/family-system-data.json` is the single source of truth for the content
- `family-pact/render-family-sheet.ps1` regenerates the HTML sheet from the data file
- `family-pact/family-system-sheet.html` is the rendered magazine-style agreement
- `family-pact/assets/` stores repo-owned images used by the sheet

## Updating The Sheet

1. Edit `family-pact/family-system-data.json`
2. Run `family-pact/render-family-sheet.ps1`
3. Open or refresh `family-pact/family-system-sheet.html`

## GitHub Pages

The repository root includes `index.html`, which redirects to the current Brat Pact sheet.
