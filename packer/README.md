# Packer AMI for use by terraform

## Requirements
- Packer https://www.packer.io/
- Ansible https://www.ansible.com/
- An AWS Account
- A willingness to pay for the AMIs created

## Instructions

1. Create a variables.json in the packer directory.

```
{
  "aws_access_key": "Accesskey",
  "aws_secret_key": "Secretkey",
  "aws_region":  "us-west-2",
  "debian_user": "admin",
}
```

2. Run the build:
`packer build -var-file=variables.json packer.json`

# The base image #
packer.json contains an image builder for AWS. This will build an AMI that has a base configuration for running tests.
This includes:
- All dependencies required for running tests (TODO: list here)
- Clone of the Apache Cassandra repo

Once built this image can be used to reduce startup times for testing.

Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables before running the amazon builder
Run with `packer build --only=amazon-ebs`

# Creating images for other providers #
Packer supports many different providers. If you wish to use another provider simply add another builder to packer.json
for the desired provider. The ansible playbook `setup.yml` will be run on the machine prior to creating the image.

# Configuring a system not supported by Packer #
For systems not supported by packer (e.g: bare metal) you can simply run the ansible playbook `setup.yml` against the machine
to get it to the "base image" state. This should only need to be done once per machine.

## What do you get
- A debian stretch based AMI
- Installs java 8 openjdk, python-pip, git, ant, aws CLI & a bunch of packages for building debian packages of C* from the repo

## TODOs:

- This code does not necessarily reflect good packer practice!!!
