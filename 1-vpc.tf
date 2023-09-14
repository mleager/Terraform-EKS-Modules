module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.1.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_names  = ["public-subnet-1a", "public-subnet-1b"]
  private_subnet_names = ["private-subnet-1a", "private-subnet-1b"]

  vpc_tags = {
    Name = "my-vpc"
  }

  igw_tags = {
    Name = "igw"
  }

  nat_gateway_tags = {
    Name = "nat"
  }

  nat_eip_tags = {
    Name = "nat-eip"
  }

  private_route_table_tags = {
    Name = "private-route"
  }

  public_route_table_tags = {
    Name = "public-route"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
