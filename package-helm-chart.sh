#!/bin/bash

# SHIWA TIME Helm Chart Packaging Script

set -e

CHART_DIR="/workspace/shiwatime-helm-chart"
OUTPUT_DIR="/workspace/helm-repo"

echo "🚀 SHIWA TIME Helm Chart Packaging Script"
echo "========================================"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Package the chart
echo "📦 Packaging Helm chart..."
helm package "$CHART_DIR" -d "$OUTPUT_DIR"

# Create or update the index.yaml file
echo "📝 Updating Helm repository index..."
helm repo index "$OUTPUT_DIR" --url https://charts.shiwatime.io/

echo "✅ Helm chart packaged successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Upload the contents of $OUTPUT_DIR to your web server"
echo "2. Users can add your repository with:"
echo "   helm repo add shiwatime https://charts.shiwatime.io/"
echo "   helm repo update"
echo "3. Install SHIWA TIME with:"
echo "   helm install shiwatime shiwatime/shiwatime-backend-chart"
echo ""
echo "🎉 SHIWA TIME is ready for deployment!"