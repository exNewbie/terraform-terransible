resource "aws_db_instance" "wp_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7.16"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.dbname}"
  username               = "${var.dbusername}"
  password               = "${var.dbpassword}"
  db_subnet_group_name   = "${aws_db_subnet_group.wp_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.wp_rds_sg.id}"]
  skip_final_snapshot    = true
}
