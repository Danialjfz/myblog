# Danial Jafarzadeh Jazi — Academic Portfolio

A static academic portfolio and research blog built with [Hugo](https://gohugo.io/) and the [Blowfish](https://blowfish.page/) theme, deployed to GitHub Pages.

**Live site:** https://danialjfz.github.io/myblog/

## Stack

- **Generator:** Hugo Extended 0.159.1
- **Theme:** Blowfish 2.88.x (vendored in `themes/blowfish/`)
- **Styling:** Tailwind CSS + custom `assets/css/custom.css`
- **Deployment:** GitHub Pages via `.github/workflows/hugo.yaml`

## Local development

```bash
# Serve with drafts and live reload
make serve

# Or directly:
hugo server --buildDrafts --bind 127.0.0.1 --baseURL http://localhost:1313/myblog/
```

## Build for production

```bash
make build
```

## Adding content

Use the provided archetypes to keep front matter consistent:

```bash
# New blog post
hugo new content posts/my-post-title.md

# New publication entry
hugo new content publications/my-paper.md

# New project entry
hugo new content projects/my-project.md
```

## Project structure

```
.
├── archetypes/            # Content templates
├── assets/
│   ├── css/custom.css     # Theme overrides
│   └── img/               # Processed images (social card, logo)
├── config/_default/       # Hugo configuration
├── content/               # All site content
├── layouts/               # Custom layout partials
├── static/                # Static assets (favicons, CV PDF, robots.txt)
├── themes/blowfish/       # Vendored theme (submodule conversion blocked; see below)
└── .github/workflows/     # Deployment automation
```

## Theme maintenance note

The current `themes/blowfish/` directory is a vendored (copied) copy that has been patched to work with Hugo 0.159.1. Converting it to a clean Git submodule is blocked because:

- Upstream Blowfish tags through v2.99.0 declare a maximum Hugo version below 0.159.1.
- The vendored copy contains patches (e.g., `config.toml` max version, removed problematic head-image loop) that do not match any upstream tag.

To update the theme safely in the future, either:

1. Fork `nunocoracao/blowfish`, apply the same patches, and submodule to your fork.
2. Wait for an upstream tag that supports Hugo 0.159.1+, test thoroughly, then migrate.

## Maintenance checklist

- [ ] Update CV PDF in `static/files/` when `content/cv.md` changes
- [ ] Add alt text to every image in new posts
- [ ] Run `make build` before committing layout/CSS changes
- [ ] Keep `README.md` theme and Hugo versions in sync with reality
