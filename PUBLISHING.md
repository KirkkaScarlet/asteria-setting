# Asteria Setting Guide — publishing notes

This is a [Quartz v5](https://quartz.jzhao.xyz) static site that publishes a
**curated** subset of the Asteria vault to the public web. It is a *separate*
git repo from the private `Asteria` vault — the two never share history.

The live site: **https://kirkkascarlet.github.io/asteria-setting**

## Two safety layers (nothing leaks)

1. **Copy-in only.** `content/` holds only files I deliberately put here.
   Nothing from the private vault is read at build time.
2. **`explicit-publish` filter.** Even within `content/`, a page is built
   **only if its frontmatter has `publish: true`**. No flag → not on the site.

So a page must be *both* copied in *and* flagged to go public.

## Requirements

- Node 22+ (`nvm use 22`).

## Preview locally

```bash
nvm use 22
npx quartz build --serve
# open http://localhost:8080
```

## Add another page later

1. Copy the note from the vault into `content/` (keep folders if you want
   nested URLs):
   ```bash
   cp "../Asteria/Asteria Vault/World/Cosmology/Aether.md" content/Aether.md
   ```
2. Add `publish: true` to its frontmatter:
   ```yaml
   ---
   title: Aether
   publish: true
   ---
   ```
3. **`[[Wikilinks]]` and backlinks work between published pages.** A link to a
   page you have *not* copied/published renders as a dead (greyed) link and
   exposes nothing. So to make `[[Aether]]` clickable from the Setting Guide,
   copy + flag `Aether.md` too.
4. Images: copy the file into `content/` and reference it (e.g.
   `![[Asteria.jpg]]`). Then flag the page that embeds it.
5. Deploy (see below).

## Deploy

GitHub Pages builds automatically via `.github/workflows/deploy.yml` on every
push to `main`. To publish changes:

```bash
git add -A
git commit -m "Update content"
git push
```

The Action installs deps, builds, and deploys. First-time setup only:
**Settings → Pages → Source → GitHub Actions**.

## Keep Quartz itself up to date

```bash
git fetch upstream
git merge upstream/v5   # resolve conflicts in quartz.config.yaml if any
```
