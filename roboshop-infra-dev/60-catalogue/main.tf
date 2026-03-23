resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]


  tags = merge (
    
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags,
  )     
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh" # Local file path
    destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh catalogue dev ${var.app_version}"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
  source_instance_id = aws_instance.catalogue.id
   depends_on = [aws_ec2_instance_state.catalogue]
  # Optional: Add description, tags, etc.
  tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60 

  health_check {
    interval            = 10                  // Time between checks in seconds (range 5-300, default 30 for instance/ip)
    path                = "/health"            // Destination path for health checks (default /)
    port                = "8080"       // Port for health checks (default traffic-port)
    protocol            = "HTTP"               // Protocol for health checks (HTTP, HTTPS, TCP, TLS, GENEVE)
    timeout             = 2                    // Time without a response means a failure (range 2-120s, default 6s for HTTP)
    healthy_threshold   = 2                 // Consecutive successes required before healthy (range 2-10, default 5)
    unhealthy_threshold = 3                    // Consecutive failures required before unhealthy (range 2-10, default 2)
    matcher             = "200-299"            // Success codes (range 200-499 for HTTP/HTTPS, default 200)
  }
}

resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"


  image_id = aws_ami_from_instance.catalogue.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  vpc_security_group_ids = [local.catalogue_sg_id]

  update_default_version = true 

  tag_specifications {
    resource_type = "instance"

     tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}
    tag_specifications {
    resource_type = "volume"

     tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}
    tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_autoscaling_group" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  desired_capacity   = 2
  max_size           = 10
  min_size           = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  force_delete              = false

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]
  target_group_arns  = [aws_lb_target_group.catalogue.arn]

    instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  dynamic "tag" {
  for_each = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
  content {
    key = tag.key
    value = tag.value
    propagate_at_launch = true
  }
 }
 timeouts {
   delete = "15m"
 }
}

resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  name                   = "${var.project}-${var.environment}-catalogue"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"

  }
  target_value = 70.0
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
   host_header {
     values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
   }
  }
}

resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  depends_on = [aws_autoscaling_policy.catalogue]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id} "
  }
}