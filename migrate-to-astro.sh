#!/usr/bin/env bash
# migrate-to-astro.sh — add Astro content collections to a Jekyll blog, non-destructively.
# Run from the repo root (e.g. ~/my-blog). Usage:
#   ./migrate-to-astro.sh --dry-run        # print actions only
#   ./migrate-to-astro.sh                  # do it (asks once)
#   ./migrate-to-astro.sh -y --site https://USER.github.io
#   ./migrate-to-astro.sh --rollback [a|b|c|d|e] [--from DIR]  # back to Jekyll (menu if no letter)
#       a abort   branch not merged: delete astro-migration (local, optional remote)
#       b revert  merged & deployed: git revert the merge on main, Pages -> branch
#       c keep    keep Astro files; disable workflow; add Jekyll exclude list; Pages -> branch
#       d clean   remove the Astro files this script generated; Pages -> branch
#       e restore copy a full backup dir (e.g. ../myBlog_v1) over this one; snapshot kept
#   Add --dry-run to any mode to print actions only; -y auto-confirms prompts.
#
# Safety (migrate mode): works on a new git branch, never deletes or moves anything,
# never overwrites existing files, never pushes. Jekyll files stay untouched.
# Rollback mode: asks before every destructive step, never force-pushes.

set -euo pipefail

BRANCH="astro-migration"
POSTS_DIR="_posts"
DRY=0; YES=0; SITE=""; MODE="migrate"; ROLLBACK_OPT=""; FROM_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --rollback)
      MODE="rollback"
      case "${2:-}" in a|b|c|d|e|abort|revert|keep|clean|restore) ROLLBACK_OPT="$2"; shift ;; esac ;;
    --from)    FROM_DIR="${2:?--from needs a directory}"; shift ;;
    --dry-run) DRY=1 ;;
    -y|--yes)  YES=1 ;;
    --site)    SITE="${2:?--site needs a URL}"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

say()  { printf '\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33mWARN: %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }
run()  { printf '  $ %s\n' "$*"; [ "$DRY" = 1 ] || "$@"; }

# write_file PATH  (content on stdin; skips if file exists; replaces __SITE__)
write_file() {
  local path="$1" content
  content="$(cat)"
  content="${content//__SITE__/$SITE}"
  if [ -e "$path" ]; then warn "exists, skipped: $path"; return 0; fi
  printf '  + %s\n' "$path"
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

# ---------- rollback (Astro -> Jekyll) ----------
yn() { [ "$YES" = 1 ] && return 0; local a; read -r -p "$1 [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

main_branch() {
  local m
  m="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)"
  if [ -n "$m" ]; then echo "$m"
  elif git show-ref --verify --quiet refs/heads/main; then echo main
  else echo master; fi
}

maybe_push() {
  if yn "Push $(git rev-parse --abbrev-ref HEAD) to origin?"; then run git push origin HEAD; fi
}

# Pages source -> "Deploy from a branch" (best-effort via gh; always prints the manual path)
pages_legacy() {
  echo "  Pages source must be: Settings -> Pages -> Deploy from a branch -> $1 / (root)"
  if command -v gh >/dev/null 2>&1 && yn "Try to set it via gh now?"; then
    if [ "$DRY" = 1 ]; then echo "  (dry-run) gh api -X PUT repos/{owner}/{repo}/pages -f build_type=legacy ..."; return 0; fi
    gh api -X PUT "repos/{owner}/{repo}/pages" -f build_type=legacy \
      -f "source[branch]=$1" -f "source[path]=/" \
      || warn "gh call failed (unverified API) — set it in the Settings UI"
  fi
}

rb_abort() {   # a: branch never merged
  local m; m="$(main_branch)"
  git show-ref --verify --quiet "refs/heads/$BRANCH" || die "branch '$BRANCH' not found"
  if git branch --merged "$m" | grep -qE "^[* ] +$BRANCH\$"; then
    die "'$BRANCH' is already merged into $m — use option b (revert)"
  fi
  yn "Switch to $m and DELETE local branch '$BRANCH' (unmerged work is lost)?" || return 0
  run git checkout "$m"
  run git branch -D "$BRANCH"
  if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    if yn "Also delete remote branch origin/$BRANCH?"; then run git push origin --delete "$BRANCH"; fi
  fi
  echo "  Pages source was never changed; nothing else to do."
}

rb_revert() {  # b: merged and deployed
  local m sha line parents
  m="$(main_branch)"
  run git checkout "$m"
  say "Recent merge commits on $m"
  git log "$m" --merges --first-parent --format='  %h %ad %s' --date=short -n 10 || true
  sha="$(git log "$m" --merges --first-parent --grep="$BRANCH" --format=%h -n 1 || true)"
  read -r -p "Commit to revert [${sha:-none}]: " line
  sha="${line:-$sha}"
  [ -n "$sha" ] || die "no commit given (fast-forward merge? find the first Astro commit with: git log --oneline)"
  git cat-file -e "$sha^{commit}" 2>/dev/null || die "unknown commit: $sha"
  parents="$(git rev-list --parents -n 1 "$sha" | wc -w | tr -d ' ')"
  if [ "$parents" -gt 2 ]; then run git revert -m 1 --no-edit "$sha"; else run git revert --no-edit "$sha"; fi
  maybe_push
  pages_legacy "$m"
}

rb_keep() {    # c: keep Astro files, host Jekyll again
  local m wf e
  local ex=(node_modules src public dist .astro package.json package-lock.json astro.config.mjs tsconfig.json)
  local add=()
  m="$(main_branch)"
  [ -f _config.yml ] || die "_config.yml not found"
  run git checkout "$m"

  wf=.github/workflows/astro-deploy.yml
  if [ -f "$wf" ]; then
    [ -e "$wf.disabled" ] && die "$wf.disabled already exists"
    run git mv "$wf" "$wf.disabled"
  fi
  if [ ! -d "$POSTS_DIR" ] && [ -d src/content/blog ]; then run git mv src/content/blog "$POSTS_DIR"; fi

  if grep -qE '^exclude:' _config.yml && ! grep -qE '^exclude:[[:space:]]*$' _config.yml; then
    warn "_config.yml has a non-block 'exclude:' — add manually: ${ex[*]}"
  else
    for e in "${ex[@]}"; do
      grep -qE "^[[:space:]]*-[[:space:]]*['\"]?${e}['\"]?[[:space:]]*\$" _config.yml || add+=("$e")
    done
    if [ "${#add[@]}" -eq 0 ]; then
      echo "  _config.yml exclude: already complete"
    else
      printf '  ~ _config.yml exclude += %s\n' "${add[*]}"
      if [ "$DRY" = 0 ]; then
        if grep -qE '^exclude:[[:space:]]*$' _config.yml; then
          awk -v items="${add[*]}" 'BEGIN{n=split(items,a," ")} {print} /^exclude:[[:space:]]*$/{for(i=1;i<=n;i++) print "  - " a[i]}' \
            _config.yml > _config.yml.tmp && mv _config.yml.tmp _config.yml
        else
          { echo; echo "exclude:"; for e in "${add[@]}"; do echo "  - $e"; done; } >> _config.yml
        fi
      fi
    fi
  fi
  if [ "$DRY" = 0 ]; then
    git add -A
    git commit -q -m "Back to Jekyll hosting (Astro files kept, workflow disabled)" || warn "nothing to commit"
  fi
  maybe_push
  pages_legacy "$m"
}

rb_clean() {   # d: remove files this script generated
  local m f
  local files=() cand=(astro.config.mjs src/content.config.ts src/pages/index.astro 'src/pages/[...slug].astro'
                       .github/workflows/astro-deploy.yml .github/workflows/astro-deploy.yml.disabled)
  m="$(main_branch)"
  run git checkout "$m"
  for f in "${cand[@]}"; do if [ -e "$f" ]; then files+=("$f"); fi; done
  if [ -d public/assets ] && [ -d assets ]; then
    if diff -rq assets public/assets >/dev/null 2>&1; then files+=(public/assets)
    else warn "public/assets differs from assets/ — kept (check manually)"; fi
  fi
  if [ "$POSTS_DIR" != "" ] && [ ! -d "$POSTS_DIR" ] && [ -d src/content/blog ]; then run git mv src/content/blog "$POSTS_DIR"; fi
  [ "${#files[@]}" -gt 0 ] || { echo "  no generated Astro files found"; return 0; }
  echo "Will remove:"; printf '    %s\n' "${files[@]}"
  yn "Remove these files?" || return 0
  for f in "${files[@]}"; do
    run git rm -rq --ignore-unmatch -- "$f"
    run rm -rf -- "$f"
  done
  [ "$DRY" = 1 ] || rmdir src/pages src/content src public 2>/dev/null || true
  if yn "Also remove build artifacts (node_modules, dist, .astro)?"; then run rm -rf node_modules dist .astro; fi
  echo "  package.json / package-lock.json kept (may predate Astro); remove manually if unused."
  if [ "$DRY" = 0 ]; then
    git add -A
    git commit -q -m "Remove Astro files; back to Jekyll" || warn "nothing to commit"
  fi
  maybe_push
  pages_legacy "$m"
}

TOOLS=(migrate-to-astro.sh blog-gh.sh BLOG-GUIDE.md)   # kept out of restore/commit

need_clean() {
  [ "${IS_GIT:-0}" = 1 ] || die "not a git repo"
  local t px=()
  for t in "${TOOLS[@]}"; do px+=(":(exclude)$t"); done   # the helper scripts themselves don't count as dirty
  px+=(":(exclude,glob)**/.DS_Store")                      # macOS Finder noise, any depth
  if [ -n "$(git status --porcelain -- . "${px[@]}")" ]; then
    git status -s -- . "${px[@]}" | head -15
    die "working tree not clean (files above). Commit or stash first: git stash -u"
  fi
}

rb_restore() {   # e: copy a full backup directory over this one (snapshot of current state kept)
  command -v rsync >/dev/null 2>&1 || die "rsync not found"
  local root src snap t m left
  local ex=() pathex=()
  root="$(pwd -P)"
  src="$FROM_DIR"
  if [ -z "$src" ]; then
    read -r -p "Backup dir [../$(basename "$root")_v1]: " src
    src="${src:-../$(basename "$root")_v1}"
  fi
  [ -d "$src" ] || die "backup dir not found: $src"
  src="$(cd "$src" && pwd -P)"
  [ "$src" != "$root" ] || die "backup dir is the current dir"
  case "$src/own" in "$root/"*) die "backup dir is inside the current dir" ;; esac
  case "$root/own" in "$src/"*) die "current dir is inside the backup dir" ;; esac
  [ -d "$src/.git" ] || die "$src has no .git — not a full copy"
  [ -d "$src/$POSTS_DIR" ] || [ -f "$src/_config.yml" ] || die "$src does not look like the Jekyll blog"

  for t in "${TOOLS[@]}"; do ex+=(--exclude "/$t"); pathex+=(":(exclude)$t"); done
  snap="$(dirname "$root")/$(basename "$root")_astro_$(date +%Y%m%d-%H%M%S)"

  say "Restore  $src  ->  $root"
  echo "  safety snapshot of current state -> $snap (node_modules excluded)"
  echo "  tools kept in place: ${TOOLS[*]}"
  echo "  changes rsync would make (first 40 lines):"
  rsync -a --checksum --delete -n -i "${ex[@]}" "$src/" "$root/" | head -40 || true
  if [ "$DRY" = 1 ]; then echo "  (dry-run) stop here"; return 0; fi
  yn "Overwrite $root with $src? (current state is snapshotted first)" || return 0

  run rsync -a --exclude node_modules "$root/" "$snap/"
  run rsync -a --checksum --delete "${ex[@]}" "$src/" "$root/"
  # verify: a second dry pass must show no file differences (--checksum: size+mtime alone can miss same-second edits)
  left="$(rsync -a --checksum --delete -n -i "${ex[@]}" "$src/" "$root/" | grep -v '^\.d' | head -5 || true)"
  [ -z "$left" ] || { warn "restore not identical, remaining diffs:"; echo "$left"; die "aborting; snapshot is at $snap"; }

  m="$(main_branch)"
  say "Restored: $(git rev-parse --abbrev-ref HEAD) @ $(git rev-parse --short HEAD)"
  git fetch -q origin 2>/dev/null || { warn "fetch failed; GitHub sync skipped"; return 0; }
  if git rev-parse --verify -q "origin/$m" >/dev/null && [ "$(git rev-parse HEAD)" != "$(git rev-parse "origin/$m")" ]; then
    echo "  origin/$m differs from the restored HEAD (GitHub still has the Astro-era commits)."
    if [ "$(git rev-parse --abbrev-ref HEAD)" != "$m" ]; then
      warn "not on $m; skipping GitHub sync"
    elif yn "Make GitHub match v1 with a normal commit on top of origin/$m (no force-push)?"; then
      run git reset --soft "origin/$m"
      run git add -A -- . "${pathex[@]}"
      run git commit -q -m "Restore blog from backup (back to Jekyll)"
      maybe_push
    fi
  fi
  pages_legacy "$m"
}

if [ "$MODE" = rollback ]; then
  c="$ROLLBACK_OPT"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then cd "$(git rev-parse --show-toplevel)"; IS_GIT=1; else IS_GIT=0; fi
  if [ -z "$c" ]; then
    cat <<'MENU'
Back to Jekyll — pick one:
  a) abort   not merged yet: delete branch astro-migration (local, optional remote)
  b) revert  merged & deployed: revert the merge on main, Pages -> branch
  c) keep    keep Astro files; disable workflow; add Jekyll exclude list; Pages -> branch
  d) clean   remove Astro files this script generated; Pages -> branch
  e) restore copy a backup dir (e.g. ../myBlog_v1) over this one; snapshot kept
MENU
    read -r -p "> " c
  fi
  case "$c" in
    a|abort)   need_clean; rb_abort ;;
    b|revert)  need_clean; rb_revert ;;
    c|keep)    need_clean; rb_keep ;;
    d|clean)   need_clean; rb_clean ;;
    e|restore) rb_restore ;;
    *) die "unknown rollback option: $c" ;;
  esac
  say "Rollback done"
  exit 0
fi

# ---------- preflight ----------
say "Preflight"
[ -d "$POSTS_DIR" ] || die "$POSTS_DIR/ not found. Run from the blog repo root."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repo"
command -v node >/dev/null || die "node not found (need Node >= 18.20)"
command -v npm  >/dev/null || die "npm not found"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 18 ] || die "Node $(node -v) too old; need >= 18.20"

if [ -n "$(git status --porcelain)" ]; then
  die "working tree not clean. Commit or stash first (backup is not a substitute)."
fi

if [ -z "$SITE" ]; then
  REMOTE="$(git remote get-url origin 2>/dev/null || true)"
  REMOTE="${REMOTE%.git}"
  if [[ "$REMOTE" =~ github\.com[:/]+([^/]+)/([^/]+)$ ]]; then
    GH_USER="${BASH_REMATCH[1]}"; GH_REPO="${BASH_REMATCH[2]}"
    SITE="https://${GH_USER}.github.io"
    [ "$GH_REPO" = "${GH_USER}.github.io" ] || \
      warn "repo '$GH_REPO' is not '${GH_USER}.github.io': project site needs base:'/$GH_REPO' in astro.config.mjs"
  else
    SITE="https://example.github.io"
    warn "could not detect GitHub user; using placeholder. Re-run with --site URL or edit astro.config.mjs"
  fi
fi

POST_COUNT="$(find "$POSTS_DIR" -type f \( -name '*.md' -o -name '*.markdown' \) | wc -l | tr -d ' ')"
say "Found $POST_COUNT posts in $POSTS_DIR/  | site: $SITE | branch: $BRANCH | dry-run: $DRY"

grep -E '^\s*permalink:' _config.yml 2>/dev/null | sed 's/^/  _config.yml: /' || true

# ---------- compatibility scan (read-only) ----------
say "Compatibility scan"
LIQUID="$(grep -rlE '\{%|\{\{' "$POSTS_DIR" 2>/dev/null || true)"
KRAMDOWN="$(grep -rlE '^\{:' "$POSTS_DIR" 2>/dev/null || true)"
[ -z "$LIQUID" ]   || { warn "Liquid tags found (render as literal text in Astro):"; echo "$LIQUID" | sed 's/^/    /'; }
[ -z "$KRAMDOWN" ] || { warn "kramdown attribute lines '{: ...}' found (unsupported):"; echo "$KRAMDOWN" | sed 's/^/    /'; }
[ -n "$LIQUID$KRAMDOWN" ] || echo "  none"

if [ "$DRY" = 0 ] && [ "$YES" = 0 ]; then
  read -r -p "Proceed on new branch '$BRANCH'? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || die "aborted"
fi

# ---------- branch ----------
say "Branch"
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  die "branch '$BRANCH' already exists. Delete it or pick another."
fi
run git checkout -b "$BRANCH"

# ---------- install ----------
say "Install Astro"
[ -f package.json ] || run npm init -y
run npm install astro @astrojs/sitemap
run npm pkg set scripts.dev="astro dev" scripts.build="astro build" scripts.preview="astro preview"

# ---------- .gitignore (append missing lines only) ----------
say ".gitignore"
for line in node_modules dist .astro; do
  if ! grep -qxF "$line" .gitignore 2>/dev/null; then
    printf '  + %s\n' "$line"
    [ "$DRY" = 1 ] || echo "$line" >> .gitignore
  fi
done

# ---------- assets: COPY (Jekyll keeps working) ----------
say "Assets -> public/assets (copy, no overwrite)"
if [ -d assets ]; then
  run mkdir -p public
  if [ -e public/assets ]; then warn "public/assets exists, skipped"; else run cp -R assets public/assets; fi
else
  echo "  no assets/ dir"
fi

# ---------- config + content collection ----------
say "Astro files"
write_file astro.config.mjs <<'EOF'
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: '__SITE__',
  integrations: [sitemap()],
});
EOF

write_file src/content.config.ts <<'EOF'
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Reads Jekyll posts in place from ./_posts (Beautiful Jekyll front matter).
const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,markdown}', base: './_posts' }),
  schema: z.object({
    layout: z.string().optional(),
    title: z.string(),
    subtitle: z.string().optional(),
    date: z.coerce.date().optional(), // Jekyll falls back to filename date
    tags: z
      .preprocess((v) => (typeof v === 'string' ? v.split(/[\s,]+/).filter(Boolean) : v), z.array(z.string()))
      .default([]),
    'cover-img': z.any().optional(),
    'thumbnail-img': z.string().optional(),
    published: z.boolean().default(true),
    pinned: z.boolean().default(false),
  }),
});

export const collections = { blog };
EOF

write_file src/pages/index.astro <<'EOF'
---
import { getCollection } from 'astro:content';
const when = (p) => p.data.date ?? new Date(p.id.slice(0, 10));
const posts = (await getCollection('blog', (p) => p.data.published))
  .sort((a, b) => Number(b.data.pinned) - Number(a.data.pinned) || +when(b) - +when(a));
---
<html lang="zh-Hant">
  <head><meta charset="utf-8" /><meta name="viewport" content="width=device-width,initial-scale=1" /><title>Blog</title></head>
  <body>
    <h1>Blog</h1>
    <ul>
      {posts.map((p) => (
        <li><a href={`/${p.id}/`}>{p.data.title}</a> <small>{when(p).toISOString().slice(0, 10)}</small></li>
      ))}
    </ul>
  </body>
</html>
EOF

write_file 'src/pages/[...slug].astro' <<'EOF'
---
import { getCollection, render } from 'astro:content';
export async function getStaticPaths() {
  const posts = await getCollection('blog', (p) => p.data.published);
  return posts.map((p) => ({ params: { slug: p.id }, props: { p } }));
}
const { p } = Astro.props;
const { Content } = await render(p);
---
<html lang="zh-Hant">
  <head><meta charset="utf-8" /><meta name="viewport" content="width=device-width,initial-scale=1" /><title>{p.data.title}</title></head>
  <body>
    <p><a href="/">&larr; Home</a></p>
    <h1>{p.data.title}</h1>
    {p.data.subtitle && <p><em>{p.data.subtitle}</em></p>}
    <Content />
  </body>
</html>
EOF

# Deploy workflow: written as .disabled so nothing changes on GitHub until you rename it
write_file .github/workflows/astro-deploy.yml.disabled <<'EOF'
# Rename to astro-deploy.yml AND set Settings -> Pages -> Source: GitHub Actions to go live.
name: Deploy Astro to GitHub Pages
on:
  push: { branches: [main] }
  workflow_dispatch:
permissions: { contents: read, pages: write, id-token: write }
concurrency: { group: pages, cancel-in-progress: true }
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: withastro/action@v3
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.d.outputs.page_url }}
    steps:
      - id: d
        uses: actions/deploy-pages@v4
EOF

# ---------- verify ----------
say "Verify build"
if [ "$DRY" = 1 ]; then
  echo "  (skipped in dry-run)"
else
  npx astro sync
  npm run build
  BUILT="$(find dist -mindepth 2 -name index.html -not -path 'dist/_astro/*' | wc -l | tr -d ' ')"
  echo "  posts in $POSTS_DIR: $POST_COUNT | post pages built: $BUILT"
  if [ "$BUILT" -lt "$POST_COUNT" ]; then
    warn "built pages < posts. Possible causes: published:false posts, or the loader skipping '_'-prefixed dirs."
    warn "Fallback: git mv _posts src/content/blog  &&  sed -i.bak \"s#./_posts#./src/content/blog#\" src/content.config.ts"
  fi
  git add -A
  git commit -q -m "Add Astro content collections (reads _posts in place)"
fi

say "Done"
cat <<EOF
  Preview:   npm run preview
  Rollback:  git checkout main && git branch -D $BRANCH
  Go live:   merge $BRANCH -> main, rename .github/workflows/astro-deploy.yml.disabled,
             set Settings -> Pages -> Source: GitHub Actions
EOF
