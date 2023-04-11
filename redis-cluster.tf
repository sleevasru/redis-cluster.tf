resource "aws_security_group" "sg" {
  name        = "${var.namespace}-${var.env}-elasticache-sg"
  description = "allow inbound access from the sg only"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description     = "Allow ingress access to DB for itself"
    protocol        = "tcp"
    from_port       = var.port
    to_port         = var.port
    self            = true
  }

  egress {
    description = "Allow egress from ANY where"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
      var.default_tags,
      {
        Name = "${var.namespace}-${var.env}"
        Environment = var.network_env
      }
  )
}

module "redis" {
  source = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=tags/0.37.0"
  availability_zones         = var.availability_zones
  namespace                  = var.namespace
  stage                      = var.env
  name                       = "redis"
  vpc_id                     = data.terraform_remote_state.network.outputs.vpc_id
  use_existing_security_groups = true
  existing_security_groups   = [aws_security_group.sg.id]
  subnets                    = data.terraform_remote_state.network.outputs.private_subnets
  instance_type              = var.instance_type
  apply_immediately          = true
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  at_rest_encryption_enabled = true
  cluster_size               = var.cluster_size
  engine_version             = var.engine_version
  family                     = var.family
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  tags = merge(
      var.default_tags,
      {
        Name = "${var.namespace}-${var.env}"
        Environment = var.network_env
      }
  )
}
