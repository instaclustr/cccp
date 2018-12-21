resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags {
    Name       = "${var.username}:${var.cluster_name}:cccp"
    managed_by = "terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name       = "${var.username}:${var.cluster_name}:cccp"
    managed_by = "terraform"
  }
}
