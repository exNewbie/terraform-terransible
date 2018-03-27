# Security groups
resource "aws_security_group" "wp_dev_sg" {
  name        = "wp_dev_sg"
  description = "Used for access to the dev instance"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  #HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wp_public_sg" {
  name        = "wp_public_sg"
  description = "Used for the elastic load balancer for public access"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wp_private_sg" {
  name        = "wp_private_sg"
  description = "Used for the private instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #Full access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wp_rds_sg" {
  name        = "wp_rds_sg"
  description = "Used for the RDS instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #MySQL access from public and private security groups
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.wp_dev_sg.id}",
      "${aws_security_group.wp_private_sg.id}",
      "${aws_security_group.wp_public_sg.id}",
    ]
  }
}

# Instances
# Dev
resource "aws_key_pair" "wp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "wp_dev" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags = {
    Name = "wp_dev"
  }

  key_name               = "${aws_key_pair.wp_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.wp_public1_subnet.id}"

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts
[dev]
${aws_instance.wp_dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instace-status-ok --instance-ids ${aws_instance.wp_dev.id} --profile default && ansible-playbook -i aws_hosts wordpress.yml"
  }
}
