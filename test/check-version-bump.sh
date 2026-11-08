#!/usr/bin/env bash

# Fails if a template in src/ changed relative to <base-ref> without its
# version in devcontainer-template.json being increased. Changes only to the
# generated README.md or to NOTES.md do not require a version bump.
#
# Usage: test/check-version-bump.sh <base-ref>

set -euo pipefail

BASE="${1:?usage: $0 <base-ref>}"
STATUS=0

cd "$(dirname "$0")/.."

for dir in src/*/; do
    template="$(basename "$dir")"
    metadata="src/$template/devcontainer-template.json"

    if git diff --quiet "$BASE"...HEAD -- "src/$template" \
            ":(exclude)src/$template/README.md" \
            ":(exclude)src/$template/NOTES.md"; then
        continue
    fi

    new_version="$(jq -r .version "$metadata")"
    if ! old_version="$(git show "$BASE:$metadata" 2>/dev/null | jq -r .version)"; then
        echo "$template: new template (version $new_version)"
        continue
    fi

    highest="$(printf '%s\n%s\n' "$old_version" "$new_version" | sort -V | tail -1)"
    if [ "$new_version" = "$old_version" ] || [ "$highest" != "$new_version" ]; then
        echo "$template: changed, but version was not increased ($old_version -> $new_version)"
        STATUS=1
    else
        echo "$template: version increased ($old_version -> $new_version)"
    fi
done

exit $STATUS
