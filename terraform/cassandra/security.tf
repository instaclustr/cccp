resource "aws_security_group" "sg" {
  name        = "ccP"
  description = "Security group for Cassandra CCP Cluster"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name       = "${var.username}:${var.cluster_name}:ccp"
    managed_by = "terraform"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_egress" {
  from_port         = 0
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_gossip_and_cql" {
  from_port         = 7000
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  to_port           = 9160
  type              = "ingress"
  cidr_blocks       = ["${formatlist("%s/32", aws_eip.cassandra-nodes.*.public_ip)}"]
}

//resource "aws_security_group_rule" "allow_stress_box" {
//  from_port = 9042
//  protocol = "tcp"
//  security_group_id = "${aws_security_group.sg.id}"
//  to_port = 9160
//  type = "ingress"
//  cidr_blocks = ["${aws_instance.cassandra-stress-box.public_ip}/32"]
//}

