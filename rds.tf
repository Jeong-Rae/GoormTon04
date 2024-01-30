# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.db-private-subnet-a.id, aws_subnet.db-private-subnet-c.id]

  tags = {
    Name = "RDSSubnetGroup"
  }
}

# RDS Primary 생성
resource "aws_db_instance" "primary-db-instance" {
  identifier           = "goorm-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  backup_retention_period = 7

  db_name              = "deploy"
  username             = "admin"
  password             = "admin0123456789"
  parameter_group_name = "default.mysql5.7"

  db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = [aws_security_group.goorm-sg.id]
  skip_final_snapshot = true

  availability_zone    = "ap-northeast-2a"

  tags = {
    Name = "PrimaryDBInstance"
  }
}

# Read Replica 생성
resource "aws_db_instance" "read-replica-db-instance" {
  identifier           = "goorm-db-replica"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"

  replicate_source_db  = aws_db_instance.primary-db-instance.arn
  db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = [aws_security_group.goorm-sg.id]
  skip_final_snapshot  = true

  availability_zone    = "ap-northeast-2c"

  tags = {
    Name = "ReadReplicaDBInstance"
  }
}
