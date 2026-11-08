mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = { names = ["us-east-1a", "us-east-1b"] }
  }
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:role/TestRunner"
      user_id    = "test-runner"
    }
  }
  mock_data "aws_partition" {
    defaults = { partition = "aws", dns_suffix = "amazonaws.com" }
  }
  mock_data "aws_region" {
    defaults = { name = "us-east-1", region = "us-east-1" }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
  mock_data "aws_eks_addon_version" {
    defaults = { version = "v1.0.0-eksbuild.1" }
  }
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/MockRole" }
  }
  mock_resource "aws_iam_policy" {
    defaults = { arn = "arn:aws:iam::123456789012:policy/MockPolicy" }
  }
  mock_resource "aws_launch_template" {
    defaults = { id = "lt-0123456789abcdef0", latest_version = 1 }
  }
  mock_resource "aws_kms_key" {
    defaults = { arn = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000" }
  }
  mock_resource "aws_eks_cluster" {
    defaults = {
      arn                   = "arn:aws:eks:us-east-1:123456789012:cluster/platform-lab"
      endpoint              = "https://mock.eks.local"
      certificate_authority = [{ data = "bW9jaw==" }]
      identity              = [{ oidc = [{ issuer = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE" }] }]
    }
  }
}
mock_provider "tls" {}
mock_provider "time" {}
mock_provider "null" {}
mock_provider "cloudinit" {}
variables {
  kubernetes_version     = "1.32"
  administrator_role_arn = "arn:aws:iam::123456789012:role/PlatformAdministrator"
}
run "lab_topology" {
  command = apply
  assert {
    condition     = module.eks.cluster_name == "platform-lab"
    error_message = "Cluster name must reflect environment."
  }
  assert {
    condition     = length(module.vpc.private_subnets) == 2 && length(module.vpc.public_subnets) == 2
    error_message = "Two private and two public subnets are required."
  }
  assert {
    condition     = length(module.vpc.natgw_ids) == 1
    error_message = "Lab should have a single NAT gateway."
  }
}
run "production_topology" {
  command = apply
  variables {
    environment = "production"
  }
  assert {
    condition     = module.eks.cluster_name == "platform-production"
    error_message = "Production cluster name must be distinct."
  }
  assert {
    condition     = length(module.vpc.natgw_ids) == 2
    error_message = "Production requires a NAT gateway per availability zone."
  }
}
run "reject_unknown_environment" {
  command = plan
  variables {
    environment = "invalid"
  }
  expect_failures = [var.environment]
}
run "reject_root_administrator" {
  command = plan
  variables {
    administrator_role_arn = "arn:aws:iam::123456789012:root"
  }
  expect_failures = [var.administrator_role_arn]
}
