# AWS configuration is provided via environment variables
# see: https://www.terraform.io/docs/providers/aws/#environment-variables
provider "aws" {
  version = "~> 1.52"
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name           = "${var.domain}"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type = "${var.node_instance_type}"
    instance_count = "${var.node_count}"
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*",
      "Condition": {
        "IpAddress": {"aws:SourceIp": ["${var.access_cidr_block}"]}
      }
    }
  ]
}
POLICY

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.node_volume_size}"
  }

  tags = {
    Domain = "elasticsearch"
  }
}
