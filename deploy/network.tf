/*
 * This file is part of Bob.
 *
 * Bob is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Bob is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Bob. If not, see <http://www.gnu.org/licenses/>.
 */

data "aws_availability_zones" "available" {}

locals {
  az_count = length(data.aws_availability_zones.available.names)
}

resource "aws_vpc" "bob_vpc" {
  cidr_block = "172.17.0.0/16"

  tags = {
    Name = "bob-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = local.az_count
  cidr_block        = cidrsubnet(aws_vpc.bob_vpc.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.bob_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "public" {
  count                   = local.az_count
  cidr_block              = cidrsubnet(aws_vpc.bob_vpc.cidr_block, 8, count.index + local.az_count)
  vpc_id                  = aws_vpc.bob_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "bob_igw" {
  vpc_id = aws_vpc.bob_vpc.id
}

resource "aws_route" "bob_route" {
  route_table_id         = aws_vpc.bob_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bob_igw.id
}

resource "aws_eip" "bob_eip" {
  count      = local.az_count
  vpc        = true
  depends_on = [
    aws_internet_gateway.bob_igw]
}
