# Requirements #
Packer https://www.packer.io/docs/install/index.html

Ansible https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

boto3   https://github.com/boto/boto3

terraform https://www.terraform.io/downloads.html

# CCCP #
This repository can be used to provision flexible Apache Cassandra clusters running any specific git branch/version. It also allows provisioning of a stress box for the cluster. Currently the repo only supports AWS.

This is a very very alpha provisioner and is intended for quick testing of Apache Cassandra on AWS only.
DO NOT USE THIS IN PRODUCTION!

Also note that you'll be expected to be a Cassandra and Linux expert in order to use this effectively.

Under the hood it's Packer + Ansible for AMI creation and Terraform for provisioning and configuration based on the AMI.

You must start by using packer to create a base AMI. See README in the packer directory to create the AMI, then you can use terraform to provision clusters following the README in the terraform directory.

Please see https://www.instaclustr.com/support/documentation/announcements/instaclustr-open-source-project-status/ for Instaclustr support status of this project
