#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Don't include e2e in the distribution artifact, to reduce size.
# But **do** include e2e/smoke since the BCR wants to run presubmit test
# and it only sees our release artifact.
# shellcheck disable=2010
ls e2e | grep -vx smoke | awk 'NF{print "e2e/" $0 " export-ignore"}' >.git/info/attributes

# Argument provided by reusable workflow caller, see
# https://github.com/bazel-contrib/.github/blob/d197a6427c5435ac22e56e33340dff912bc9334e/.github/workflows/release_ruleset.yaml#L72
TAG=$1
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_webpack-${TAG:1}"
ARCHIVE="rules_webpack-$TAG.tar.gz"
git archive --format=tar --prefix="${PREFIX}/" "${TAG}" | gzip >"$ARCHIVE"

cat <<EOF

Add to your \`MODULE.bazel\` file:
\`\`\`starlark
bazel_dep(name = "aspect_rules_webpack", version = "${TAG:1}")
\`\`\`
EOF
