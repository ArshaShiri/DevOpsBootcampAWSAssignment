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