data "aws_ami" "cccp-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["cccp-*"]
  }

  owners = ["379101102735", "003793401444", "494770124270"]
}

resource "aws_instance" "cassandra-nodes" {
  count                  = "${var.num_nodes}"
  subnet_id              = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  ami                    = "${data.aws_ami.cccp-ami.id}"
  instance_type          = "${var.instance_size}"
  key_name               = "${var.aws_keyname}"
  availability_zone      = "${element(data.aws_availability_zones.available.names, count.index)}"
  user_data              = "${data.template_file.user_data_seed.rendered}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags {
    Name       = "${var.username}:${var.cluster_name}:cccp-instance-${element(data.aws_availability_zones.available.names, count.index)}"
    managed_by = "terraform"
  }
}

data "template_file" "install_cassandra" {
  count = "${var.num_nodes}"

  template = "${file("${path.module}/files/scripts/install_cassandra.sh.tpl")}"

  vars {
    repo         = "${var.git_repo}"
    branch       = "${var.git_branch}"
    install_repo = "${var.install_repo}"
  }
}

data "template_file" "cassandra_yaml" {
  count = "${var.num_nodes}"

  template = "${file("${path.module}/files/conf/cassandra.yaml.tpl")}"

  vars {
    cluster_name          = "${var.cluster_name}"
    broadcast_rpc_address = "${element(aws_eip.cassandra-nodes.*.public_ip, count.index)}"
    broadcast_address     = "${element(aws_eip.cassandra-nodes.*.public_ip, count.index)}"

    # We need to get a list of seeds
    # 1. we construct a string of all IPs
    # 2. we replace the current IP with ""
    # 3. split into a new list
    # 4. compact to remove empty members
    # 5. slice to max(1, num_nodes)
    # 6. join to final list
    seeds = "${join(",",
                  slice(
                    compact(
                      split(
                           ",",
                           replace(
                              join(",", aws_eip.cassandra-nodes.*.public_ip),
                              element(aws_eip.cassandra-nodes.*.public_ip, count.index),
                              "")
                      )
                    ),
                    0,
                    var.num_nodes - 1
                  )
              )}"

    self = "${count.index == 0 ? format(",%s",element(aws_eip.cassandra-nodes.*.public_ip, count.index)) : ""}"
  }
}

data "template_file" "cassandra_rack" {
  count = "${var.num_nodes}"

  template = "${file("${path.module}/files/conf/cassandra-rackdc.properties.tpl")}"

  vars {
    dc   = "${var.dc_name}"
    rack = "${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "null_resource" "install_cassandra" {
  count = "${var.num_nodes}"

  connection {
    host        = "${element(aws_eip_association.cassandra-nodes.*.public_ip, count.index)}"
    type        = "ssh"
    user        = "admin"
    private_key = "${file(var.private_key)}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "[ -d /tmp/etc/systemd/system/cassandra.service.d ] || mkdir -p /tmp/etc/systemd/system/cassandra.service.d",
      "[ -d /tmp/etc/cassandra ] || mkdir -p /tmp/etc/cassandra",
      "[ -d /tmp/etc/apt/sources.list.d ] || mkdir -p /tmp/etc/apt/sources.list.d",
      "[ -d /home/admin/cassandra ] || mkdir /home/admin/cassandra",
    ]
  }

  provisioner "file" {
    content     = "${file("${path.module}/files/scripts/cassandra-dpkg.sh")}"
    destination = "/tmp/cassandra-dpkg.sh"
  }

  provisioner "file" {
    content     = "${file("${path.module}/files/conf/cassandra.service")}"
    destination = "/tmp/etc/systemd/system/cassandra.service"
  }

  provisioner "file" {
    content     = "${file("${path.module}/files/conf/cassandra.sources.list")}"
    destination = "/tmp/etc/apt/sources.list.d/cassandra.sources.list"
  }

  provisioner "file" {
    content     = "${file("${path.module}/files/conf/cassandra.conf")}"
    destination = "/tmp/etc/systemd/system/cassandra.service.d/cassandra.conf"
  }

  provisioner "file" {
    content     = "${element(data.template_file.cassandra_yaml.*.rendered, count.index)}"
    destination = "/tmp/etc/cassandra/cassandra.yaml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.cassandra_rack.*.rendered, count.index)}"
    destination = "/tmp/etc/cassandra/cassandra-rackdc.properties"
  }

  provisioner "remote-exec" {
    inline = <<EOF
${element(data.template_file.install_cassandra.*.rendered, count.index)}
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown cassandra:cassandra /cassandra",
      "sudo systemctl daemon-reload && sudo systemctl start cassandra",
    ]
  }
}

resource "aws_instance" "cassandra-stress-box" {
  count                       = "${var.create_stressbox == true ? 1 : 0}"
  subnet_id                   = "${element(aws_subnet.public_subnets.*.id, 1)}"
  ami                         = "${data.aws_ami.cccp-ami.id}"
  instance_type               = "${var.instance_size}"
  key_name                    = "${var.aws_keyname}"
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  user_data                   = "${data.template_file.user_data_stress_box.rendered}"
  associate_public_ip_address = true

  tags {
    Name       = "${var.username}:${var.cluster_name}:cccp-stressbox"
    managed_by = "terraform"
  }
}

resource "null_resource" "install_stress_box" {
  count = "${var.create_stressbox == true ? 1 : 0}"

  connection {
    host        = "${element(aws_instance.cassandra-stress-box.*.public_ip, count.index)}"
    type        = "ssh"
    user        = "admin"
    private_key = "${file(var.private_key)}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "[ -d /home/admin/stress ] || mkdir /home/admin/stress",
      "[ -d /home/admin/cassandra ] || mkdir /home/admin/cassandra",
    ]
  }

  provisioner "file" {
    content     = "${file("${path.module}/files/conf/udf.cql")}"
    destination = "/home/admin/stress/udf.cql"
  }

  provisioner "file" {
    content     = "${join(",", aws_eip.cassandra-nodes.*.public_ip)}"
    destination = "/home/admin/stress/nodelist.txt"
  }

  provisioner "file" {
    content     = "${element(data.template_file.stressspec.*.rendered, count.index)}"
    destination = "/home/admin/stress/stressspec.yaml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.stressspectwcs.*.rendered, count.index)}"
    destination = "/home/admin/stress/stressspectwcs.yaml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.stressspectwcs_archive.*.rendered, count.index)}"
    destination = "/home/admin/stress/stressspectwcs_archive.yaml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.stressspectwcsbucket.*.rendered, count.index)}"
    destination = "/home/admin/stress/stressspectwcsbucket.yaml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.stressspectwcsbucket_archive.*.rendered, count.index)}"
    destination = "/home/admin/stress/stressspectwcsbucket.yaml"
  }
  provisioner "file" {
    content     = "${file("${path.module}/files/scripts/cassandra-dpkg.sh")}"
    destination = "/tmp/cassandra-dpkg.sh"
  }

  provisioner "remote-exec" {
    inline = <<EOF
${element(data.template_file.install_cassandra.*.rendered, count.index)}
EOF
  }
}
