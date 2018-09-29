variable "private_key" {}
variable "vol_size" {}
variable "vol_type" {}
variable "instance_size" {}
variable "cluster_name" {}
variable "dc_name" {}
variable "username" {}
variable "num_nodes" {}
variable "git_repo" {}
variable "git_branch" {}
variable "install_repo" {}
variable "aws_keyname" {}

variable "create_stressbox" {
  default = false
}

variable "create_extra_volume_per_node" {
  default = false
}

//variable "enabled" {default = 1}

//variable "extra_volume_vol_size" {}
//variable "extra_volume_vol_type" {}

data "aws_availability_zones" "available" {}

data "template_file" "user_data_seed" {
  template = "${file("${path.module}/files/scripts/user-data.sh")}"
}

data "template_file" "user_data_stress_box" {
  template = "${file("${path.module}/files/scripts/user-data-stress-box.sh")}"

  vars {
    nodelist  = "${join(",", aws_eip.cassandra-nodes.*.public_ip)}"
    dc_name   = "${var.dc_name}"
    num_nodes = "${var.num_nodes}"
  }
}
