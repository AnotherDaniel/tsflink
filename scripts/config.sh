# Handle case where this is running outside of a GitHub runner
GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-.}"

# Shared configuration
TSFFER_DIR="$GITHUB_WORKSPACE/tsffer_assets"

# Optional tsffer source URL parameter, empty if not provided
TSFFER_URL="${1:-}"