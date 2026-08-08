# My site

This is my academic portfolio / research blog, built with [Hugo](https://gohugo.io/) and the Blowfish theme, hosted on GitHub Pages at:

**https://danialjfz.github.io/myblog/**

## Quick commands

```bash
# Run locally with drafts
make serve

# Build exactly like CI does
make build

# Clean generated junk
make clean
```

## Stack

- **Hugo:** 0.159.1 (extended)
- **Theme:** Blowfish 2.88.x, but it's a vendored/patched copy in `themes/blowfish/`
- **Base URL:** `/myblog/` because GitHub Pages serves it from the repo path

## Adding stuff

Use the archetypes so front matter stays consistent:

```bash
hugo new content posts/my-cool-idea.md
hugo new content publications/my-paper.md
hugo new content projects/my-project.md
```

## Where things live

- `content/` — all pages and posts
- `content/cv.md` — my CV (keep this in sync with the PDF in `static/files/`)
- `assets/css/custom.css` — all my visual overrides
- `layouts/partials/` — custom header, homepage, head extensions, favicons
- `static/files/Danial_Jafarzadeh_Jazi_CV.pdf` — downloadable CV
- `static/robots.txt`, `static/site.webmanifest` — SEO bits

## Theme note (read this before updating)

The theme is **not** a submodule right now. The copy in `themes/blowfish/` has been patched to work with Hugo 0.159.1. If you try to replace it with a clean upstream submodule, the build breaks because:

1. Upstream tags through v2.99.0 don't claim support for Hugo 0.159.1.
2. The head partial in the clean theme crashes on this config due to a nil image resource.

So don't blindly swap it. If you ever want a clean submodule, you need to either:

- Fork Blowfish, apply the same patches, and submodule to your fork, or
- Downgrade Hugo to ≤ 0.157.0 and use upstream v2.99.0.

Until then, leave `themes/blowfish/` alone unless you know what you're changing.

## Before publishing

- [ ] Run `make build` and make sure it exits cleanly.
- [ ] If you updated `content/cv.md`, regenerate or replace `static/files/Danial_Jafarzadeh_Jazi_CV.pdf`.
- [ ] Add alt text to any images in new posts.
- [ ] Keep titles and descriptions under ~160 chars where possible (good for SEO/social previews).

## Random reminders

- The site uses a `/myblog/` baseURL, so internal links should use `relURL` or page refs, not absolute paths.
- The social card image lives at `assets/img/social-card.png` and is referenced in `config/_default/params.toml`.
- Custom JSON-LD / schema stuff is in `layouts/partials/extend-head.html`.
