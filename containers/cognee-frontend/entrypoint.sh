#!/bin/sh
set -e

# NEXT_PUBLIC_* variables are inlined into the browser bundle at BUILD time.
# The image is built with literal placeholders (ENV NAME=NAME) so they can be
# swapped for the container's real environment values here, at startup. This
# keeps the API URL and cloud/local mode configurable at RUNTIME.
#
# Each variable listed below MUST also be declared as `ENV NAME=NAME` in the
# Dockerfile builder stage, otherwise there is no placeholder to substitute.
PLACEHOLDERS="NEXT_PUBLIC_LOCAL_API_URL NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT NEXT_PUBLIC_COGWIT_API_KEY"

for name in $PLACEHOLDERS; do
  # Resolve the real runtime value; fall back to the placeholder itself so an
  # unset variable is left untouched rather than blanked out.
  value=$(printenv "$name" || true)
  [ -z "$value" ] && value="$name"

  # Rewrite every occurrence of the placeholder token in the built assets.
  find /app/.next /app/public -type f 2>/dev/null \
    | while IFS= read -r file; do
        if grep -q "$name" "$file" 2>/dev/null; then
          sed -i "s|$name|$value|g" "$file"
        fi
      done
done

exec "$@"
