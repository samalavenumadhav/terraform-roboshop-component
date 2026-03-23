data "aws_ami" "joindevops" {
  most_recent = true
  owners      = ["973714476881"]

  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice"]
  }

   filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_instance" "terraform"{
    instance_id = "i-08ba6ab84792a1162"
}
