æternity SDK Kubernetes setup
=============================

This project contains [Terraform] and [Kubernetes] configuration files to
reproduce the Kubernetes infrastructure of the æternity SDK from scratch.

The setup is directly derived from the [upstream template] for [AWS EKS] (AWS
managed Kubernetes). Therefore, the [Heptio Authenticator for AWS] is also
required.

[Terraform]: https://www.terraform.io/
[Kubernetes]: https://kubernetes.io/
[upstream template]: https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started
[AWS EKS]: https://aws.amazon.com/eks/
[Heptio Authenticator for AWS]: https://github.com/heptio/authenticator

Usage
-----

It is assumed that Terraform has already been
[installed](https://www.terraform.io/downloads.html) and the binary in
`$PATH`. Same goes for the `go` binary.

1. Install Heptio Autenticator

```sh
go get -u -v github.com/heptio/authenticator/cmd/heptio-authenticator-aws
```

2. Deploy EKS

```sh
cp terraform.tfvars{.example,}
$EDITOR terraform.tfvars # check variables.tf for a description of the variables
terraform init
terraform apply
```

3. Deploy Kubernetes infrastructure

```sh
mkdir -p ~/.kube
terraform output config_map_aws_auth > aws-auth.yaml
terraform output kubeconfig > ~/.kube/config
kubectl apply -f aws-auth.yaml
kubectl apply -f kubernetes/aws-auth.yaml
kubectl apply -f kubernetes/master.yaml
kubectl apply -f kubernetes/miner.yaml
kubectl apply -f kubernetes/aepp-contracts.yaml
# etc
```

License
-------

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
