# Terraform to deploy a debian stretch Cassandra cluster

## Requirements
Terraform >0.10 https://www.terraform.io/
An AWS Account + awcli installed + credentials/profile defined (~/.aws/profile + ~/.aws/credentials)
A willingness to pay for the instances created
An understanding that this software is for TESTING USE ONLY, it will break, and you'll be responsible for fixing it. DO NOT USE THIS IN PRODUCTION!


## Instructions
1. You have to build the AMI first! (Or, you can use someone else's AMI). See instructions in packer directory to get started.

2. Run terraform init in this directory.

3. Either create a terraform.tfvars file and place it in this directory (use terraform.tfvars.template as a guide) OR you can provide these options on the commandline (see below).

The following parameters would need to be provided:
cluster_name=...
dc_name=...
profile=<aws profile name>
private_key=<path/to/private/key>
aws_keyname=<Key name of keypair in AWS>
username=<Name to tag AWS resources with>

Optionally also:
git_repo=
git_branch=
install_repo=<yes|no> # Will install cassandra from provided repo
num_nodes=N

To pass in on commandline:
    terraform plan -out tf.plan -var "cluster_name=alourie" -var "dc_name=alourie" -var "profile=ccp" -var "private_key=~/.ssh/key.pem" -var "aws_keyname=prodkey" -var "username=alourie" -var "git_repo=https://github.com/apache/cassandra" -var "git_branch=trunk" -var "install_repo=yes" -var "num_nodes=3"`

4. If you created terraform.tfvars: 

Run `terraform apply`. It will automatically `terraform plan` and ask you for confirmation first. Look through the resources it is planning to create and verify that those look correct. Enter `y` if you do plan to create.

Otherwise run your plan command as per the above and then run:

    terraform apply <tf.plan>

5. If you want to create a different cluster, I'd suggest trying to use a different workspace. https://www.terraform.io/docs/state/workspaces.html

   `terraform workspace new waboku`

6. To destroy:

   `terraform destroy`

7. Note that you can keep applying terraform iteratively. So if you make a change, you don't have to destroy. Just keep running `terraform apply`.
Keep in mind though, that terraform is not a software provisioner, so configuration changes might not be reapplied.

## What do you get
- An <n> node Cassandra cluster running on debian stretch.
- For a list of included goodies, see the packer AMI.
- Potentially a stress box that uses the same AMI, but doesn't have Cassandra running. (in the next iteration of the refactor)
- Potentially a second volume attached to each instance (you will have to mount it yourself though) (in the next iteration of the refactor)
- Potentially an extra DC identical to the first one (in the next iterations of the refactor)

## User guide ##
Cassandra is run through systemd units. To view Cassandra logs run:

    journalctl -u cassandra

To stop and start cassandra run:

    sudo systemctl stop cassandra
    sudo systemctl start cassandra
    sudo systemctl restart cassandra

System is not perfect, so the cluster may not start up correctly. I advise using some kind of multi-ssh client to manage the nodes after they have been provisioned.

nodetool is in the PATH and should work as expected.

## Troubleshooting ##
At this point, you're required to be a fully fledged Cassandra expert and be able to figure it out yourself.

## TODOs

- Better way of actually sed-ing the public IP, because if we set auto_assign_public_ip it can steal that one first before EIP.
An example is tagging the EIP(? is that possible?) and then searching for it using aws CLI

- Due to modules not being able to be made conditional there are enabled checks in the Cassandra module.
Not sure how you make this cleaner

- This code does not necessarily reflect good terraform practice!!!

- Implement without elastic IPs, so only using private IPs. Will need a gateway for SSH, peering connection and route tables for second DC.
