# Handle case where this is running outside of a GitHub runner
GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-.}"
GITHUB_RUN_ID="${GITHUB_RUN_ID:-}"

# Github Repo ID
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-}"

# Shared configuration
TSFFER_DIR="$GITHUB_WORKSPACE/tsffer_assets"

# Optional tsffer source URL parameter, empty if not provided
TSFFER_URL="${1:-}"

# Trudag scoring output file
TRUDAG_SCORE_OUTPUT="trudag_score.txt"

# Trudag report archive file
TRUDAG_REPORT_ARCHIVE="trudag_report.tar.bz2"
