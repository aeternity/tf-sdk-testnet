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

variable "aws_region" {
  description = "AWS region to launch servers."
  type    = "string"
  default = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use."
  type    = "string"
}

variable "cluster_name" {
  default = "sdk-testnet"
  type    = "string"
  description = "Name of the cluster."
}

variable "my_ip" {
  description = "Own IP for HTTPS management access."
  type = "string"
}
