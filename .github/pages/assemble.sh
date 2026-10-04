#!/usr/bin/env bash
#
# Assemble the GitHub Pages source tree for the common-store umbrella site.
# README.md is the single source of truth: it is copied in at build time and never duplicated.
set -euo pipefail

REPO_SLUG="${REPO_SLUG:?REPO_SLUG is required}"
BASEURL="${BASEURL:?BASEURL is required}"
BRANCH="${BRANCH:-main}"

SRC="_site_src"

rm -rf "$SRC"
mkdir -p "$SRC"

cp .github/pages/_config.yml "$SRC/_config.yml"
cp -r .github/pages/_layouts "$SRC/_layouts"
cp .github/pages/index.md "$SRC/index.md"
cp .github/pages/robots.txt "$SRC/robots.txt"
cp README.md "$SRC/readme.md"
cp llms.txt "$SRC/llms.txt"

# --- link rewrites: repo-only files point at GitHub --------------------------------
sed -i \
  -e "s#](LICENSE)#](https://github.com/${REPO_SLUG}/blob/${BRANCH}/LICENSE)#g" \
  -e "s#](AGENTS\.md)#](https://github.com/${REPO_SLUG}/blob/${BRANCH}/AGENTS.md)#g" \
  "$SRC/readme.md"

# --- front matter + Liquid escaping (``` fences with {{...}} must survive) ---------
inject_front_matter() {
  local file="$1" override="${2:-}" title description
  title="${override:-$(sed -n 's/^# \{1,\}\(.*\)$/\1/p' "$file" | head -n 1)}"
  description="$(awk 'length($0) >= 50 && $0 !~ /^[[:space:]]/ && $0 !~ /^[#>|!]/ && $0 !~ /^```/ { print; exit }' "$file")"
  title="$(printf '%s' "$title" | tr -d '"' | sed -E 's/[*`]//g' | cut -c1-120)"
  description="$(printf '%s' "$description" | tr -d '"' | sed -E 's/[*`]//g' | cut -c1-180)"
  {
    printf -- '---\n'
    printf 'title: "%s"\n' "$title"
    if [ -n "$description" ]; then
      printf 'description: "%s"\n' "$description"
    fi
    printf -- '---\n\n'
    printf '{%% raw %%}\n'
    cat "$file"
    printf '\n{%% endraw %%}\n'
  } > "${file}.tmp"
  mv "${file}.tmp" "$file"
}

inject_front_matter "$SRC/readme.md" "Overview"

# --- sitemap -----------------------------------------------------------------------
{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
  while IFS= read -r path; do
    case "$path" in
      index.md) url="${BASEURL}/" ;;
      */index.md) url="${BASEURL}/${path%index.md}" ;;
      *) url="${BASEURL}/${path%.md}.html" ;;
    esac
    printf '  <url><loc>%s</loc></url>\n' "$url"
  done < <(cd "$SRC" && find . -name '*.md' -printf '%P\n' | sort)
  printf '</urlset>\n'
} > "$SRC/sitemap.xml"

cp .github/pages/_config.yml ./_config.yml

echo "--- assembled site source ---"
(cd "$SRC" && find . -type f | sort)
echo "--- sitemap ---"
cat "$SRC/sitemap.xml"
