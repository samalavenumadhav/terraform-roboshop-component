module "ec2" {
  source                 = "../terraform-aws-instance"
  project                = var.project
  environment           = var.environment
  ami_id        = data.aws_ami.joindevops.id
  sg_ids        = var.sg_ids
 

  tags = {
    Name = "${var.project}-${var.environment}-catalogue"
  }
}
