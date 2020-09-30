#!/bin/bash 
COUNTER=0
echo ------------

while [  $COUNTER -lt 5 ]; do
    TASK=$(aws ecs run-task --cluster poc-efsstorage --task-definition poc-efsecsstorage-task --count 1 --launch-type FARGATE --platform-version 1.4.0 --network-configuration "awsvpcConfiguration={subnets=[subnet-0bd5d10faed104005, subnet-0641705ebc07250d3],securityGroups=[sg-00dd56d04ec56d0d7],assignPublicIp=ENABLED}" --region ap-southest-1)
    TASK_ARN=$(echo $TASK | jq --raw-output .tasks[0].taskArn) 
    sleep 20
    TASK=$(aws ecs describe-tasks --cluster app-cluster --tasks $TASK_ARN --region ap-southest-1)
    TASK_ENI=$(echo $TASK | jq --raw-output '.tasks[0].attachments[0].details[] | select(.name=="networkInterfaceId") | .value')
    ENI=$(aws ec2 describe-network-interfaces --network-interface-ids $TASK_ENI --region ap-southest-1)
    PUBLIC_IP=$(echo $ENI | jq --raw-output .NetworkInterfaces[0].Association.PublicIp)
    sleep 100
    curl $PUBLIC_IP
    echo ------------
    aws ecs stop-task --cluster app-cluster --task $TASK_ARN --region ap-southest-1 > /dev/null
    let COUNTER=COUNTER+1 
done