#### This project is for the Devops bootcamp exercise for

## EXERCISE 1: Create IAM user
First of all, you need an IAM user with correct permissions to execute the tasks below.

* Create a new IAM user "your name" with "devops" user-group
* Give the "devops" group all needed permissions to execute the tasks below - with login and CLI credentials


Note: Do that using the AWS UI with Admin User

**Solution:**

    # We can check if the AWS local user is configured.
    aws configure list
    cat ~/.aws/credentials

    # We can the create a new user.
    aws iam create-user --user-name arshaAssignment

    # A new group is also created.
    aws iam create-group --group-name devops

    # Add the user to newly created group.
    aws iam add-user-to-group --user-name arshaAssignment --group-name devops

    # Verify that devops group contains the user
    aws iam get-group --group-name devops

Now we can give the user UI and CLI access.

    # Generate user keys for CLI access & save key.txt file in safe location
    aws iam create-access-key --user-name arshaAssignment > key.txt

    # Generate user login credentials for UI & save password in safe location
    aws iam create-login-profile --user-name arshaAssignment --password Password12345

    # Give user permission to change password
    aws iam list-policies | grep ChangePassword
    aws iam attach-user-policy --user-name arshaAssignment --policy-arn "arn:aws:iam::aws:policy/IAMUserChangePassword"

Finally, we can assign permissions to the "devops" group.

    # Check which policies are available for managing EC2 & VPC services, including subnet and security groups
    aws iam list-policies | grep EC2FullAccess
    aws iam list-policies | grep VPCFullAccess

    # Give devops group needed permissions
    aws iam attach-group-policy --group-name devops --policy-arn "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    aws iam attach-group-policy --group-name devops --policy-arn "arn:aws:iam::aws:policy/AmazonVPCFullAccess"

    # Check policies for group
    aws iam list-attached-group-policies --group-name devops

## EXERCISE 2: Configure AWS CLI
You want to use the AWS CLI for the following tasks. So, to be able to interact with the AWS account from the AWS Command Line tool you need to configure it correctly:

* Set credentials for that user for AWS CLI
* Configure correct region for your AWS CLI

**Solution:**

    # After saving the current admin user keys from ~/.aws/credentials in a safe location,
    # the credentials of the new use can be set from the key.txt file that was created in the previous step.
    aws configure
    AWS Access Key ID [****]: new-access-key-id
    AWS Secret Access Key [****]: new-secret-access-key
    Default region name [us-west-1]: new-region
    Default output format [None]:

    # The changes can validated via cat ~/.aws/credentials.

## EXERCISE 3: Create VPC
You want to create the EC2 Instance in a dedicated VPC, instead of using the default one. So you:

* create a new VPC with 1 subnet and
* create a security group in the VPC that will allow you access on ssh port 22 and will allow browser access to your Node application
(using the AWS CLI)

**Solution:**

    # Create VPC and return VPC id
    aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query Vpc.VpcId --output text

    # Create subnet in the VPC
    # aws ec2 create-subnet --vpc-id vpc-0c19469408af3eaf4 --cidr-block 10.0.1.0/24
    aws ec2 create-subnet --vpc-id {vpc-id} --cidr-block 10.0.1.0/24 

We can make the VPC public:

    # Create internet gateway & return the gateway id
    aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text

    # Attach internet gateway to our VPC
    # aws ec2 attach-internet-gateway --vpc-id vpc-0c19469408af3eaf4 --internet-gateway-id igw-033d0ae221c8140d8
    aws ec2 attach-internet-gateway --vpc-id {vpc-id} --internet-gateway-id {igw-id}

    # Create a custom Route table for our VPC & return route table ID
    # aws ec2 create-route-table --vpc-id vpc-0c19469408af3eaf4 --query RouteTable.RouteTableId --output text
    aws ec2 create-route-table --vpc-id {vpc-id} --query RouteTable.RouteTableId --output text

    # Create Route rule for handling all traffic between internet & VPC
    # aws ec2 create-route --route-table-id rtb-08b2279d5e370b451 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-033d0ae221c8140d8
    aws ec2 create-route --route-table-id {rtb-id} --destination-cidr-block 0.0.0.0/0 --gateway-id {igw-id}

    # Validate your custom route table has correct configurations, 1 local and 1 internet gateway routes
    # aws ec2 describe-route-tables --route-table-id rtb-08b2279d5e370b451
    aws ec2 describe-route-tables --route-table-id {rtb-id}

    # Associate subnet with the route table to allow internet traffic in the subnet as well
    # aws ec2 associate-route-table  --subnet-id subnet-0c929232221315e15 --route-table-id rtb-08b2279d5e370b451
    aws ec2 associate-route-table  --subnet-id {subnet-id} --route-table-id {rtb-id}

Create security group in the VPC to allow access to port 22.

    # Create security group - this will print security group id as output
    # aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id vpc-0c19469408af3eaf4
    aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id {vpc-id}

    # Add incoming access on port 22 from all sources to security group
    # aws ec2 authorize-security-group-ingress --group-id sg-004c36b1a2e0d2126 --protocol tcp --port 22 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-id {sg-id} --protocol tcp --port 22 --cidr 0.0.0.0/0

    # You can also specify your IP address CIDR block instead of 0.0.0.0/0 for more security


## EXERCISE 4: Create EC2 Instance
Once the VPC is created, you:

* Create an EC2 instance in that VPC
* with the security group you just created and ssh key file (using the AWS CLI)

**Solution:**

    # Create key pair and save it locally in a pem file.
    aws ec2 create-key-pair --key-name AssignmentKey --query "KeyMaterial" --output text > AssignmentKey.pem

    # Set stricter permission on it for later use
    chmod 400 AssignmentKey.pem

    # Create 1 EC2 instance with the above key, in our subnet and using security group we created
    aws ec2 run-instances --image-id ami-06c39ed6b42908a36 --count 1 --instance-type t2.micro --key-name AssignmentKey --security-group-ids sg-004c36b1a2e0d2126 --subnet-id subnet-0c929232221315e15

    # Validate that EC2 instance is in a running state, and get its public ip address to connect via ssh
    aws ec2 describe-instances --instance-id i-0a5cd2b3bbc072a4a --query "Reservations[*].Instances[*].{State:State.Name,Address:PublicIpAddress}"

## EXERCISE 5: SSH into the server and install Docker on it
Once the EC2 instance is created successfully, you want to prepare the server to run Docker containers. So you:

* ssh into the server and
* install Docker on it to run the dockerized application later

**Solution:**

    # ssh into EC2 instance using the public IP address we got earlier
    ssh -i "AssignmentKey.pem" ec2-user@18.185.254.138

    # Install Docker, start docker service and allow ec2-user to run docker commands without sudo by adding it to docker group
    sudo yum update -y && sudo yum install -y docker
    sudo systemctl start docker 
    sudo usermod -aG docker ec2-user

## EXERCISE 6: Add docker-compose for deployment
First:

* add docker-compose to your NodeJS application

The reason is you want to have the whole configuration for starting the docker container in a file, in case you need to make changes to that, instead of a plain docker command with parameters. Also, in case you add a database later.

**Solution:**

Added the docker-compose.yaml file.


## EXERCISE 7: Add "deploy to EC2" step to your pipeline
* Complete the previous pipeline by adding a deployment step for your previous NodeJS project with docker-compose.

**Solution:**

The Jenkinsfile and dockerfile are added to the repository from the [DevOpsBootcampJenkinsAssignment](https://github.com/ArshaShiri/DevOpsBootcampJenkinsAssignment.git) branch and build on Jenkins is successful. Next, the new stage to deploy to EC2 is added. Make sure a ssh credential is added to jenkins by the name of ec2-server-key.