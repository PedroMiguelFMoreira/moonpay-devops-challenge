#!/bin/bash

cat <<EOT >> /etc/ecs/ecs.config
ECS_DATADIR=/data
ECS_ENABLE_TASK_ENI=true
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_LOGFILE=/log/ecs-agent.log
ECS_LOGLEVEL=info
ECS_CLUSTER=${cluster_name}
EOT

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_NAME="${instance_prefix}_$INSTANCE_ID"
aws ec2 create-tags --resources "$INSTANCE_ID" --tags Key=Name,Value="$INSTANCE_NAME"
