resource "aws_db_parameter_group" "this" {
  name   = "${local.system_name}-${local.env_name}-${local.service_name}"
  family = "mysql8.0"

  parameter {
    name         = "general_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
  }
  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
  }
  parameter {
    name         = "character_set_filesystem"
    value        = "utf8mb4"
  }
  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
  }
  
  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
  }
  parameter {
    name         = "collation_server" # 照合順序
    value        = "utf8mb4_0900_ai_ci"
  }

  parameter {
    name         = "slow_query_log" #スロークエリログを出力する
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "long_query_time" #スロークエリ判定の秒数
    value        = "1.0"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_output" # cloudwatch logsに出力する
    value        = "FILE"
    apply_method = "immediate"
  }
  tags = {
    Name = "${local.system_name}-${local.env_name}-${local.service_name}"
  }
}