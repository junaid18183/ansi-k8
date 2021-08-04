###############################################################################
#
# A simple K8s cluster in AWS using SLES 12 SP1
#
###############################################################################


###############################################################################
#
# Get variables from command line or environment
#
###############################################################################

variable "access_key" {
        description = "AWS key id"
}
variable "secret_key" {
        description = "AWS secret key"
}

variable "region" {
    default = "us-east-1"
}

variable "ssh_key_name" {
    description = "key to ssh instance"
}

variable "amis" {
  type = "map"

  default = {
    us-east-1 = "ami-fde4ebea"
    us-west-2 = "ami-e4a30084"
  }
}

variable "number_of_workers" {
   default = "1"
}

variable "etcd-instance_type" {
   default = "t2.micro"
}
variable "master-instance_type" {
   default = "t2.micro"
}
variable "worker-instance_type" {
   default = "t2.micro"
}

variable "instance_profile" {
   description = "instance_profile needed if you configure api with cloud=aws so that volume can be launched for storage" #removed for now
}

variable "aws_security_group_id" {
   description = "aws_security_group_id"
}
variable "aws_vpc_security_group_id" {
   description = "aws_vpc_security_group_id"
}

variable "aws_subnet_id" {
   description = "aws_subnet_id"
}

###############################################################################
#
# Specify provider
#
###############################################################################

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}


###############################################################################
#
# Master host 
#
###############################################################################


resource "aws_instance" "sles_k8s_master" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.master-instance_type}"
    security_groups = ["${var.aws_security_group_id}"]
    vpc_security_group_ids = ["${var.aws_vpc_security_group_id}"]
    subnet_id = "${var.aws_subnet_id}"
    associate_public_ip_address = true
    #iam_instance_profile        = "{var.instance_profile}"
    key_name = "${var.ssh_key_name}"
    tags {
    Name = "k8s-master-with-etcd"
    Cluster = "SLES12SP2"
    Role = "master"
    Owner = "juned.memon"
    }
}
###############################################################################
#
# Worker hosts
#
###############################################################################


resource "aws_instance" "sles_k8s_worker" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.worker-instance_type}"
    security_groups = ["${var.aws_security_group_id}"]
    vpc_security_group_ids = ["${var.aws_vpc_security_group_id}"]
    subnet_id = "${var.aws_subnet_id}"
    associate_public_ip_address = true
#    iam_instance_profile        = "{var.instance_profile}"
    key_name = "${var.ssh_key_name}"
    tags {
    Name = "k8s-worker"
    Cluster = "SLES12SP2"
    Role = "worker"
    Owner = "juned.memon"
    }

    count = "${var.number_of_workers}"
}
###############################################################################
data "template_file" "worker_ansible" {
  count = "${var.number_of_workers}"
  template = <<EOF
${worker_public} masterserver=${master_private}
EOF
  vars {
    master_private = "${aws_instance.sles_k8s_master.private_ip}"
    worker_public = "${element(aws_instance.sles_k8s_worker.*.public_ip,count.index)}"
  }
}

data "template_file" "ansible_inventory" {
    template = <<EOF
[etcd]
${master_public}
[master]
${master_public}  etcdserver=${master_private}
[workers]
${worker_hosts}
EOF
    vars {
        master_public = "${aws_instance.sles_k8s_master.public_ip}"
        master_private = "${aws_instance.sles_k8s_master.private_ip}"
        worker_hosts  = "${join("\n",data.template_file.worker_ansible.*.rendered)}"
    }
}

resource "null_resource" "local" {
  triggers {
    template = "${data.template_file.ansible_inventory.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible_inventory.rendered}\" > inventroy/host.list"
}
}
###############################################################################
output "master-host" {
  value = ["${aws_instance.sles_k8s_master.private_ip}","${aws_instance.sles_k8s_master.public_ip}"]
}
output "worker-host" {
  value = ["${aws_instance.sles_k8s_worker.*.private_ip}","${aws_instance.sles_k8s_worker.*.public_ip}"]
}

output "ansible_inventory" {
	value = "${data.template_file.ansible_inventory.rendered}"
}
