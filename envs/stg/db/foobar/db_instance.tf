# DB Instance
resource "aws_db_instance" "mysql" {
  # Engine options
  engine                                = "mysql"
  engine_version                        = "8.0.25"
  # Setting
  identifier                            = "${local.system_name}-${local.env_name}-${local.service_name}"
  license_model                         = "general-public-license"
  # Credential Setting
  username                              = "local.service_name"
  password                              = "password" #temporary
  # DB Instance Class
  instance_class                        = "db.t3.micro"
  # Storage
  storage_type                          = "gp2"
  allocated_storage                     = 20
  max_allocated_storage                 = 0
  # AZ
  multi_az                              = false
  # Connectivity
  db_subnet_group_name                  = aws_db_subnet_group.subnet.name
  publicly_accessible                   = false
  vpc_security_group_ids                = [data.terraform_remote_state.network_main.outputs.security_group_db_foobar_id]
  availability_zone                     = "ap-northeast-1a" 
  port                                  = 3306
  # DB Auth
  iam_database_authentication_enabled   = false
  # DB Option
  name                                  = "local.service_name"
  parameter_group_name                  = aws_db_parameter_group.this.name
  option_group_name                     = aws_db_option_group.this.name
  # backup
  backup_retention_period               = 1
  backup_window                         = "19:00-20:00"
  copy_tags_to_snapshot                 = true
  delete_automated_backups              = true
  skip_final_snapshot                   = true #rdsを削除したときにスナップショットも削除
  # Encrypt
  storage_encrypted                     = true
  kms_key_id                            = data.aws_kms_alias.rds.target_key_arn
  # Performance 
  performance_insights_enabled          = false #microのクラスではそもそも使えない
  # monitoring
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
  # Log Exports
  enabled_cloudwatch_logs_exports       = ["error", "general", "slowquery"]
  # Maintenance
  auto_minor_version_upgrade            = false
  maintenance_window                    = "Sat:20:00-Sat:21:00"
  # Deletion protection
  deletion_protection                   = false

  tags = {
    Name = "${local.system_name}-${local.system_name}-${local.env_name}-${local.service_name}db-instance"
  }  
}
