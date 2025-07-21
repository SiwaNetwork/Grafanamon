#!/bin/bash

# SHIWA TIME Helm Chart Testing Script

set -e

CHART_DIR="/workspace/shiwatime-helm-chart"

echo "🧪 SHIWA TIME Helm Chart Testing"
echo "================================"

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Lint the chart
echo "🔍 Linting Helm chart..."
helm lint "$CHART_DIR"

# Dry run installation
echo "🏃 Running dry-run installation..."
helm install shiwatime-test "$CHART_DIR" --dry-run --debug

echo "✅ Helm chart validation completed successfully!"
echo ""
echo "📋 Chart Summary:"
helm show chart "$CHART_DIR"
echo ""
echo "🎉 SHIWA TIME Helm chart is ready for deployment!"