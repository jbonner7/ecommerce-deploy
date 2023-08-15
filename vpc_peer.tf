module "single_account_single_region" {
  source  = "grem11n/vpc-peering/aws"
  version = "6.0.0"

  providers = {
    aws.this = aws
    aws.peer = aws
  }

  this_vpc_id         = aws_vpc.vpc.id
  peer_vpc_id         = var.targetvpc
  this_dns_resolution = true
  peer_dns_resolution = true
  auto_accept_peering = true
}
