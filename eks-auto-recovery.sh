#!/bin/bash

# EKS Auto-Recovery Script
# Description: This script monitors and automatically recovers critical EKS components
# Version: 1.0
# Author: Vivienne Dotsey
# Requirements: awscli, kubectl, jq

set -o errexit
set -o nounset
set -o pipefail

# Configuration Variables
CLUSTER_NAME="eks-dev-eks-cluster"
REGION="eu-north-1"
NAMESPACES=("kube-system" "devops-apps" "monitoring")
CRITICAL_DEPLOYMENTS=("coredns" "metrics-server" "cluster-autoscaler")
MAX_RETRIES=3
SLEEP_INTERVAL=30
SLACK_WEBHOOK_URL="" # Optional for notifications
EMAIL_NOTIFICATION="viviennedotsey32@gmail.com" # Optional for email alerts

# Initialize logging
LOG_FILE="$HOME/eks-recovery-logs/eks-recovery-$(date +%Y%m%d).log"
mkdir -p $HOME/eks-recovery-logs
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

notify() {
    local message="$1"
    log "$message"
    
    # Send to Slack if configured
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"[EKS Recovery] $message\"}" \
        "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || log "Slack notification failed"
    fi
    
    # AWS SES email notification
    if [ -n "$EMAIL_NOTIFICATION" ]; then
        aws ses send-email \
            --from "viviennedotsey32@gmail.com" \
            --to "$EMAIL_NOTIFICATION" \
            --subject "[EKS Recovery Alert] $CLUSTER_NAME" \
            --text "$message" \
            --region eu-north-1 >/dev/null 2>&1 || log "AWS SES notification failed"
    fi
}

verify_aws_credentials() {
    log "Verifying AWS credentials..."
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        notify "AWS credentials are not valid. Please configure proper credentials."
        exit 1
    fi
}

verify_kubectl_config() {
    log "Verifying kubectl configuration..."
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log "Updating kubeconfig..."
        aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"
        
        if ! kubectl cluster-info >/dev/null 2>&1; then
            notify "Failed to configure kubectl for EKS cluster $CLUSTER_NAME"
            exit 1
        fi
    fi
}

check_eks_control_plane() {
    log "Checking EKS control plane health..."
    local cluster_status=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query 'cluster.status' --output text 2>/dev/null)
    
    if [ "$cluster_status" != "ACTIVE" ]; then
        notify "EKS control plane is not healthy. Status: $cluster_status"
        return 1
    fi
    return 0
}

check_node_health() {
    log "Checking worker node health..."
    local unhealthy_nodes=$(kubectl get nodes --no-headers | grep -v "Ready" | wc -l)
    
    if [ "$unhealthy_nodes" -gt 0 ]; then
        notify "Found $unhealthy_nodes unhealthy worker nodes"
        return 1
    fi
    return 0
}

check_critical_pods() {
    log "Checking critical pods in all namespaces..."
    local all_critical_pods_healthy=true
    
    for ns in "${NAMESPACES[@]}"; do
        local crashed_pods=$(kubectl get pods -n "$ns" --no-headers | grep -Ev "Running|Completed" | wc -l)
        
        if [ "$crashed_pods" -gt 0 ]; then
            notify "Found $crashed_pods unhealthy pods in namespace $ns"
            kubectl get pods -n "$ns" | grep -Ev "Running|Completed" >> "$LOG_FILE"
            all_critical_pods_healthy=false
        fi
    done
    
    if ! $all_critical_pods_healthy; then
        return 1
    fi
    return 0
}

check_deployments() {
    log "Checking critical deployments..."
    local all_deployments_healthy=true
    
    for deployment in "${CRITICAL_DEPLOYMENTS[@]}"; do
        for ns in "${NAMESPACES[@]}"; do
            if kubectl get deployment "$deployment" -n "$ns" >/dev/null 2>&1; then
                local available=$(kubectl get deployment "$deployment" -n "$ns" -o jsonpath='{.status.availableReplicas}')
                local desired=$(kubectl get deployment "$deployment" -n "$ns" -o jsonpath='{.status.replicas}')
                
                if [ "$available" -lt "$desired" ]; then
                    notify "Deployment $deployment in namespace $ns has only $available out of $desired pods available"
                    all_deployments_healthy=false
                    
                    # Attempt to restart the deployment
                    kubectl rollout restart deployment "$deployment" -n "$ns"
                fi
            fi
        done
    done
    
    if ! $all_deployments_healthy; then
        return 1
    fi
    return 0
}

restart_failed_pods() {
    log "Restarting failed pods..."
    for ns in "${NAMESPACES[@]}"; do
        local failed_pods=$(kubectl get pods -n "$ns" --no-headers | grep -Ev "Running|Completed" | awk '{print $1}')
        
        for pod in $failed_pods; do
            notify "Restarting failed pod $pod in namespace $ns"
            kubectl delete pod "$pod" -n "$ns"
        done
    done
}

scale_down_up_deployments() {
    log "Scaling down/up problematic deployments..."
    for deployment in "${CRITICAL_DEPLOYMENTS[@]}"; do
        for ns in "${NAMESPACES[@]}"; do
            if kubectl get deployment "$deployment" -n "$ns" >/dev/null 2>&1; then
                local available=$(kubectl get deployment "$deployment" -n "$ns" -o jsonpath='{.status.availableReplicas}')
                local desired=$(kubectl get deployment "$deployment" -n "$ns" -o jsonpath='{.status.replicas}')
                
                if [ "$available" -lt "$desired" ]; then
                    notify "Scaling down and up deployment $deployment in namespace $ns"
                    kubectl scale deployment "$deployment" -n "$ns" --replicas=0
                    sleep 10
                    kubectl scale deployment "$deployment" -n "$ns" --replicas="$desired"
                fi
            fi
        done
    done
}

drain_unhealthy_nodes() {
    log "Checking for unhealthy nodes to drain..."
    local unhealthy_nodes=$(kubectl get nodes --no-headers | grep -v "Ready" | awk '{print $1}')
    
    for node in $unhealthy_nodes; do
        notify "Draining unhealthy node $node"
        kubectl drain "$node" --ignore-daemonsets --delete-emptydir-data --force || true
        
        # If node is still not healthy after drain, terminate it (ASG will launch new one)
        local node_ready=$(kubectl get node "$node" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
        if [ "$node_ready" != "True" ]; then
            local instance_id=$(kubectl get node "$node" -o jsonpath='{.spec.providerID}' | cut -d'/' -f5)
            notify "Terminating instance $instance_id for node $node"
            aws ec2 terminate-instances --instance-ids "$instance_id" --region "$REGION"
        fi
    done
}

main() {
    log "Starting EKS auto-recovery for cluster $CLUSTER_NAME"
    
    verify_aws_credentials
    verify_kubectl_config
    
    local attempts=0
    local success=false
    
    while [ $attempts -lt $MAX_RETRIES ] && ! $success; do
        attempts=$((attempts + 1))
        log "Attempt $attempts of $MAX_RETRIES"
        
        # Check components
        check_eks_control_plane || break
        check_node_health || drain_unhealthy_nodes
        check_critical_pods || restart_failed_pods
        check_deployments || scale_down_up_deployments
        
        # Verify if all checks pass now
        if check_eks_control_plane && check_node_health && check_critical_pods && check_deployments; then
            success=true
            notify "All EKS components are healthy after recovery attempts"
            break
        fi
        
        if [ $attempts -lt $MAX_RETRIES ]; then
            log "Waiting $SLEEP_INTERVAL seconds before next attempt..."
            sleep $SLEEP_INTERVAL
        fi
    done
    
    if ! $success; then
        notify "Failed to recover EKS cluster $CLUSTER_NAME after $MAX_RETRIES attempts. Manual intervention required."
        exit 1
    fi
    
    log "EKS auto-recovery completed successfully"
    exit 0
}

main
