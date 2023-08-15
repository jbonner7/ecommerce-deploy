locals {
  policy_name = "allow-manage-stack-${random_string.random.result}"
}


resource "aws_iam_policy" "allow-manage-stack" {
  name        = local.policy_name
  description = "Allow managing the entire stack"

  policy = <<EOT
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "allowManageStack",
			"Effect": "Allow",
			"Action": [
				"rds:*",
				"kms:*",
				"ec2:*",
        "s3:*",
				"sts:GetAccessKeyInfo",
				"sts:GetCallerIdentity",
				"sts:GetSessionToken"
			],
			"Resource": "*"
		}
	]
}
EOT
}

output "role_arn" {
  value = aws_iam_policy.allow-manage-stack.arn
}

