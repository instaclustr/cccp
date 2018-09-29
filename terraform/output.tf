output "cassandra_ips" {
  value = "${module.cassandra.public-ips}"
}

output "final_message" {
  value = "The cluster is ready. It may take a few minutes to bootstrap and finalise, so be patient. Use `ssh -i ${var.private_key} admin@<ip_address>` to connect."
}

output "cassandra_stress_box_ip" {
  value = "${module.cassandra.stress-box-ip}"
}

//
//output "cassandra_2nd_dc_ips" {
//  value = "${module.secondDCCassandra.public-ips}"
//}

