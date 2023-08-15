output "security_group" {
  value = aws_security_group.reporter-all-intra-traffic.id
}

output "instance_profile" {
  value = aws_iam_instance_profile.reporter_ec2_instance_profile.id
}

output "name_suffix" {
  value = local.name_suffix
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_id1" {
  value = aws_subnet.subnet.id
}

output "subnet_id2" {
  value = aws_subnet.subnet1.id
}

// instance outputs
output "usernames" {
  value = [
    module.instance.username,
    module.instance1.username,
  ]
}

output "ips" {
  value = [
    module.instance.ip,
    module.instance1.ip,
  ]
}

output "pems" {
  value     = tls_private_key.keypair.private_key_pem
  sensitive = true
}

output "sg_ids" {
  value = [
    module.instance.sg_id,
    module.instance1.sg_id,
  ]
}

output "instance_ids" {
  value = [
    module.instance.instance_id,
    module.instance1.instance_id,
  ]
}

output "keypairs" {
  value = [
    module.instance.keypair,
    module.instance1.keypair,
  ]
}

output "private_ips" {
  value = [
    module.instance.private_ip,
    module.instance1.private_ip,
  ]
}

output "public_keys" {
  value = tls_private_key.keypair.public_key_openssh
}

output "ami_types" {
  value = var.ami_type
}

output "amis" {
  value = data.aws_ami.ubuntu.id
}

output "rds_password" {
  value     = random_string.password.result
  sensitive = true
}

output "rds_username" {
  value     = random_string.username.result
  sensitive = true
}

output "rds_engine" {
  value = var.engine
}

output "rds_engine_version" {
  value = local.final_version
}

output "rds_address" {
  value = aws_db_instance.rds.address
}

output "rds_port" {
  value = aws_db_instance.rds.port
}
