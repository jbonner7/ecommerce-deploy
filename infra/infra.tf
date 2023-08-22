resource "random_string" "random" {
  length  = 10
  special = false
  upper   = false
}

resource "random_string" "password" {
  length  = 32
  special = false
  upper   = true
}

resource "random_string" "username" {
  length  = 32
  special = false
  upper   = true
}

locals {
  name_suffix = random_string.random.result
  ami_data = {
    "ubuntu" : {
      "username" : "ubuntu"
      "name_filter" : ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
      "owners" : ["099720109477"] # Canonical
    }
    "amazonlinux" : {
      "username" : "ec2-user"
      "name_filter" : ["amzn2-ami-hvm*"]
      "owners" : ["amazon"]
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = local.ami_data[var.ami_type]["name_filter"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = local.ami_data[var.ami_type]["owners"]
}


resource "aws_security_group" "reporter-all-intra-traffic" {
  name   = "ecomm-reporter-internal-traffic_${local.name_suffix}"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = "ALL"
    self      = true
    from_port = 0
    to_port   = 0
  }
}

# EC2 IAM role setup
resource "aws_iam_policy" "reporter_ec2_policy" { // ec2 policy
  name = "reporter_ec2_policy_${local.name_suffix}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "reporter_ec2_role" { // assume role
  name = "reporter_ec2_role_${local.name_suffix}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "reporter_ec2_role_attachment" {
  name       = "reporter_ec2_role_attach_${local.name_suffix}"
  roles      = [aws_iam_role.reporter_ec2_role.id]
  policy_arn = aws_iam_policy.reporter_ec2_policy.id
}

resource "aws_iam_instance_profile" "reporter_ec2_instance_profile" {
  name = "reporter_ec2_instance_profile_${local.name_suffix}"
  role = aws_iam_role.reporter_ec2_role.id
}

resource "tls_private_key" "keypair" {
  algorithm = "RSA"
}

module "instance" {
  source               = "./modules/instance"
  instance_name        = "rpt-frontend-${local.name_suffix}"
  vpc_id               = aws_vpc.vpc.id
  subnet               = aws_subnet.subnet.id
  instance_type        = "t2.micro"
  instance_profile_arn = aws_iam_instance_profile.reporter_ec2_instance_profile.arn
  security_group_arns  = aws_security_group.reporter-all-intra-traffic.id
  ports                = "22,8080"
  ssh_public_key       = tls_private_key.keypair.public_key_openssh
  ami_id               = data.aws_ami.ubuntu.id
  username             = local.ami_data[var.ami_type]["username"]
}

module "instance1" {
  source               = "./modules/instance"
  instance_name        = "rpt-backend-${local.name_suffix}"
  vpc_id               = aws_vpc.vpc.id
  subnet               = aws_subnet.subnet.id
  instance_type        = "t2.micro"
  instance_profile_arn = aws_iam_instance_profile.reporter_ec2_instance_profile.arn
  security_group_arns  = aws_security_group.reporter-all-intra-traffic.id
  ports                = "22,8080"
  ssh_public_key       = tls_private_key.keypair.public_key_openssh
  ami_id               = data.aws_ami.ubuntu.id
  username             = local.ami_data[var.ami_type]["username"]
}

module "ecomm-bucket" {
  source              = "./modules/s3"
  partial_bucket_name = "order-tracker-bucket"
}

module "sko-bucket" {
  source              = "./modules/s3"
  partial_bucket_name = "sko-bucket"
}
