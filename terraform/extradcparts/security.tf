# Needs to be explicitly declared to pass in provider from parent module, see https://www.terraform.io/docs/modules/usage.html#providers-within-modules
provider "aws" {
  alias = "dc1"
}

# Needs to be explicitly declared to pass in provider from parent module, see https://www.terraform.io/docs/modules/usage.html#providers-within-modules
provider "aws" {
  alias = "dc2"
}

data "aws_security_group" "dc1-sg" {
  id       = "${var.dc1-sg}"
  provider = "aws.dc1"
  count    = "${var.enabled}"
}

data "aws_security_group" "dc2-sg" {
  id       = "${var.dc2-sg}"
  provider = "aws.dc2"
  count    = "${var.enabled}"
}

resource "aws_security_group_rule" "allow_dc2" {
  count             = "${var.enabled}"
  from_port         = 7000
  protocol          = "tcp"
  security_group_id = "${data.aws_security_group.dc1-sg.id}"
  to_port           = 9160
  type              = "ingress"
  cidr_blocks       = ["${formatlist("%s/32", var.dc2-public-ips)}"]
  provider          = "aws.dc1"
}

resource "aws_security_group_rule" "allow_dc1" {
  count             = "${var.enabled}"
  from_port         = 7000
  protocol          = "tcp"
  security_group_id = "${data.aws_security_group.dc2-sg.id}"
  to_port           = 9160
  type              = "ingress"
  cidr_blocks       = ["${formatlist("%s/32", var.dc1-public-ips)}"]
  provider          = "aws.dc2"
}
