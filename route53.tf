# Primary zone
resource "aws_route53_zone" "primary" {
  name              = "${var.actual_domain_name}"
  delegation_set_id = "${var.delegation_set}"
}

# terransible sub-domain
resource "aws_route53_record" "terransible" {
  zone_id = "${aws_route53_zone.primary.id}"
  name    = "${var.sub_domain}.${var.actual_domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.wp_elb.dns_name}"
    zone_id                = "${aws_elb.wp_elb.zone_id}"
    evaluate_target_health = true
  }
}

# dev
resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.primary.id}"
  name    = "dev.${var.actual_domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.wp_dev.public_ip}"]
}

# Private zone
resource "aws_route53_zone" "secondary" {
  name   = "${var.actual_domain_name}"
  vpc_id = "${aws_vpc.wp_vpc.id}"
}

# database
resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.secondary.id}"
  name    = "db.${var.actual_domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.wp_db.address}"]
}
