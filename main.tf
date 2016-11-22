# Specify the provider and access details

# For Ec2 + scaling Group + LC +ELB + IAM profile
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_elb" "web-elb" {
  name = "${var.env-name}-govindraj-elb"

  # The same availability zone as our instances
  #availability_zones = ["${split(",", var.availability_zones)}"]
  subnets = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]

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
    target              = "TCP:80"
    interval            = 30
  }
}

resource "aws_autoscaling_group" "web-asg" {
  lifecycle { create_before_destroy = true }
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                 = "${var.env-name}-govindraj-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_min}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web-lc.id}"
  load_balancers       = ["${aws_elb.web-elb.name}"]

  vpc_zone_identifier = ["${aws_subnet.subnet_1.id}"]
  tag {
    key                 = "Name"
    value               = "web-asg-${var.env-name}"
    propagate_at_launch = "true"
  }
}

resource "aws_iam_instance_profile" "web_instance_profile" {
    name = "web_instance_profile"
    roles = ["web_iam_role"]
}

resource "aws_iam_role" "web_iam_role" {
    name = "web_iam_role"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "web_iam_role_policy" {
   name = "web_iam_role_policy"
   role = "${aws_iam_role.web_iam_role.id}"
   policy = <<EOF
{
"Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:Describe*",
        "rds:ListTagsForResource",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudwatch:GetMetricStatistics",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_launch_configuration" "web-lc" {
  lifecycle { create_before_destroy = true }
#  name          = "${var.env-name}-govindraj-lc"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  user_data       = "${file("userdata/userdata.sh")}"
  key_name        = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.web_instance_profile.id}"
  lifecycle {
      create_before_destroy = true
    }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "${var.env-name}-govindraj_sg"
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
    security_groups = ["${aws_security_group.elb-sg.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   vpc_id = "${aws_vpc.smvpc.id}"

}

resource "aws_security_group" "elb-sg" {
  name        = "${var.env-name}-govindraj_elb_sg"
  description = "Used by elb"


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
   vpc_id = "${aws_vpc.smvpc.id}"

}

# for resource VPC

resource "aws_vpc" "smvpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true

}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.smvpc.id}"
}

resource "aws_route_table" "us-east-1-public" {
    vpc_id = "${aws_vpc.smvpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
}

resource "aws_route_table_association" "us-east-1c-public" {
    subnet_id = "${aws_subnet.subnet_1.id}"
    route_table_id = "${aws_route_table.us-east-1-public.id}"
}

resource "aws_route_table_association" "us-east-1b-public" {
    subnet_id = "${aws_subnet.subnet_2.id}"
    route_table_id = "${aws_route_table.us-east-1-public.id}"
}


# for resource DATABASE
resource "aws_db_instance" "default" {
  depends_on             = ["aws_security_group.rds_sg"]
  identifier             = "${var.env-name}govindrajdb-rds"
  allocated_storage      = "10"
  engine                 = "mysql"
  engine_version         = "5.6.22"
  instance_class         = "db.t2.micro"
  name                   = "${var.env-name}govindrajdb"
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
