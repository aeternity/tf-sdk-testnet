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

resource "aws_vpc" "sdk_testnet" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "sdk-testnet VPC",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "sdk_testnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.sdk_testnet.id}"

  tags = "${
    map(
     "Name", "sdk-testnet subnet",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "sdk_testnet" {
  vpc_id = "${aws_vpc.sdk_testnet.id}"

  tags {
    Name = "sdk-testnet gateway"
  }
}

resource "aws_route_table" "sdk_testnet" {
  vpc_id = "${aws_vpc.sdk_testnet.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sdk_testnet.id}"
  }
}

resource "aws_route_table_association" "sdk_testnet" {
  count = 2

  subnet_id      = "${aws_subnet.sdk_testnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.sdk_testnet.id}"
}
