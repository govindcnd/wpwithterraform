resource "aws_subnet" "subnet_1" {
  vpc_id            = "${aws_vpc.smvpc.id}"
  cidr_block        = "${var.subnet_1_cidr}"
  availability_zone = "${var.az_1}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "main_subnet1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = "${aws_vpc.smvpc.id}"
  cidr_block        = "${var.subnet_2_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "main_subnet2"
  }
}
