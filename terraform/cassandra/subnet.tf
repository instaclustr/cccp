resource "aws_subnet" "public_subnets" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block                      = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)}"
  map_public_ip_on_launch         = "true"
  assign_ipv6_address_on_creation = "false"

  tags {
    Name       = "${var.username}:${var.cluster_name}:cccp-public-${element(data.aws_availability_zones.available.names, count.index)}"
    managed_by = "terraform"
  }
}

data "aws_route_table" "main_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "internet_gateway" {
  route_table_id         = "${data.aws_route_table.main_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}
