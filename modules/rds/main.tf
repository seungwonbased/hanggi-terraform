resource "aws_db_subnet_group" "rds-subnet-group" {
  name = "rds-subnet-group"
  subnet_ids = [
    var.subnet_1_id,
    var.subnet_2_id
  ]
}


resource "aws_db_instance" "hanggi-rds" {
  allocated_storage = 5
  max_allocated_storage = 20
  availability_zone = "us-west-2b"
  vpc_security_group_ids = [ var.sg_id ]
  db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.name
  engine = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  skip_final_snapshot = true
  identifier = "recipe-rds"
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  port = "5432"
}
