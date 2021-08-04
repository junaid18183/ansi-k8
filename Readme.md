===Install kubernetes on SLES12SP2
This repository consists 
1. A terraform plan to launch the SLES12SP2 master  with etcd included on the same host. you can optionally launch a worker at the same time so that you have 2 node cluster.
Just copy  the example.tfvars.sample file and  change the parameter values suiting your need and run the terraform 
terraform apply -var-file=rean-trainee.tfvars

The terraform also generates the required inventory file at ./inventroy/host.list required for ansible.

2. The ansible playbook/roles to deploy the Kubernetes cluster.
Once you have machine ready, either using the terraform or manually. you can run the ansible to deploy the cluster.
Make sure you change the inventroy/host.list if you have deployed the machines manually.

3. Make sure you have ssh enabled from controll machine running the ansible to the newly deployed hosts. or change the ansible.cfg private_key_file section
