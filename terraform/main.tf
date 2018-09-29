variable "profile" {}

variable "region" {
  default = "us-west-2"
}

variable "private_key" {}

variable "vol_size" {
  default = 400
}

variable "vol_type" {
  default = "gp2"
}

variable "instance_size" {
  default = "m4.xlarge"
}

variable "num_nodes" {
  default = 3
}

variable "git_repo" {
  default = ""
}

variable "git_branch" {
  default = ""
}

variable "install_repo" {
  default = "no"
}

variable "aws_keyname" {
}

// Only for tags; will actually edit YAML in the future
variable cluster_name {}

variable dc_name {}

//Username to tag instances with, or else Jordan becomes very unhappy
variable "username" {}

// Create a stress box of the same size with the same AMI
variable "create_stressbox" {
  default = false
}

provider "aws" {
  version = ">= 1.0.0"
  profile = "${var.profile}"
  region  = "${var.region}"
}

module "cassandra" {
  source        = "cassandra/"
  vol_size      = "${var.vol_size}"
  vol_type      = "${var.vol_type}"
  instance_size = "${var.instance_size}"
  cluster_name  = "${var.cluster_name}"
  dc_name       = "${var.dc_name}"
  username      = "${var.username}"
  num_nodes     = "${var.num_nodes}"
  git_repo      = "${var.git_repo}"
  git_branch    = "${var.git_branch}"
  private_key   = "${var.private_key}"
  aws_keyname   = "${var.aws_keyname}"
  install_repo  = "${var.install_repo}"

  //  extra_volume_vol_size = "${var.extra_volume_vol_size}"
  //  extra_volume_vol_type = "${var.extra_volume_vol_type}"

  create_stressbox = "${var.create_stressbox}"

  //  create_extra_volume_per_node = "${var.create_extra_volume_per_node}"
}

//provider "aws" {
//  alias = "extra-dc-region"
//  region = "${var.create_extra_dc_region}"
//  access_key = "${var.aws_access_key}"
//  secret_key = "${var.aws_secret_key}"
//}


//module "secondDCCassandra" {
//  source = "cassandra/"
//  vol_size = "${var.vol_size}"
//  vol_type = "${var.vol_type}"
//  vpc_cidr = "${var.create_extra_dc_cidr}"
//  instance_size = "${var.instance_size}"
//  cluster_name = "${var.cluster_name}"
//  initial_seeds = "${module.cassandra.seeds}"
//  dc_name = "${var.extra_dc_name}"
//  enabled = "${var.create_extra_dc}"
//  username = "${var.username}"
//  num_nodes = "${var.extra_dc_num_nodes}"
//
//  extra_volume_vol_size = "${var.extra_volume_vol_size}"
//  extra_volume_vol_type = "${var.extra_volume_vol_type}"
//
//  create_stressbox = false
//  create_extra_volume_per_node = "${var.create_extra_volume_per_node}"
//
//  providers = {
//    aws = "aws.extra-dc-region"
//  }
//}
//
//module "extraDCParts" {
//  source = "extradcparts/"
//  "dc1-sg" = "${module.cassandra.security-group}"
//  "dc2-sg" = "${module.secondDCCassandra.security-group}"
//  "dc1-public-ips" = "${module.cassandra.public-ips}"
//  "dc2-public-ips" = "${module.secondDCCassandra.public-ips}"
//  enabled = "${var.create_extra_dc}"
//  providers = {
//    "aws.dc1" = "aws"
//    "aws.dc2" = "aws.extra-dc-region"
//  }
//}

