provider "aws" {
  region = "us-east-2"
}

variable "vpc_cidr_block" {}
variable "private_subnet_cidr_blocks" {}
variable "public_subnet_cidr_blocks" {}


data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"
  name = "vpc"

  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernates.io/cluster/golang-eks-cluster" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernates.io/cluster/golang-eks-cluster" = "shared"
  }
  private_subnet_tags = {
    "kubernates.io/cluster/golang-eks-cluster" = "shared"
    "kubernates.io/cluster/golang-eks-cluster" = "shared"
  }
}

provider "kubernetes" {

  host = data.aws_eks_cluster.myapp-cluster.endpoint 
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.myapp-cluster.token

}

data "aws_eks_cluster" "myapp-cluster" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_id
}


module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "17.20.0"
    
    cluster_name = "golang-eks-cluste"
    cluster_version = "1.28"

    subnets = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id

    tags = {
        Name = "golang-eks-cluster"
        application = "golang"
    }

    node_groups = [
        {
            instance_type = "t2.small"  
            name = "worker-node-1"
            asg_desire_capacity = 2
            asg_max_capacity = 4
            asg_min_capacity = 1
            volume_size = 5
            
        }
    ]
}

resource "aws_ecr_repository" "ecr_repo" {
  name = "golange"
  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_iam_role" "ebs-role" {
  name = "ebs-role"
  assume_role_policy = jsonencode(
    {
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  }
  )
}
resource "aws_iam_role_policy_attachment" "attach-this-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.ebs-role.name
}
resource "aws_ebs_volume" "ebs-volume" {
  availability_zone = "us-east-2a"
  size = 20
  type = "gp2"
}
