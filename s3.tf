resource "aws_vpc_endpoint" "wp_private_s3_endpoint" {
  vpc_id       = "${aws_vpc.wp_vpc.id}"
  service_name = "com.amazonws.${var.aws_region}.s3"

  route_table_ids = [
    "${aws_vpc.wp_vpc.main_route_table_id}",
    "${aws_route_table.wp_public_rt.id}",
  ]

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
EOF
}

# will use my bucket later
resource "random_id" "wp_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket        = "${var.domain_name}-${random_id.wp_code_bucket.dec}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "WP Code Bucket"
  }
}
