#!/bin/bash

echo 'ECS_DATADIR=/data\nECS_ENABLE_TASK_ENI=true\nECS_ENABLE_TASK_IAM_ROLE=true\nECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true\nECS_LOGFILE=/log/ecs-agent.log\nECS_LOGLEVEL=info\nECS_CLUSTER=' > /etc/ecs/ecs.config
sed -i "s#^\(ECS_CLUSTER=\s*\).*\$#\1${cluster_name}#" /etc/ecs/ecs.config

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_NAME="${instance_prefix}_$INSTANCE_ID"
aws ec2 create-tags --resources "$INSTANCE_ID" --tags Key=Name,Value="$INSTANCE_NAME"
