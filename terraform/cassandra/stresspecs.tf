data "template_file" "stressspec" {
  count    = "${var.create_stressbox == true ? 1 : 0}"
  template = "${file("${path.module}/files/stressconf/stressspec.yaml.tpl")}"

  vars {
    dc        = "${var.dc_name}"
    num_nodes = "${var.num_nodes}"
  }
}

data "template_file" "stressspectwcs" {
  count    = "${var.create_stressbox == true ? 1 : 0}"
  template = "${file("${path.module}/files/stressconf/stressspectwcs.yaml.tpl")}"

  vars {
    dc        = "${var.dc_name}"
    num_nodes = "${var.num_nodes}"
  }
}

data "template_file" "stressspectwcs_archive" {
  count    = "${var.create_stressbox == true ? 1 : 0}"
  template = "${file("${path.module}/files/stressconf/stressspectwcs_archive.yaml.tpl")}"

  vars {
    dc        = "${var.dc_name}"
    num_nodes = "${var.num_nodes}"
  }
}

data "template_file" "stressspectwcsbucket" {
  count    = "${var.create_stressbox == true ? 1 : 0}"
  template = "${file("${path.module}/files/stressconf/stressspectwcsbucket.yaml.tpl")}"

  vars {
    dc        = "${var.dc_name}"
    num_nodes = "${var.num_nodes}"
  }
}

data "template_file" "stressspectwcsbucket_archive" {
  count    = "${var.create_stressbox == true ? 1 : 0}"
  template = "${file("${path.module}/files/stressconf/stressspectwcsbucket_archive.yaml.tpl")}"

  vars {
    dc        = "${var.dc_name}"
    num_nodes = "${var.num_nodes}"
  }
}
