output "public-ips" {
  value = "${aws_eip.cassandra-nodes.*.public_ip}"
}

output "stress-box-ip" {
  value = "${join(" ", aws_instance.cassandra-stress-box.*.public_ip)}"
}

# Have to put in all these ugly things because of https://github.com/hashicorp/terraform/issues/15165
# In a nutshell, terraform outputs do not support conditionals in the sense that both sides of the conditional
# must resolve to something legit, even though (in our case) if you never set 'var.enabled' there's no way you can
# get the latter, it will still complain
output "seeds" {
  //  value = "${var.initial_seeds == "" ? join(",", slice(aws_eip.cassandra-nodes.*.public_ip, 0 , 2)) : var.initial_seeds}"
  value = "${join(",", slice(concat(aws_eip.cassandra-nodes.*.public_ip, list(""), list("")), 0 , 2))}"
}

# It's always 0. It has to use this syntax because we are using count = 1 as 'enabled', so it expects splat syntax
# The rest is due to the comment above
output "security-group" {
  value = "${element(concat(aws_security_group.sg.*.id, list("")), 0)}"

  //  value = "${compact(concat(list(""), aws_security_group.sg.*.id))}"
}

# It's always 0. It has to use this syntax because we are using count = 1 as 'enabled', so it expects splat syntax
# The rest is due to the comment above
output "vpc" {
  value = "${element(concat(aws_vpc.vpc.*.id, list("")), 0)}"

  //  value = "${compact(concat(list(""), aws_vpc.vpc.*.id))}"
}
