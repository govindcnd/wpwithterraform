resource "aws_security_group" "rds_sg" {
  name        = "main_rds_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.smvpc.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    security_groups = ["${aws_security_group.default.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.sg_name}"
  }
}
