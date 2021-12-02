# (cutre) awslocal vs aws (amb alias: elegant) 
#  aws configure --profile localstack
#  alias aws='aws --endpoint-url=http://localhost:4566 --profile localstack'
#  unalias aws

VPC_CIDR=10.0.0.0/16
SUBNET_CIDR=10.0.0.0/24
COUNT=26
NOM_CLAU=JoanKeyPair$COUNT
CLAU=$NOM_CLAU.pem
NOM_SECGROUP=sshaccess$COUNT
IMAGE_ID=ami-04ad2567c9e3d7893
INSTANCE_TYPE=t2.micro
NOM_INSTANCIA=dijous$COUNT

VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query Vpc.VpcId --output text)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames "{\"Value\":true}"

SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --query Subnet.SubnetId --output text)
GATEWAY_ID=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $GATEWAY_ID

ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query RouteTable.RouteTableId --output text)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAY_ID

aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock}"
aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE_ID --no-cli-pager

aws ec2 associate-route-table  --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch

aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock,IP_PUBLICA:MapPublicIpOnLaunch}"

aws ec2 create-key-pair --key-name $NOM_CLAU --query "KeyMaterial" --output text > ${CLAU}

SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $NOM_SECGROUP --description "Security group for SSH access" --vpc-id $VPC_ID  --output text)
echo $SECURITY_GROUP_ID

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

INSTANCE_ID=$(aws ec2 run-instances  --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $NOM_CLAU --security-group-ids $SECURITY_GROUP_ID --subnet-id $SUBNET_ID  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NOM_INSTANCIA}]" --query 'Instances[].InstanceId' --output text)
echo $INSTANCE_ID

PUB_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].PublicIpAddress' --output text)
echo $PUB_IP
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

chmod 400 ./${CLAU}
## -> ## ssh -v -i ./${CLAU} ec2-user@$PUB_IP

