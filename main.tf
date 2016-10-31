# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_elb" "web-elb" {
  name = "stealthmode-elb"

  # The same availability zone as our instances
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_autoscaling_group" "web-asg" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                 = "stealthmode-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]

  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "web-lc" {
  name          = "stealthmode-lc"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  user_data       = "${file("userdata/userdata.sh")}"
  key_name        = "${var.key_name}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "stealthmode_sg"
  description = "Used by app"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_subnet" "us-east-1c-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1c"
}

resource "aws_subnet" "us-east-1b-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1b"
}

resource "aws_subnet" "us-east-1d-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1d"
}

resource "aws_route_table" "us-east-1-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
}

resource "aws_route_table_association" "us-east-1c-public" {
    subnet_id = "${aws_subnet.us-east-1c-public.id}"
    route_table_id = "${aws_route_table.us-east-1-public.id}"
}

resource "aws_route_table_association" "us-east-1b-public" {
    subnet_id = "${aws_subnet.us-east-1b-public.id}"
    route_table_id = "${aws_route_table.us-east-1-public.id}"
}


resource "aws_route_table_association" "us-east-1d-public" {
    subnet_id = "${aws_subnet.us-east-1d-public.id}"
    route_table_id = "${aws_route_table.us-east-1-public.id}"
}



resource "aws_db_instance" "default" {
  depends_on             = ["aws_security_group.rds_sg"]
  identifier             = "stealthmodedb-rds"
  allocated_storage      = "10"
  engine                 = "mysql"
  engine_version         = "5.6.22"
  instance_class         = "db.t2.micro"
  name                   = "stealthmodedb"
  username               = "root"
  password               = "password"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
}
resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
}

