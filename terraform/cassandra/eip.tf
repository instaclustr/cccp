resource "aws_eip" "cassandra-nodes" {
  count = "${var.num_nodes}"
  vpc   = true
}

resource "aws_eip_association" "cassandra-nodes" {
  count         = "${var.num_nodes}"
  instance_id   = "${element(aws_instance.cassandra-nodes.*.id, count.index)}"
  allocation_id = "${element(aws_eip.cassandra-nodes.*.id, count.index)}"
}
