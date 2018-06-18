# Copyright © 2018 aeternity developers
# Author: Alexander Kahl <ak@sodosopa.io>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

resource "aws_iam_role" "sdk_testnet_cluster" {
  name = "sdk_testnet-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sdk_testnet_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.sdk_testnet_cluster.name}"
}

resource "aws_iam_role_policy_attachment" "sdk_testnet_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.sdk_testnet_cluster.name}"
}

resource "aws_security_group" "sdk_testnet_cluster" {
  name        = "kuernetes-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.sdk_testnet.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sdk-testnet"
  }
}

resource "aws_security_group_rule" "sdk_testnet_https" {
  cidr_blocks       = ["${var.my_ip}/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sdk_testnet_cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_iam_role" "sdk_testnet_node" {
  name = "sdk-testnet-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sdk_testnet_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.sdk_testnet_node.name}"
}

resource "aws_iam_role_policy_attachment" "sdk_testnet_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.sdk_testnet_node.name}"
}

resource "aws_iam_role_policy_attachment" "sdk_testnet_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.sdk_testnet_node.name}"
}

resource "aws_iam_instance_profile" "sdk_testnet_node" {
  name = "terraform-eks-demo"
  role = "${aws_iam_role.sdk_testnet_node.name}"
}

resource "aws_security_group" "sdk_testnet_node" {
  name        = "kuernetes-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.sdk_testnet.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "sdk-testnet node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "sdk_testnet_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.sdk_testnet_node.id}"
  source_security_group_id = "${aws_security_group.sdk_testnet_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "sdk_testnet_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sdk_testnet_node.id}"
  source_security_group_id = "${aws_security_group.sdk_testnet_cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "kubernets_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sdk_testnet_cluster.id}"
  source_security_group_id = "${aws_security_group.sdk_testnet_node.id}"
  to_port                  = 443
  type                     = "ingress"
}
