#!/bin/bash
# Build OpenClaw minimal Docker image
#
# Usage:
#   ./scripts/build-docker-minimal.sh [options]
#
# Options:
#   --tag <tag>        Image tag (default: minimal)
#   --variant <v>      Base variant: default or slim (default: slim)
#   --no-cache         Build without cache
#   --help             Show this help
#
# Examples:
#   ./scripts/build-docker-minimal.sh
#   ./scripts/build-docker-minimal.sh --tag my-registry/openclaw:latest
#   ./scripts/build-docker-minimal.sh --variant default --no-cache
#
# Image size comparison:
#   - Default (bookworm):      ~2.29GB (full featured)
#   - Slim (bookworm-slim):    ~1.8GB  (no UI/QA builds)
#   - Minimal (slim -ui -qa):  ~1.42GB (gateway + MCP only)
#
# Minimal mode removes:
#   - UI build and dist/ui/
#   - QA Lab build and qa/
#   - skills/ directory
#   - docs/ directory
#
# Keep using minimal mode when:
#   - Running headless gateway
#   - Using MCP for external services (e.g., PPT generation)
#   - No Web UI access needed
#   - No local skills/docs needed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TAG="minimal"
VARIANT="slim"
NO_CACHE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --variant)
            VARIANT="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --help)
            head -30 "$0" | tail -25
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Building OpenClaw minimal Docker image..."
echo "  Tag:     $TAG"
echo "  Variant: $VARIANT"
echo "  No cache: ${NO_CACHE:-no}"
echo ""

cd "$REPO_ROOT"

docker build $NO_CACHE \
    --build-arg OPENCLAW_VARIANT="$VARIANT" \
    --build-arg OPENCLAW_MINIMAL=1 \
    -t "openclaw:$TAG" \
    .

echo ""
echo "Build complete!"
echo ""
echo "Image size:"
docker images "openclaw:$TAG" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""
echo "To run:"
echo "  docker run -p 18789:18789 openclaw:$TAG"
echo ""
echo "Note: Minimal mode does not include UI, QA Lab, skills, or docs."
