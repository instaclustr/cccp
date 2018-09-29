resource "aws_ebs_volume" "datavolume" {
  count             = "${var.num_nodes}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  size              = "${var.vol_size}"
  type              = "${var.vol_type}"

  tags {
    Name       = "${var.username}:${var.cluster_name}:ccp-volume-${element(data.aws_availability_zones.available.names, count.index)}"
    managed_by = "terraform"
  }
}

resource "aws_volume_attachment" "cassandra-data-volume-ssd" {
  count        = "${var.num_nodes}"
  volume_id    = "${element(aws_ebs_volume.datavolume.*.id, count.index)}"
  instance_id  = "${element(aws_instance.cassandra-nodes.*.id, count.index)}"
  device_name  = "/dev/xvdf"
  force_detach = true
}

//resource "aws_ebs_volume" "extradatavolume" {
//  count = "${var.num_nodes * var.create_extra_volume_per_node * var.enabled}"
//  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
//  size = "${var.extra_volume_vol_size}"
//  type = "${var.extra_volume_vol_type}"
//
//  tags {
//    Name = "${var.username}:${var.cluster_name}:ccp-extravolume-${element(data.aws_availability_zones.available.names, count.index)}"
//    managed_by = "terraform"
//  }
//}


//resource "aws_volume_attachment" "cassandra-data-volume-hdd" {
//  count = "${var.num_nodes * var.create_extra_volume_per_node * var.enabled}"
//  volume_id = "${element(aws_ebs_volume.extradatavolume.*.id, count.index)}"
//  instance_id = "${element(aws_instance.cassandra-nodes.*.id, count.index)}"
//  device_name = "/dev/xvdg"
//  force_detach = true
//}

