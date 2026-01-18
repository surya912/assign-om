#!/bin/bash

# AI-Powered Health Check Script
# Analyzes application logs and metrics to determine deployment health

set -e

NAMESPACE=${1:-idea-board-production}
OPENAI_API_KEY=${OPENAI_API_KEY:-""}

if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY not set. Using basic health checks only."
fi

echo "🏥 Running AI-Powered Health Check for namespace: $NAMESPACE"

# Collect metrics
echo "📊 Collecting metrics..."
kubectl top pods -n "$NAMESPACE" > /tmp/metrics.txt 2>&1 || true
kubectl get pods -n "$NAMESPACE" -o wide > /tmp/pods.txt

# Collect logs
echo "📋 Collecting logs..."
kubectl logs -l app=backend -n "$NAMESPACE" --tail=200 > /tmp/backend-logs.txt 2>&1 || true
kubectl logs -l app=frontend -n "$NAMESPACE" --tail=200 > /tmp/frontend-logs.txt 2>&1 || true

# Check pod status
POD_STATUS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].status.phase}')
FAILED_PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[?(@.status.phase=="Failed")].metadata.name}')

# Basic health checks
HEALTHY=true
ISSUES=()

if [ -n "$FAILED_PODS" ]; then
    HEALTHY=false
    ISSUES+=("Failed pods detected: $FAILED_PODS")
fi

# Check for errors in logs
if grep -qi "error\|exception\|fatal" /tmp/backend-logs.txt; then
    HEALTHY=false
    ERROR_COUNT=$(grep -ci "error\|exception\|fatal" /tmp/backend-logs.txt)
    ISSUES+=("Found $ERROR_COUNT errors in backend logs")
fi

# Check CPU/Memory usage
if [ -f /tmp/metrics.txt ]; then
    while IFS= read -r line; do
        if [[ $line =~ CPU.*[5-9][0-9]% ]] || [[ $line =~ Memory.*[8-9][0-9]% ]]; then
            HEALTHY=false
            ISSUES+=("High resource usage detected: $line")
        fi
    done < /tmp/metrics.txt
fi

# AI Analysis (if API key is available)
if [ -n "$OPENAI_API_KEY" ]; then
    echo "🤖 Running AI analysis..."
    
    # Prepare analysis prompt
    ANALYSIS_PROMPT=$(cat <<EOF
Analyze the following Kubernetes deployment health data:

Pod Status:
$(cat /tmp/pods.txt)

Metrics:
$(cat /tmp/metrics.txt)

Backend Logs (last 50 lines):
$(tail -50 /tmp/backend-logs.txt)

Provide a health assessment:
1. Is the deployment healthy? (yes/no)
2. What issues were detected?
3. What actions should be taken?
4. Should we rollback? (yes/no)
EOF
)
    
    # Call OpenAI API (simplified - in production, use proper API client)
    echo "⚠️  AI analysis requires OpenAI API integration. Using basic checks for now."
fi

# Output results
echo ""
echo "📋 Health Check Results:"
echo "========================"

if [ "$HEALTHY" = true ]; then
    echo "✅ Status: HEALTHY"
    echo "✅ All systems operational"
else
    echo "❌ Status: UNHEALTHY"
    echo ""
    echo "Issues detected:"
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
    echo "⚠️  Consider rolling back the deployment"
    exit 1
fi

echo ""
echo "✅ Health check complete"

