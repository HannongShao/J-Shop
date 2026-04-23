# AI Codebase Guide

This guide is the fastest way for another AI system to understand where to read first, which files are authoritative, and how to make low-risk changes in this project.

## 1. Project Intent

This repository contains three parallel layers for the same jewelry brand system:

- `preview/`
  Editorial prototype used for rapid design, layout, and interaction exploration
- `layout/`, `sections/`, `snippets/`, `templates/`, `assets/`, `locales/`, `config/`
  Shopify theme implementation
- `database/`
  PostgreSQL schema, seed data, and operations documentation for the backend jewelry database

When making changes, do not assume every idea is already mirrored across all three layers. The preview often evolves first, then the Shopify theme and backend catch up.

## 2. Primary Source Of Truth By Task

### Homepage visual design or interaction changes

Read in this order:

1. [preview/index.html](/Users/hannongshao/Documents/New%20project/preview/index.html)
2. [preview/preview.css](/Users/hannongshao/Documents/New%20project/preview/preview.css)
3. [preview/preview.js](/Users/hannongshao/Documents/New%20project/preview/preview.js)

Use this layer for:

- section order
- editorial storytelling
- hover and pointer behavior
- conversion-oriented homepage experiments

### Shopify storefront implementation

Read in this order:

1. [layout/theme.liquid](/Users/hannongshao/Documents/New%20project/layout/theme.liquid)
2. relevant file in [templates](/Users/hannongshao/Documents/New%20project/templates)
3. matching section in [sections](/Users/hannongshao/Documents/New%20project/sections)
4. related snippet in [snippets](/Users/hannongshao/Documents/New%20project/snippets)
5. shared behavior in [assets](/Users/hannongshao/Documents/New%20project/assets)

Use this layer for:

- production storefront behavior
- Liquid rendering logic
- Shopify metafield output
- theme editor schemas

### Backend product data, clients, passports, and aftercare

Read in this order:

1. [database/jewelry_catalog_schema.sql](/Users/hannongshao/Documents/New%20project/database/jewelry_catalog_schema.sql)
2. [database/jewelry_backend_seed.sql](/Users/hannongshao/Documents/New%20project/database/jewelry_backend_seed.sql)
3. [database/jewelry_database_management_manual.md](/Users/hannongshao/Documents/New%20project/database/jewelry_database_management_manual.md)
4. [database/README.md](/Users/hannongshao/Documents/New%20project/database/README.md)

Use this layer for:

- structured product data
- bilingual content rules
- customer and consultation flows
- jewelry passport and service request logic

## 3. Canonical Editing Order

For most changes, follow one of these sequences.

### Sequence A: design-first homepage work

1. Update `preview/index.html`
2. Update `preview/preview.css`
3. Update `preview/preview.js`
4. Only after the prototype is stable, mirror the same idea into Shopify sections/snippets

### Sequence B: storefront product detail work

1. Update section in `sections/`
2. Update any supporting snippet in `snippets/`
3. Update shared behavior in `assets/`
4. Confirm metafield assumptions against `database/` docs

### Sequence C: backend data capability work

1. Update schema
2. Update seed data if needed
3. Update database manual
4. Only then update Shopify or preview assumptions

## 4. Machine-Friendly Conventions Already In Use

### Stable section targeting

The preview homepage now uses:

- `data-component`
- `data-section-title`
- `data-nav-key`

These should be preferred over brittle positional assumptions.

### JS organization pattern

The preview script is intentionally organized in this order:

1. media queries and selector contracts
2. content libraries
3. generic DOM helpers
4. one initializer per feature
5. a single boot sequence

When adding new interactions, keep the same shape. Avoid dropping ad hoc listeners at the bottom of the file.

### Theme scripts

Theme JS files in `assets/` now prefer:

- small selector maps
- named helpers for open/close/toggle work
- one initializer per component family

If you add a new theme behavior, match that pattern.

## 5. High-Value Files To Read Before Editing

- [preview/index.html](/Users/hannongshao/Documents/New%20project/preview/index.html)
  Canonical map of homepage narrative order and component names
- [preview/preview.js](/Users/hannongshao/Documents/New%20project/preview/preview.js)
  Canonical map of homepage interaction logic
- [sections/main-product.liquid](/Users/hannongshao/Documents/New%20project/sections/main-product.liquid)
  Core product detail structure in the Shopify theme
- [snippets/product-materials.liquid](/Users/hannongshao/Documents/New%20project/snippets/product-materials.liquid)
  Key product explanation output from metafields
- [database/jewelry_catalog_schema.sql](/Users/hannongshao/Documents/New%20project/database/jewelry_catalog_schema.sql)
  Core backend data model

## 6. Avoid These Mistakes

- Do not treat the preview as the production Shopify theme. It is a design and interaction sandbox.
- Do not hardcode repeated material/care/shipping explanations into product copy if the database already models them structurally.
- Do not edit a Shopify snippet before checking whether the same concern is already abstracted in a more central snippet.
- Do not add new front-end selectors without deciding whether `data-component` or an existing class should be the canonical hook.
- Do not introduce a second interaction boot path when the existing file already has a single initializer flow.

## 7. Safe Expansion Rules

When adding a new homepage component:

1. Add a new `data-component` to the HTML wrapper
2. Keep the component styles grouped in `preview/preview.css`
3. If it has behavior, add one initializer in `preview/preview.js`
4. Register that initializer in the boot sequence

When adding a new backend concept:

1. Decide whether it is master data, a relationship, or a time-based event
2. Reflect that in SQL naming
3. Add or update an admin view if the concept needs daily operations visibility
4. Document the flow in the database manual

## 8. Fast Mental Model

Use this short model when navigating the repo:

- `preview/` is where the brand experience is explored
- `sections/` and `snippets/` are where the storefront is assembled
- `assets/` supports storefront behavior
- `database/` explains what the business actually knows about products, clients, and service history

If an AI follows that order, it can usually make the right edit without scanning the whole repository.
