# AWS configuration is provided via environment variables
# see: https://www.terraform.io/docs/providers/aws/#environment-variables
provider "aws" {
  version = "~> 1.52"
}

provider "archive" {
  version = "~> 1.1"
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

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "./lambda/"
  output_path = "./lambda.zip"

}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"


  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "elasticsearch" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "elasticsearch"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  runtime          = "nodejs8.10"
  timeout          = "120"

  environment {
    variables = {
      ES_ENDPOINT = "${aws_elasticsearch_domain.elasticsearch.endpoint}"
    }
  }
}
