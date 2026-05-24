#!/usr/bin/env bash
# Fallback index.json generator documenting the discovery contract
# (architecture.md §9). The generic `skillrig index` is authoritative — it shares
# skillcore/manifest parsing with verify/bump so values can't diverge. This
# script exists so the contract is legible and CI works before the binary is
# wired up. Requires: yq or tomlq (pinned via mise.toml in CI). Emits to stdout.
set -euo pipefail

CONV=$(grep -E '^convention_version' .skillrig-origin.toml | sed -E 's/[^0-9]//g')
ORIGIN=$(grep -E '^origin' .skillrig-origin.toml | sed -E 's/.*"(.*)".*/\1/')

# NOTE: this is a documentation-grade emitter. Production index generation runs
# through `skillrig index`, which parses skill.toml with the same code path as
# verify. Prefer that path in CI; keep this as the legible fallback.
printf '{\n  "skillrigConvention": %s,\n  "origin": "%s",\n  "skills": [\n' "$CONV" "$ORIGIN"

first=1
for toml in skills/*/skill.toml; do
  dir=$(dirname "$toml")
  name=$(grep -E '^name'        "$toml" | head -1 | sed -E 's/.*"(.*)".*/\1/')
  ver=$(grep -E '^version'      "$toml" | head -1 | sed -E 's/.*"(.*)".*/\1/')
  desc=$(grep -E '^description' "$toml" | head -1 | sed -E 's/.*"(.*)".*/\1/')
  [[ $first -eq 1 ]] || printf ',\n'
  first=0
  printf '    { "name": "%s", "version": "%s", "description": "%s", "path": "%s" }' \
    "$name" "$ver" "$desc" "$dir"
done

printf '\n  ]\n}\n'
